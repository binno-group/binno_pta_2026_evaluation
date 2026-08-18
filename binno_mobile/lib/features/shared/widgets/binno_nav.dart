import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

class BinnoNavItem {
  const BinnoNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The bottom navigation. No border line, targets ≥48dp.
///
/// Tabs: Home · Catalogue · Orders · Profile. Notifications are not a
/// fifth tab; they open from the bell at the top and deep links.
class BinnoBottomNav extends StatelessWidget {
  const BinnoBottomNav({
    super.key,
    required this.activeIndex,
    this.onTap,
    this.items = tabs,
  });

  final List<BinnoNavItem> items;
  final int activeIndex;
  final ValueChanged<int>? onTap;

  static const tabs = [
    BinnoNavItem(icon: Icons.home_rounded, label: 'Bosh sahifa'),
    BinnoNavItem(icon: Icons.grid_view_rounded, label: 'Katalog'),
    BinnoNavItem(icon: Icons.receipt_long_rounded, label: 'Buyurtmalar'),
    BinnoNavItem(icon: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              // Expanded, so it still fits on 360dp screens.
              Expanded(
                child: _NavButton(
                  item: items[i],
                  active: i == activeIndex,
                  onTap: onTap == null ? null : () => onTap!(i),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.active, this.onTap});

  final BinnoNavItem item;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.navy950 : AppColors.ink3;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      // A min height instead of a fixed one: no 2px overflow even at a
      // 1.3x text scale. The active indicator line was dropped; activity
      // is shown with colour.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.s(
                12,
                active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.navy950 : AppColors.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
