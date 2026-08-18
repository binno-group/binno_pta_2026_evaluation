import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'app_button.dart';

/// The app's single dialog (centred).
///
/// Used when a short message or confirmation fits better than a bottom
/// sheet.
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required Widget child,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: AppColors.navy950.withValues(alpha: 0.45),
    builder: (context) => Dialog(
      backgroundColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.rCard),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: child,
      ),
    ),
  );
}

/// The confirmation dialog: title, text, two buttons. Returns `true`
/// when confirmed.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Tasdiqlash',
  String cancelLabel = 'Bekor qilish',
  bool destructive = false,
}) async {
  final result = await showAppDialog<bool>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: AppText.display(22)),
        const SizedBox(height: 8),
        Text(message, style: AppText.body(size: 14)),
        const SizedBox(height: 22),
        AppButton(
          label: confirmLabel,
          destructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        const SizedBox(height: 10),
        AppButton.secondary(
          label: cancelLabel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
    ),
  );
  return result ?? false;
}
