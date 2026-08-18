import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// A white card on the light grey background, with a soft shadow.
class BinnoCard extends StatelessWidget {
  const BinnoCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppDimens.rCardSm,
    this.color = AppColors.white,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppDimens.shadowCard,
      ),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// An icon chip: a square icon on a grey/navy background.
class BinnoIconChip extends StatelessWidget {
  const BinnoIconChip({
    super.key,
    required this.icon,
    this.size = 44,
    this.iconSize = 21,
    this.background = AppColors.navy100,
    this.color = AppColors.navy950,
    this.radius = AppDimens.rThumb,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// The icon table for construction-material categories.
///
/// Used in place of product photos: when the image files arrive, swapping
/// this single place is enough.
abstract class BinnoCategoryIcons {
  static const _map = <String, IconData>{
    'Sement': Icons.inventory_2_rounded,
    'Armatura': Icons.view_stream_rounded,
    'G\'isht': Icons.grid_view_rounded,
    'Quruq qorishma': Icons.blender_rounded,
    'Bo\'yoq': Icons.format_paint_rounded,
    'Metallprokat': Icons.view_column_rounded,
    'Izolyatsiya': Icons.layers_rounded,
    'Keramika': Icons.dashboard_customize_rounded,
  };

  static IconData of(String category) =>
      _map[category] ?? Icons.category_rounded;

  /// An icon by product label (M400, Ø12, M150…).
  static IconData forProduct(String thumbLabel) {
    if (thumbLabel.startsWith('Ø')) return Icons.view_stream_rounded;
    if (thumbLabel.startsWith('M1')) return Icons.grid_view_rounded;
    if (thumbLabel.startsWith('M')) return Icons.inventory_2_rounded;
    if (thumbLabel.startsWith('QQ')) return Icons.blender_rounded;
    return Icons.category_rounded;
  }
}

/// The icon tile standing in for a product photo.
///
/// Shows the image when `assets/products/<name>.png` exists, otherwise an
/// icon. Adding photos later therefore needs no code change.
class BinnoProductImage extends StatelessWidget {
  const BinnoProductImage({
    super.key,
    required this.thumbLabel,
    this.asset,
    this.size = 72,
    this.radius = AppDimens.rThumb,
    this.background = AppColors.surface2,
  });

  final String thumbLabel;

  /// A path like `assets/products/cement.png`.
  final String? asset;

  final double size;
  final double radius;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: asset == null
          ? _fallback()
          : Image.asset(
              asset!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              // The app must not crash while the image is missing.
              errorBuilder: (context, error, stackTrace) => _fallback(),
            ),
    );
  }

  Widget _fallback() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          BinnoCategoryIcons.forProduct(thumbLabel),
          size: size * 0.34,
          color: AppColors.navy700,
        ),
        SizedBox(height: size * 0.06),
        Text(
          thumbLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.s(
            size * 0.14,
            FontWeight.w700,
            color: AppColors.slate700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// The category thumbnail: the image when `asset` is set, otherwise an icon.
class BinnoCategoryThumb extends StatelessWidget {
  const BinnoCategoryThumb({
    super.key,
    required this.label,
    this.asset,
    this.size = 44,
    this.radius = AppDimens.rThumb,
  });

  final String label;
  final String? asset;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: asset == null
          ? Icon(
              BinnoCategoryIcons.of(label),
              size: size * 0.48,
              color: AppColors.navy950,
            )
          : Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: Image.asset(
                asset!,
                fit: BoxFit.contain,
                // A missing image must not crash the app; fall back to the icon.
                errorBuilder: (context, error, stackTrace) => Icon(
                  BinnoCategoryIcons.of(label),
                  size: size * 0.48,
                  color: AppColors.navy950,
                ),
              ),
            ),
    );
  }
}

/// The small category card on the home page.
class BinnoCategoryCard extends StatelessWidget {
  const BinnoCategoryCard({
    super.key,
    required this.label,
    this.onTap,
    this.offerCount,
    this.asset,
    this.compact = true,
  });

  final String label;
  final VoidCallback? onTap;
  final int? offerCount;

  /// The category image icon path.
  final String? asset;

  /// `true` for the narrow home-page variant, `false` for the wide catalogue one.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BinnoCard(
      onTap: onTap,
      padding: EdgeInsets.all(compact ? 10 : 14),
      radius: compact ? AppDimens.rTile : AppDimens.rCardSm,
      child: compact
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BinnoCategoryThumb(label: label, asset: asset, size: 44),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.s(12, FontWeight.w600),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                BinnoCategoryThumb(
                  label: label,
                  asset: asset,
                  size: 50,
                  radius: AppDimens.rTile,
                ),
                const SizedBox(height: 10),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.s(15, FontWeight.w600),
                ),
                if (offerCount != null) ...[
                  const SizedBox(height: 2),
                  Text('$offerCount ta taklif', style: AppText.meta()),
                ],
              ],
            ),
    );
  }
}
