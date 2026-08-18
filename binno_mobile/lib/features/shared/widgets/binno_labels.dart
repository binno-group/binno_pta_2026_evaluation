import 'package:flutter/material.dart';

import '../../../core/helpers/money.dart';
import '../../../core/theme/theme.dart';

/// Status pill tones, matching the design vocabulary.
enum BinnoPillTone { success, warning, danger, neutral, brandNew }

/// A status pill with radius 999.
class BinnoPill extends StatelessWidget {
  const BinnoPill(
    this.text, {
    super.key,
    this.tone = BinnoPillTone.neutral,
  });

  final String text;
  final BinnoPillTone tone;

  @override
  Widget build(BuildContext context) {
    late final Color fg;
    late final Color bg;
    var size = 11.0;
    var weight = FontWeight.w600;

    switch (tone) {
      case BinnoPillTone.success:
        fg = AppColors.successText;
        bg = AppColors.successBg;
      case BinnoPillTone.warning:
        fg = AppColors.warningText;
        bg = AppColors.warningBg;
      case BinnoPillTone.danger:
        fg = AppColors.danger;
        bg = AppColors.dangerBg;
      case BinnoPillTone.neutral:
        fg = AppColors.slate700;
        bg = AppColors.surface3;
      case BinnoPillTone.brandNew:
        fg = AppColors.navy800;
        bg = AppColors.navy100;
        size = 10;
        weight = FontWeight.w700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
      ),
      child: Text(
        text,
        style: AppText.s(size, weight, color: fg),
      ),
    );
  }
}

/// Offer age, the Master Spec §4.2 tiers.
enum BinnoFreshness {
  /// ≤24 hours: full score.
  fresh,

  /// 24–72 hours: no label.
  normal,

  /// 3–7 days: "the price may be out of date".
  stale,

  /// >7 days: end of the list, reconfirmation required.
  expired,
}

/// The freshness label. Shows nothing in the [normal] tier.
class BinnoFreshnessLabel extends StatelessWidget {
  const BinnoFreshnessLabel(this.tier, {super.key, this.freshText});

  final BinnoFreshness tier;

  /// e.g. "Bugun 08:20 da yangilangan"; falls back to "Bugun yangilangan".
  final String? freshText;

  @override
  Widget build(BuildContext context) {
    switch (tier) {
      case BinnoFreshness.fresh:
        return BinnoPill(
          freshText ?? 'Bugun yangilangan',
          tone: BinnoPillTone.success,
        );
      case BinnoFreshness.normal:
        return const SizedBox.shrink();
      case BinnoFreshness.stale:
        return const BinnoPill(
          'Narx eskirgan bo\'lishi mumkin',
          tone: BinnoPillTone.warning,
        );
      case BinnoFreshness.expired:
        return const BinnoPill(
          'Sotuvchi tasdig\'i so\'raladi',
          tone: BinnoPillTone.danger,
        );
    }
  }
}

/// The declared-stock label; no other wording is allowed.
///
/// Rule (Master Spec §3.2): stock is the seller's claim and the platform
/// does not verify it. Wording like "in stock ✓" is forbidden.
class BinnoDeclaredStockLabel extends StatelessWidget {
  const BinnoDeclaredStockLabel({
    super.key,
    required this.qty,
    this.unit = 'qop',
    this.style,
    this.lowercase = false,
  });

  final num qty;
  final String unit;
  final TextStyle? style;

  /// Starts lowercase when used inside a sentence.
  final bool lowercase;

  @override
  Widget build(BuildContext context) {
    final prefix = lowercase
        ? 'e\'lon qilingan qoldiq'
        : 'E\'lon qilingan qoldiq';
    return Text(
      '$prefix: ${Money.qty(qty, unit)}',
      style: style ?? AppText.s(12, FontWeight.w400, color: AppColors.ink2),
    );
  }
}

/// The median response time, shown only with ≥5 samples (§4.3).
class BinnoResponseTimeLabel extends StatelessWidget {
  const BinnoResponseTimeLabel({
    super.key,
    required this.minutes,
    required this.sampleCount,
    this.style,
  });

  final int minutes;
  final int sampleCount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (sampleCount < 5) return const SizedBox.shrink();
    return Text(
      'odatda ~$minutes daqiqada javob beradi',
      style: style ?? AppText.s(12, FontWeight.w400, color: AppColors.ink2),
    );
  }
}

/// The pickup badge.
class BinnoPickupBadge extends StatelessWidget {
  const BinnoPickupBadge({super.key, this.label = 'Olib ketish mumkin'});

  final String label;

  @override
  Widget build(BuildContext context) =>
      BinnoPill(label, tone: BinnoPillTone.neutral);
}

/// The verified-store tick.
class BinnoVerifiedTick extends StatelessWidget {
  const BinnoVerifiedTick({super.key, this.size = 15});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.info,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.check, size: size * 0.62, color: AppColors.white),
    );
  }
}

/// The rating row.
///
/// Rule (§10): a new store shows "Yangi", never "0.0 ★". A numeric rating
/// appears only with ≥3 reviews.
class BinnoRatingLabel extends StatelessWidget {
  const BinnoRatingLabel({
    super.key,
    required this.rating,
    required this.reviewCount,
    this.style,
  });

  final double rating;
  final int reviewCount;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (reviewCount < 3) {
      return const BinnoPill('Yangi', tone: BinnoPillTone.brandNew);
    }

    final text = rating.toStringAsFixed(1).replaceAll('.', ',');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: style ?? AppText.s(12, FontWeight.w400, color: AppColors.ink2),
        ),
        const SizedBox(width: 3),
        const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
        const SizedBox(width: 3),
        Text(
          '($reviewCount)',
          style: style ?? AppText.s(12, FontWeight.w400, color: AppColors.ink2),
        ),
      ],
    );
  }
}

/// Star rating, in read-only or pick mode.
class BinnoStars extends StatelessWidget {
  const BinnoStars({
    super.key,
    required this.value,
    this.size = 44,
    this.onChanged,
  });

  final int value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (i) {
        final filled = i < value;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: size * 0.11),
          child: InkResponse(
            onTap: onChanged == null ? null : () => onChanged!(i + 1),
            radius: size * 0.6,
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_outline_rounded,
              size: size,
              color: filled ? AppColors.warning : AppColors.edge2,
            ),
          ),
        );
      }),
    );
  }
}
