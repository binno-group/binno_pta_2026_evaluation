import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 08 · The refund request: the focus is the amount and evidence photos.
///
/// Language rule (§6.3): this is **the seller's refund obligation**, not a
/// platform guarantee; BINNO holds no money and technically cannot refund.
class RefundRequestPage extends StatefulWidget {
  const RefundRequestPage({super.key});

  @override
  State<RefundRequestPage> createState() => _RefundRequestPageState();
}

class _RefundRequestPageState extends State<RefundRequestPage> {
  /// The attached evidence photos, decisive in a dispute.
  int _photos = 2;

  static const _maxPhotos = 4;

  int _qty = MockData.refundQty;
  int _reason = 0;

  static const _reasons = [
    'Miqdor to\'liq kelmadi',
    'Tavsifga mos emas',
    'Yetkazilmadi',
  ];

  int get _amount => _qty * MockData.cementMetall.price;

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          const BinnoBackBar(
            label: '${MockData.orderId} · yetkazildi 28-iyul',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
              children: [
                BinnoAmountBlock(
                  eyebrow: 'Qaytariladigan summa',
                  amount: _amount,
                  note: '$_qty qop × '
                      '${Money.format(MockData.cementMetall.price)} · '
                      '${MockData.orderQty} qopdan',
                ),
                const SizedBox(height: 22),
                BinnoStepper(
                  value: _qty,
                  unit: 'qop',
                  max: MockData.orderQty,
                  valueSize: 34,
                  centered: false,
                  onChanged: (v) => setState(() => _qty = v),
                ),
                const SizedBox(height: 26),
                const BinnoHairline(),
                const SizedBox(height: 12),
                Text(
                  'SABAB',
                  style: AppText.eyebrow(weight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                BinnoChoiceChips(
                  options: _reasons,
                  selectedIndex: _reason,
                  onChanged: (v) => setState(() => _reason = v),
                ),
                const SizedBox(height: 22),
                Text(
                  'DALIL',
                  style: AppText.eyebrow(weight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    for (var i = 0; i < _photos; i++) ...[
                      if (i != 0) const SizedBox(width: 10),
                      const Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BinnoImageSlot(
                            radius: AppDimens.rTile,
                            dark: false,
                          ),
                        ),
                      ),
                    ],
                    if (_photos < _maxPhotos) ...[
                      if (_photos != 0) const SizedBox(width: 10),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: BinnoAddTile(
                            onTap: () => setState(() => _photos++),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          BinnoFooter(
            note: 'So\'rov sotuvchiga yuboriladi. 48 soat ichida javob '
                'bo\'lmasa, BINNO ko\'rib chiqishga o\'tadi.',
            children: [
              BinnoPrimaryButton(
                label: 'So\'rovni yuborish',
                onPressed: () => context.push(AppRoutes.refundTracker),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
