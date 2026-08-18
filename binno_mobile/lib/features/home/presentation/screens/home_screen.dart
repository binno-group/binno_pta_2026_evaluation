import 'package:binno_app/design_system/components/binno_reference_components.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:binno_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BinnoHeroHeader(
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.appName.toLowerCase(),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: colors.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: l10n.notificationsLabel,
                          onPressed: () {},
                          icon: const Badge(
                            smallSize: BinnoSpacing.x2,
                            child: Icon(Icons.notifications_none_rounded),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 100),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: colors.primary,
                          child: const Icon(Icons.location_on_outlined),
                        ),
                        const SizedBox(width: BinnoSpacing.x3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.deliveryAddressLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: colors.onPrimary.withValues(
                                        alpha: 0.72,
                                      ),
                                      letterSpacing: 1.2,
                                    ),
                              ),
                              Text(
                                l10n.deliveryAddressValue,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: colors.onPrimary),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            l10n.changeAction,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: colors.onPrimary.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              BinnoSpacing.x4,
              0,
              BinnoSpacing.x4,
              BinnoSpacing.x8,
            ),
            sliver: SliverList.list(
              children: [
                const SizedBox(height: BinnoSpacing.x4),
                SizedBox(
                  height: BinnoSpacing.x16,
                  child: TextField(
                    readOnly: true,
                    onTap: () {},
                    decoration: InputDecoration(
                      hintText: l10n.searchHint,
                      prefixIcon: const Icon(Icons.search_rounded),
                      fillColor: colors.surface,
                    ),
                  ),
                ),
                Text(
                  l10n.updatedTodayTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: BinnoSpacing.x4),
                BinnoSurfaceCard(
                  color: colors.primary,
                  child: SizedBox(
                    height: 120,
                    child: Center(
                      child: Icon(
                        Icons.inventory_2_outlined,
                        size: BinnoSpacing.x12,
                        color: colors.onPrimary.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: BinnoSpacing.x3),
                _ProductRow(
                  title: l10n.cementProduct,
                  subtitle: l10n.cementSeller,
                  price: l10n.cementPrice,
                  unit: l10n.priceUnit,
                ),
                const Divider(height: BinnoSpacing.x8),
                _ProductRow(
                  title: l10n.rebarProduct,
                  subtitle: l10n.rebarSeller,
                  price: l10n.rebarPrice,
                  unit: l10n.priceUnit,
                ),
                const SizedBox(height: BinnoSpacing.x6),
                Row(
                  children: [
                    _Category(label: l10n.categoryCement),
                    const SizedBox(width: BinnoSpacing.x3),
                    _Category(label: l10n.categoryRebar),
                    const SizedBox(width: BinnoSpacing.x3),
                    _Category(label: l10n.categoryBrick),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.unit,
  });

  final String title;
  final String subtitle;
  final String price;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BinnoSurfaceCard(
          padding: EdgeInsets.all(BinnoSpacing.x4),
          child: Icon(Icons.construction_outlined),
        ),
        const SizedBox(width: BinnoSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: Theme.of(context).textTheme.titleLarge),
            Text(unit, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ],
    );
  }
}

class _Category extends StatelessWidget {
  const _Category({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const AspectRatio(
            aspectRatio: 1.4,
            child: BinnoSurfaceCard(
              child: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(height: BinnoSpacing.x2),
          Text(label, style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
