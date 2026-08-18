import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 14 · The offline / rule-blocked state.
///
/// Cached prices are **marked stale** and order creation closes: the
/// platform claims nothing it does not know. The cause and the way out are
/// stated plainly (WHAT, WHY, WHAT TO DO).
class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  /// Connectivity is back, so the blocked state unlocks.
  bool _online = false;

  /// A connectivity check is in progress.
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    // In the mock stage the network check is simulated with this delay.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _checking = false;
      _online = true;
    });
    binnoSnack(context, 'Ulanish tiklandi — narxlar yangilandi');
  }

  @override
  Widget build(BuildContext context) {
    const cached = [MockData.cementMetall, MockData.cementBaraka];

    return BinnoScreen(
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: BinnoBanner(
                tone: _online
                    ? BinnoBannerTone.success
                    : BinnoBannerTone.warning,
                text: _online
                    ? 'Ulanish tiklandi — narxlar yangi'
                    : 'Internet yo\'q — keshdagi ma\'lumot ko\'rsatilmoqda',
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              children: [
                Text('M400 sement', style: AppText.display(24)),
                const SizedBox(height: 14),
                for (var i = 0; i < cached.length; i++) ...[
                  if (i != 0) ...[
                    const SizedBox(height: 14),
                    const BinnoHairline(),
                    const SizedBox(height: 14),
                  ],
                  BinnoOfferRow(
                    thumbLabel: cached[i].thumbLabel,
                    title: cached[i].store.title,
                    // Once connectivity returns, prices stop being
                    // "stale" and the dimming is removed.
                    dimmed: !_online,
                    metaLines: [
                      'E\'lon qilingan qoldiq: '
                          '${Money.qty(cached[i].declaredQty, cached[i].unit)}',
                    ],
                    badge: i == 0 && !_online
                        ? const BinnoPill(
                            'Narx eskirgan bo\'lishi mumkin',
                            tone: BinnoPillTone.warning,
                          )
                        : null,
                    price: cached[i].price,
                  ),
                ],
                const SizedBox(height: 28),
                const BinnoSoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buyurtma yaratish vaqtincha yopiq',
                        style: TextStyle(
                          fontFamily: AppText.family,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Narxni tasdiqlash uchun ulanish kerak. Internet '
                        'qaytganda buyurtma yaratish avtomatik ochiladi.',
                        style: TextStyle(
                          fontFamily: AppText.family,
                          fontSize: 12,
                          height: 1.55,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BinnoFooter(
            children: [
              // A rule-blocked state: the primary CTA is disabled, no shadow.
              BinnoPrimaryButton(
                label: 'Buyurtma yaratish',
                enabled: _online,
                onPressed: _online
                    ? () => context.push(AppRoutes.orderDraft)
                    : null,
              ),
              BinnoSecondaryButton(
                label: _checking ? 'Tekshirilmoqda…' : 'Qayta urinish',
                icon: Icons.refresh_rounded,
                onPressed: _checking || _online ? null : _retry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
