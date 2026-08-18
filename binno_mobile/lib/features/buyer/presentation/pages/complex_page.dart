import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_map.dart';
import '../../../shared/widgets/widgets.dart';

/// 09 · The complex page, the **signature screen**.
///
/// The bazaar itself, digitized: offers are grouped **by block** and sorted
/// by price within a product (§4.4). Delivery tariffs are not kept at the
/// complex level; only the shared pickup point is shown (ADR-004).
class ComplexPage extends StatelessWidget {
  const ComplexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      onNavy: true,
      child: Column(
        children: [
          BinnoNavyHeader(
            bottomPadding: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BinnoBackBar(onNavy: true, safeArea: false),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Qo\'yliq\nqurilish bozori',
                        style: AppText.display(
                          34,
                          color: AppColors.white,
                          height: 1.06,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: const [
                          _Stat(value: '4', label: 'blok'),
                          SizedBox(width: 24),
                          _Stat(value: '86', label: 'do\'kon'),
                          SizedBox(width: 24),
                          _Stat(value: '312', label: 'taklif'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.09),
                          borderRadius: BorderRadius.circular(AppDimens.rTile),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.place_outlined,
                              size: 17,
                              color: AppColors.onNavySuccess,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Olib ketish mumkin — 1-darvoza, '
                                'umumiy nuqta',
                                style: AppText.s(
                                  12,
                                  FontWeight.w400,
                                  color: AppColors.onNavy2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        'M400 sement',
                        style: AppText.s(15, FontWeight.w600),
                      ),
                    ),
                    Text('narx bo\'yicha', style: AppText.meta()),
                  ],
                ),
                const SizedBox(height: 14),
                BinnoMapPreview(
                  latitude: MockData.complexes.first.latitude,
                  longitude: MockData.complexes.first.longitude,
                  height: 140,
                  onTap: () => binnoSnack(
                    context,
                    'Umumiy olib ketish nuqtasi — Qo\'yliq, 1-darvoza',
                  ),
                ),
                const SizedBox(height: 20),
                for (final entry in MockData.complexGroups.entries) ...[
                  if (entry.key != MockData.complexGroups.keys.first) ...[
                    const SizedBox(height: 16),
                    const BinnoHairline(),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    '${entry.key} · ${entry.value.length} taklif'.toUpperCase(),
                    style: AppText.eyebrow(weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 14),
                  for (var i = 0; i < entry.value.length; i++) ...[
                    if (i != 0) const SizedBox(height: 14),
                    _ComplexOfferRow(offer: entry.value[i]),
                  ],
                ],
              ],
            ),
          ),
          const _StickyBar(),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: AppText.display(20, color: AppColors.white)),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.s(11, FontWeight.w400, color: AppColors.onNavyMeta),
        ),
      ],
    );
  }
}

class _ComplexOfferRow extends StatelessWidget {
  const _ComplexOfferRow({required this.offer});

  final MockOffer offer;

  @override
  Widget build(BuildContext context) {
    return BinnoOfferRow(
      thumbLabel: offer.thumbLabel,
      thumbSize: 52,
      title: offer.store.title,
      metaLines: [
        'E\'lon qilingan qoldiq: '
            '${Money.qty(offer.declaredQty, offer.unit)}',
      ],
      badge: offer.freshness == BinnoFreshness.fresh
          ? BinnoFreshnessLabel(offer.freshness)
          : null,
      price: offer.price,
      priceStyle: AppText.display(17),
      onTap: () => context.push(AppRoutes.offer),
    );
  }
}

class _StickyBar extends StatelessWidget {
  const _StickyBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.hairline)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Eng arzon narx', style: AppText.meta()),
                    const SizedBox(height: 2),
                    Text(
                      Money.som(MockData.cementSardor.price),
                      style: AppText.display(20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BinnoInlineAction(
                label: 'Buyurtma berish',
                onPressed: () => context.push(AppRoutes.offer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
