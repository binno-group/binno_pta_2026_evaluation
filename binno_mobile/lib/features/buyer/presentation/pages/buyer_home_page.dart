import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/filters_nav.dart';
import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// The home page.
///
/// Discovery always starts **from the address** (§4.1), which is why the
/// delivery address sits inside the navy header, above even the search.
class BuyerHomePage extends StatelessWidget {
  const BuyerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      onNavy: true,
      background: AppColors.surface,
      child: ListView(
        padding: EdgeInsets.zero,
        children: const [
          _Header(),
          SizedBox(height: 18),
          _SearchRow(),
          SizedBox(height: 18),
          _CategoryRow(),
          SizedBox(height: 24),
          _FreshSection(),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppDimens.rHeader),
      ),
      child: Container(
        width: double.infinity,
        color: AppColors.navy950,
        child: Stack(
          children: [
            // Dekorativ doira — navy ustida bir oz ochroq.
            Positioned(
              right: -70,
              top: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 6, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SvgPicture.asset(AppSvgs.binnoWhite, height: 26),
                        const _NotificationBell(),
                      ],
                    ),
                    const SizedBox(height: 18),
                    RichText(
                      text: TextSpan(
                        style: AppText.display(
                          34,
                          color: AppColors.white,
                          height: 1.12,
                        ),
                        children: [
                          const TextSpan(text: 'Qurilishni\n'),
                          TextSpan(
                            text: 'oson boshlang',
                            style: AppText.display(
                              34,
                              color: AppColors.onNavy3,
                              height: 1.12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Kerakli materialni toping,\neng yaxshi taklifni oling',
                      style: AppText.s(
                        13,
                        FontWeight.w400,
                        color: AppColors.onNavy2,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _AddressCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => context.push(AppRoutes.notifications),
      radius: 26,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 21,
                color: AppColors.white,
              ),
            ),
            Positioned(
              top: 9,
              right: 9,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  // Orange as a brand moment, not a status colour.
                  color: AppColors.orange,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.navy950, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The delivery address card, full width under the header.
class _AddressCard extends StatefulWidget {
  const _AddressCard();

  @override
  State<_AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<_AddressCard> {
  MockAddress _address = MockData.addresses.first;

  Future<void> _pick() async {
    final result = await context.push<Object?>(AppRoutes.addresses);
    if (!mounted) return;
    if (result is MockAddress) setState(() => _address = result);
  }

  @override
  Widget build(BuildContext context) {
    final address = _address;

    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppDimens.rCardSm),
      child: InkWell(
        onTap: _pick,
        borderRadius: BorderRadius.circular(AppDimens.rCardSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rCardSm),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.place_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YETKAZISH MANZILI',
                      style: AppText.eyebrow(
                        color: AppColors.onNavy3,
                        size: 10,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      address.line,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.s(
                        15,
                        FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.onNavy2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  const _SearchRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
      child: Row(
        children: [
          Expanded(
            child: BinnoSearchField(
              placeholder: 'Sement, armatura, g\'isht…',
              onTap: () => context.push(AppRoutes.search),
            ),
          ),
          const SizedBox(width: 10),
          _FilterButton(onTap: () => openFiltersThenResults(context)),
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

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories.take(4).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
      child: Row(
        children: [
          for (var i = 0; i < categories.length; i++) ...[
            if (i != 0) const SizedBox(width: 10),
            Expanded(
              child: BinnoCategoryCard(
                label: categories[i].name,
                asset: categories[i].asset,
                onTap: () => context.push(AppRoutes.searchResults),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FreshSection extends StatelessWidget {
  const _FreshSection();

  @override
  Widget build(BuildContext context) {
    const offers = [MockData.cementMetall, MockData.armaturaBaraka];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  'Bugun yangilangan',
                  style: AppText.display(22),
                ),
              ),
              InkWell(
                onTap: () => context.push(AppRoutes.searchResults),
                borderRadius: BorderRadius.circular(AppDimens.rPill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Text('Barchasi', style: AppText.link()),
                      const SizedBox(width: 2),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: AppColors.navy700,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < offers.length; i++) ...[
          if (i != 0) const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.gutter),
            child: _OfferCard(offer: offers[i], compact: i != 0),
          ),
        ],
      ],
    );
  }
}

class _OfferCard extends StatefulWidget {
  const _OfferCard({required this.offer, this.compact = false});

  final MockOffer offer;
  final bool compact;

  @override
  State<_OfferCard> createState() => _OfferCardState();
}

class _OfferCardState extends State<_OfferCard> {
  /// Price watching: local state, not persisted in the mock stage.
  bool _watched = false;

  void _toggleWatch() {
    setState(() => _watched = !_watched);
    binnoSnack(
      context,
      _watched
          ? 'Kuzatuvga qo\'shildi — narx o\'zgarsa xabar beramiz'
          : 'Kuzatuvdan olib tashlandi',
    );
  }

  @override
  Widget build(BuildContext context) {
    final offer = widget.offer;
    final compact = widget.compact;

    return BinnoCard(
      onTap: () => context.push(AppRoutes.offer),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BinnoProductImage(
            thumbLabel: offer.thumbLabel,
            asset: MockData.productAsset(offer.thumbLabel),
            size: compact ? 60 : 88,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!compact && offer.updatedLabel != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: BinnoPill(
                      offer.updatedLabel!,
                      tone: BinnoPillTone.success,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  offer.productTitle,
                  style: AppText.rowTitle(),
                ),
                const SizedBox(height: 3),
                Text(
                  '${offer.store.title} · '
                  '${offer.pickupAvailable && offer.deliveryFee == null
                      ? 'olib ketish'
                      : '${(offer.distanceKm ?? 0).toStringAsFixed(1)
                          .replaceAll('.', ',')} km'}',
                  style: AppText.meta(),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Money.format(offer.price),
                            style: AppText.display(compact ? 18 : 21),
                          ),
                          const SizedBox(width: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              'so\'m / ${offer.unit}',
                              style: AppText.note(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (compact)
                      InkResponse(
                        onTap: _toggleWatch,
                        radius: 22,
                        child: SizedBox(
                          width: 36,
                          height: 36,
                          child: Icon(
                            _watched
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            size: 21,
                            color: _watched
                                ? AppColors.navy950
                                : AppColors.ink2,
                          ),
                        ),
                      ),
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
