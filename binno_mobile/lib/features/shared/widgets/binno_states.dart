import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// An image slot. The mock stage has no real photos, so a placeholder shows.
class BinnoImageSlot extends StatelessWidget {
  const BinnoImageSlot({
    super.key,
    this.placeholder,
    this.height,
    this.width,
    this.radius = AppDimens.rImage,
    this.dark = true,
  });

  final String? placeholder;
  final double? height;
  final double? width;
  final double radius;

  /// `true` for a navy background (hero images), `false` for grey.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? AppColors.navy950 : AppColors.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: placeholder == null
          ? Icon(
              Icons.image_outlined,
              size: 26,
              color: dark ? AppColors.onNavyMeta : AppColors.ink3,
            )
          : Text(
              placeholder!,
              textAlign: TextAlign.center,
              style: AppText.s(
                12,
                FontWeight.w500,
                color: dark ? AppColors.onNavyMeta : AppColors.ink3,
              ),
            ),
    );
  }
}

/// The add-image tile (dashed).
class BinnoAddTile extends StatelessWidget {
  const BinnoAddTile({super.key, this.size = 96, this.onTap});

  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rTile),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.rTile),
          border: Border.all(
            color: AppColors.border16,
            width: AppDimens.bwControl,
          ),
        ),
        child: const Icon(Icons.add_rounded, size: 24, color: AppColors.ink3),
      ),
    );
  }
}

enum BinnoBannerTone { info, warning, danger, success }

/// The warning/error banner: an icon plus text.
class BinnoBanner extends StatelessWidget {
  const BinnoBanner({
    super.key,
    required this.text,
    this.tone = BinnoBannerTone.info,
    this.title,
    this.icon,
  });

  final String text;
  final BinnoBannerTone tone;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData defaultIcon;

    switch (tone) {
      case BinnoBannerTone.info:
        bg = AppColors.navy50;
        fg = AppColors.ink;
        defaultIcon = Icons.info_outline_rounded;
      case BinnoBannerTone.warning:
        bg = AppColors.warningBg2;
        fg = AppColors.warningText;
        defaultIcon = Icons.warning_amber_rounded;
      case BinnoBannerTone.danger:
        bg = AppColors.dangerBg;
        fg = AppColors.danger;
        defaultIcon = Icons.error_outline_rounded;
      case BinnoBannerTone.success:
        bg = AppColors.successBg;
        fg = AppColors.successText;
        defaultIcon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rThumb),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon ?? defaultIcon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: AppText.s(14, FontWeight.w600, color: fg),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  text,
                  style: AppText.s(
                    12,
                    FontWeight.w400,
                    color: title != null ? AppColors.ink : fg,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The empty/error state.
///
/// The structure is mandatory: **WHAT, WHY, WHAT TO DO**.
class BinnoEmptyState extends StatelessWidget {
  const BinnoEmptyState({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.search_rounded,
    this.iconBg = AppColors.surface2,
    this.iconColor = AppColors.ink2,
    this.iconSize = 88,
  });

  /// The WHAT: short, up to two lines.
  final String title;

  /// The WHY plus WHAT TO DO.
  final String body;

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, size: iconSize * 0.34, color: iconColor),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.display(26, height: 1.15),
        ),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center, style: AppText.body()),
      ],
    );
  }
}

/// The soft info card (`#F3F6FA`, radius 22).
class BinnoSoftCard extends StatelessWidget {
  const BinnoSoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 18, 20, 18),
    this.color = AppColors.navy50,
    this.radius = AppDimens.rCard,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}
