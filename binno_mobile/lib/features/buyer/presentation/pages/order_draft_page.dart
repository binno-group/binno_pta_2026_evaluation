import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/widgets.dart';

/// 04 · Drafting the order: whitespace leads, the focus is quantity.
///
/// Rule §6.1: `total = goods price + zone-tariff delivery`; both are
/// fixed, so the full total is shown. There is no estimated component.
class OrderDraftPage extends StatefulWidget {
  const OrderDraftPage({super.key, this.fulfillment = 0});

  /// The fulfilment choice made on the offer page is kept here.
  final int fulfillment;

  @override
  State<OrderDraftPage> createState() => _OrderDraftPageState();
}

class _OrderDraftPageState extends State<OrderDraftPage> {
  int _qty = MockData.orderQty;
  late int _fulfillment = widget.fulfillment; // 0 = yetkazish, 1 = olib ketish
  int _buyerType = 1; // 0 = jismoniy, 1 = yuridik

  /// The delivery address, returned by the addresses screen.
  MockAddress _address = MockData.addresses.first;

  static const _offer = MockData.cementMetall;

  int get _goods => _qty * _offer.price;

  // Olib ketishda yetkazish qatori nolga tushadi (§7.2).
  int get _delivery => _fulfillment == 0 ? MockData.deliveryFee : 0;

  int get _total => _goods + _delivery;

  Future<void> _changeAddress() async {
    final result = await context.push<Object?>(AppRoutes.addresses);
    if (!mounted) return;
    if (result is MockAddress) setState(() => _address = result);
  }

  @override
  Widget build(BuildContext context) {
    return BinnoScreen(
      child: Column(
        children: [
          BinnoBackBar(label: _offer.store.title),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 26, 24, 0),
                  child: Column(
                    children: [
                      Text(
                        'QANCHA KERAK',
                        style: AppText.eyebrow(),
                      ),
                      const SizedBox(height: 12),
                      BinnoStepper(
                        value: _qty,
                        unit: _offer.unit,
                        max: _offer.declaredQty,
                        onChanged: (v) => setState(() => _qty = v),
                        hint: 'e\'lon qilingan qoldiq: '
                            '${Money.qty(_offer.declaredQty, _offer.unit)}',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimens.gutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const BinnoHairline(),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          BinnoThumb(label: _offer.thumbLabel),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _offer.productTitle,
                                  style: AppText.s(14, FontWeight.w600),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  Money.perUnit(_offer.price, _offer.unit),
                                  style: AppText.meta(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      BinnoSegmented(
                        options: const ['Yetkazish', 'Olib ketish'],
                        selectedIndex: _fulfillment,
                        onChanged: (v) => setState(() => _fulfillment = v),
                      ),
                      const SizedBox(height: 18),
                      if (_fulfillment == 0)
                        _AddressBlock(
                          address: _address,
                          onChange: _changeAddress,
                        )
                      else
                        Text(
                          'Manzil to\'lovdan keyin ochiladi',
                          style: AppText.meta(size: 13),
                        ),
                      const SizedBox(height: 18),
                      const BinnoHairline(),
                      const SizedBox(height: 18),
                      BinnoSegmented(
                        options: const ['Jismoniy', 'Yuridik'],
                        selectedIndex: _buyerType,
                        onChanged: (v) => setState(() => _buyerType = v),
                      ),
                      if (_buyerType == 1) ...[
                        const SizedBox(height: 14),
                        const BinnoField(
                          label: 'STIR',
                          value: MockData.buyerTin,
                          hint: '9 raqam',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          BinnoFooter(
            topPadding: 18,
            note: 'To\'lov tasdiqdan keyin',
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      _delivery == 0
                          ? Money.format(_goods)
                          : '${Money.format(_goods)} + '
                              '${Money.format(_delivery)} yetkazish',
                      style: AppText.meta(size: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(Money.format(_total), style: AppText.display(26)),
                ],
              ),
              BinnoPrimaryButton(
                label: 'Sotuvchiga yuborish',
                onPressed: () => context.push(AppRoutes.awaiting),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  const _AddressBlock({required this.address, this.onChange});

  final MockAddress address;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(address.line, style: AppText.s(14, FontWeight.w600)),
              const SizedBox(height: 3),
              Text(
                '${address.receiver} · ${MockData.deliveryDate}',
                style: AppText.meta(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onChange,
          child: SizedBox(
            height: 44,
            child: Center(
              child: Text('O\'zgartirish', style: AppText.link()),
            ),
          ),
        ),
      ],
    );
  }
}
