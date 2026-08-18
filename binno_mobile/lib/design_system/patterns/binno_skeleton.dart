import 'package:binno_app/design_system/tokens/binno_colors.dart';
import 'package:binno_app/design_system/tokens/binno_radius.dart';
import 'package:flutter/material.dart';

class BinnoSkeleton extends StatelessWidget {
  const BinnoSkeleton({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: BinnoColors.muted,
          borderRadius: BorderRadius.circular(BinnoRadius.sm),
        ),
        child: SizedBox(width: width, height: height),
      ),
    );
  }
}
