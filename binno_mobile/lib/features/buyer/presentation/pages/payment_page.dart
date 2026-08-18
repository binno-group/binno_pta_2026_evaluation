import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 05 · Payment: typography leads, the focus is the amount.
///
/// **No escrow.** Money goes straight to the seller's account; "funds
/// protected" wording, shield icons, and guarantee vaults are forbidden.
class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  /// Consent to the payment terms; the CTA stays locked without it.
  bool _consent = true;

  int _method = 0;

  static const _methods = [
    _PaymentMethod('Payme', 'Ilovada tasdiqlaysiz', AppColors.payme),
    _PaymentMethod('Click', 'Click Up yoki USSD', AppColors.click),
    _PaymentMethod('Paynet', 'Ilova yoki terminal orqali', AppColors.paynet),
  ];

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      onNavy: true,
      background: AppColors.navy950,
      child: Column(
        children: [
          const BinnoBackBar(onNavy: true),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.successDot,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 12,
                        color: AppColors.successInk,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sotuvchi tasdiqladi · '
                      '${Money.qty(MockData.orderQty, "qop")} mavjud',
                      style: AppText.s(
                        13,
                        FontWeight.w600,
                        color: AppColors.onNavySuccess,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const BinnoAmountBlock(
                  eyebrow: 'To\'lanadigan summa',
                  amount: MockData.totalAmount,
                  size: 52,
                  onNavy: true,
                ),
                const SizedBox(height: 8),
                Text(
                  '${Money.format(MockData.goodsAmount)} mahsulot · '
                  '${Money.format(MockData.deliveryFee)} yetkazish',
                  style: AppText.s(
                    13,
                    FontWeight.w400,
                    color: AppColors.onNavyMeta,
                    height: 1.5,
                  ),
                ),
                Text(
                  'To\'lov to\'g\'ridan-to\'g\'ri sotuvchi hisobiga o\'tadi',
                  style: AppText.s(
                    13,
                    FontWeight.w400,
                    color: AppColors.onNavyMeta,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
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
                        Text('TO\'LOV TIZIMI', style: AppText.eyebrow()),
                        const SizedBox(height: 14),
                        for (var i = 0; i < _methods.length; i++) ...[
                          if (i != 0) const SizedBox(height: 10),
                          _MethodRow(
                            method: _methods[i],
                            selected: i == _method,
                            onTap: () => setState(() => _method = i),
                          ),
                        ],
                        const SizedBox(height: 18),
                        InkWell(
                          onTap: () =>
                              setState(() => _consent = !_consent),
                          borderRadius: BorderRadius.circular(
                            AppDimens.rThumb,
                          ),
                          child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                color: _consent
                                    ? AppColors.navy950
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(
                                  color: _consent
                                      ? AppColors.navy950
                                      : AppColors.border16,
                                  width: 2,
                                ),
                              ),
                              child: _consent
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: AppColors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'BINNO karta ma\'lumotlarini saqlamaydi — '
                                'to\'lov tanlangan tizim ilovasida amalga '
                                'oshiriladi. Qaytarishni sotuvchi shu tizim '
                                'orqali bajaradi.',
                                style: AppText.s(
                                  12,
                                  FontWeight.w400,
                                  color: AppColors.ink2,
                                  height: 1.55,
                                ),
                              ),
                            ),
                          ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  BinnoFooter(
                    note: _consent
                        ? 'Davom etish bilan shartlarga rozilik bildirasiz'
                        : 'To\'lovni davom ettirish uchun shartlarni '
                              'tasdiqlang',
                    children: [
                      BinnoPrimaryButton(
                        label: 'To\'lash',
                        enabled: _consent,
                        onPressed: _consent
                            ? () => context.push(AppRoutes.orderActive)
                            : null,
                      ),
                    ],
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

class _PaymentMethod {
  const _PaymentMethod(this.name, this.subtitle, this.color);

  final String name;
  final String subtitle;
  final Color color;
}

class _MethodRow extends StatelessWidget {
  const _MethodRow({
    required this.method,
    required this.selected,
    this.onTap,
  });

  final _PaymentMethod method;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return BinnoSelectableBox(
      selected: selected,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: method.color,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              method.name.toLowerCase(),
              style: AppText.display(10, color: AppColors.white),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(method.name, style: AppText.rowTitle()),
                const SizedBox(height: 2),
                Text(method.subtitle, style: AppText.meta()),
              ],
            ),
          ),
          const SizedBox(width: 12),
          BinnoRadioDot(selected: selected),
        ],
      ),
    );
  }
}
