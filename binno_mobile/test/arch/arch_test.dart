import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _import = RegExp(
  r'''^import\s+['"]package:binno_app/([^'"]+)['"]''',
  multiLine: true,
);

Map<String, List<String>> importGraph() {
  final graph = <String, List<String>>{};
  for (final file
      in Directory('lib').listSync(recursive: true).whereType<File>()) {
    if (!file.path.endsWith('.dart') ||
        file.path.endsWith('.g.dart') ||
        file.path.endsWith('.freezed.dart')) {
      continue;
    }
    final relative = file.path.replaceFirst('lib/', '');
    graph[relative] = _import
        .allMatches(file.readAsStringSync())
        .map((match) => match.group(1)!)
        .toList();
  }
  return graph;
}

String? featureOf(String path) =>
    path.startsWith('features/') ? path.split('/')[1] : null;

void main() {
  final graph = importGraph();

  test('A1 feature isolation', () {
    final bad = <String>[];
    graph.forEach((file, imports) {
      final from = featureOf(file);
      for (final imported in imports) {
        final to = featureOf(imported);
        if (to != null && to != from && imported != 'features/$to/api.dart') {
          bad.add('$file -> $imported');
        }
      }
    });
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('A2 layering', () {
    final bad = <String>[];
    graph.forEach((file, imports) {
      final from = featureOf(file);
      if (from == null) return;
      for (final imported in imports) {
        if (featureOf(imported) != from) continue;
        if (file.contains('/presentation/') && imported.contains('/data/')) {
          bad.add('presentation bypasses domain: $file -> $imported');
        }
        if (file.contains('/domain/') &&
            (imported.contains('/data/') ||
                imported.contains('/presentation/'))) {
          bad.add('domain depends upward: $file -> $imported');
        }
      }
    });
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('A3 core purity', () {
    final bad = <String>[];
    graph.forEach((file, imports) {
      if (!file.startsWith('core/') && !file.startsWith('design_system/')) {
        return;
      }
      for (final imported in imports) {
        if (imported.startsWith('features/')) {
          bad.add('$file -> $imported');
        }
      }
    });
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('A4 http containment', () {
    final raw = RegExp(
      r'''^import\s+['"]package:(dio|http)/''',
      multiLine: true,
    );
    final bad = <String>[];
    for (final file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      final relative = file.path.replaceFirst('lib/', '');
      final allowed = relative.startsWith('core/api/') ||
          RegExp(r'^features/[^/]+/data/').hasMatch(relative);
      if (!allowed && raw.hasMatch(file.readAsStringSync())) {
        bad.add(relative);
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });

  test('A5 controller purity', () {
    final bad = <String>[];
    for (final file
        in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!file.path.contains('/presentation/controllers/')) continue;
      final source = file.readAsStringSync();
      if (source.contains('package:flutter/material.dart') ||
          source.contains('package:flutter/widgets.dart')) {
        bad.add(file.path);
      }
    }
    expect(bad, isEmpty, reason: bad.join('\n'));
  });
}
