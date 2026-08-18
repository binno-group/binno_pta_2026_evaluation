// Endurance profile: 25 VUs for 2 hours. The k6 side keeps a steady mixed
// workload and pins error/latency floors; resource drift (goroutines, heap,
// DB connections) is sampled from the metrics endpoint by run.sh, which fails
// the run on upward drift.
import { Trend } from 'k6/metrics';
import { sleep } from 'k6';
import { searchOnce, aggregateOnce, fullOrderFlow } from './lib.js';

const orderCreate = new Trend('order_create_duration', true);

export const options = {
  scenarios: {
    endurance: {
      executor: 'constant-vus',
      vus: 25,
      duration: '2h',
      exec: 'mixed',
    },
  },
  thresholds: {
    http_req_failed: ['rate<0.01'],
    http_req_duration: ['p(95)<500'],
    order_create_duration: ['p(95)<600'],
  },
};

export function mixed() {
  const roll = Math.random();
  if (roll < 0.7) {
    searchOnce();
  } else if (roll < 0.85) {
    aggregateOnce();
  } else {
    fullOrderFlow(orderCreate);
  }
  sleep(Math.random() * 0.5 + 0.2);
}
