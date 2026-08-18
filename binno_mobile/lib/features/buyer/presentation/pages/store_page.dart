import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// The store page.
///
/// Rule (ADR-008): the page is **per store**; the rating, response time,
/// and freshness coverage belong to this outlet. The owner's name does
/// not appear here; it shows up only in the invoice details.
class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  /// Only the first two reviews are shown initially.
  bool _allReviews = false;

  static const _previewCount = 2;

  List<MockReview> get _visibleReviews => _allReviews
      ? MockData.reviews
      : MockData.reviews.take(_previewCount).toList();

  @override
  Widget build(BuildContext context) {
    const store = MockData.metallSavdo;
    const offers = [MockData.cementMetall, MockData.armaturaMetall];

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
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              store.name,
                              style: AppText.display(
                                30,
                                color: AppColors.white,
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (store.verified) ...[
                            const SizedBox(width: 10),
                            const BinnoVerifiedTick(size: 20),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        store.locationChain,
                        style: AppText.s(
                          13,
                          FontWeight.w400,
                          color: AppColors.onNavyMeta,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _Stat(
                            value: store.rating
                                .toStringAsFixed(1)
                                .replaceAll('.', ','),
                            label: '${store.reviewCount} sharh',
                          ),
                          const SizedBox(width: 24),
                          _Stat(
                            value: '~${store.responseMinutes} daq',
                            label: 'javob vaqti',
                          ),
                          const SizedBox(width: 24),
                          const _Stat(value: '92%', label: 'yangilangan'),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BinnoSecondaryButton(
                        label: 'Chat',
                        icon: Icons.chat_bubble_outline_rounded,
                        strong: true,
                        onPressed: () => context.push(AppRoutes.chat),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: BinnoSecondaryButton(
                        label: 'Qo\'ng\'iroq',
                        icon: Icons.call_outlined,
                        onPressed: () => binnoSnack(
                          context,
                          'Sotuvchi telefoni buyurtma qabul qilinganidan '
                          'keyin ochiladi',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                const BinnoBanner(
                  tone: BinnoBannerTone.info,
                  icon: Icons.place_outlined,
                  text: 'Olib ketish mumkin — Qo\'yliq, 1-darvoza, umumiy '
                      'nuqta. Aniq do\'kon manzili to\'lov tasdiqlangach '
                      'ochiladi.',
                ),
                const SizedBox(height: 22),
                Text('JOYLASHUV', style: AppText.eyebrow()),
                const SizedBox(height: 12),
                BinnoMapPreview(
                  latitude: MockData.complexes.first.latitude,
                  longitude: MockData.complexes.first.longitude,
                  onTap: () => binnoSnack(
                    context,
                    'Aniq do\'kon manzili to\'lov tasdiqlangach ochiladi',
                  ),
                ),
                const SizedBox(height: 22),
                Text('TAKLIFLAR', style: AppText.eyebrow()),
                const SizedBox(height: 14),
                for (var i = 0; i < offers.length; i++) ...[
                  if (i != 0) ...[
                    const SizedBox(height: 16),
                    const BinnoHairline(),
                    const SizedBox(height: 16),
                  ],
                  BinnoOfferRow(
                    thumbLabel: offers[i].thumbLabel,
                    title: offers[i].productTitle,
                    metaLines: [
                      'E\'lon qilingan qoldiq: '
                          '${Money.qty(offers[i].declaredQty, offers[i].unit)}',
                    ],
                    badge: offers[i].freshness == BinnoFreshness.normal
                        ? null
                        : BinnoFreshnessLabel(offers[i].freshness),
                    price: offers[i].price,
                    priceSub: 'so\'m / ${offers[i].unit}',
                    onTap: () => context.push(AppRoutes.offer),
                  ),
                ],
                const SizedBox(height: 24),
                const BinnoHairline(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: Text('SHARHLAR', style: AppText.eyebrow())),
                    Text(
                      '${store.reviewCount} ta',
                      style: AppText.meta(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (var i = 0; i < _visibleReviews.length; i++) ...[
                  if (i != 0) const SizedBox(height: 18),
                  _ReviewRow(review: _visibleReviews[i]),
                ],
                if (MockData.reviews.length > _previewCount) ...[
                  const SizedBox(height: 18),
                  BinnoSecondaryButton(
                    label: _allReviews
                        ? 'Yig\'ish'
                        : 'Barcha sharhlar · ${MockData.reviews.length}',
                    onPressed: () =>
                        setState(() => _allReviews = !_allReviews),
                  ),
                ],
                const SizedBox(height: 20),
                Text(
                  'Reyting va javob vaqti shu do\'konga tegishli — '
                  'eganing boshqa do\'konlariga o\'tmaydi.',
                  textAlign: TextAlign.center,
                  style: AppText.note(),
                ),
              ],
            ),
          ),
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

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.review});

  final MockReview review;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(review.author, style: AppText.rowTitle(size: 14)),
            ),
            Row(
              children: List.generate(
                5,
                (i) => Icon(
                  i < review.rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  size: 14,
                  color: i < review.rating
                      ? AppColors.warning
                      : AppColors.edge2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(review.text, style: AppText.s(13, FontWeight.w400, height: 1.5)),
        const SizedBox(height: 4),
        Text(review.date, style: AppText.note()),
      ],
    );
  }
}
