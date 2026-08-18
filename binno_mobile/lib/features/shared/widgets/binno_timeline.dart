import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

enum BinnoStepState { done, current, future }

/// Timeline qadami.
///
/// Qoida: jurnal append-only, kelajakdagi qadam **hech qachon** bajarilgandek
/// ko'rinmaydi.
class BinnoTimelineStep {
  const BinnoTimelineStep({
    required this.title,
    required this.state,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final BinnoStepState state;
  final String? subtitle;

  /// The timestamp on the right ("10:04", "29-iyul").
  final String? trailing;
}

/// The order/refund state timeline.
class BinnoTimeline extends StatelessWidget {
  const BinnoTimeline({
    super.key,
    required this.steps,
    this.stepGap = 22,
    this.doneColor = AppColors.successDot,
  });

  final List<BinnoTimelineStep> steps;
  final double stepGap;
  final Color doneColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          _StepRow(
            step: steps[i],
            isLast: i == steps.length - 1,
            gap: stepGap,
            doneColor: doneColor,
          ),
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.step,
    required this.isLast,
    required this.gap,
    required this.doneColor,
  });

  final BinnoTimelineStep step;
  final bool isLast;
  final double gap;
  final Color doneColor;

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.state == BinnoStepState.current;
    final isFuture = step.state == BinnoStepState.future;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 14,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: isCurrent ? 3 : 5),
                  child: _Dot(state: step.state, doneColor: doneColor),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4),
                      color: AppColors.railLine,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : gap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: isCurrent
                              ? AppText.s(15, FontWeight.w700)
                              : AppText.s(
                                  14,
                                  FontWeight.w600,
                                  color: isFuture
                                      ? AppColors.ink3
                                      : AppColors.ink,
                                ),
                        ),
                        if (step.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(step.subtitle!, style: AppText.meta()),
                        ],
                      ],
                    ),
                  ),
                  if (step.trailing != null) ...[
                    const SizedBox(width: 12),
                    Text(step.trailing!, style: AppText.meta()),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.state, required this.doneColor});

  final BinnoStepState state;
  final Color doneColor;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case BinnoStepState.done:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: doneColor, shape: BoxShape.circle),
        );
      case BinnoStepState.current:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.navy950, width: 3),
          ),
        );
      case BinnoStepState.future:
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.railFuture, width: 2),
          ),
        );
    }
  }
}
