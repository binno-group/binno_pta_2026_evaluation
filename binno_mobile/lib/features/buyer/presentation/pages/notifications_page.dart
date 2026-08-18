import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/theme.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/widgets/binno_chrome.dart';
import '../../../shared/widgets/binno_states.dart';

/// Notifications.
///
/// Rule: this is not a fifth tab; it opens from the bell at the top and
/// via deep links. Each notification leads to its state screen.
///
/// Style: each card has a **decorative colour strip** on the left marking
/// the unread state. It disappears on tap (or on "mark all read").
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  /// Indices of the notifications marked as read.
  final _read = <int>{};

  bool _isUnread(int index) =>
      MockData.notifications[index].unread && !_read.contains(index);

  void _markAllRead(int count) {
    setState(() => _read.addAll(List.generate(count, (i) => i)));
  }

  @override
  Widget build(BuildContext context) {
    final items = MockData.notifications;
    final unread = List.generate(items.length, _isUnread)
        .where((u) => u)
        .length;

    return BinnoScreen(
      background: AppColors.surface,
      child: Column(
        children: [
          _AppBar(
            unread: unread,
            onMarkAll: unread == 0 ? null : () => _markAllRead(items.length),
          ),
          Expanded(
            child: items.isEmpty
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(32, 60, 32, 0),
                    child: BinnoEmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'Bildirishnoma yo\'q',
                      body: 'Buyurtma holati o\'zgarganda va to\'lov '
                          'muddati yaqinlashganda shu yerda xabar beramiz.',
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, i) => _NotificationCard(
                      item: items[i],
                      unread: _isUnread(i),
                      // An opened notification counts as read; the
                      // decorative strip disappears.
                      onOpen: () => setState(() => _read.add(i)),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// The header row: back, the "Bildirishnomalar" title, the done-all icon.
class _AppBar extends StatelessWidget {
  const _AppBar({required this.unread, this.onMarkAll});

  final int unread;
  final VoidCallback? onMarkAll;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 12, 8),
        child: Row(
          children: [
            InkResponse(
              onTap: () => Navigator.of(context).maybePop(),
              radius: 24,
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 26,
                  color: AppColors.navy950,
                ),
              ),
            ),
            const SizedBox(width: 2),
            // The app bar title (§12).
            Expanded(
              child: Text(
                'Bildirishnomalar',
                style: AppText.display(20),
              ),
            ),
            // The done-all icon marks everything as read.
            _DoneAllButton(enabled: onMarkAll != null, onTap: onMarkAll),
          ],
        ),
      ),
    );
  }
}

class _DoneAllButton extends StatelessWidget {
  const _DoneAllButton({required this.enabled, this.onTap});

  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(
          Icons.done_all_rounded,
          size: 22,
          color: enabled ? AppColors.navy950 : AppColors.ink3,
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.unread,
    this.onOpen,
  });

  final MockNotification item;
  final bool unread;
  final VoidCallback? onOpen;

  ({IconData icon, Color color, Color bg, String route}) get _style {
    switch (item.kind) {
      case MockNotificationKind.order:
        return (
          icon: Icons.inventory_2_outlined,
          color: AppColors.navy950,
          bg: AppColors.navy100,
          route: AppRoutes.orderActive,
        );
      case MockNotificationKind.payment:
        return (
          icon: Icons.receipt_long_outlined,
          color: AppColors.warningText,
          bg: AppColors.warningBg,
          route: AppRoutes.payment,
        );
      case MockNotificationKind.refund:
        return (
          icon: Icons.assignment_return_outlined,
          color: AppColors.danger,
          bg: AppColors.dangerBg,
          route: AppRoutes.refundTracker,
        );
      case MockNotificationKind.price:
        return (
          icon: Icons.trending_down_rounded,
          color: AppColors.successText,
          bg: AppColors.successBg,
          route: AppRoutes.searchResults,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final radius = BorderRadius.circular(AppDimens.rCardSm);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: unread ? AppDimens.shadowCard : null,
      ),
      child: Material(
        color: AppColors.white,
        borderRadius: radius,
        child: InkWell(
          onTap: () {
            onOpen?.call();
            context.push(style.route);
          },
          borderRadius: radius,
          child: ClipRRect(
            borderRadius: radius,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // The left colour strip: visible while unread,
                  // transparent once read.
                  AnimatedContainer(
                    duration: AppDimens.motionFast,
                    width: 5,
                    color: unread ? style.color : Colors.transparent,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: style.bg,
                              borderRadius: BorderRadius.circular(
                                AppDimens.rSm,
                              ),
                            ),
                            child: Icon(
                              style.icon,
                              size: 19,
                              color: style.color,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: AppText.s(
                                          14,
                                          unread
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (unread) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 5),
                                        decoration: BoxDecoration(
                                          color: style.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.body,
                                  style: AppText.s(
                                    13,
                                    FontWeight.w400,
                                    height: 1.5,
                                    color: AppColors.ink2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(item.time, style: AppText.note()),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
