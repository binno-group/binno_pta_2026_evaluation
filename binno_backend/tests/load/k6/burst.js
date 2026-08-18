// Burst profile: 10 -> 300 VUs in 30s, hold 2m, ramp down. The service may
// shed load (503s from admission control are fine) but must not fall over
// (non-503 5xx) and must return to baseline latency within 60s of the burst
// ending — the `recovery` scenario measures exactly that window.
import { Rate } from 'k6/metrics';
import { sleep } from 'k6';
import { searchOnce } from './lib.js';

// Server faults exclude 503: shedding is graceful degradation, 500s are not.
const serverFaults = new Rate('server_faults');
// Shed rate is reported for the pool-queues-not-exhausts judgement: shedding
// should be a slice of the burst, not the whole of it.
const shedResponses = new Rate('shed_responses');

// Burst timeline: 30s ramp + 2m hold + 30s down = 3m; recovery starts 60s
// after the burst ends and measures one clean minute.
export const options = {
  scenarios: {
    burst: {
      executor: 'ramping-vus',
      startVUs: 10,
      stages: [
        { duration: '30s', target: 300 },
        { duration: '2m', target: 300 },
        { duration: '30s', target: 10 },
      ],
      exec: 'burstRead',
    },
    recovery: {
      executor: 'constant-vus',
      vus: 5,
      duration: '1m',
      startTime: '4m',
      exec: 'recoveryRead',
    },
  },
  thresholds: {
    server_faults: ['rate<0.01'],
    'shed_responses{scenario:burst}': ['rate<0.5'],
    // Baseline latency restored within 60s after the burst.
    'http_req_duration{scenario:recovery}': ['p(95)<300'],
    'http_req_failed{scenario:recovery}': ['rate<0.01'],
  },
};

function observe(res) {
  serverFaults.add(res.status >= 500 && res.status !== 503);
  shedResponses.add(res.status === 503);
}

export function burstRead() {
  observe(searchOnce());
}

export function recoveryRead() {
  observe(searchOnce());
  sleep(0.2);
}
