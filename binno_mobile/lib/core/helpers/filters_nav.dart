import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/shared/mock/search_filters.dart';
import '../router/app_routes.dart';

/// Opening the filters from the home page and the catalogue.
///
/// These screens have no results list "behind" them, so applying a filter
/// opens the results screen instead of popping back; otherwise the user
/// would pick filters and see nothing change.
Future<void> openFiltersThenResults(BuildContext context) async {
  final result = await context.push<Object?>(AppRoutes.filters);
  if (!context.mounted) return;
  if (result is! SearchFilters) return;

  context.push(AppRoutes.searchResults, extra: result);
}
