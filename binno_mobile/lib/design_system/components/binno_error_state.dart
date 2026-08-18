import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/tokens/binno_colors.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:flutter/material.dart';

class BinnoErrorState extends StatelessWidget {
  const BinnoErrorState({
    required this.title,
    required this.explanation,
    required this.actionLabel,
    required this.onRetry,
    super.key,
  });

  final String title;
  final String explanation;
  final String actionLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BinnoSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: BinnoColors.danger,
              size: BinnoSpacing.x8,
            ),
            const SizedBox(height: BinnoSpacing.x3),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BinnoSpacing.x2),
            Text(explanation, textAlign: TextAlign.center),
            const SizedBox(height: BinnoSpacing.x6),
            BinnoButton(label: actionLabel, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
