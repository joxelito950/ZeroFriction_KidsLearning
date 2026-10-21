import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// El dominio es Dart puro (SPECIFICATION 3.1, TD-004): no depende de Flutter,
/// de la persistencia ni de otras capas. Este test falla si alguien lo rompe.
void main() {
  final domainFiles = Directory('lib/domain')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart'))
      .toList();

  const forbiddenImports = [
    'package:hive_ce/',
    'package:hive/',
    'package:flutter/',
    'package:flutter_bloc/',
    'package:bloc/',
    'package:path_provider/',
    'package:toddler_logic/data/',
    'package:toddler_logic/presentation/',
    '../data/',
    '../presentation/',
  ];

  test('lib/domain contains Dart files to check', () {
    expect(domainFiles, isNotEmpty);
  });

  for (final file in domainFiles) {
    final path = file.path.replaceAll(r'\', '/');

    test('$path does not depend on frameworks, persistence or other layers', () {
      final directives = file
          .readAsLinesSync()
          .where((line) => line.startsWith('import ') || line.startsWith('export '));

      for (final directive in directives) {
        for (final forbidden in forbiddenImports) {
          expect(directive.contains(forbidden), isFalse, reason: '$path: $directive');
        }
      }
    });

    test('$path has no generated code parts', () {
      final parts = file.readAsLinesSync().where((line) => line.startsWith('part '));
      expect(parts, isEmpty, reason: path);
    });
  }
}
