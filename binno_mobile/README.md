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
and iOS. It currently runs on realistic mock data; connecting it to the
backend API is the next step, and the screens are built so that swapping the
mock layer for repositories does not change them.

---

## If you are short on time

This order shows the most in a few minutes.

| Time | Open | Why |
| --- | --- | --- |
| 2 min | [lib/core/theme/](lib/core/theme/) | The design system as code: colour, typography, size and shadow tokens, one light theme |
| 2 min | [lib/features/buyer/presentation/pages/](lib/features/buyer/presentation/pages/) | The full buyer flow, screen by screen: search, offer, order, payment, refund |
| 1 min | [lib/features/shared/mock/mock_data.dart](lib/features/shared/mock/mock_data.dart) | Realistic mock data with the product rules encoded in it, ready to be swapped for an API layer |
| 1 min | [lib/core/services/yandex_map_service.dart](lib/core/services/yandex_map_service.dart) | The whole MapKit API kept behind one service |
| 1 min | [test/](test/) | Unit tests for money formatting, filters, mock-data integrity, the map boundary, and theme state |

How to run the app is described below. The overview of both projects is in
the [main README](../README.md).

---

## About this repository

> The main repository is private, on GitLab. This is a public copy made for
> the incubation stage of the President Tech Award.

**Where the project stands.** The platform is in pre-deployment staging and
has not gone to production. The buyer interface is fully built against mock
data; wiring it to the backend API is in progress. In the private repository
the code lives on working branches (`staging-M`, `dev`, `staging`) with a
GitLab CI pipeline that runs `flutter test` on every push to `dev` and
promotes the code to `staging` when the tests pass.

What differs between the two repositories:

| Content | Private GitLab repository | This copy |
| --- | --- | --- |
| Source code | Full | Full |
| Change history | Full | No: a single commit |
| CI configuration and its access token | Yes | No |
| Yandex MapKit API key | Real | Replaced with a placeholder |

There are no secrets here. The Yandex MapKit API key was replaced with the
`YOUR_YANDEX_MAPKIT_KEY` placeholder in the three places it appears
(`lib/core/constants/map_const.dart`, `MainActivity.kt`,
`AppDelegate.swift`); to run the map screens, put your own key there. The
history was removed and the result was checked with `gitleaks`.

---

## How it is built

### Structure

```text
lib/
├── core/            theme tokens, router, DI, services (map, location), helpers
├── features/
│   ├── app/         shared UI primitives (button, dialog, sheet) + ThemeCubit
│   ├── buyer/       the buyer screens: search, offer, order, payment, refund
│   ├── shared/      the BINNO widget library and the mock data layer
│   └── gallery/     a dev-only gallery that opens every screen from one place
test/                unit tests
```

The design system lives in `lib/core/theme/` as tokens: colours, typography
(Montserrat with tabular figures for numbers), sizes, radii, shadows and
motion durations. Screens compose widgets from `lib/features/shared/widgets/`
instead of styling ad hoc.

The product rules are encoded in the UI itself, for example: stock is always
shown as "declared" and never as verified; new stores show "Yangi" instead of
a zero rating; there is no ETA, no live courier map and no fake-urgency
countdowns; empty and error states always say what happened, why, and what to
do next.

### Stack

| Task | Solution |
| --- | --- |
| Toolchain | Flutter (Material 3), Dart |
| State management | `flutter_bloc` (e.g. `ThemeCubit`) |
| Navigation | `go_router`: four tab roots in a `StatefulShellRoute`, detail screens above them |
| Dependency injection | `get_it` + `injectable` |
| Maps and address picking | `yandex_mapkit`, `geolocator` |
| Storage | `shared_preferences` |

### Tests

```bash
flutter test
```

| File | What it covers |
| --- | --- |
| `test/helpers/money_test.dart` | Money formatting |
| `test/mock/search_filters_test.dart` | Filtering and sorting logic |
| `test/mock/mock_data_test.dart` | Mock-data integrity and the models |
| `test/services/uzbekistan_boundary_test.dart` | The Uzbekistan boundary polygon |
| `test/bloc/theme_cubit_test.dart` | Theme state and persistence |

---

## Running the app

You need the Flutter SDK (`stable` channel) and the usual Android or iOS
tooling.

```bash
flutter pub get
# First time on iOS:
cd ios && pod install && cd ..
flutter run

# Tests
flutter test
```

> The map screens need a Yandex MapKit key: replace the
> `YOUR_YANDEX_MAPKIT_KEY` placeholder with your own key (see "About this
> repository" above). Everything else runs without configuration.

---

## License

All rights reserved. This source code is provided within the President Tech
Award only for evaluation.

© 2026 Solution Labs LLC. All rights reserved. This code is provided solely
for evaluation purposes.
