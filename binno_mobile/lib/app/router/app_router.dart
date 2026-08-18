import 'package:binno_app/app/router/app_shell.dart';
import 'package:binno_app/core/auth_session/auth_session.dart';
import 'package:binno_app/features/auth/api.dart';
import 'package:binno_app/features/catalog/api.dart';
import 'package:binno_app/features/home/api.dart';
import 'package:binno_app/features/orders/api.dart';
import 'package:binno_app/features/profile/api.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const home = '/';
  static const catalog = '/catalog';
  static const orders = '/orders';
  static const profile = '/profile';
  static const sessions = '/profile/sessions';
  static const signIn = '/auth/phone';
}

GoRouter createRouter(AuthSession session) {
  final rootKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: AppRoutes.home,
    refreshListenable: session,
    redirect: (context, state) {
      final needsAuthentication = state.matchedLocation == AppRoutes.sessions;
      if (needsAuthentication &&
          session.status != AuthSessionStatus.authenticated) {
        return AppRoutes.signIn;
      }
      if (state.matchedLocation == AppRoutes.signIn &&
          session.status == AuthSessionStatus.authenticated) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.catalog,
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.sessions,
        builder: (context, state) => const SessionsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: AppRoutes.signIn,
        builder: (context, state) => const PhoneScreen(),
      ),
    ],
  );
}
