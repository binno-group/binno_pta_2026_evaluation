import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/helpers/money.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_inputs.dart';
import '../../../shared/widgets/binno_labels.dart';
import '../../../shared/widgets/binno_shell.dart';
import '../../../shared/widgets/binno_states.dart';
import '../../../shared/widgets/binno_store.dart';

/// The orders tab; each order leads to its own state screen.
///
/// The state machine (§5.1) surfaces here in the UI: waiting, payment,
/// preparing, refund, closed.
class BuyerOrdersPage extends StatefulWidget {
  const BuyerOrdersPage({super.key});

  @override
  State<BuyerOrdersPage> createState() => _BuyerOrdersPageState();
}

class _BuyerOrdersPageState extends State<BuyerOrdersPage> {
  int _filter = 0;

  @override
  Widget build(BuildContext context) {
    final orders = MockData.buyerOrders
        .where((o) => _filter == 0 ? o.isActive : !o.isActive)
        .toList();

    return BinnoScreen(
      child: Column(
        children: [
          const BinnoTabHeader(title: 'Buyurtmalar'),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
            child: BinnoSegmented(
              options: const ['Faol', 'Yakunlangan'],
              selectedIndex: _filter,
              onChanged: (v) => setState(() => _filter = v),
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(32, 60, 32, 0),
                    child: BinnoEmptyState(
                      icon: Icons.receipt_long_rounded,
                      title: 'Bu yerda hozircha\nbo\'sh',
                      body: 'Yakunlangan buyurtmalar shu ro\'yxatga tushadi. '
                          'Katalogdan taklif tanlab boshlang.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    itemCount: orders.length,
                    separatorBuilder: (context, index) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: BinnoHairline(),
                    ),
                    itemBuilder: (context, i) => _OrderRow(order: orders[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _OrderRow extends StatelessWidget {
  const _OrderRow({required this.order});

  final MockOrderSummary order;

  /// State to screen. Each order opens on the screen matching its state.
  String get _route {
    switch (order.state) {
      case MockOrderState.awaitingConfirmation:
        return AppRoutes.awaiting;
      case MockOrderState.awaitingPayment:
        return AppRoutes.payment;
      case MockOrderState.preparing:
      case MockOrderState.delivering:
        return AppRoutes.orderActive;
      case MockOrderState.refund:
        return AppRoutes.refundTracker;
      case MockOrderState.closed:
        return AppRoutes.rating;
    }
  }

  Widget get _statusPill {
    switch (order.state) {
      case MockOrderState.awaitingConfirmation:
        return const BinnoPill(
          'Sotuvchi tasdig\'ini kutmoqda',
          tone: BinnoPillTone.warning,
        );
      case MockOrderState.awaitingPayment:
        return const BinnoPill(
          'To\'lov kutilmoqda',
          tone: BinnoPillTone.warning,
        );
      case MockOrderState.preparing:
        return const BinnoPill(
          'Yetkazishga tayyorlanmoqda',
          tone: BinnoPillTone.neutral,
        );
      case MockOrderState.delivering:
        return const BinnoPill('Yo\'lda', tone: BinnoPillTone.neutral);
      case MockOrderState.refund:
        return const BinnoPill(
          'Qaytarish · muddat o\'tdi',
          tone: BinnoPillTone.danger,
        );
      case MockOrderState.closed:
        return const BinnoPill('Yopildi', tone: BinnoPillTone.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(_route),
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BinnoThumb(label: order.thumbLabel),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        order.product,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.rowTitle(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(order.id, style: AppText.meta(size: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(order.storeTitle, style: AppText.meta()),
                const SizedBox(height: 2),
                Text(order.dateLabel, style: AppText.meta()),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _statusPill,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Money.format(order.total),
                      style: AppText.display(17),
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
