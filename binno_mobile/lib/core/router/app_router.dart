import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../features/buyer/presentation/pages/addresses_page.dart';
import '../../features/buyer/presentation/pages/alternatives_page.dart';
import '../../features/buyer/presentation/pages/awaiting_page.dart';
import '../../features/buyer/presentation/pages/buyer_home_page.dart';
import '../../features/buyer/presentation/pages/buyer_orders_page.dart';
import '../../features/buyer/presentation/pages/buyer_profile_page.dart';
import '../../features/buyer/presentation/pages/catalog_page.dart';
import '../../features/buyer/presentation/pages/chat_page.dart';
import '../../features/buyer/presentation/pages/complex_page.dart';
import '../../features/buyer/presentation/pages/empty_results_page.dart';
import '../../features/buyer/presentation/pages/filters_page.dart';
import '../../features/buyer/presentation/pages/help_page.dart';
import '../../features/buyer/presentation/pages/language_page.dart';
import '../../features/buyer/presentation/pages/legal_info_page.dart';
import '../../features/buyer/presentation/pages/map_picker_page.dart';
import '../../features/buyer/presentation/pages/notifications_page.dart';
import '../../features/buyer/presentation/pages/offer_detail_page.dart';
import '../../features/buyer/presentation/pages/offline_page.dart';
import '../../features/buyer/presentation/pages/order_active_page.dart';
import '../../features/buyer/presentation/pages/order_draft_page.dart';
import '../../features/buyer/presentation/pages/owner_stores_page.dart';
import '../../features/buyer/presentation/pages/payment_page.dart';
import '../../features/buyer/presentation/pages/product_request_page.dart';
import '../../features/buyer/presentation/pages/profile_edit_page.dart';
import '../../features/buyer/presentation/pages/rating_page.dart';
import '../../features/buyer/presentation/pages/refund_request_page.dart';
import '../../features/buyer/presentation/pages/refund_tracker_page.dart';
import '../../features/buyer/presentation/pages/search_page.dart';
import '../../features/buyer/presentation/pages/search_results_page.dart';
import '../../features/buyer/presentation/pages/store_page.dart';
import '../../features/gallery/presentation/pages/gallery_page.dart';
import '../../features/shared/mock/search_filters.dart';
import '../../features/shared/widgets/binno_shell.dart';
import 'app_routes.dart';

/// The BINNO routes: one role, one navigation shell.
@lazySingleton
class AppRouter {
  static final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

  /// A detail route; it opens above the bottom navigation.
  static GoRoute _detail(String path, Widget Function() build) => GoRoute(
    parentNavigatorKey: _rootKey,
    path: path,
    builder: (context, state) => build(),
  );

  static final GoRouter router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.home,
    routes: [
      // ══ Persistent bottom navigation ══════════════════════════════════════
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            BinnoShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const BuyerHomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.catalog,
                builder: (context, state) => const CatalogPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const BuyerOrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const BuyerProfilePage(),
              ),
            ],
          ),
        ],
      ),

      // ══ Discovery ═════════════════════════════════════════════════════════
      _detail(AppRoutes.search, SearchPage.new),
      // Results and filters exchange state through `extra`.
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.searchResults,
        builder: (context, state) => SearchResultsPage(
          filters: state.extra is SearchFilters
              ? state.extra! as SearchFilters
              : null,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.filters,
        builder: (context, state) => FiltersPage(
          initial: state.extra is SearchFilters
              ? state.extra! as SearchFilters
              : null,
        ),
      ),
      _detail(AppRoutes.complex, ComplexPage.new),
      _detail(AppRoutes.store, StorePage.new),
      _detail(AppRoutes.ownerStores, OwnerStoresPage.new),
      _detail(AppRoutes.offer, OfferDetailPage.new),
      _detail(AppRoutes.productRequest, ProductRequestPage.new),
      _detail(AppRoutes.emptyResults, EmptyResultsPage.new),
      _detail(AppRoutes.offline, OfflinePage.new),

      // ══ Order flow ════════════════════════════════════════════════════════
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.orderDraft,
        builder: (context, state) => OrderDraftPage(
          fulfillment: state.extra is int ? state.extra! as int : 0,
        ),
      ),
      _detail(AppRoutes.awaiting, AwaitingPage.new),
      _detail(AppRoutes.alternatives, AlternativesPage.new),
      _detail(AppRoutes.payment, PaymentPage.new),
      _detail(AppRoutes.orderActive, OrderActivePage.new),
      _detail(AppRoutes.refund, RefundRequestPage.new),
      _detail(AppRoutes.refundTracker, RefundTrackerPage.new),
      _detail(AppRoutes.rating, RatingPage.new),

      // ══ Map ═══════════════════════════════════════════════════════════════
      GoRoute(
        parentNavigatorKey: _rootKey,
        path: AppRoutes.mapPicker,
        builder: (context, state) {
          final query = state.uri.queryParameters;
          return MapPickerPage(
            initialLat: double.tryParse(query['lat'] ?? ''),
            initialLng: double.tryParse(query['lng'] ?? ''),
          );
        },
      ),

      // ══ Communication ═════════════════════════════════════════════════════
      _detail(AppRoutes.chat, ChatPage.new),
      _detail(AppRoutes.notifications, NotificationsPage.new),

      // ══ Profile sections ══════════════════════════════════════════════════
      _detail(AppRoutes.addresses, AddressesPage.new),
      _detail(AppRoutes.profileEdit, ProfileEditPage.new),
      _detail(AppRoutes.legalInfo, LegalInfoPage.new),
      _detail(AppRoutes.language, LanguagePage.new),
      _detail(AppRoutes.help, HelpPage.new),

      // ══ Dev ═══════════════════════════════════════════════════════════════
      _detail(AppRoutes.gallery, GalleryPage.new),
    ],
  );

  GoRouter get goRouter => router;
}
