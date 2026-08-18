import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import 'binno_nav.dart';

/// The app shell with the persistent bottom navigation.
///
/// Each tab keeps its own navigation stack: open a product in the
/// catalogue, switch to the profile and back, and the product is still
/// there. Detail screens (offer, order, payment) open on the root
/// navigator and cover the bottom navigation entirely; those flows are
/// one-way and meant to be completed.
class BinnoShell extends StatelessWidget {
  const BinnoShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    // Tapping the active tab again returns to that tab's root.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(color: AppColors.white),
        child: BinnoBottomNav(
          activeIndex: navigationShell.currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}

/// The header block for tab screens; it has no back button.
///
/// A tab root never shows "back": the way out is the bottom navigation.
class BinnoTabHeader extends StatelessWidget {
  const BinnoTabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.display(30, height: 1.1)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 6),
                    Text(subtitle!, style: AppText.meta(size: 13)),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 12), trailing!],
          ],
        ),
      ),
    );
  }
}

/// A profile/settings row.
class BinnoSettingsRow extends StatelessWidget {
  const BinnoSettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.destructive = false,
    this.trailingText,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool destructive;
  final String? trailingText;

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.danger : AppColors.ink;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(AppDimens.rSm),
                ),
                child: Icon(icon, size: 19, color: color),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppText.s(15, FontWeight.w600, color: color),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: AppText.meta()),
                  ],
                ],
              ),
            ),
            if (trailingText != null) ...[
              const SizedBox(width: 12),
              Text(trailingText!, style: AppText.meta()),
            ],
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 22,
              color: AppColors.ink3,
            ),
          ],
        ),
      ),
    );
  }
}
