package orders

import (
	"context"
	"errors"
	"time"

	"github.com/jackc/pgx/v5"
)

// Settlement refusals.
var (
	// ErrSettlementConflict is a refusal the caller can act on: a second invoice
	// for one order, a second verdict on one payment, a second commission entry for
	// one closed order.
	ErrSettlementConflict = errors.New("orders: settlement conflict")
	// ErrSettlementInvalid is a malformed settlement request.
	ErrSettlementInvalid = errors.New("orders: settlement input invalid")
)

// SettlementPort is the billing surface the order lifecycle drives.
type SettlementPort interface {
	// IssueInvoice creates the payment document for an accepted order.
	IssueInvoice(ctx context.Context, tx pgx.Tx, request InvoiceRequest) (IssuedInvoice, error)
	// RecordPaymentReceipt files the buyer's proof of a bank transfer.
	RecordPaymentReceipt(ctx context.Context, tx pgx.Tx, request ReceiptRequest) error
	// SettlePayment applies the seller's verdict on a submitted receipt.
	SettlePayment(ctx context.Context, tx pgx.Tx, decision PaymentDecision) error
	// AccrueCommission writes the owner's ledger entry for a closed order.
	AccrueCommission(ctx context.Context, tx pgx.Tx, request CommissionRequest) (CommissionAccrued, error)
	// CancelSettlement compensates billing when an order stops before payment
	// settles: the issued invoice is voided and any still-open payment fails.
	// Idempotent; touching nothing is a valid outcome.
	CancelSettlement(ctx context.Context, tx pgx.Tx, orderID string, at time.Time) error
	// OpenRefund records that the seller owes the order's money back.
	OpenRefund(ctx context.Context, tx pgx.Tx, request RefundRequest) error
	// CompleteRefund closes the order's open refund on the buyer's confirmation
	// and reverses the settled payment.
	CompleteRefund(ctx context.Context, tx pgx.Tx, orderID string, at time.Time) error
}

// Payee is the selling account an invoice is paid to, snapshotted at issue.
type Payee struct {
	OwnerID     string `json:"owner_id"`
	StoreID     string `json:"store_id"`
	StoreName   string `json:"store_name"`
	LegalName   string `json:"legal_name"`
	TIN         string `json:"tin"`
	BankAccount string `json:"bank_account"`
	MFO         string `json:"mfo"`
}

// Payer is the buying party, snapshotted at issue.
type Payer struct {
	BuyerID   string `json:"buyer_id"`
	BuyerType string `json:"buyer_type"`
	TIN       string `json:"tin"`
}

// InvoiceRequest is everything billing needs to issue a payment document.
type InvoiceRequest struct {
	OrderID     string
	TotalAmount int64
	Payee       Payee
	Payer       Payer
	IssuedAt    time.Time
	ExpiresAt   time.Time
}

// IssuedInvoice is the document reference the buyer pays against.
type IssuedInvoice struct {
	Number      string
	Version     int32
	TotalAmount int64
	ExpiresAt   time.Time
}

// ReceiptRequest files a bank-transfer receipt against an order.
type ReceiptRequest struct {
	OrderID                  string
	ReceiptURL               string
	GoodsAmount, DeliveryFee int64
	At                       time.Time
}

// PaymentDecision is the seller's verdict on a submitted receipt.
type PaymentDecision struct {
	OrderID  string
	Accepted bool
	At       time.Time
}

// RefundRequest opens a refund against a paid order.
type RefundRequest struct {
	OrderID string
	// Amount is what the seller owes back, in tiyin.
	Amount int64
	Reason string
	At     time.Time
	// DueAt is when the refund becomes overdue for the SLA sweep.
	DueAt time.Time
}

// CommissionRequest is the platform's charge for one closed order.
type CommissionRequest struct {
	OrderID, OwnerID string
	BaseAmount       int64
	Accrued          int64
	RateBps          int32
	At               time.Time
}

// CommissionAccrued is the ledger entry that was written.
type CommissionAccrued struct {
	Accrued, Discount, Payable int64
	// FreeOrder reports that the founding allowance covered this order in full.
	FreeOrder bool
	// Sequence is this order's position in the owner's completed history, starting
	// at 1.
	Sequence int64
}
