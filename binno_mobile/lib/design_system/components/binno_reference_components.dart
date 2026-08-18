import 'package:binno_app/design_system/tokens/binno_colors.dart';
import 'package:binno_app/design_system/tokens/binno_radius.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:flutter/material.dart';

class BinnoHeroHeader extends StatelessWidget {
  const BinnoHeroHeader({
    required this.child,
    this.height,
    this.padding = const EdgeInsets.fromLTRB(
      BinnoSpacing.x6,
      BinnoSpacing.x6,
      BinnoSpacing.x6,
      BinnoSpacing.x8,
    ),
    super.key,
  });

  final Widget child;
  final double? height;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: const BoxDecoration(
        color: BinnoColors.navy950,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(BinnoRadius.hero),
          bottomRight: Radius.circular(BinnoRadius.hero),
        ),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: BinnoColors.canvas),
        child: IconTheme.merge(
          data: const IconThemeData(color: BinnoColors.canvas),
          child: child,
        ),
      ),
    );
  }
}

class BinnoSurfaceCard extends StatelessWidget {
  const BinnoSurfaceCard({
    required this.child,
    this.padding = const EdgeInsets.all(BinnoSpacing.x5),
    this.color = BinnoColors.navy50,
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(BinnoRadius.xl),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

enum BinnoStatusTone { success, warning, danger, neutral }

class BinnoStatusPill extends StatelessWidget {
  const BinnoStatusPill({
    required this.label,
    this.tone = BinnoStatusTone.neutral,
    super.key,
  });

  final String label;
  final BinnoStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      BinnoStatusTone.success => (
          BinnoColors.successSurface,
          BinnoColors.success,
        ),
      BinnoStatusTone.warning => (
          BinnoColors.warningSurface,
          BinnoColors.warning,
        ),
      BinnoStatusTone.danger => (
          BinnoColors.dangerSurface,
          BinnoColors.danger,
        ),
      BinnoStatusTone.neutral => (
          BinnoColors.navy50,
          BinnoColors.textSecondary,
        ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(BinnoRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BinnoSpacing.x3,
          vertical: BinnoSpacing.x2,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
