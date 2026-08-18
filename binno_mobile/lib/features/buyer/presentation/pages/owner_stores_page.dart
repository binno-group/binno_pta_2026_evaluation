import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// "N more stores": one owner's collapsed offers.
///
/// Rule (§4.3): in the results list an owner shows **one** best offer per
/// product. The rest open here, still **per store**, with no merged
/// rating.
class OwnerStoresPage extends StatelessWidget {
  const OwnerStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    const others = [MockData.cementBarakaSergeli, MockData.cementBarakaD];

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoPageHeader(
            title: 'Baraka Qurilish\nboshqa do\'konlari',
            subtitle: 'M400 sement · 2 taklif · narx bo\'yicha',
            titleSize: 26,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                const BinnoBanner(
                  tone: BinnoBannerTone.info,
                  text: 'Har do\'konning narxi, qoldig\'i va reytingi '
                      'alohida. Ular birlashtirilmaydi — taqqoslash faqat '
                      'do\'kon darajasida bo\'ladi.',
                ),
                const SizedBox(height: 22),
                for (var i = 0; i < others.length; i++) ...[
                  if (i != 0) ...[
                    const SizedBox(height: 16),
                    const BinnoHairline(),
                    const SizedBox(height: 16),
                  ],
                  BinnoOfferRow(
                    thumbLabel: others[i].thumbLabel,
                    title: others[i].store.title,
                    verified: others[i].store.verified,
                    metaLines: [
                      '${others[i].store.complexBlock} · '
                          '${Money.qty(others[i].declaredQty, others[i].unit)}',
                      if (others[i].store.responseSamples >= 5)
                        'odatda ~${others[i].store.responseMinutes} daqiqada '
                            'javob beradi',
                    ],
                    badge: others[i].freshness == BinnoFreshness.normal
                        ? null
                        : BinnoFreshnessLabel(others[i].freshness),
                    price: others[i].price,
                    priceSub: others[i].deliveryFee != null
                        ? '+${Money.format(others[i].deliveryFee!)} yetkazish'
                        : 'olib ketish',
                    onTap: () => context.push(AppRoutes.offer),
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
