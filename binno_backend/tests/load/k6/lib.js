// Shared plumbing for the capacity profiles. Every profile loads the
// environment written by tests/load/seed and talks to BASE_URL.
import http from 'k6/http';
import { check } from 'k6';

export const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';

const envPath = __ENV.ENV_JSON || '../out/env.json';
export const world = JSON.parse(open(envPath));

export function uuid4() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

export function buyerToken() {
  return world.buyer_tokens[__VU % world.buyer_tokens.length];
}

export function pick(list) {
  return list[Math.floor(Math.random() * list.length)];
}

export function authParams(token, name) {
  return {
    headers: { Authorization: `Bearer ${token}` },
    tags: { name },
  };
}

export function mutateParams(token, name) {
  return {
    headers: {
      Authorization: `Bearer ${token}`,
      'Idempotency-Key': uuid4(),
      'Content-Type': 'application/json',
    },
    tags: { name },
  };
}

// searchOnce is the dominant read: a product search near the seeded store.
export function searchOnce() {
  const productId = pick(world.product_ids);
  const res = http.get(
    `${BASE_URL}/search?product_id=${productId}&lat=${world.lat}&lng=${world.lng}&radius_m=5000`,
    authParams(buyerToken(), 'search'),
  );
  check(res, { 'search 200': (r) => r.status === 200 });
  return res;
}

// aggregateOnce is the PostGIS product-aggregate read: store count, price
// range and distances for one complex.
export function aggregateOnce() {
  const productId = pick(world.product_ids);
  const res = http.get(
    `${BASE_URL}/complexes/${world.complex_id}/aggregate?product_id=${productId}`,
    authParams(buyerToken(), 'complex_aggregate'),
  );
  check(res, { 'aggregate 200': (r) => r.status === 200 });
  return res;
}

// createOrder places one pickup order and returns its id, or null.
export function createOrder(token, createTrend) {
  const body = JSON.stringify({
    store_id: world.store_id,
    buyer_type: 'individual',
    fulfillment: 'pickup',
    district_id: world.district_id,
    items: [{ product_id: pick(world.product_ids), qty: '1' }],
  });
  const res = http.post(`${BASE_URL}/orders`, body, mutateParams(token, 'create_order'));
  if (createTrend) {
    createTrend.add(res.timings.duration);
  }
  check(res, { 'order created': (r) => r.status === 201 });
  if (res.status !== 201) {
    return null;
  }
  return res.json('order_id');
}

export function orderAction(orderId, path, token, payload, name) {
  const res = http.post(
    `${BASE_URL}/orders/${orderId}/${path}`,
    payload ? JSON.stringify(payload) : null,
    mutateParams(token, name),
  );
  check(res, { [`${name} 2xx`]: (r) => r.status >= 200 && r.status < 300 });
  return res;
}

// fullOrderFlow drives one order from creation to a closed delivery.
export function fullOrderFlow(createTrend) {
  const buyer = buyerToken();
  const seller = world.seller_token;
  const orderId = createOrder(buyer, createTrend);
  if (!orderId) {
    return;
  }
  orderAction(orderId, 'supplier-confirm', seller, null, 'supplier_confirm');
  orderAction(orderId, 'payment-receipt', buyer,
    { receipt_url: 'https://storage.example/receipts/load.pdf' }, 'payment_receipt');
  orderAction(orderId, 'payment-confirm', seller, null, 'payment_confirm');
  orderAction(orderId, 'preparing', seller, null, 'preparing');
  orderAction(orderId, 'ready', seller, null, 'ready');
  orderAction(orderId, 'delivery-confirm', seller, null, 'delivery_confirm');
}

// settlementChurn exercises the payment-verdict endpoints: receipt, rejection,
// second receipt, confirmation. This stands in for the brief's "callback"
// share — payment truth here is the settlement flow (docs/test-plan.md D2).
export function settlementChurn() {
  const buyer = buyerToken();
  const seller = world.seller_token;
  const orderId = createOrder(buyer, null);
  if (!orderId) {
    return;
  }
  orderAction(orderId, 'supplier-confirm', seller, null, 'supplier_confirm');
  orderAction(orderId, 'payment-receipt', buyer,
    { receipt_url: 'https://storage.example/receipts/first.pdf' }, 'payment_receipt');
  orderAction(orderId, 'payment-reject', seller, { reason: 'illegible' }, 'payment_reject');
  orderAction(orderId, 'payment-receipt', buyer,
    { receipt_url: 'https://storage.example/receipts/second.pdf' }, 'payment_receipt');
  orderAction(orderId, 'payment-confirm', seller, null, 'payment_confirm');
}
