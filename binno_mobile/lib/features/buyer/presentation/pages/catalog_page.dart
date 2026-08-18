import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/filters_nav.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// The catalogue tab: categories and trading complexes.
///
/// Only categories with live offers are shown: an empty category walks the
/// user into a dead end.
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          const BinnoTabHeader(
            title: 'Katalog',
            subtitle: 'Faqat jonli takliflari bor kategoriyalar',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BinnoSearchField(
                        placeholder: 'Sement, armatura, g\'isht…',
                        onTap: () => context.push(AppRoutes.search),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _FilterButton(
                      onTap: () => openFiltersThenResults(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('KATEGORIYALAR', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    for (final category in MockData.categories)
                      BinnoCategoryCard(
                        label: category.name,
                        asset: category.asset,
                        offerCount: category.offerCount,
                        compact: false,
                        onTap: () => context.push(AppRoutes.searchResults),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                Text('SAVDO MAJMUALARI', style: AppText.eyebrow()),
                const SizedBox(height: 6),
                Text(
                  'Majmua sahifasida takliflar blok kesimida, narx bo\'yicha '
                  'saralangan holda ko\'rinadi.',
                  style: AppText.meta(),
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < MockData.complexes.length; i++) ...[
                  if (i != 0) const SizedBox(height: 10),
                  _ComplexCard(
                    complex: MockData.complexes[i],
                    onTap: () => context.push(AppRoutes.complex),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _FilterButton extends StatelessWidget {
  const _FilterButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.rField),
        boxShadow: AppDimens.shadowSearch,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppDimens.rField),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.rField),
          child: const SizedBox(
            width: AppDimens.hSearch,
            height: AppDimens.hSearch,
            child: Icon(
              Icons.tune_rounded,
              size: 21,
              color: AppColors.navy950,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComplexCard extends StatelessWidget {
  const _ComplexCard({required this.complex, this.onTap});

  final MockComplex complex;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BinnoCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
      child: Row(
        children: [
          const BinnoIconChip(
            icon: Icons.storefront_rounded,
            size: 44,
            background: AppColors.surface2,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(complex.name, style: AppText.rowTitle()),
                const SizedBox(height: 3),
                Text(
                  '${complex.storeCount}+ do\'kon · ${complex.district}',
                  style: AppText.meta(),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            size: 22,
            color: AppColors.ink3,
          ),
        ],
      ),
    );
  }
}
