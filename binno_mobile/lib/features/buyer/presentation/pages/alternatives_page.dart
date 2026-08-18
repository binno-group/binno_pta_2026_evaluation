import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 10 · Alternatives, the `buyer_decision_pending` state.
///
/// Rule (§5.3, ADR): **no auto-redirect**. The store that declined is
/// dropped from the list (RankExcluding) and the buyer makes the choice.
/// Tone: calm and blame-free; the buyer is never made to feel at fault.
class AlternativesPage extends StatelessWidget {
  const AlternativesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The store that declined (Metall Savdo) is not in the list.
    const alternatives = [MockData.cementBaraka, MockData.cementSardor];

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoBackBar(label: MockData.orderId),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              children: [
                Text(
                  'Bu do\'kon\ntasdiqlamadi',
                  style: AppText.display(28, height: 1.12),
                ),
                const SizedBox(height: 10),
                Text(
                  '${MockData.metallSavdo.name} bu miqdorni tasdiqlay olmadi. '
                  'To\'lov qilinmagan. Yaqin muqobillar — tanlovni siz '
                  'qilasiz.',
                  style: AppText.body(),
                ),
                const SizedBox(height: 24),
                const BinnoHairline(),
                const SizedBox(height: 16),
                Text(
                  'YAQIN MUQOBILLAR',
                  style: AppText.eyebrow(weight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < alternatives.length; i++) ...[
                  if (i != 0) ...[
                    const SizedBox(height: 16),
                    const BinnoHairline(),
                    const SizedBox(height: 16),
                  ],
                  _AlternativeRow(offer: alternatives[i]),
                ],
              ],
            ),
          ),
          BinnoFooter(
            children: [
              BinnoPrimaryButton(
                label: '${MockData.barakaQurilish.name}ga buyurtma berish',
                onPressed: () => context.push(AppRoutes.orderDraft),
              ),
              BinnoSecondaryButton(
                label: 'Boshqa takliflarni ko\'rish',
                onPressed: () => context.push(AppRoutes.searchResults),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlternativeRow extends StatelessWidget {
  const _AlternativeRow({required this.offer});

  final MockOffer offer;

  @override
  Widget build(BuildContext context) {
    final store = offer.store;

    return BinnoOfferRow(
      thumbLabel: offer.thumbLabel,
      title: store.title,
      metaLines: [
        '${store.complexBlock} · ${Money.qty(offer.declaredQty, offer.unit)}',
        if (store.responseSamples >= 5)
          'odatda ~${store.responseMinutes} daqiqada javob beradi'
        else if (!store.isNew)
          '${store.rating.toStringAsFixed(1).replaceAll('.', ',')} ★ '
              '(${store.reviewCount})',
      ],
      badge: offer.freshness == BinnoFreshness.fresh
          ? BinnoFreshnessLabel(offer.freshness)
          : null,
      price: offer.price,
      priceSub: offer.deliveryFee != null
          ? '+${Money.format(offer.deliveryFee!)}'
          : 'olib ketish',
      onTap: () => context.push(AppRoutes.offer),
    );
  }
}
