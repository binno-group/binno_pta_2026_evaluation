import 'package:flutter/material.dart';

import '../../../core/helpers/money.dart';
import '../../../core/theme/theme.dart';
import 'binno_store.dart';

/// The universal offer/product row.
///
/// Structure: a thumb, then the name with meta lines and a status pill,
/// then the price on the right.
class BinnoOfferRow extends StatelessWidget {
  const BinnoOfferRow({
    super.key,
    required this.thumbLabel,
    required this.title,
    this.metaLines = const [],
    this.badge,
    this.price,
    this.priceSub,
    this.thumbSize = 56,
    this.verified = false,
    this.trailingChip,
    this.onTap,
    this.dimmed = false,
    this.priceStyle,
  });

  final String thumbLabel;
  final String title;
  final List<String> metaLines;
  final Widget? badge;
  final num? price;
  final String? priceSub;
  final double thumbSize;
  final bool verified;
  final Widget? trailingChip;
  final VoidCallback? onTap;

  /// For stale or unconfirmed data.
  final bool dimmed;

  final TextStyle? priceStyle;

  @override
  Widget build(BuildContext context) {
    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BinnoThumb(label: thumbLabel, size: thumbSize),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.rowTitle(),
                    ),
                  ),
                  if (verified) ...[
                    const SizedBox(width: 6),
                    const _Tick(),
                  ],
                  if (trailingChip != null) ...[
                    const SizedBox(width: 8),
                    trailingChip!,
                  ],
                ],
              ),
              for (final line in metaLines) ...[
                const SizedBox(height: 2),
                Text(line, style: AppText.meta()),
              ],
              if (badge != null) ...[const SizedBox(height: 8), badge!],
            ],
          ),
        ),
        if (price != null) ...[
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Money.format(price!),
                style: priceStyle ?? AppText.display(18),
              ),
              if (priceSub != null) ...[
                const SizedBox(height: 2),
                Text(priceSub!, style: AppText.note()),
              ],
            ],
          ),
        ],
      ],
    );

    final content = dimmed ? Opacity(opacity: 0.72, child: row) : row;

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.rThumb),
      child: content,
    );
  }
}

class _Tick extends StatelessWidget {
  const _Tick();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: const BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.check, size: 9, color: AppColors.white),
    );
  }
}

/// A label-value row (for totals).
class BinnoInfoRow extends StatelessWidget {
  const BinnoInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.onCopy,
    this.valueStyle,
    this.labelStyle,
  });

  final String label;
  final String value;
  final bool copyable;
  final VoidCallback? onCopy;
  final TextStyle? valueStyle;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: labelStyle ??
                AppText.s(13, FontWeight.w400, color: AppColors.ink2),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: valueStyle ?? AppText.s(14, FontWeight.w600),
          ),
        ),
        if (copyable) ...[
          const SizedBox(width: 8),
          InkResponse(
            onTap: onCopy,
            radius: 20,
            child: const SizedBox(
              width: 32,
              height: 32,
              child: Icon(
                Icons.copy_rounded,
                size: 16,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The total row: `total = goods + delivery` (rule §6.1).
class BinnoTotalRow extends StatelessWidget {
  const BinnoTotalRow({
    super.key,
    required this.total,
    this.label = 'Jami',
    this.size = 24,
  });

  final num total;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: Text(label, style: AppText.s(14, FontWeight.w600))),
        Text(Money.format(total), style: AppText.display(size)),
      ],
    );
  }
}

/// The large amount block: an eyebrow, a giant number, the unit, a note.
class BinnoAmountBlock extends StatelessWidget {
  const BinnoAmountBlock({
    super.key,
    required this.eyebrow,
    required this.amount,
    this.unit = 'so\'m',
    this.note,
    this.size = 50,
    this.onNavy = false,
  });

  final String eyebrow;
  final num amount;
  final String unit;
  final String? note;
  final double size;
  final bool onNavy;

  @override
  Widget build(BuildContext context) {
    final metaColor = onNavy ? AppColors.onNavyMeta : AppColors.ink2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow.toUpperCase(),
          style: AppText.eyebrow(color: metaColor),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  Money.format(amount),
                  style: AppText.display(
                    size,
                    height: 0.95,
                    color: onNavy ? AppColors.white : AppColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                unit,
                style: AppText.s(13, FontWeight.w400, color: metaColor),
              ),
            ),
          ],
        ),
        if (note != null) ...[
          const SizedBox(height: 8),
          Text(
            note!,
            style: AppText.s(13, FontWeight.w400, color: metaColor, height: 1.5),
          ),
        ],
      ],
    );
  }
}
