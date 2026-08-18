// Baseline profile: the daily traffic shape. 80% catalog/search reads, 15%
// order flow, 5% payment settlement, with the PostGIS product-aggregate as its
// own named scenario. Ramp to 50 VUs over 5m, hold 10m.
import { Trend } from 'k6/metrics';
import { sleep } from 'k6';
import { searchOnce, aggregateOnce, fullOrderFlow, settlementChurn } from './lib.js';

const orderCreate = new Trend('order_create_duration', true);

export const options = {
  scenarios: {
    // 80% of the 50 VUs read the catalog; a slice of those reads is the
    // aggregate scenario below so it gets its own threshold.
    catalog_reads: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 34 },
        { duration: '10m', target: 34 },
      ],
      exec: 'catalogRead',
    },
    complex_aggregate: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 6 },
        { duration: '10m', target: 6 },
      ],
      exec: 'complexAggregate',
    },
    order_flow: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 7 },
        { duration: '10m', target: 7 },
      ],
      exec: 'orderFlow',
    },
    settlement: {
      executor: 'ramping-vus',
      startVUs: 0,
      stages: [
        { duration: '5m', target: 3 },
        { duration: '10m', target: 3 },
      ],
      exec: 'settlement',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    'http_req_duration{scenario:catalog_reads}': ['p(95)<300'],
    'http_req_duration{scenario:complex_aggregate}': ['p(95)<400'],
    order_create_duration: ['p(95)<600'],
  },
};

export function catalogRead() {
  searchOnce();
  sleep(Math.random() * 0.4 + 0.1);
}

export function complexAggregate() {
  aggregateOnce();
  sleep(Math.random() * 0.6 + 0.2);
}

export function orderFlow() {
  fullOrderFlow(orderCreate);
  sleep(Math.random() * 2 + 1);
}

export function settlement() {
  settlementChurn();
  sleep(Math.random() * 3 + 2);
}
