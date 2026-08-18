import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/theme.dart';

/// The screen scaffold. Status bar icons adapt to the background.
class BinnoScreen extends StatelessWidget {
  const BinnoScreen({
    super.key,
    required this.child,
    this.background = AppColors.white,
    this.onNavy = false,
  });

  final Widget child;
  final Color background;

  /// `true` when the top of the screen is navy, so status bar icons go white.
  final bool onNavy;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: onNavy ? AppTheme.overlayOnNavy : AppTheme.overlayOnLight,
      child: Scaffold(backgroundColor: background, body: child),
    );
  }
}

/// The navy header, bottom corners rounded with radius 32.
class BinnoNavyHeader extends StatelessWidget {
  const BinnoNavyHeader({
    super.key,
    required this.child,
    this.bottomPadding = 26,
    this.rounded = true,
  });

  final Widget child;
  final double bottomPadding;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.navy950,
        borderRadius: rounded
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppDimens.rHeader),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        ),
      ),
    );
  }
}

/// The back row: a 48dp tap target plus context text.
///
/// The design has no titled AppBar: a chevron with a small grey context line.
class BinnoBackBar extends StatelessWidget {
  const BinnoBackBar({
    super.key,
    this.label,
    this.onNavy = false,
    this.onBack,
    this.trailing,
    this.safeArea = true,
  });

  final String? label;
  final bool onNavy;
  final VoidCallback? onBack;
  final Widget? trailing;
  final bool safeArea;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          _TapIcon(
            icon: Icons.chevron_left_rounded,
            color: onNavy ? AppColors.white : AppColors.navy950,
            onTap: onBack ?? () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 6),
          if (label != null)
            Expanded(
              child: Text(
                label!,
                style: AppText.s(
                  13,
                  FontWeight.w400,
                  color: onNavy ? AppColors.onNavyMeta : AppColors.ink2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          if (trailing != null) trailing!,
        ],
      ),
    );

    if (!safeArea) return row;
    return SafeArea(bottom: false, child: row);
  }
}

class _TapIcon extends StatelessWidget {
  const _TapIcon({required this.icon, required this.color, this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: SizedBox(
        width: AppDimens.hTapTarget,
        height: AppDimens.hTapTarget,
        child: Icon(icon, size: 26, color: color),
      ),
    );
  }
}

/// The UPPERCASE label above a section.
class BinnoEyebrow extends StatelessWidget {
  const BinnoEyebrow(
    this.text, {
    super.key,
    this.onNavy = false,
    this.weight = FontWeight.w600,
    this.size = 11,
  });

  final String text;
  final bool onNavy;
  final FontWeight weight;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppText.eyebrow(
        color: onNavy ? AppColors.onNavyMeta : AppColors.ink2,
        weight: weight,
        size: size,
      ),
    );
  }
}

/// The 1px divider.
class BinnoHairline extends StatelessWidget {
  const BinnoHairline({super.key, this.color = AppColors.hairline});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      Container(height: AppDimens.bwHairline, color: color);
}

/// The sticky footer: an optional note plus buttons.
class BinnoFooter extends StatelessWidget {
  const BinnoFooter({
    super.key,
    required this.children,
    this.note,
    this.topPadding = 16,
    this.topBorder = false,
  });

  final List<Widget> children;
  final String? note;
  final double topPadding;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: topBorder
          ? const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.hairline, width: 1),
              ),
            )
          : null,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimens.gutter,
            topPadding,
            AppDimens.gutter,
            26,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (note != null) ...[
                Text(
                  note!,
                  textAlign: TextAlign.center,
                  style: AppText.note(),
                ),
                const SizedBox(height: 10),
              ],
              for (var i = 0; i < children.length; i++) ...[
                if (i != 0) const SizedBox(height: 10),
                children[i],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// A section heading: large display text left, a small counter right.
class BinnoSectionHead extends StatelessWidget {
  const BinnoSectionHead({
    super.key,
    required this.title,
    this.trailing,
    this.size = 22,
  });

  final String title;
  final String? trailing;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(title, style: AppText.display(size))),
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(trailing!, style: AppText.meta()),
          ),
      ],
    );
  }
}

/// The detail-screen header: a back button plus a large title.
///
/// Tab roots use [BinnoTabHeader] (no back button); screens inside a stack
/// use this one.
class BinnoPageHeader extends StatelessWidget {
  const BinnoPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.titleSize = 30,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const BinnoBackBar(),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.display(titleSize, height: 1.1),
                    ),
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
      ],
    );
  }
}

/// A short notice for actions that have no page yet.
///
/// No button may stay "silent": when an action is not wired to the backend
/// yet, the user still sees that something happened.
void binnoSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
