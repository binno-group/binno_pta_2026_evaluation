import 'dart:convert';
import 'dart:io';

void main() {
  final canonical = File('docs/design-tokens.json').readAsStringSync();
  final colors = File(
    'lib/design_system/tokens/binno_colors.dart',
  ).readAsStringSync();
  final spacing = File(
    'lib/design_system/tokens/binno_spacing.dart',
  ).readAsStringSync();
  final radius = File(
    'lib/design_system/tokens/binno_radius.dart',
  ).readAsStringSync();
  final decoded = jsonDecode(canonical) as Map<String, Object?>;
  final encodedSources = '$colors\n$spacing\n$radius'.toUpperCase();
  for (final match in RegExp(r'#[0-9A-F]{6}').allMatches(canonical)) {
    final hex = match.group(0)!;
    if (!encodedSources.contains(hex.substring(1))) {
      throw StateError('Token $hex is missing from Dart sources');
    }
  }
  // ignore: avoid_print
  print(const JsonEncoder.withIndent('  ').convert(decoded));
}
