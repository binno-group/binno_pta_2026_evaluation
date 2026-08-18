import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// The app's single switch (toggle): 52×32, navy in the active state.
class AppSwitch extends StatelessWidget {
  const AppSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => onChanged!(!value) : null,
      child: AnimatedContainer(
        duration: AppDimens.motionFast,
        width: 52,
        height: 32,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.navy950 : AppColors.edge2,
          borderRadius: BorderRadius.circular(AppDimens.rPill),
        ),
        child: AnimatedAlign(
          duration: AppDimens.motionFast,
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: AppDimens.shadowCard,
            ),
          ),
        ),
      ),
    );
  }
}
