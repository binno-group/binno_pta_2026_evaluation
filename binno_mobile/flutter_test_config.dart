import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'test/support/tolerant_comparator.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final testFile = (goldenFileComparator as LocalFileComparator).basedir;
  goldenFileComparator = TolerantComparator(testFile);
  await testMain();
}
