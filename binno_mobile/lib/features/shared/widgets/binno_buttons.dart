import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// The primary CTA: 56dp, pill, navy, with a shadow.
///
/// Rule: each screen state has exactly **one** primary action.
class BinnoPrimaryButton extends StatelessWidget {
  const BinnoPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.height = AppDimens.hPrimaryCta,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && onPressed != null;

    return Material(
      color: isEnabled ? AppColors.navy950 : AppColors.surface2,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            boxShadow: isEnabled ? AppDimens.shadowPrimary : null,
            color: isEnabled ? AppColors.navy950 : AppColors.surface2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isEnabled ? AppColors.white : AppColors.ink3,
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.button(
                    color: isEnabled ? AppColors.white : AppColors.ink3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The secondary CTA: 52dp, pill, a 1.5px border.
///
/// With [destructive] the text goes red while the border stays neutral;
/// that is a "risky but normal" action (cancel, money did not arrive).
class BinnoSecondaryButton extends StatelessWidget {
  const BinnoSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.destructive = false,
    this.strong = false,
    this.height = AppDimens.hSecondaryCta,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Red text (the border stays neutral).
  final bool destructive;

  /// A dark navy border with navy text.
  final bool strong;

  final double height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final borderColor = strong ? AppColors.navy950 : AppColors.border15;
    final textColor = destructive
        ? AppColors.danger
        : strong
        ? AppColors.navy950
        : AppColors.slate700;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            border: Border.all(
              color: borderColor,
              width: AppDimens.bwControl,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: textColor),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.s(14, FontWeight.w600, color: textColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The circular icon button (chat, call, +/−).
class BinnoCircleButton extends StatelessWidget {
  const BinnoCircleButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = AppDimens.circleControl,
    this.filled = false,
    this.iconSize = 20,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool filled;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.navy950 : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: filled
                ? null
                : Border.all(
                    color: AppColors.border16,
                    width: AppDimens.bwControl,
                  ),
          ),
          child: Icon(
            icon,
            size: iconSize,
            color: filled ? AppColors.white : AppColors.navy950,
          ),
        ),
      ),
    );
  }
}

/// The floating pill button (e.g. "Filtrlar").
class BinnoFloatingPill extends StatelessWidget {
  const BinnoFloatingPill({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy950,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: AppDimens.hSegment,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: AppColors.navy950,
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            boxShadow: AppDimens.shadowPill,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.white),
                const SizedBox(width: 10),
              ],
              Text(label, style: AppText.s(14, FontWeight.w600,
                  color: AppColors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small filled pill action used inside cards ("Yangilash", "O'tish").
class BinnoInlineAction extends StatelessWidget {
  const BinnoInlineAction({
    super.key,
    required this.label,
    this.onPressed,
    this.filled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (!filled) {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rSm),
        child: Container(
          height: AppDimens.hControl,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label, style: AppText.link()),
        ),
      );
    }

    return Material(
      color: AppColors.navy950,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: AppDimens.hControl,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppText.s(13, FontWeight.w600, color: AppColors.white),
          ),
        ),
      ),
    );
  }
}
