import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/services/phone_caller_service.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 07 · The active order: state stages, **no live map**.
///
/// Rule: no ETA, no moving vehicle, no minute countdown. Just the
/// timeline, the last checkpoint, and its timestamp.
class OrderActivePage extends StatelessWidget {
  const OrderActivePage({super.key});

  /// The phone number unlocks once payment is confirmed (§7.3), so a
  /// real call is placed here.
  Future<void> _call(BuildContext context) async {
    final phone = MockData.metallSavdo.phone;
    if (phone == null) return;

    final ok = await sl<PhoneCallerService>().callDirect(
      phone.replaceAll(' ', ''),
    );
    if (!context.mounted || ok) return;
    binnoSnack(context, 'Qo\'ng\'iroqni boshlab bo\'lmadi: $phone');
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      onNavy: true,
      child: Column(
        children: [
          BinnoNavyHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const BinnoBackBar(
                  label: MockData.orderId,
                  onNavy: true,
                  safeArea: false,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HOZIRGI HOLAT',
                        style: AppText.eyebrow(color: AppColors.onNavyMeta),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Yetkazishga\ntayyorlanmoqda',
                        style: AppText.display(
                          32,
                          color: AppColors.white,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Sotuvchi ${MockData.deliveryDate}ga rejalashtirdi',
                        style: AppText.s(
                          13,
                          FontWeight.w400,
                          color: AppColors.onNavyMeta,
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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 12),
              children: [
                const BinnoTimeline(
                  steps: [
                    BinnoTimelineStep(
                      title: 'Sotuvchi tasdiqladi',
                      state: BinnoStepState.done,
                      trailing: '10:04',
                    ),
                    BinnoTimelineStep(
                      title: 'To\'lov qabul qilindi',
                      subtitle: 'Payme',
                      state: BinnoStepState.done,
                      trailing: '10:12',
                    ),
                    BinnoTimelineStep(
                      title: 'Yetkazishga tayyorlanmoqda',
                      subtitle: 'Pallet yuklanmoqda · 28-iyul, ertalab',
                      state: BinnoStepState.current,
                    ),
                    BinnoTimelineStep(
                      title: 'Yetkazildi',
                      state: BinnoStepState.future,
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                const BinnoHairline(),
                const SizedBox(height: 18),
                BinnoStoreIdentity(
                  storeName: MockData.metallSavdo.title,
                  locationLine: MockData.metallSavdo.phone!,
                  initials: MockData.metallSavdo.initials,
                  trailing: BinnoCircleButton(
                    icon: Icons.call_outlined,
                    size: 48,
                    iconSize: 19,
                    onPressed: () => _call(context),
                  ),
                ),
              ],
            ),
          ),
          BinnoFooter(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'To\'langan · ${Money.qty(MockData.orderQty, "qop")}',
                      style: AppText.meta(size: 13),
                    ),
                  ),
                  Text(
                    Money.format(MockData.totalAmount),
                    style: AppText.display(22),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: BinnoSecondaryButton(
                      label: 'Chat',
                      strong: true,
                      height: AppDimens.hPrimaryCta,
                      onPressed: () => context.push(AppRoutes.chat),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BinnoSecondaryButton(
                      label: 'Muammo bor',
                      height: AppDimens.hPrimaryCta,
                      onPressed: () => context.push(AppRoutes.refund),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // After delivery the flow closes with rating (§8).
              BinnoInlineAction(
                label: 'Yetkazildi — do\'konni baholash',
                filled: false,
                onPressed: () => context.push(AppRoutes.rating),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
