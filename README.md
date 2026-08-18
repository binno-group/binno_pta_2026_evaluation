# BINNO — PTA 2026 Evaluation Repository

Sanitized copies of the BINNO backend and Flutter mobile app, prepared for
President Tech Award 2026.

The production code lives in private GitLab repositories. The platform is in
pre-deployment staging and has not been released yet: the backend has finished
its pre-deployment test programme, and the mobile app is currently being
connected to it.

There are no production credentials, secrets, private infrastructure config or
user data anywhere in this repository. It exists only for technical
evaluation.

---

## Where to start

Short on time? This order covers the most ground in about ten minutes, and
every entry is a direct link.

| # | Time | Open | Why |
| --- | --- | --- | --- |
| 1 | 2 min | [binno_backend/README.md](binno_backend/README.md) | Backend architecture, load-test numbers, how the project is run |
| 2 | 2 min | [binno_backend/tests/arch/arch_test.go](binno_backend/tests/arch/arch_test.go) | The architecture rules are tests, not documentation. Six rules; break one and the build fails |
| 3 | 1 min | [binno_backend/.github/workflows/ci.yml](binno_backend/.github/workflows/ci.yml) | Six-stage pipeline. The vulnerability scan runs on the built binary, and integration tests hit real PostgreSQL, Redis and ClickHouse |
| 4 | 2 min | [binno_backend/contracts/binno-openapi-v1.yaml](binno_backend/contracts/binno-openapi-v1.yaml) | Contract-first API. CI checks the contract against the actual routes |
| 5 | 1 min | [binno_mobile/README.md](binno_mobile/README.md) | Mobile architecture, design system, localization, quality gates |
| 6 | 2 min | [binno_mobile/lib/features/](binno_mobile/lib/features/) and [binno_mobile/lib/design_system/](binno_mobile/lib/design_system/) | Feature modules and a token-based design system instead of one-off styling |

If you have more time, three places show the depth behind the correctness
guarantees:

| Open | Why |
| --- | --- |
| [binno_backend/internal/platform/messaging/outbox/](binno_backend/internal/platform/messaging/outbox/) | Transactional outbox: an event is written in the same database transaction as the change that caused it, so events don't get lost or invented |
| [binno_backend/internal/modules/orders/](binno_backend/internal/modules/orders/) | The order aggregate and its lifecycle, including stock reservation under concurrent load |
| [binno_backend/table-ownership.yml](binno_backend/table-ownership.yml) | Each database schema has one owner module; CI checks it |

---

## Structure

```text
binno_backend/     Go backend: HTTP API and background dispatcher
  cmd/             entry points (API, dispatcher)
  internal/modules/  business modules: identity, location, catalog, search,
                     orders, billing, trust, operator
  internal/platform/ shared infrastructure: authorization, HTTP layer, money,
                     caching, database access, outbox, telemetry, SMS
  contracts/       OpenAPI 3.1 contract
  migrations/      SQL migrations, per module, with up and down pairs
  deploy/          compose overlays, nginx and monitoring configuration
  scripts/         CI gates, backup, TLS and deployment scripts
  tests/arch/      executable architecture boundary rules

binno_mobile/      Flutter application (buyer experience)
  lib/app/         application shell, routing, build flavors
  lib/core/        API client, session handling, analytics, logging
  lib/design_system/ design tokens, components and patterns
  lib/features/    feature modules
  test/            unit and widget tests
  integration_test/ integration tests
```

Size: the backend has 206 Go files (about 29,100 lines, 74 of them tests) and
27 SQL files; the app has 88 Dart files (12 of them tests), not counting the
generated API client.

---

## Running the projects

Neither project needs credentials to build and run locally.

**Backend** — Docker and Go 1.25:

```bash
cd binno_backend
cp .env.example .env      # local defaults are sufficient
make up                   # nginx, API, PostgreSQL, Redis
make migrate-up
curl localhost:8080/healthz
```

`make test` runs the unit tests, `make arch` the architecture rules and
`make gates` the full set of CI gates. Details are in
[binno_backend/README.md](binno_backend/README.md).

**Mobile** — Flutter SDK, stable channel:

```bash
cd binno_mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run --flavor dev --target lib/main_dev.dart
flutter test
```

---

## About the history

This is an evaluation snapshot, not a development repository. Its commit
history only shows how the sanitized copy was assembled and says nothing about
how the products were built. The real engineering history stays in the private
GitLab repositories; for the backend alone it spans module implementation,
database optimization, ACID correctness fixes and a full pre-deployment test
campaign. We can show it to the evaluation committee on request.

---

## Sanitization

There are no credentials or secrets in the tree or in the history. We ran
`gitleaks` across every commit and reviewed the result by hand: no env files,
private keys, certificates, signing keystores or service-account files at any
point. The config values that do appear, such as the local database password
in the backend's `docker-compose.yml`, are local development defaults;
production takes every password from environment variables.

---

## Legal

© 2026 Solution Labs LLC. All rights reserved. This code is provided solely for
evaluation purposes.
