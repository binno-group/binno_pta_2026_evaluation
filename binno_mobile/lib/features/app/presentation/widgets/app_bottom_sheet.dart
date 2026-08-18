import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import 'app_button.dart';

/// The app's single modal bottom-sheet shell.
///
/// Rounded top corners, a drag handle, the safe area. Use
/// `showAppBottomSheet` for any content and `showAppConfirmSheet` for a
/// confirmation dialog.
Future<T?> showAppBottomSheet<T>(
  BuildContext context, {
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.navy950.withValues(alpha: 0.45),
    builder: (context) => _AppSheetShell(child: child),
  );
}

class _AppSheetShell extends StatelessWidget {
  const _AppSheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.rSheet),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.edge,
                    borderRadius: BorderRadius.circular(AppDimens.rPill),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// The confirmation bottom sheet: an icon, title, text, and two buttons.
///
/// Returns `true` on confirmation. For destructive actions (log out,
/// delete) the confirm button turns red.
Future<bool> showAppConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Tasdiqlash',
  String cancelLabel = 'Bekor qilish',
  IconData icon = Icons.help_outline_rounded,
  bool destructive = false,
}) async {
  final result = await showAppBottomSheet<bool>(
    context,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: destructive ? AppColors.dangerBg : AppColors.navy100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: destructive ? AppColors.danger : AppColors.navy950,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppText.display(22),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: AppText.body(size: 14),
        ),
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
