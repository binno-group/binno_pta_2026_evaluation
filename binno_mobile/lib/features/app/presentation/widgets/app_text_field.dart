import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/theme.dart';

/// The app's single text input field.
///
/// A label plus an outlined field. The border turns navy on focus. All
/// styles come from the app theme.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.prefixIcon,
    this.minLines = 1,
    this.maxLines = 1,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final IconData? prefixIcon;
  final int minLines;
  final int maxLines;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: AppText.eyebrow(size: 11, color: AppColors.ink2),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: maxLines,
          enabled: enabled,
          textCapitalization: textCapitalization,
          cursorColor: AppColors.navy950,
          style: AppText.s(15, FontWeight.w500),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.white,
            hintText: hint,
            hintStyle: AppText.s(14, FontWeight.w400, color: AppColors.ink3),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 20, color: AppColors.ink3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _border(AppColors.border15),
            enabledBorder: _border(AppColors.border15),
            focusedBorder: _border(AppColors.navy950),
            disabledBorder: _border(AppColors.edge),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppDimens.rField),
    borderSide: BorderSide(color: color, width: AppDimens.bwControl),
  );
}
