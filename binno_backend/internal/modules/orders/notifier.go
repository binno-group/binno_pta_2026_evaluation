package orders

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"fmt"
	"log/slog"
	"time"

	"github.com/binnoapp-glitch/binno_backend/internal/platform/sms"
)

// confirmTokenBytes is the entropy in a supplier confirmation token.
const confirmTokenBytes = 32

// notifyTimeout bounds one post-commit SMS delivery.
const notifyTimeout = 5 * time.Second

// newConfirmToken returns a fresh single-use confirmation token.
func newConfirmToken() (string, error) {
	buf := make([]byte, confirmTokenBytes)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("orders: generate confirm token: %w", err)
	}
	return base64.RawURLEncoding.EncodeToString(buf), nil
}

// ConfirmationNotice is what the store needs to confirm an order by SMS link.
type ConfirmationNotice struct {
	OrderID    string
	StorePhone string
	Token      string
	ExpiresAt  time.Time
}

// SMSNotifier delivers order notifications over SMS, outside the transaction
// and best-effort: the order stands whether or not the message arrives.
type SMSNotifier struct {
	sender sms.Sender
	// linkBase is the public confirmation URL prefix the SMS embeds.
	linkBase string
	logger   *slog.Logger
}

// NewSMSNotifier returns an SMS notifier over sender.
func NewSMSNotifier(sender sms.Sender, linkBase string, logger *slog.Logger) *SMSNotifier {
	if logger == nil {
		logger = slog.Default()
	}
	return &SMSNotifier{sender: sender, linkBase: linkBase, logger: logger}
}

// OrderNeedsConfirmation sends the store its single-use confirmation link.
// Fire-and-forget: failures are logged, never surfaced to the buyer.
func (n *SMSNotifier) OrderNeedsConfirmation(ctx context.Context, notice ConfirmationNotice) {
	if n == nil || notice.StorePhone == "" {
		return
	}
	go func() {
		sendCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), notifyTimeout)
		defer cancel()
		message := fmt.Sprintf("BINNO: yangi buyurtma. Tasdiqlash: %s/%s?token=%s",
			n.linkBase, notice.OrderID, notice.Token)
		if err := n.sender.Send(sendCtx, notice.StorePhone, message); err != nil {
			n.logger.ErrorContext(sendCtx, "order confirmation SMS not delivered",
				"order_id", notice.OrderID, "err", err)
		}
	}()
}
