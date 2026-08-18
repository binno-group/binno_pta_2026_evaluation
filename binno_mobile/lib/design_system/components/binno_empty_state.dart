import 'package:binno_app/design_system/components/binno_button.dart';
import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:flutter/material.dart';

class BinnoEmptyState extends StatelessWidget {
  const BinnoEmptyState({
    required this.title,
    required this.explanation,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final String title;
  final String explanation;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BinnoSpacing.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: BinnoSpacing.x2),
            Text(explanation, textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: BinnoSpacing.x6),
              BinnoButton(label: actionLabel!, onPressed: onAction),
            ],
          ],
        ),
      ),
    );
  }
}
