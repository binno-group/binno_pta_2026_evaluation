# BINNO Backend

BINNO is a B2B/B2C e-commerce platform for digitizing the stores that work in
Central Asian trading complexes: bazaars and shopping centres. A buyer finds
products in nearby stores and places an order, the seller accepts and delivers
it, and the owner of the complex takes a commission from every completed deal.

Trading complexes are still the main form of retail in the region, and most of
them are not digitized. We are launching in Uzbekistan first. The neighbouring
Central Asian markets have similar trading culture, consumer habits and
regulation, so expansion there is planned as the next step.

This repository is the server side: one Go service (a modular monolith) and a
background worker.

---

## If you are short on time

This order shows the most in about ten minutes.

| Time | Open | Why |
| --- | --- | --- |
| 2 min | [tests/arch/arch_test.go](tests/arch/arch_test.go) | The architecture rules are tests, not documentation. Six rules; break one and the build fails |
| 1 min | [.github/workflows/ci.yml](.github/workflows/ci.yml) | Six stages. The vulnerability scan runs on the final binary, and integration tests run against real databases |
| 2 min | [contracts/binno-openapi-v1.yaml](contracts/binno-openapi-v1.yaml) | Contract-first API. CI keeps the contract and the routes in sync |
| 2 min | [internal/platform/messaging/outbox/](internal/platform/messaging/outbox/) | An event is written in the same transaction as the change that caused it, so it can't get lost or invented |
| 2 min | [internal/modules/orders/](internal/modules/orders/) | The order aggregate, its lifecycle, stock reservation under concurrent load |
| 1 min | [table-ownership.yml](table-ownership.yml) | One owner module per database schema, checked by a CI gate |

How to run the project is described below. The overview of both projects is
in the [main README](../README.md).

---

## About this repository

> The main repository is private, on GitLab. This is a public copy made for
> the incubation stage of the President Tech Award.

**Where the project stands.** The platform is in pre-deployment staging and
has not gone to production. The backend has finished its pre-deployment test
programme (the results are in the private repository); the mobile app is
being connected to it now.

What differs between the two repositories:

| Content | Private GitLab repository | This copy |
| --- | --- | --- |
| Source code | Full | Full, unmodified |
| Change history | Full | No: a single commit |
| Technical docs: ADRs/TADRs, runbooks, load-test reports | Yes | No |
| Configuration files, keys, certificates | Yes | No |
| CI and deployment secrets | Yes | No |

There are no secrets here: config files were never copied, the history was
removed, and the result was checked with `gitleaks`. The `binno:binno`
password in `docker-compose.yml` is a local development default; the
production config (`deploy/compose/prod.yml`) takes every password from
environment variables.

---

## How it is built

### Architecture

The system is an enforced modular monolith: one deployable binary with hard
boundaries between the business modules inside it. This keeps us clear of the
operational overhead of microservices without sliding into the usual monolith
tangle.

```text
                 ┌──────────┐
   client ─────▶ │  nginx   │ ──▶ binno (N replicas)
                 └──────────┘         │
                                      ├─▶ PostgreSQL 16 + PostGIS   (OLTP)
                                      ├─▶ Redis 7                   (one-time codes,
                                      │                              rate limiting,
                                      │                              idempotency, caching)
                                      └─▶ outbox table (within the same transaction)
                                                 │
                                        dispatcher (separate process)
                                                 │
                                                 ▼
                                      analytics (PostgreSQL or ClickHouse)
```

### Business modules (`internal/modules/`)

| Module | Responsibility |
| --- | --- |
| `identity` | Auth: a JWT pair issued against a phone number and a one-time SMS code, token rotation, theft detection |
| `location` | Owners, trading complexes, blocks and stores |
| `catalog` | The product catalogue, seller offers, stock, delivery tariffs |
| `search` | Public read model for geographic search: PostGIS, sorted by distance |
| `orders` | The order aggregate and its lifecycle |
| `billing` | Invoices, payments, refunds, owner commission |
| `trust` | Binary feedback, allowed only on a completed order |
| `operator` | Operator queues built on analytics data |
| `api` | Wires the modules together |

### Platform layer (`internal/platform/`)

The platform layer holds the shared packages: `authz` (who is calling and do
they own the resource), `httpx` (RFC 7807 errors, shared middleware,
routing), `money` (integer tiyin arithmetic), `cache/{otp,ratelimit,idempotency,redisx}`
(Redis, with a circuit breaker), `database/{postgres,geo,dedup,analytics}`,
`messaging/outbox`, `telemetry/{logging,otelx}`, `sms` (Eskiz and Play Mobile
providers), `tin` (taxpayer id verification), `runtime/{config,clock}`.

### Stack

| Area | Technology |
| --- | --- |
| Language and libraries | Go 1.25, `chi`, `pgx/v5`, `go-redis/v9` |
| Primary database | PostgreSQL 16 with PostGIS 3.4; geographic search uses a `LATERAL` join and a GiST index |
| Operational store | Redis 7: one-time codes, rate limiting, idempotency responses, search cache |
| Analytics store | ClickHouse or PostgreSQL, interchangeable |
| Data access | Go generated from SQL with `sqlc` |
| Migrations | `golang-migrate`, a separate migration table per module |
| Observability | OpenTelemetry, Prometheus, Grafana, Loki, Tempo |
| Deployment | Docker compose, a distroless nonroot image, nginx in front |

### Adapting to a new country

Country-specific rules sit behind interfaces in the platform layer, not
inside the business modules. Entering a new market means writing adapters,
not rewriting logic.

| Rule | Where it lives |
| --- | --- |
| One-time code delivery | `platform/sms`, the `Sender` interface. Eskiz and Play Mobile are implemented, plus a logging adapter for development. A new provider is one more adapter |
| Taxpayer id | `platform/tin`, the `Verifier` interface. Format checks and the authoritative lookup are separate |
| Phone number format | the `identity` module |
| Currency | `platform/money`, integer tiyin. Floats are banned by an architecture test |

Geographic search is plain PostGIS with no national data sources behind it,
so it works anywhere as is. Time is stored in UTC and ids are UUID v7, so
data from several countries can live in one system without extra work.

---

## Engineering approach

The rule we follow: architecture decisions are enforced by CI, not written
down and forgotten. If a rule is broken, the build fails.

### Architecture tests (`tests/arch/`)

| Rule | What it guarantees |
| --- | --- |
| Module boundaries | Modules talk to each other only through the interface declared in `module.go`, or through the `events` package |
| Generated code stays home | Generated data-access code lives inside the module that owns it |
| Platform independence | Platform packages never import business modules |
| Float ban | Money is `int64` tiyin; no floating point in the modules |
| Sync-call allowlist | Synchronous cross-module calls are limited to an explicit, justified list |
| Analytics isolation | Only the `dispatcher` touches the analytics store, so nothing can double-write |

### CI gates (`scripts/`, `make gates`)

| Gate | Purpose |
| --- | --- |
| `todo-gate` | No unfinished-work comments left in the code |
| `migration-pairs` | Every `up` migration has a matching `down` |
| `openapi-drift` | The contract and the routes change together |
| `sqlc-drift` | Generated code matches the source SQL |
| `mutating-routes` | Every mutating route goes through `httpx.Mutating`, so `Idempotency-Key` is mandatory |
| `status-write` | The state machine is written only through the approved query |
| `table-ownership` | Table ownership matches `table-ownership.yml` |
| `no-latest` | No `:latest` tags on container images |
| `alerts-presence` | Monitoring alert rules exist |
| `coverage-gate` | Test coverage stays at 80% or higher |

### CI pipeline (`.github/workflows/ci.yml`)

1. Static analysis (`golangci-lint`).
2. Vulnerability scan. `govulncheck` runs on the final built binary, not on
   the source.
3. The gates listed above.
4. Unit tests, with `-race`.
5. Integration tests against real PostgreSQL/PostGIS, ClickHouse and Redis.
   Migration reversibility is proven with an up — down — up cycle.
6. Building the final container images.

### Platform invariants

1. All ids are UUID v7, all time is UTC, all money is integer tiyin.
2. Every mutating request needs an `Idempotency-Key` header. The response is
   kept for 24 hours, so a retry does not repeat the change.
3. Domain events go through a transactional outbox: an event is written in
   the same database transaction as the state change that caused it.
4. Errors come back as `application/problem+json`, per RFC 7807.
5. `/auth/otp/request` answers the same whether or not an account exists, so
   nobody can probe which phone numbers are registered.

---

## Measured performance

These numbers come from controlled load tests, not production traffic; the
platform has not launched. The tests ran on a four-core server (CCX23 class)
with two replicas of the service. The full methodology and raw data are in
the private repository under `docs/testing/`.

| Scenario | Result |
| --- | --- |
| Search, cached | Up to 2,000 rps without errors; p50 of 1.4–2.0 ms; peak around 3,400 rps |
| Search, uncached | Stable at 700 rps |
| Order creation | Error-free at 500 rps; p50 of 2.6 ms, p95 of 23.6 ms; no 5xx |
| Search latency | p50 around 2 ms over 8,000 stores and 152,000 offers |
| Outbox drain | 656 events per second |
| Restore from backup | 26 MB, 55,000 orders, restored on a fresh server in 6 seconds |

The stock invariants held exactly: with 500 units in stock, exactly 500 out
of 50,000 concurrent requests became orders. Idempotency held exactly too:
10,000 concurrent requests with one key produced one order, one reservation
and one outbox event.

---

## Running the project

```bash
cp .env.example .env          # local defaults are sufficient
make up                       # full environment: nginx, api, postgres, redis
make migrate-up               # OLTP migrations, per module
make migrate-analytics-up     # analytics store migrations

curl localhost:8080/healthz
open  localhost:8080/docs     # Swagger UI, development only
```

Common commands:

```bash
make test              # unit tests, with -race
make test-integration  # needs real databases, Redis and ClickHouse
make arch              # architecture boundary tests
make gates             # all CI gates
make lint              # static analysis
make scale n=3         # N replicas of the service behind nginx
```

Production deployment:

```bash
docker compose -f docker-compose.yml \
               -f deploy/compose/prod.yml \
               -f deploy/compose/hetzner/ccx23.yml up -d
```

`scripts/tls-bootstrap.sh` does the initial Let's Encrypt setup;
`scripts/rolling-deploy.sh` rolls out new versions with minimal downtime.

---

## Layout

```text
cmd/binno/          HTTP API entry point
cmd/dispatcher/     background process relaying the outbox to the analytics store
internal/modules/   business modules
internal/platform/  shared infrastructure
contracts/          OpenAPI 3.1 contract, kept in sync with the code by CI
migrations/         per-module SQL migrations, up and down pairs
deploy/             compose configs, nginx, monitoring
scripts/            CI gates, backup, TLS and deployment scripts
tests/arch/         architecture boundary tests
```

206 Go files, about 29,100 lines, 74 of them tests, plus 27 SQL files.

---

## License and status

The software is closed source; all rights are reserved. This copy was made
public only for evaluation within the President Tech Award.

© 2026 Solution Labs LLC. All rights reserved. This code is provided solely
for evaluation purposes.
