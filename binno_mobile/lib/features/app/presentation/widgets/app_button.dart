import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// The app's single button type.
///
/// Three looks: `primary` (filled navy), `secondary` (outlined), `text`
/// (text only). The press effect (`overlayColor`) comes from the app
/// theme, so every button feels the same: calm and clear.
enum AppButtonKind { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.kind = AppButtonKind.primary,
    this.icon,
    this.expand = true,
    this.height,
    this.destructive = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.height,
    this.destructive = false,
  }) : kind = AppButtonKind.secondary;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.destructive = false,
  }) : kind = AppButtonKind.text,
       expand = false,
       height = null;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final bool expand;
  final double? height;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final h =
        height ??
        (kind == AppButtonKind.text
            ? AppDimens.hControl
            : AppDimens.hPrimaryCta);

    final accent = destructive ? AppColors.danger : AppColors.navy950;

    late final Color bg;
    late final Color fg;
    late final BoxBorder? border;
    switch (kind) {
      case AppButtonKind.primary:
        bg = enabled ? accent : AppColors.edge;
        fg = enabled ? AppColors.white : AppColors.ink3;
        border = null;
      case AppButtonKind.secondary:
        bg = AppColors.white;
        fg = enabled ? accent : AppColors.ink3;
        border = Border.all(
          color: enabled ? AppColors.border16 : AppColors.edge,
          width: AppDimens.bwControl,
        );
      case AppButtonKind.text:
        bg = Colors.transparent;
        fg = enabled ? accent : AppColors.ink3;
        border = null;
    }

    // The press overlay: white on a filled button, navy otherwise, at
    // low opacity, calm and clear.
    final overlay = kind == AppButtonKind.primary
        ? AppColors.white.withValues(alpha: 0.14)
        : accent.withValues(alpha: 0.08);

    final radius = BorderRadius.circular(AppDimens.rField);

    Widget child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 19, color: fg),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.s(15, FontWeight.w600, color: fg),
          ),
        ),
      ],
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: kind == AppButtonKind.primary && enabled
            ? AppDimens.shadowCard
            : null,
      ),
      child: Material(
        color: bg,
        borderRadius: radius,
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          overlayColor: WidgetStateProperty.all(overlay),
          child: Container(
            height: h,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: radius, border: border),
            child: child,
          ),
        ),
      ),
    );
  }
}
