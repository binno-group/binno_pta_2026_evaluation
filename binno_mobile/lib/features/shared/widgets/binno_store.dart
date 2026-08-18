import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'binno_labels.dart';

/// The typographic tile standing in for a product "photo" (M400, Ø12…).
///
/// The prototype's list rows look exactly like this: a grey square with a
/// small label. It is intended behaviour, not a stopgap.
class BinnoThumb extends StatelessWidget {
  const BinnoThumb({
    super.key,
    required this.label,
    this.size = 52,
    this.radius = AppDimens.rThumb,
    this.fontSize = 11,
  });

  final String label;
  final double size;
  final double radius;
  final double fontSize;

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
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppText.s(
          fontSize,
          FontWeight.w600,
          color: AppColors.ink,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// The store avatar: a navy circle with initials inside.
class BinnoAvatar extends StatelessWidget {
  const BinnoAvatar({super.key, required this.initials, this.size = 48});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.navy950,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: AppText.display(size * 0.33, color: AppColors.white),
      ),
    );
  }
}

/// The store identity.
///
/// Rule (§2, ADR-008): the **owner's name never appears** here, only the
/// store name and the location chain "Qo'yliq, B-blok, 47-do'kon".
class BinnoStoreIdentity extends StatelessWidget {
  const BinnoStoreIdentity({
    super.key,
    required this.storeName,
    required this.locationLine,
    this.verified = false,
    this.trailing,
    this.initials,
    this.avatarSize = AppDimens.avatar,
  });

  final String storeName;

  /// A line like "Qo'yliq, B-blok, 47-do'kon · 4,8 ★".
  final String locationLine;
  final bool verified;
  final Widget? trailing;
  final String? initials;
  final double avatarSize;

  String get _initials {
    if (initials != null) return initials!;
    final parts = storeName
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        BinnoAvatar(initials: _initials, size: avatarSize),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      storeName,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.rowTitle(),
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(width: 6),
                    const BinnoVerifiedTick(),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(locationLine, style: AppText.meta()),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}
