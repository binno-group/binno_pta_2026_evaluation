import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 03 · The offer page: the photo leads, the white sheet rises over it.
///
/// The price is fixed: no bargaining, no "negotiable" label.
class OfferDetailPage extends StatefulWidget {
  const OfferDetailPage({super.key});

  @override
  State<OfferDetailPage> createState() => _OfferDetailPageState();
}

class _OfferDetailPageState extends State<OfferDetailPage> {
  int _fulfillment = 0; // 0 = yetkazish, 1 = olib ketish

  @override
  Widget build(BuildContext context) {
    const offer = MockData.cementMetall;

    return BinnoScreen(
      onNavy: true,
      background: AppColors.navy950,
      child: Stack(
        children: [
          Positioned(top: 0, left: 0, right: 0, height: 330, child: _PhotoHero()),
          Column(
            children: [
              // Varaq surat ustiga 38px chiqadi.
              const SizedBox(height: 292),
              Expanded(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppDimens.rSheet),
                ),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(24, 26, 24, 8),
                      children: [
                        _TitleRow(),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            BinnoFreshnessLabel(
                              offer.freshness,
                              freshText: 'Bugun 08:20 da yangilangan',
                            ),
                            const BinnoPickupBadge(),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const _DeclaredStockCard(),
                        const SizedBox(height: 16),
                        BinnoStoreIdentity(
                          storeName: offer.store.name,
                          locationLine:
                              '${offer.store.locationChain} · '
                              '${offer.store.rating.toStringAsFixed(1)
                                  .replaceAll('.', ',')} ★',
                          verified: offer.store.verified,
                          initials: offer.store.initials,
                          trailing: InkWell(
                            onTap: () => context.push(AppRoutes.store),
                            child: Text('Do\'kon', style: AppText.link()),
                          ),
                        ),
                        const SizedBox(height: 16),
                        _FulfillmentPicker(
                          selected: _fulfillment,
                          onChanged: (v) => setState(() => _fulfillment = v),
                        ),
                      ],
                    ),
                  ),
                  BinnoFooter(
                    note: 'Buyurtma sotuvchi tasdiqlagandan keyin '
                        'kuchga kiradi',
                    children: [
                      Row(
                        children: [
                          BinnoCircleButton(
                            icon: Icons.chat_bubble_outline_rounded,
                            size: 56,
                            onPressed: () => context.push(AppRoutes.chat),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: BinnoPrimaryButton(
                              label: 'Buyurtma yaratish',
                              onPressed: () => context.push(
                                AppRoutes.orderDraft,
                                extra: _fulfillment,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 330,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const BinnoImageSlot(
            placeholder: 'M400 qop · studio surat',
            radius: 0,
          ),
          // The scrim keeps the status bar and nav buttons readable.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF09111F).withValues(alpha: 0.6),
                  const Color(0xFF09111F).withValues(alpha: 0),
                ],
                stops: const [0, 0.38],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _ScrimButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  _ScrimButton(
                    icon: Icons.ios_share_rounded,
                    onTap: () async {
                      await Clipboard.setData(
                        const ClipboardData(
                          text: 'https://binno.uz/o/48211',
                        ),
                      );
                      if (!context.mounted) return;
                      binnoSnack(context, 'Havola nusxalandi: binno.uz/o/48211');
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScrimButton extends StatelessWidget {
  const _ScrimButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF09111F).withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: AppColors.white),
      ),
    );
  }
}

class _TitleRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const offer = MockData.cementMetall;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('M400 sement', style: AppText.display(27, height: 1.1)),
              Text('50 kg qop', style: AppText.display(27, height: 1.1)),
              const SizedBox(height: 6),
              Text('Bekobod zavodi · PC 400-D20', style: AppText.meta()),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(Money.format(offer.price), style: AppText.display(25)),
            Text('so\'m / ${offer.unit}', style: AppText.note()),
          ],
        ),
      ],
    );
  }
}

class _DeclaredStockCard extends StatelessWidget {
  const _DeclaredStockCard();

  @override
  Widget build(BuildContext context) {
    return BinnoSoftCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'E\'LON QILINGAN QOLDIQ',
                  style: AppText.eyebrow(size: 11),
                ),
                const SizedBox(height: 4),
                // Rule §3.2: stock is the seller's claim and needs confirmation.
                Text('tasdiqlanishi kerak', style: AppText.meta(size: 13)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${MockData.cementMetall.declaredQty}',
                style: AppText.display(34),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('qop', style: AppText.meta()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FulfillmentPicker extends StatelessWidget {
  const _FulfillmentPicker({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: BinnoSelectableBox(
            selected: selected == 0,
            onTap: () => onChanged(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Yetkazish', style: AppText.s(13, FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  Money.som(MockData.deliveryFee),
                  style: AppText.meta(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: BinnoSelectableBox(
            selected: selected == 1,
            onTap: () => onChanged(1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Olib ketaman', style: AppText.s(13, FontWeight.w600)),
                const SizedBox(height: 4),
                // The address unlocks once payment is confirmed (§7.2).
                Text('1-darvoza', style: AppText.meta()),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
