import 'package:flutter/material.dart';

abstract final class BinnoMotion {
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 400);

  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }
}
