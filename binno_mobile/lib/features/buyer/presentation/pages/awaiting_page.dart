import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 06 · Awaiting confirmation: whitespace leads, **no ETA**.
///
/// Rule §5.2: the confirmation window is 4 **working** hours. The deadline
/// is given as honest text ("the seller answers by 09:00 tomorrow"); no
/// fake-urgency countdown.
class AwaitingPage extends StatelessWidget {
  const AwaitingPage({super.key});

  /// Cancelling is irreversible, so confirmation is requested.
  Future<void> _confirmCancel(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.rCard),
        ),
        title: Text('Buyurtmani bekor qilasizmi?', style: AppText.display(22)),
        content: Text(
          'So\'rov sotuvchidan olib tashlanadi. To\'lov qilinmagani uchun '
          'hech qanday jarima yo\'q.',
          style: AppText.body(size: 14),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              'Kutaman',
              style: AppText.s(14, FontWeight.w600, color: AppColors.ink2),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              'Bekor qilish',
              style: AppText.s(14, FontWeight.w600, color: AppColors.danger),
            ),
          ),
        ],
      ),
    );

    if (result != true || !context.mounted) return;
    binnoSnack(context, 'Buyurtma bekor qilindi');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          const BinnoBackBar(label: '${MockData.orderId} · 25-iyul, 09:38'),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 46, 24, 0),
                  child: Column(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.warningBadgeBg,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.warningBorder,
                            width: AppDimens.bwControl,
                          ),
                        ),
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppColors.warning,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Sotuvchi tasdiqlashini\nkutmoqda',
                        textAlign: TextAlign.center,
                        style: AppText.display(28, height: 1.12),
                      ),
                      const SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Qoldiq va yetkazish sanasi tekshirilmoqda. '
                          '${MockData.metallSavdo.name} odatda '
                          '~${MockData.metallSavdo.responseMinutes} daqiqada '
                          'javob beradi. To\'lov hozircha talab qilinmaydi.',
                          textAlign: TextAlign.center,
                          style: AppText.body(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // An honest deadline, counted in working hours (§5.2).
                      Text(
                        'Sotuvchi ertaga 09:00 gacha javob beradi',
                        textAlign: TextAlign.center,
                        style: AppText.s(
                          13,
                          FontWeight.w600,
                          color: AppColors.warningText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.gutter,
                  ),
                  child: Column(
                    children: [
                      const BinnoHairline(),
                      const SizedBox(height: 18),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const BinnoThumb(label: 'M400'),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'M400 sement · '
                                  '${Money.qty(MockData.orderQty, "qop")}',
                                  style: AppText.s(14, FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${MockData.deliveryDate} · '
                                  '${MockData.buyerAddress}',
                                  style: AppText.meta(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            Money.format(MockData.totalAmount),
                            style: AppText.display(17),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BinnoFooter(
            note: 'Sotuvchi tasdiqlagach to\'lov varaqasi ochiladi',
            children: [
              // The mock stage shows both branches: confirm leads to
              // payment, decline to alternative offers (§5.2).
              BinnoPrimaryButton(
                label: 'Sotuvchi tasdiqladi — to\'lovga o\'tish',
                onPressed: () => context.push(AppRoutes.payment),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: BinnoSecondaryButton(
                      label: 'Chatda so\'rash',
                      strong: true,
                      height: AppDimens.hPrimaryCta,
                      onPressed: () => context.push(AppRoutes.chat),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: BinnoSecondaryButton(
                      label: 'Bekor qilish',
                      destructive: true,
                      height: AppDimens.hPrimaryCta,
                      onPressed: () => _confirmCancel(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              BinnoInlineAction(
                label: 'Sotuvchi tasdiqlamadi — muqobillarni ko\'rish',
                filled: false,
                onPressed: () => context.push(AppRoutes.alternatives),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
