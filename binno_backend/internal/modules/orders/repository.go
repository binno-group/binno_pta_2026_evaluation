package orders

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgtype"

	"github.com/binnoapp-glitch/binno_backend/internal/eventcatalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/catalog"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/location"
	"github.com/binnoapp-glitch/binno_backend/internal/modules/orders/store"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/dedup"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/geo"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/database/postgres"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/httpx"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/messaging/outbox"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/money"
	"github.com/binnoapp-glitch/binno_backend/internal/platform/runtime/clock"
)

// Repository persists orders, their events and their outbox records.
type Repository struct {
	pool       *postgres.Pool
	catalog    catalog.OrderLinePort
	saleGate   location.SaleGatePort
	settlement SettlementPort
	outbox     *outbox.Writer
	// notify delivers post-commit notifications; nil disables them.
	notify *SMSNotifier
	// paymentWindow is how long an issued invoice stays payable.
	paymentWindow time.Duration
	// refundWindow is how long a seller has to settle an opened refund.
	refundWindow time.Duration
}

// NewRepository returns an order repository. notify may be nil when the
// process has no SMS delivery (the dispatcher).
func NewRepository(
	pool *postgres.Pool,
	lines catalog.OrderLinePort,
	saleGate location.SaleGatePort,
	settlement SettlementPort,
	notify *SMSNotifier,
	clk clock.Clock,
) *Repository {
	return &Repository{
		pool:          pool,
		catalog:       lines,
		saleGate:      saleGate,
		settlement:    settlement,
		notify:        notify,
		outbox:        outbox.NewWriter(clk),
		paymentWindow: defaultPaymentWindow,
		refundWindow:  defaultRefundWindow,
	}
}

// defaultPaymentWindow is how long a buyer has to pay an issued invoice.
const defaultPaymentWindow = 72 * time.Hour

// defaultRefundWindow is how long a seller has to settle an opened refund.
const defaultRefundWindow = 72 * time.Hour

// Create places an order: reserve stock, persist the priced lines, record the
// creation event.
func (r *Repository) Create(ctx context.Context, cmd CreateCommand) (Created, error) {
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return Created{}, fmt.Errorf("orders: begin create: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	orderID := newID()
	replay, existingID, err := dedup.ReserveNew(ctx, tx, httpx.OperationKey(ctx), orderID, cmd.At)
	if err != nil {
		return Created{}, err
	}
	if replay {
		return r.replayCreated(ctx, tx, existingID)
	}

	seller, err := r.saleGate.ResolveSellerForOrder(ctx, tx, cmd.StoreID)
	if err != nil {
		return Created{}, mapLocationError(err)
	}

	quote, err := r.catalog.ReserveOrderLines(ctx, tx, catalog.ReserveRequest{
		StoreID:    cmd.StoreID,
		DistrictID: cmd.DistrictID,
		Delivery:   cmd.Fulfillment == fulfilDelivery,
		Lines:      requestedLines(cmd.Items),
		At:         cmd.At,
	})
	if err != nil {
		return Created{}, mapCatalogError(err)
	}

	queries := store.New(tx)
	dropoffLat, dropoffLng := geo.NullableCoordinates(cmd.Dropoff)
	districtID := cmd.DistrictID
	order, err := queries.CreateOrder(ctx, &store.CreateOrderParams{
		ID:                           uuidValue(orderID),
		BuyerID:                      uuidText(cmd.BuyerID),
		StoreID:                      uuidText(cmd.StoreID),
		BuyerType:                    cmd.BuyerType,
		BuyerTin:                     optional(cmd.BuyerTIN),
		Fulfillment:                  cmd.Fulfillment,
		IsUrgent:                     cmd.Urgent,
		GoodsAmount:                  quote.GoodsAmount,
		DeliveryFee:                  quote.DeliveryFee,
		TotalAmount:                  quote.TotalAmount,
		DropoffLat:                   dropoffLat,
		DropoffLng:                   dropoffLng,
		DropoffAddress:               optional(cmd.DropoffAddress),
		DistrictID:                   &districtID,
		SupplierConfirmationDeadline: timeValue(quote.ConfirmationDeadline),
		CreatedAt:                    timeValue(cmd.At),
	})
	if err != nil {
		return Created{}, mapError(err)
	}

	for _, line := range quote.Lines {
		quantity, err := numeric(line.Qty)
		if err != nil {
			return Created{}, ErrInvalid
		}
		if _, err := queries.CreateOrderItem(ctx, &store.CreateOrderItemParams{
			ID: uuidValue(newID()), OrderID: order.ID, ProductID: uuidText(line.ProductID),
			Qty: quantity, UnitPrice: line.UnitPrice, LineAmount: line.LineAmount,
			CommissionBps: line.CommissionBps,
		}); err != nil {
			return Created{}, mapError(err)
		}
	}

	if err := queries.AppendOrderEvent(ctx, &store.AppendOrderEventParams{
		OrderID: order.ID, ToStatus: string(StatusCreated),
		Actor: string(ActorBuyer), Source: string(SourceApp), CreatedAt: timeValue(cmd.At),
	}); err != nil {
		return Created{}, mapError(err)
	}

	// The SMS fallback rail: a single-use token the store can confirm with,
	// created atomically with the order.
	token, err := newConfirmToken()
	if err != nil {
		return Created{}, err
	}
	tokenDigest := sha256.Sum256([]byte(token))
	if err := queries.CreateConfirmToken(ctx, &store.CreateConfirmTokenParams{
		TokenHash: hex.EncodeToString(tokenDigest[:]),
		OrderID:   order.ID,
		StoreID:   uuidText(cmd.StoreID),
		ExpiresAt: timeValue(quote.ConfirmationDeadline),
	}); err != nil {
		return Created{}, mapError(err)
	}

	if err := r.outbox.Write(ctx, tx, "orders", orderID.String(), eventcatalog.OrderCreatedPayload{
		StoreID:     cmd.StoreID,
		BuyerID:     cmd.BuyerID,
		GoodsAmount: quote.GoodsAmount,
		DeliveryFee: quote.DeliveryFee,
		TotalAmount: quote.TotalAmount,
		ItemCount:   len(quote.Lines),
		Urgent:      cmd.Urgent,
		DueAt:       quote.ConfirmationDeadline,
	}); err != nil {
		return Created{}, err
	}

	if err := tx.Commit(ctx); err != nil {
		return Created{}, fmt.Errorf("orders: commit create: %w", err)
	}
	r.notify.OrderNeedsConfirmation(ctx, ConfirmationNotice{
		OrderID:    orderID.String(),
		StorePhone: seller.Phone,
		Token:      token,
		ExpiresAt:  quote.ConfirmationDeadline,
	})
	return Created{
		OrderID:                      orderID.String(),
		Status:                       string(StatusCreated),
		GoodsAmount:                  quote.GoodsAmount,
		DeliveryFee:                  quote.DeliveryFee,
		TotalAmount:                  quote.TotalAmount,
		SupplierConfirmationDeadline: quote.ConfirmationDeadline,
	}, nil
}

// replayCreated returns the order a previous attempt with this key created.
func (r *Repository) replayCreated(ctx context.Context, tx pgx.Tx, orderID uuid.UUID) (Created, error) {
	order, err := store.New(tx).GetOrder(ctx, uuidValue(orderID))
	if err != nil {
		return Created{}, mapError(err)
	}
	return Created{
		OrderID:                      orderID.String(),
		Status:                       order.Status,
		GoodsAmount:                  order.GoodsAmount,
		DeliveryFee:                  order.DeliveryFee,
		TotalAmount:                  order.TotalAmount,
		SupplierConfirmationDeadline: order.SupplierConfirmationDeadline.Time,
	}, nil
}

// Apply performs one state-machine transition.
func (r *Repository) Apply(ctx context.Context, cmd TransitionCommand) error {
	if _, ok := TransitionFor(cmd.Trigger); !ok {
		return fmt.Errorf("orders: unknown trigger %q", cmd.Trigger)
	}
	orderID, ok := parseUUID(cmd.OrderID)
	if !ok {
		return ErrInvalid
	}

	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("orders: begin transition: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(orderID.Bytes), cmd.At)
	if err != nil {
		return mapDedupError(err)
	}
	if replay {
		return nil
	}

	queries := store.New(tx)
	order, err := queries.GetOrderForUpdate(ctx, orderID)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return mapError(err)
	}
	if err := r.runTransition(ctx, tx, queries, order, cmd.Trigger, cmd); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

// runTransition applies one trigger and, if the edge declares one, the follow-on
// it implies, both inside the caller's transaction.
func (r *Repository) runTransition(
	ctx context.Context,
	tx pgx.Tx,
	queries *store.Queries,
	order *store.OrdersOrder,
	trigger Trigger,
	cmd TransitionCommand,
) error {
	transition, ok := TransitionFor(trigger)
	if !ok {
		return fmt.Errorf("orders: unknown trigger %q", trigger)
	}
	if !transition.Permits(Status(order.Status)) {
		return ErrConflict
	}
	updated, err := r.transition(ctx, tx, queries, order, trigger, transition, cmd)
	if err != nil {
		return err
	}
	if transition.Then == "" {
		return nil
	}

	follow, ok := TransitionFor(transition.Then)
	if !ok {
		return fmt.Errorf("orders: trigger %q declares unknown follow-on %q", trigger, transition.Then)
	}
	if follow.Then != "" {
		return fmt.Errorf("orders: follow-on %q may not declare its own", transition.Then)
	}
	if !follow.Permits(Status(updated.Status)) {
		return ErrConflict
	}
	_, err = r.transition(ctx, tx, queries, updated, transition.Then, follow, cmd)
	return err
}

// transition writes the status change, the audit event, any stock release and
// the domain event.
func (r *Repository) transition(
	ctx context.Context,
	tx pgx.Tx,
	queries *store.Queries,
	order *store.OrdersOrder,
	trigger Trigger,
	transition Transition,
	cmd TransitionCommand,
) (*store.OrdersOrder, error) {
	from := Status(order.Status)
	updated, err := queries.TransitionOrder(ctx, &store.TransitionOrderParams{
		ToStatus: string(transition.To), OccurredAt: timeValue(cmd.At),
		ID: order.ID, FromStatus: string(from),
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, ErrConflict
	} else if err != nil {
		return nil, mapError(err)
	}

	fromStatus := string(from)
	if err := queries.AppendOrderEvent(ctx, &store.AppendOrderEventParams{
		OrderID: order.ID, FromStatus: &fromStatus, ToStatus: string(transition.To),
		Actor: string(transition.Actor), Source: string(transition.Source),
		Payload:   eventPayload(cmd),
		CreatedAt: timeValue(cmd.At),
	}); err != nil {
		return nil, mapError(err)
	}

	if transition.ReleasesStock {
		if err := r.releaseStock(ctx, tx, queries, order); err != nil {
			return nil, err
		}
	}
	if transition.ConsumesStock {
		if err := r.consumeStock(ctx, tx, queries, order); err != nil {
			return nil, err
		}
	}

	if err := r.settle(ctx, tx, queries, updated, trigger, cmd); err != nil {
		return nil, err
	}

	if transition.Event == "" {
		return updated, nil
	}
	if err := r.outbox.Write(ctx, tx, "orders", uuidString(order.ID),
		eventcatalog.NewOrderStatusChanged(transition.Event, eventcatalog.OrderStatusChangedPayload{
			StoreID:    uuidString(order.StoreID),
			BuyerID:    uuidString(order.BuyerID),
			FromStatus: string(from),
			ToStatus:   string(transition.To),
			Actor:      string(transition.Actor),
			Source:     string(transition.Source),
			Reason:     cmd.Reason,
		})); err != nil {
		return nil, err
	}
	return updated, nil
}

// eventPayload renders the transition's context for the audit log, or nil when
// there is none. This is the record disputes are settled with.
func eventPayload(cmd TransitionCommand) []byte {
	fields := map[string]string{}
	if cmd.Reason != "" {
		fields["reason"] = cmd.Reason
	}
	if cmd.ReceiptURL != "" {
		fields["receipt_url"] = cmd.ReceiptURL
	}
	if cmd.PickupCode != "" {
		fields["pickup_code"] = cmd.PickupCode
	}
	if cmd.PickupSignatureURL != "" {
		fields["pickup_signature_url"] = cmd.PickupSignatureURL
	}
	if len(fields) == 0 {
		return nil
	}
	raw, err := json.Marshal(fields)
	if err != nil {
		return nil
	}
	return raw
}

// releaseStock returns the order's reserved quantities to the catalogue.
func (r *Repository) releaseStock(ctx context.Context, tx pgx.Tx, queries *store.Queries, order *store.OrdersOrder) error {
	items, err := queries.ListOrderItems(ctx, order.ID)
	if err != nil {
		return mapError(err)
	}
	lines := orderLines(items)
	if len(lines) == 0 {
		return nil
	}
	if err := r.catalog.ReleaseOrderLines(ctx, tx, catalog.ReleaseRequest{
		StoreID: uuidString(order.StoreID), Lines: lines,
	}); err != nil {
		return fmt.Errorf("orders: release stock: %w", err)
	}
	return nil
}

// consumeStock deducts the order's quantities from the catalogue for good.
func (r *Repository) consumeStock(ctx context.Context, tx pgx.Tx, queries *store.Queries, order *store.OrdersOrder) error {
	items, err := queries.ListOrderItems(ctx, order.ID)
	if err != nil {
		return mapError(err)
	}
	lines := orderLines(items)
	if len(lines) == 0 {
		return nil
	}
	if err := r.catalog.ConsumeOrderLines(ctx, tx, catalog.ReleaseRequest{
		StoreID: uuidString(order.StoreID), Lines: lines,
	}); err != nil {
		return fmt.Errorf("orders: consume stock: %w", err)
	}
	return nil
}

func orderLines(items []*store.OrdersOrderItem) []catalog.RequestedLine {
	lines := make([]catalog.RequestedLine, 0, len(items))
	for _, item := range items {
		lines = append(lines, catalog.RequestedLine{
			ProductID: uuidString(item.ProductID),
			Qty:       numericText(item.Qty),
		})
	}
	return lines
}

// ConfirmToken accepts an order through its single-use SMS token.
func (r *Repository) ConfirmToken(ctx context.Context, id, token string, at time.Time) error {
	if _, ok := TransitionFor(TriggerTokenConfirm); !ok {
		return fmt.Errorf("orders: token confirm trigger is not registered")
	}
	orderID, ok := parseUUID(id)
	if !ok {
		return ErrInvalid
	}

	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return fmt.Errorf("orders: begin token confirm: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(orderID.Bytes), at)
	if err != nil {
		return mapDedupError(err)
	}
	if replay {
		return nil
	}

	queries := store.New(tx)
	digest := sha256.Sum256([]byte(token))
	consumed, err := queries.ConsumeConfirmToken(ctx, &store.ConsumeConfirmTokenParams{
		UsedAt: timeValue(at), TokenHash: hex.EncodeToString(digest[:]),
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrGone
	}
	if err != nil {
		return mapError(err)
	}
	if uuidString(consumed.OrderID) != id {
		return ErrConflict
	}

	order, err := queries.GetOrderForUpdate(ctx, consumed.OrderID)
	if err != nil {
		return mapError(err)
	}
	if err := r.runTransition(ctx, tx, queries, order, TriggerTokenConfirm, TransitionCommand{
		OrderID: id, Trigger: TriggerTokenConfirm, At: at,
	}); err != nil {
		return err
	}
	return tx.Commit(ctx)
}

// Summary implements the cross-module read.
func (r *Repository) Summary(ctx context.Context, id string) (Summary, error) {
	orderID, ok := parseUUID(id)
	if !ok {
		return Summary{}, ErrInvalid
	}
	row, err := store.New(r.pool).GetOrderSummary(ctx, orderID)
	if errors.Is(err, pgx.ErrNoRows) {
		return Summary{}, ErrNotFound
	}
	if err != nil {
		return Summary{}, mapError(err)
	}
	summary := Summary{
		OrderID:     uuidString(row.ID),
		BuyerID:     uuidString(row.BuyerID),
		StoreID:     uuidString(row.StoreID),
		Status:      Status(row.Status),
		TotalAmount: row.TotalAmount,
		CreatedAt:   row.CreatedAt.Time,
	}
	if row.ClosedAt.Valid {
		closed := row.ClosedAt.Time
		summary.ClosedAt = &closed
	}
	return summary, nil
}

// listPageSize is the client-visible page size of order lists.
const listPageSize = 50

// ListByBuyer returns one keyset page of the buyer's orders, newest first.
func (r *Repository) ListByBuyer(ctx context.Context, buyerID, cursor string) (OrderPage, error) {
	position, positioned, err := decodeListCursor(cursor)
	if err != nil {
		return OrderPage{}, err
	}
	params := &store.ListOrdersByBuyerParams{
		BuyerID: uuidText(buyerID), PageSize: listPageSize + 1,
	}
	if positioned {
		before := timeValue(position.CreatedAt)
		params.BeforeCreatedAt = before
		params.BeforeID = uuidText(position.ID)
	}
	rows, err := store.New(r.pool).ListOrdersByBuyer(ctx, params)
	if err != nil {
		return OrderPage{}, mapError(err)
	}
	return orderPage(rows), nil
}

// ListStoreOpen returns one keyset page of a store's open orders, newest first.
func (r *Repository) ListStoreOpen(ctx context.Context, storeID, cursor string) (OrderPage, error) {
	position, positioned, err := decodeListCursor(cursor)
	if err != nil {
		return OrderPage{}, err
	}
	params := &store.ListStoreOpenOrdersParams{
		StoreID: uuidText(storeID), PageSize: listPageSize + 1,
	}
	if positioned {
		before := timeValue(position.CreatedAt)
		params.BeforeCreatedAt = before
		params.BeforeID = uuidText(position.ID)
	}
	rows, err := store.New(r.pool).ListStoreOpenOrders(ctx, params)
	if err != nil {
		return OrderPage{}, mapError(err)
	}
	return orderPage(rows), nil
}

// Detail returns one order with its item snapshot.
func (r *Repository) Detail(ctx context.Context, id string) (OrderDetail, error) {
	orderID, ok := parseUUID(id)
	if !ok {
		return OrderDetail{}, ErrInvalid
	}
	queries := store.New(r.pool)
	order, err := queries.GetOrder(ctx, orderID)
	if errors.Is(err, pgx.ErrNoRows) {
		return OrderDetail{}, ErrNotFound
	}
	if err != nil {
		return OrderDetail{}, mapError(err)
	}
	items, err := queries.ListOrderItems(ctx, orderID)
	if err != nil {
		return OrderDetail{}, mapError(err)
	}
	detail := OrderDetail{
		OrderView: orderView(order),
		Items:     make([]OrderLineView, 0, len(items)),
	}
	for _, item := range items {
		detail.Items = append(detail.Items, OrderLineView{
			ProductID:  uuidString(item.ProductID),
			Qty:        numericText(item.Qty),
			UnitPrice:  item.UnitPrice,
			LineAmount: item.LineAmount,
		})
	}
	return detail, nil
}

func orderPage(rows []*store.OrdersOrder) OrderPage {
	limit := min(len(rows), listPageSize)
	page := OrderPage{Items: make([]OrderView, 0, limit)}
	for _, row := range rows[:limit] {
		page.Items = append(page.Items, orderView(row))
	}
	if len(rows) > limit && limit > 0 {
		last := page.Items[limit-1]
		page.NextCursor = encodeListCursor(last.CreatedAt, last.OrderID)
	}
	return page
}

func orderView(order *store.OrdersOrder) OrderView {
	view := OrderView{
		OrderID:                      uuidString(order.ID),
		StoreID:                      uuidString(order.StoreID),
		Status:                       order.Status,
		BuyerType:                    order.BuyerType,
		Fulfillment:                  order.Fulfillment,
		Urgent:                       order.IsUrgent,
		GoodsAmount:                  order.GoodsAmount,
		DeliveryFee:                  order.DeliveryFee,
		TotalAmount:                  order.TotalAmount,
		SupplierConfirmationDeadline: order.SupplierConfirmationDeadline.Time,
		CreatedAt:                    order.CreatedAt.Time,
	}
	if order.PaymentDueAt.Valid {
		due := order.PaymentDueAt.Time
		view.PaymentDueAt = &due
	}
	if order.ClosedAt.Valid {
		closed := order.ClosedAt.Time
		view.ClosedAt = &closed
	}
	return view
}

// Alternatives lists substitute offers for the order's products.
func (r *Repository) Alternatives(ctx context.Context, id, cursor string) (AlternativePage, error) {
	orderID, ok := parseUUID(id)
	if !ok {
		return AlternativePage{}, ErrInvalid
	}
	queries := store.New(r.pool)
	order, err := queries.GetOrder(ctx, orderID)
	if errors.Is(err, pgx.ErrNoRows) {
		return AlternativePage{}, ErrNotFound
	}
	if err != nil {
		return AlternativePage{}, mapError(err)
	}
	items, err := queries.ListOrderItems(ctx, orderID)
	if err != nil {
		return AlternativePage{}, mapError(err)
	}
	productIDs := make([]string, 0, len(items))
	for _, item := range items {
		productIDs = append(productIDs, uuidString(item.ProductID))
	}

	page, err := r.catalog.ListAlternatives(ctx, catalog.AlternativesRequest{
		ProductIDs:     productIDs,
		ExcludeStoreID: uuidString(order.StoreID),
		Cursor:         cursor,
	})
	if err != nil {
		return AlternativePage{}, mapCatalogError(err)
	}

	out := AlternativePage{
		Items:      make([]Alternative, 0, len(page.Items)),
		NextCursor: page.NextCursor,
	}
	for _, item := range page.Items {
		out.Items = append(out.Items, Alternative(item))
	}
	return out, nil
}

// AwaitingConfirmation lists orders whose supplier deadline has passed.
func (r *Repository) AwaitingConfirmation(ctx context.Context, deadline time.Time, limit int32) ([]DueOrder, error) {
	rows, err := store.New(r.pool).ListOrdersAwaitingConfirmation(ctx, &store.ListOrdersAwaitingConfirmationParams{
		Deadline: timeValue(deadline), PageSize: limit,
	})
	if err != nil {
		return nil, fmt.Errorf("orders: list overdue confirmations: %w", err)
	}
	out := make([]DueOrder, 0, len(rows))
	for _, row := range rows {
		out = append(out, DueOrder{
			OrderID: uuidString(row.ID),
			StoreID: uuidString(row.StoreID),
			BuyerID: uuidString(row.BuyerID),
			DueAt:   row.SupplierConfirmationDeadline.Time,
		})
	}
	return out, nil
}

// PaymentOverdue lists invoiced orders whose payment window has elapsed.
func (r *Repository) PaymentOverdue(ctx context.Context, deadline time.Time, limit int32) ([]DueOrder, error) {
	rows, err := store.New(r.pool).ListOrdersPaymentOverdue(ctx, &store.ListOrdersPaymentOverdueParams{
		Deadline: timeValue(deadline), PageSize: limit,
	})
	if err != nil {
		return nil, fmt.Errorf("orders: list overdue payments: %w", err)
	}
	out := make([]DueOrder, 0, len(rows))
	for _, row := range rows {
		out = append(out, DueOrder{
			OrderID: uuidString(row.ID),
			StoreID: uuidString(row.StoreID),
			BuyerID: uuidString(row.BuyerID),
			DueAt:   row.PaymentDueAt.Time,
		})
	}
	return out, nil
}

// RecordEscalation opens an operator queue item for an overdue order. The
// returned flag reports whether this call created the escalation, so a
// replayed sweep pass is not counted twice.
func (r *Repository) RecordEscalation(ctx context.Context, order DueOrder, at time.Time) (bool, error) {
	orderID, ok := parseUUID(order.OrderID)
	if !ok {
		return false, ErrInvalid
	}
	tx, err := r.pool.BeginTx(ctx, pgx.TxOptions{})
	if err != nil {
		return false, fmt.Errorf("orders: begin escalation: %w", err)
	}
	defer func() { _ = tx.Rollback(ctx) }()

	replay, err := dedup.ReserveFor(ctx, tx, httpx.OperationKey(ctx), uuid.UUID(orderID.Bytes), at)
	if err != nil {
		return false, mapDedupError(err)
	}
	if replay {
		return false, nil
	}
	if err := r.outbox.Write(ctx, tx, "orders", order.OrderID, eventcatalog.OrderSLAEscalatedPayload{
		StoreID: order.StoreID,
		BuyerID: order.BuyerID,
		Reason:  "supplier confirmation overdue",
		DueAt:   order.DueAt,
	}); err != nil {
		return false, err
	}
	return true, tx.Commit(ctx)
}

func requestedLines(items []ItemInput) []catalog.RequestedLine {
	lines := make([]catalog.RequestedLine, 0, len(items))
	for _, item := range items {
		lines = append(lines, catalog.RequestedLine{ProductID: item.ProductID, Qty: item.Qty})
	}
	return lines
}

func newID() uuid.UUID {
	id, err := uuid.NewV7()
	if err != nil {
		return uuid.New()
	}
	return id
}

func parseUUID(value string) (pgtype.UUID, bool) {
	id, err := uuid.Parse(value)
	if err != nil {
		return pgtype.UUID{}, false
	}
	return pgtype.UUID{Bytes: id, Valid: true}, true
}

func uuidText(value string) pgtype.UUID {
	id, err := uuid.Parse(value)
	return pgtype.UUID{Bytes: id, Valid: err == nil}
}

func uuidValue(id uuid.UUID) pgtype.UUID { return pgtype.UUID{Bytes: id, Valid: true} }

func uuidString(value pgtype.UUID) string {
	if !value.Valid {
		return ""
	}
	return uuid.UUID(value.Bytes).String()
}

func timeValue(value time.Time) pgtype.Timestamptz {
	return pgtype.Timestamptz{Time: value, Valid: true}
}

func optional(value string) *string {
	if value == "" {
		return nil
	}
	return &value
}

func numeric(value string) (pgtype.Numeric, error) {
	var n pgtype.Numeric
	err := n.Scan(value)
	return n, err
}

func numericText(value pgtype.Numeric) string {
	raw, err := value.Value()
	if err != nil || raw == nil {
		return "0"
	}
	return fmt.Sprint(raw)
}

// mapCatalogError translates the catalog port's vocabulary into this module's.
func mapCatalogError(err error) error {
	switch {
	case errors.Is(err, catalog.ErrOfferUnavailable), errors.Is(err, catalog.ErrTariffUnavailable):
		return fmt.Errorf("%w: %s", ErrConflict, err)
	case errors.Is(err, catalog.ErrInvalid):
		return ErrInvalid
	default:
		if mapped := classifyContention(err); mapped != nil {
			return mapped
		}
		return err
	}
}

func mapDedupError(err error) error {
	if errors.Is(err, dedup.ErrKeyReuse) {
		return fmt.Errorf("%w: %s", ErrConflict, err)
	}
	return err
}

func mapError(err error) error {
	if err == nil {
		return nil
	}
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if mapped := classifyContention(err); mapped != nil {
		return mapped
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) && (pgErr.Code == "23505" || pgErr.Code == "23503" || pgErr.Code == "23514") {
		return ErrConflict
	}
	return fmt.Errorf("orders repository: %w", err)
}

// settle runs the billing consequence of a transition inside the same
// transaction.
func (r *Repository) settle(
	ctx context.Context,
	tx pgx.Tx,
	queries *store.Queries,
	order *store.OrdersOrder,
	trigger Trigger,
	cmd TransitionCommand,
) error {
	switch trigger {
	case TriggerIssueInvoice:
		return r.issueInvoice(ctx, tx, order, cmd.At)

	case TriggerSubmitReceipt:
		if err := r.settlement.RecordPaymentReceipt(ctx, tx, ReceiptRequest{
			OrderID:     uuidString(order.ID),
			ReceiptURL:  cmd.ReceiptURL,
			GoodsAmount: order.GoodsAmount,
			DeliveryFee: order.DeliveryFee,
			At:          cmd.At,
		}); err != nil {
			return mapSettlementError(err)
		}
		return nil

	case TriggerConfirmPayment, TriggerRejectPayment:
		if err := r.settlement.SettlePayment(ctx, tx, PaymentDecision{
			OrderID:  uuidString(order.ID),
			Accepted: trigger == TriggerConfirmPayment,
			At:       cmd.At,
		}); err != nil {
			return mapSettlementError(err)
		}
		return nil

	case TriggerCloseOrder:
		return r.accrueCommission(ctx, tx, queries, order, cmd.At)

	case TriggerBuyerCancel, TriggerOperatorCancel, TriggerPaymentExpire:
		if err := r.settlement.CancelSettlement(ctx, tx, uuidString(order.ID), cmd.At); err != nil {
			return mapSettlementError(err)
		}
		return nil

	case TriggerRefundRequest:
		if err := r.settlement.OpenRefund(ctx, tx, RefundRequest{
			OrderID: uuidString(order.ID),
			Amount:  order.TotalAmount,
			Reason:  cmd.Reason,
			At:      cmd.At,
			DueAt:   cmd.At.Add(r.refundWindow),
		}); err != nil {
			return mapSettlementError(err)
		}
		return nil

	case TriggerConfirmRefund:
		if err := r.settlement.CompleteRefund(ctx, tx, uuidString(order.ID), cmd.At); err != nil {
			return mapSettlementError(err)
		}
		return nil

	default:
		return nil
	}
}

// issueInvoice creates the payment document for a newly accepted order.
func (r *Repository) issueInvoice(ctx context.Context, tx pgx.Tx, order *store.OrdersOrder, at time.Time) error {
	seller, err := r.saleGate.ResolveSellerForOrder(ctx, tx, uuidString(order.StoreID))
	if err != nil {
		return mapLocationError(err)
	}
	if _, err := r.settlement.IssueInvoice(ctx, tx, InvoiceRequest{
		OrderID:     uuidString(order.ID),
		TotalAmount: order.TotalAmount,
		Payee: Payee{
			OwnerID: seller.OwnerID, StoreID: seller.StoreID, StoreName: seller.StoreName,
			LegalName: seller.LegalName, TIN: seller.TIN,
			BankAccount: seller.BankAccount, MFO: seller.MFO,
		},
		Payer: Payer{
			BuyerID:   uuidString(order.BuyerID),
			BuyerType: order.BuyerType,
			TIN:       deref(order.BuyerTin),
		},
		IssuedAt:  at,
		ExpiresAt: at.Add(r.paymentWindow),
	}); err != nil {
		return mapSettlementError(err)
	}
	// Mirror the invoice deadline onto the order so the payment SLA sweeper
	// never reads the billing schema.
	if err := store.New(tx).SetOrderPaymentDue(ctx, &store.SetOrderPaymentDueParams{
		PaymentDueAt: timeValue(at.Add(r.paymentWindow)), ID: order.ID,
	}); err != nil {
		return mapError(err)
	}
	return nil
}

// accrueCommission bills the owner for a closed order.
func (r *Repository) accrueCommission(
	ctx context.Context, tx pgx.Tx, queries *store.Queries, order *store.OrdersOrder, at time.Time,
) error {
	items, err := queries.ListOrderItems(ctx, order.ID)
	if err != nil {
		return mapError(err)
	}
	var accrued int64
	for _, item := range items {
		charge, err := money.ApplyBasisPoints(item.LineAmount, item.CommissionBps)
		if err != nil {
			return fmt.Errorf("orders: commission for line %s: %w", uuidString(item.ID), err)
		}
		accrued += charge
	}

	// Deliberately error-tolerant: the sale gate returns the resolved seller
	// alongside ErrStoreUnavailable/ErrOwnerBlocked, and a completed sale owes
	// its commission even if the store was suspended or the owner blocked
	// after payment. Only a seller that cannot be resolved at all aborts.
	seller, err := r.saleGate.ResolveSellerForOrder(ctx, tx, uuidString(order.StoreID))
	if err != nil && seller.OwnerID == "" {
		return mapLocationError(err)
	}

	if _, err := r.settlement.AccrueCommission(ctx, tx, CommissionRequest{
		OrderID:    uuidString(order.ID),
		OwnerID:    seller.OwnerID,
		BaseAmount: order.GoodsAmount,
		Accrued:    accrued,
		RateBps:    rateForLines(items, order.GoodsAmount, accrued),
		At:         at,
	}); err != nil {
		return mapSettlementError(err)
	}
	return nil
}

// rateForLines is the rate to record on the ledger row.
func rateForLines(items []*store.OrdersOrderItem, base, accrued int64) int32 {
	if len(items) > 0 {
		uniform := items[0].CommissionBps
		same := true
		for _, item := range items[1:] {
			if item.CommissionBps != uniform {
				same = false
				break
			}
		}
		if same {
			return uniform
		}
	}
	return effectiveRateBps(base, accrued)
}

// maxRateBps is 100% in basis points, and the ceiling every recorded rate is
// clamped to.
const maxRateBps = 10_000

// effectiveRateBps is the blended rate a mixed basket's accrual represents,
// rounded half-up in integer arithmetic.
func effectiveRateBps(base, accrued int64) int32 {
	if base <= 0 || accrued <= 0 {
		return 0
	}
	rate := (accrued*maxRateBps + base/2) / base
	if rate >= maxRateBps {
		return maxRateBps
	}
	//nolint:gosec // G115: rate is provably in [1, 10000) on this branch.
	return int32(rate)
}

func deref(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}

// classifyContention turns "another writer was in the way" into an answer the
// client can act on, and returns nil for everything else.
func classifyContention(err error) error {
	switch {
	case postgres.IsRetryableConflict(err):
		return fmt.Errorf("%w: %s", ErrConflict, err)
	case postgres.IsContentionTimeout(err):
		return fmt.Errorf("%w: %s", ErrUnavailable, err)
	default:
		return nil
	}
}

// mapLocationError translates the sale gate's vocabulary into this module's.
func mapLocationError(err error) error {
	switch {
	case errors.Is(err, location.ErrOwnerBlocked), errors.Is(err, location.ErrStoreUnavailable):
		return fmt.Errorf("%w: %s", ErrConflict, err)
	default:
		return err
	}
}

// mapSettlementError keeps billing's refusals from surfacing as 500s.
func mapSettlementError(err error) error {
	switch {
	case errors.Is(err, ErrSettlementConflict):
		return fmt.Errorf("%w: %s", ErrConflict, err)
	case errors.Is(err, ErrSettlementInvalid):
		return ErrInvalid
	default:
		return err
	}
}
