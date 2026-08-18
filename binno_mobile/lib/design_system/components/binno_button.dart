import 'package:binno_app/design_system/tokens/binno_spacing.dart';
import 'package:flutter/material.dart';

enum BinnoButtonState { idle, submitting, success, failure }

class BinnoButton extends StatelessWidget {
  const BinnoButton({
    required this.label,
    required this.onPressed,
    this.state = BinnoButtonState.idle,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final BinnoButtonState state;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final submitting = state == BinnoButtonState.submitting;
    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: double.infinity,
        height: BinnoSpacing.x16,
        child: FilledButton(
          onPressed: submitting ? null : onPressed,
          child: submitting
              ? const SizedBox.square(
                  dimension: BinnoSpacing.x5,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(label),
        ),
      ),
    );
  }
}
