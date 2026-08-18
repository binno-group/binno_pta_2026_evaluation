import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'binno_buttons.dart';

/// The quantity stepper: − / number / +.
class BinnoStepper extends StatelessWidget {
  const BinnoStepper({
    super.key,
    required this.value,
    required this.unit,
    this.onChanged,
    this.min = 1,
    this.max,
    this.valueSize = 76,
    this.centered = true,
    this.hint,
  });

  final int value;
  final String unit;
  final ValueChanged<int>? onChanged;
  final int min;
  final int? max;
  final double valueSize;
  final bool centered;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final canDecrease = value > min;
    final canIncrease = max == null || value < max!;

    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: centered
              ? MainAxisAlignment.center
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            BinnoCircleButton(
              icon: Icons.remove_rounded,
              onPressed: canDecrease && onChanged != null
                  ? () => onChanged!(value - 1)
                  : null,
            ),
            SizedBox(width: centered ? 22 : 18),
            Column(
              children: [
                Text(
                  '$value',
                  style: AppText.display(valueSize, height: 0.9),
                ),
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: AppText.s(13, FontWeight.w400, color: AppColors.ink2),
                ),
              ],
            ),
            SizedBox(width: centered ? 22 : 18),
            BinnoCircleButton(
              icon: Icons.add_rounded,
              filled: true,
              onPressed: canIncrease && onChanged != null
                  ? () => onChanged!(value + 1)
                  : null,
            ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 14),
          Text(hint!, style: AppText.meta()),
        ],
      ],
    );
  }
}

/// A pill toggle with two or more segments.
class BinnoSegmented extends StatelessWidget {
  const BinnoSegmented({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          Expanded(
            child: _Segment(
              label: options[i],
              selected: i == selectedIndex,
              onTap: onChanged == null ? null : () => onChanged!(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy950 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: AppDimens.hSegment,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            border: selected
                ? null
                : Border.all(
                    color: AppColors.border15,
                    width: AppDimens.bwControl,
                  ),
          ),
          child: Text(
            label,
            style: AppText.s(
              13,
              FontWeight.w600,
              color: selected ? AppColors.white : AppColors.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Wrapping choice chips (reason, date, filter).
class BinnoChoiceChips extends StatelessWidget {
  const BinnoChoiceChips({
    super.key,
    required this.options,
    required this.selectedIndex,
    this.onChanged,
  });

  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < options.length; i++)
          _Chip(
            label: options[i],
            selected: i == selectedIndex,
            onTap: onChanged == null ? null : () => onChanged!(i),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.navy950 : Colors.transparent,
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.rPill),
        child: Container(
          height: AppDimens.hControl,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rPill),
            border: selected
                ? null
                : Border.all(
                    color: AppColors.border15,
                    width: AppDimens.bwControl,
                  ),
          ),
          child: Text(
            label,
            style: AppText.s(
              13,
              FontWeight.w600,
              color: selected ? AppColors.white : AppColors.slate700,
            ),
          ),
        ),
      ),
    );
  }
}

/// An outlined selectable box (delivery option, payment provider).
class BinnoSelectableBox extends StatelessWidget {
  const BinnoSelectableBox({
    super.key,
    required this.selected,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.radius = AppDimens.rField,
  });

  final bool selected;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: selected ? AppColors.navy950 : AppColors.border15,
              width: AppDimens.bwControl,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// The radio ring.
class BinnoRadioDot extends StatelessWidget {
  const BinnoRadioDot({super.key, required this.selected, this.size = 22});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.navy950 : AppColors.border16,
          width: 2,
        ),
      ),
      child: selected
          ? Container(
              width: size * 0.5,
              height: size * 0.5,
              decoration: const BoxDecoration(
                color: AppColors.navy950,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }
}

/// An outlined field: label plus value (STIR, price).
///
/// Editable when a `controller` is given, otherwise display-only.
class BinnoField extends StatelessWidget {
  const BinnoField({
    super.key,
    this.label,
    required this.value,
    this.suffix,
    this.hint,
    this.focused = false,
    this.valueStyle,
    this.controller,
    this.keyboardType,
    this.onChanged,
  });

  final String? label;

  /// The text shown when no `controller` is given; used as the hint
  /// otherwise.
  final String value;

  final String? suffix;
  final String? hint;
  final bool focused;
  final TextStyle? valueStyle;

  /// Makes the field editable when given.
  final TextEditingController? controller;

  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.rField),
            border: Border.all(
              color: focused ? AppColors.navy950 : AppColors.border15,
              width: AppDimens.bwControl,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null) ...[
                Text(
                  label!.toUpperCase(),
                  style: AppText.eyebrow(size: 11, color: AppColors.ink2),
                ),
                const SizedBox(height: 4),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: controller == null
                        ? Text(
                            value,
                            style: valueStyle ?? AppText.display(17),
                          )
                        : TextField(
                            controller: controller,
                            keyboardType: keyboardType,
                            onChanged: onChanged,
                            style: valueStyle ?? AppText.display(17),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              hintText: value,
                              hintStyle: (valueStyle ?? AppText.display(17))
                                  .copyWith(color: AppColors.ink3),
                            ),
                          ),
                  ),
                  if (suffix != null)
                    Text(
                      suffix!,
                      style: AppText.s(
                        12,
                        FontWeight.w400,
                        color: AppColors.ink2,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(hint!, style: AppText.meta()),
        ],
      ],
    );
  }
}

/// Pill switch (52×32).
class BinnoSwitch extends StatelessWidget {
  const BinnoSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: BorderRadius.circular(AppDimens.rPill),
      child: AnimatedContainer(
        duration: AppDimens.motionFast,
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? AppColors.navy950 : AppColors.border16,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
        ),
        child: Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

/// The search field (floating or inline).
class BinnoSearchField extends StatelessWidget {
  const BinnoSearchField({
    super.key,
    required this.placeholder,
    this.onTap,
    this.floating = true,
    this.filled = false,
  });

  final String placeholder;
  final VoidCallback? onTap;
  final bool floating;

  /// `true` renders the text as an entered value (dark text).
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(
        floating ? AppDimens.rField : AppDimens.rThumb,
      ),
      child: Container(
        height: floating ? AppDimens.hSearch : AppDimens.hControl,
        padding: EdgeInsets.symmetric(horizontal: floating ? 18 : 14),
        decoration: BoxDecoration(
          color: floating ? AppColors.white : AppColors.surface2,
          borderRadius: BorderRadius.circular(
            floating ? AppDimens.rField : AppDimens.rThumb,
          ),
          boxShadow: floating ? AppDimens.shadowFloating : null,
        ),
        child: Row(
          children: [
            if (floating) ...[
              const Icon(
                Icons.search_rounded,
                size: 19,
                color: AppColors.navy950,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Text(
                placeholder,
                overflow: TextOverflow.ellipsis,
                style: filled
                    ? AppText.s(15, FontWeight.w500)
                    : AppText.s(16, FontWeight.w400, color: AppColors.ink2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A multi-line text field for notes, descriptions, reasons.
class BinnoTextArea extends StatelessWidget {
  const BinnoTextArea({
    super.key,
    required this.controller,
    required this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.sentences,
  });

  final TextEditingController controller;
  final String hint;
  final int minLines;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: AppDimens.outlined(),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        textCapitalization: textCapitalization,
        style: AppText.s(15, FontWeight.w500),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppText.s(14, FontWeight.w400, color: AppColors.ink3),
        ),
      ),
    );
  }
}
