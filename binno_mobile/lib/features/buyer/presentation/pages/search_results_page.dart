import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/mock/search_filters.dart';
import '../../../shared/widgets/widgets.dart';

/// 02 · Search results: one hero result, the rest typographic rows.
///
/// Rules: one owner appears with **one** best offer per product (the rest
/// collapse into "N more stores"); stock is always "declared".
class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({super.key, this.filters});

  /// The state handed over from the search or filters screen.
  final SearchFilters? filters;

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  late SearchFilters _filters = widget.filters ?? const SearchFilters();

  /// The filtered and sorted offers, from a single source.
  List<MockOffer> get _offers => _filters.apply(MockData.searchResults);

  /// The hero-card eyebrow follows the sort criterion.
  String get _heroEyebrow => switch (_filters.sort) {
    1 => 'ENG YAQIN',
    2 => 'ENG YANGI',
    3 => 'ENG YUQORI REYTING',
    _ => 'ENG ARZON',
  };

  Future<void> _openFilters() async {
    final result = await context.push<Object?>(
      AppRoutes.filters,
      extra: _filters,
    );
    if (!mounted) return;
    if (result is SearchFilters) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final offers = _offers;
    final storeCount = SearchFilters.storeCount(offers);
    final activeCount = _filters.activeCount;

    // An empty result is its own screen (§4.5): never a dead end.
    if (offers.isEmpty) {
      return BinnoScreen(
        child: Column(
          children: [
            BinnoBackBar(label: _filters.query),
            const Expanded(
              child: BinnoEmptyState(
                title: 'Bu filtrlarga\nmos taklif yo\'q',
                body: 'Filtrlar juda tor. Radius yoki narx oralig\'ini '
                    'kengaytiring — yoki filtrlarni tozalang.',
              ),
            ),
            BinnoFooter(
              topBorder: true,
              children: [
                BinnoPrimaryButton(
                  label: 'Filtrlarni tozalash',
                  onPressed: () => setState(
                    () => _filters = SearchFilters(query: _filters.query),
                  ),
                ),
                const SizedBox(height: 10),
                BinnoSecondaryButton(
                  label: 'Filtrlarni o\'zgartirish',
                  onPressed: _openFilters,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return BinnoScreen(
      child: Column(
        children: [
          BinnoBackBar(
            label: '${offers.length} taklif · $storeCount do\'kon',
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 100),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
                      child: _QueryTitle(filters: _filters),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                      child: _CheapestCard(
                        offer: offers.first,
                        eyebrow: _heroEyebrow,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _ResultList(offers: offers.skip(1).toList()),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 26),
                  child: BinnoFloatingPill(
                    label: activeCount == 0
                        ? 'Filtrlar'
                        : 'Filtrlar · $activeCount',
                    icon: Icons.tune_rounded,
                    onPressed: _openFilters,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QueryTitle extends StatelessWidget {
  const _QueryTitle({required this.filters});

  final SearchFilters filters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(filters.query, style: AppText.display(32, height: 1.06)),
        const SizedBox(height: 8),
        Text(filters.summaryLine, style: AppText.meta(size: 13)),
      ],
    );
  }
}

/// The "ENG ARZON" hero card: a 44px price, the largest typographic
/// moment. The first offer in the list (best by the sort) becomes the hero.
class _CheapestCard extends StatelessWidget {
  const _CheapestCard({required this.offer, required this.eyebrow});

  final MockOffer offer;

  /// Changes with the sort criterion: "ENG ARZON", "ENG YAQIN"…
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return BinnoSoftCard(
      radius: AppDimens.rHero,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: AppText.eyebrow(
                        color: AppColors.navy800,
                        size: 10,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      offer.store.name,
                      style: AppText.s(16, FontWeight.w600, height: 1.3),
                    ),
                    Text(
                      offer.store.unitNumber,
                      style: AppText.s(16, FontWeight.w600, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              BinnoThumb(
                label: offer.thumbLabel,
                size: 76,
                radius: AppDimens.rCardSm,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.format(offer.price),
                style: AppText.display(44, height: 0.95),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('so\'m / ${offer.unit}', style: AppText.meta()),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BinnoDeclaredStockLabel(
                qty: offer.declaredQty,
                unit: offer.unit,
                style: AppText.s(
                  13,
                  FontWeight.w400,
                  color: AppColors.slate700,
                ),
              ),
              Text('·', style: AppText.meta(size: 13)),
              BinnoRatingLabel(
                rating: offer.store.rating,
                reviewCount: offer.store.reviewCount,
                style: AppText.s(
                  13,
                  FontWeight.w400,
                  color: AppColors.slate700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          BinnoFreshnessLabel(offer.freshness),
        ],
      ),
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({required this.offers});

  /// The hero-card offer is excluded from this list to avoid a duplicate.
  final List<MockOffer> offers;

  @override
  Widget build(BuildContext context) {
    final rest = offers;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
      child: Column(
        children: [
          for (var i = 0; i < rest.length; i++) ...[
            if (i != 0) ...[
              const SizedBox(height: 16),
              const BinnoHairline(),
              const SizedBox(height: 16),
            ],
            _OfferRow(offer: rest[i]),
          ],
        ],
      ),
    );
  }
}

class _OfferRow extends StatelessWidget {
  const _OfferRow({required this.offer});

  final MockOffer offer;

  @override
  Widget build(BuildContext context) {
    final store = offer.store;
    final meta = <String>[
      '${Money.qty(offer.declaredQty, offer.unit)} · '
          '${store.isNew ? store.complexBlock : _ratingText(store)}',
      if (store.responseSamples >= 5)
        'odatda ~${store.responseMinutes} daqiqada javob beradi',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BinnoOfferRow(
          thumbLabel: offer.thumbLabel,
          title: store.title,
          verified: store.verified,
          trailingChip: store.isNew
              ? const BinnoPill('YANGI', tone: BinnoPillTone.brandNew)
              : null,
          metaLines: meta,
          badge: offer.freshness == BinnoFreshness.normal
              ? null
              : BinnoFreshnessLabel(offer.freshness),
          price: offer.price,
          priceSub: offer.deliveryFee != null
              ? '+${Money.format(offer.deliveryFee!)} yetkazish'
              : 'olib ketish',
          priceStyle: AppText.s(19, FontWeight.w600),
          dimmed: offer.freshness == BinnoFreshness.expired,
          onTap: () => context.push(AppRoutes.offer),
        ),
        // One owner, one best offer; their other stores collapse.
        if (store == MockData.barakaQurilish)
          Padding(
            padding: const EdgeInsets.only(left: 70, top: 8),
            child: InkWell(
              onTap: () => context.push(AppRoutes.ownerStores),
              child: Text('yana 2 do\'koni →', style: AppText.link()),
            ),
          ),
      ],
    );
  }

  String _ratingText(MockStore store) =>
      '${store.rating.toStringAsFixed(1).replaceAll('.', ',')} ★ '
      '(${store.reviewCount})';
}
