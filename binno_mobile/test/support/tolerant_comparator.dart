import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TolerantComparator extends LocalFileComparator {
  TolerantComparator(super.testFile, {this.tolerance = 0.001});

  final double tolerance;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );
    if (result.passed || result.diffPercent <= tolerance) return true;
    throw FlutterError(
      'Golden "${golden.path}" diff '
      '${(result.diffPercent * 100).toStringAsFixed(3)}% exceeds budget.',
    );
  }
}
