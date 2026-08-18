# BINNO Mobile

BINNO is a B2B/B2C e-commerce platform for digitizing the stores that work in
Central Asian trading complexes: bazaars and shopping centres. A buyer finds
products in nearby stores and places an order, the seller accepts and delivers
it, and the owner of the complex takes a commission from every completed deal.

Trading complexes are still the main form of retail in the region, and most of
them are not digitized. We are launching in Uzbekistan first. The neighbouring
Central Asian markets have similar trading culture, consumer habits and
regulation, so expansion there is planned as the next step.

This repository is the mobile side: the buyer-facing Flutter app for Android
and iOS.

---

## If you are short on time

This order shows the most in a few minutes.

| Time | Open | Why |
| --- | --- | --- |
| 2 min | [lib/design_system/](lib/design_system/) | Design tokens, components and patterns kept apart; no one-off styling |
| 2 min | [lib/features/](lib/features/) | Feature-first structure; each module owns its own state and screens |
| 1 min | [lib/core/api/](lib/core/api/) | The network layer: one place for error handling and retries |
| 1 min | [lib/core/auth_session/](lib/core/auth_session/) | Session storage and automatic token rotation |
| 1 min | [.github/workflows/ci.yml](.github/workflows/ci.yml) | The CI pipeline: static analysis, tests, builds |
| 1 min | [test/](test/) and [integration_test/](integration_test/) | Unit, widget and integration tests, kept separate |

How to run the app is described below. The overview of both projects is in
the [main README](../README.md).

---

## About this repository

> The main repository is private, on GitLab. This is a public copy made for
> the incubation stage of the President Tech Award.

**Where the project stands.** The platform is in pre-deployment staging and
has not gone to production. The app's interface is fully built and is being
connected to the backend now.

What differs between the two repositories:

| Content | Private GitLab repository | This copy |
| --- | --- | --- |
| Source code | Full | Full |
| Change history | Full | No: a single commit |
| Technical docs: ADRs/TADRs, design specs, runbooks | Yes | No |
| Signing keys: `keystore`, `provisioning profile`, certificates | Yes | No |
| CI and deployment secrets | Yes | No |
| Dev and staging server addresses | Real | Replaced with placeholders |

There are no secrets here. Only files under version control were copied;
build outputs (`build/`, `.dart_tool/`), local settings
(`android/local.properties`) and signing keys never made it in. The history
was removed and the result was checked with `gitleaks`.

The dev and staging server addresses were replaced with the `example.com`
placeholder domain. The production address is unchanged: it is a public API
address, already published in `docs/binno-openapi-v1.yaml`.

---

## How it is built

### Architecture

The app is feature-first. Every feature module has three layers, and the
dependencies point one way: presentation depends on domain, and domain
depends on nothing.

```text
   lib/
    │
    ├─ app/              application startup, navigation, theming
    │
    ├─ core/             cross-cutting services: HTTP, session, errors,
    │                    logging, analytics, feature flags
    │
    ├─ design_system/    the design system: tokens and components
    │
    ├─ features/         feature modules
    │   └─ <module>/
    │        ├─ domain/         business rules and use cases
    │        ├─ data/           repository implementations, HTTP calls
    │        ├─ presentation/   screens and controllers
    │        └─ api.dart        the module's single public boundary
    │
    └─ l10n/             localization resources
```

Modules never call each other directly; the only way in is the boundary
declared in a module's `api.dart`. The rule is enforced by tests
(`test/arch/arch_test.dart`), so it can't quietly rot.

| Id | Rule |
| --- | --- |
| A1 | Module isolation: cross-module calls go through `api.dart` only |
| A2 | Layer order: presentation can't bypass data, and domain has no upward dependencies |
| A3 | `core/` and `design_system/` don't depend on feature modules |
| A4 | `dio` and `http` are used only in `core/api/` and the modules' `data/` layers |
| A5 | Controllers don't import `flutter/material.dart` or `flutter/widgets.dart` |

### Feature modules (`lib/features/`)

| Module | Responsibility |
| --- | --- |
| `auth` | Sign-in with a phone number and one-time SMS code, active session management |
| `home` | The home screen: nearby stores and recommendations |
| `catalog` | The product catalogue and search |
| `orders` | The order list and order status |
| `profile` | The user profile and sessions |

### Stack

| Task | Solution |
| --- | --- |
| Toolchain | Flutter, Dart SDK `>=3.5.0 <4.0.0` |
| State management | `flutter_riverpod` |
| Navigation | `go_router` with `StatefulShellRoute` branches |
| Networking | `dio` |
| Secure storage | `flutter_secure_storage` |
| Data models | `freezed`, `json_serializable` |
| Localization | `flutter_localizations`, `intl`, ARB resources |
| Testing | `flutter_test`, `integration_test`, `mocktail` |

### API client

`packages/binno_api` is a `dart-dio` client generated from the server's
`docs/binno-openapi-v1.yaml` spec with `openapi-generator`. Nobody edits it
by hand.

In CI, `scripts/api-drift.sh` regenerates the client from the spec and diffs
it against the copy in the repository. Any difference fails the build, so the
client and the server contract can't drift apart.

### Auth and session

The user signs in with a phone number and a one-time SMS code. The session is
stored like this:

- the access token lives in memory only;
- the refresh token lives in the device's secure storage
  (`Keychain` or `Keystore`).

On a `401`, `BinnoInterceptor` refreshes the tokens and retries the request.
Refreshes go through a single queue, so two can't run at once. If the server
reports refresh-token reuse (`token_reuse_detected`), the whole session is
dropped.

Server errors arrive as RFC 7807 `Problem Details`, get parsed in
`core/api/problem_parser.dart` and mapped to domain error types
(`core/errors/`). Screens never see raw HTTP.

### Design system

Colours, spacing, corner radii, text styles and animation parameters all live
as tokens in `lib/design_system/tokens/`. A data copy of the tokens sits in
`docs/design-tokens.json`.

Two checks keep this honest:

- `scripts/tokens-gate.sh` fails on any raw colour or text style declared
  outside the design system;
- `scripts/tokens-drift.sh` compares the tokens in the code against
  `docs/design-tokens.json` and fails on any difference.

### Localization

All interface strings live in `lib/l10n/app_uz.arb`; the app currently ships
in Uzbek. `scripts/l10n-gate.sh` catches hard-coded strings, and
`scripts/unused-code-gate.sh` catches unused translation keys and resources.
Since nothing is hard-coded, adding a language comes down to filling in
another ARB file.

Country-specific rules sit in known places:

| Rule | Where it lives |
| --- | --- |
| Phone number format and validation | `features/auth/domain/phone_number.dart` |
| Money formatting | `core/utils/money_formatter.dart`, the single presentation boundary |
| Interface language | `lib/l10n/` |

So a new market touches only the parts listed here, not the core logic. Money
enters the app as integer tiyin only, never as a float; the server stays the
single source of truth for all calculations.

---

## Quality control

Quality requirements run as mandatory automated gates, not as documents. They
run locally through `lefthook` (`lefthook.yml`) and again in CI
(`.github/workflows/ci.yml`).

| Gate | Purpose |
| --- | --- |
| `dart format`, `flutter analyze` | One code style; the analyzer runs strict (`strict-casts`, `strict-inference`, `strict-raw-types`) |
| `test/arch` | The A1–A5 rules above |
| `scripts/todo-gate.sh` | No `TODO`/`FIXME` without a task id |
| `scripts/tokens-gate.sh`, `scripts/tokens-drift.sh` | Design token discipline |
| `scripts/l10n-gate.sh` | No hard-coded interface strings |
| `scripts/banned-copy.sh` | No legally risky or overpromising wording |
| `scripts/a11y-gate.sh` | Every screen has an accessibility test |
| `scripts/coverage-gate.sh` | Domain and controller coverage stays at 80% or higher |
| `scripts/golden-budget.sh` | Golden image changes need an explicit justification |
| `scripts/perf-budget.sh` | The performance budgets hold |
| `scripts/api-drift.sh` | The client matches the server contract |
| `scripts/flag-expiry.sh` | No expired feature flags |
| `scripts/unused-code-gate.sh` | No unused resources or translation keys |

### Tests

- **Architecture tests** check module boundaries and layer order.
- **Unit tests** cover domain rules, controllers, session handling and the
  network layer.
- **Golden tests** (`test/goldens/`) catch unintended visual changes.
- **Accessibility tests** use the `expectBinnoA11y` helper to check tap
  target sizes, labels and text contrast against the Android and iOS
  requirements.
- **Performance tests** (`integration_test/perf/`) measure list scrolling on
  a real device.

### Performance budgets

| Metric | Budget |
| --- | --- |
| Average frame build time | 8 ms |
| Frame build time, 90th percentile | 12 ms |
| Frame raster time, 90th percentile | 12 ms |
| Janky frame share | 5% |

---

## Environments

The app builds in three flavors. Each has its own entry point, and the server
address is fixed at build time.

| Environment | Entry point |
| --- | --- |
| Development | `lib/main_dev.dart` |
| Staging | `lib/main_staging.dart` |
| Production | `lib/main_prod.dart` |

---

## Running the app

You need the Flutter SDK (`stable` channel) and the usual Android or iOS
tooling.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n

# Run in the development flavor
flutter run --flavor dev --target lib/main_dev.dart

# Run the tests
flutter test
```

> There is no environment configuration in the repository. To point the app
> at a real server, replace the placeholder address in the entry-point file.

---

## License

All rights reserved. This source code is provided within the President Tech
Award only for evaluation.

© 2026 Solution Labs LLC. All rights reserved. This code is provided solely
for evaluation purposes.
