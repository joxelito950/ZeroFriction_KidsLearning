import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Ningún texto visible se escribe en el código: todos salen del catálogo
/// (lib/l10n/*.arb, HU-011 regla R1).
///
/// Detecta cadenas que parecen texto para el usuario: con espacios, mayúsculas,
/// letras acentuadas o signos de puntuación. Las claves técnicas (`farm_easy`,
/// `memory-card-$index`) y los emojis del contenido de los juegos no cuentan.
void main() {
  final files = [
    File('lib/main.dart'),
    ...Directory('lib/presentation')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart') && !file.path.endsWith('.g.dart')),
  ];

  final stringLiteral = RegExp(r"'((?:[^'\\]|\\.)*)'|" r'"((?:[^"\\]|\\.)*)"');
  final looksLikeUserText = RegExp(r"[\sA-ZÀ-ÿ¡!¿?.,:;]");
  final hasLetter = RegExp(r'[A-Za-zÀ-ÿ]');

  bool isIgnoredLine(String line) {
    final String trimmed = line.trimLeft();
    return trimmed.startsWith('import ') ||
        trimmed.startsWith('export ') ||
        trimmed.startsWith('part ') ||
        trimmed.startsWith('//');
  }

  for (final file in files) {
    final path = file.path.replaceAll(r'\', '/');

    test('$path has no hard-coded user-facing texts', () {
      final offenders = <String>[];
      final lines = file.readAsLinesSync();

      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (isIgnoredLine(line)) continue;

        for (final match in stringLiteral.allMatches(line)) {
          final String literal = match.group(1) ?? match.group(2) ?? '';
          final String withoutInterpolation = literal.replaceAll(RegExp(r'\$\{[^}]*\}|\$\w+'), '');
          if (hasLetter.hasMatch(withoutInterpolation) &&
              looksLikeUserText.hasMatch(withoutInterpolation)) {
            offenders.add('${index + 1}: $literal');
          }
        }
      }

      expect(offenders, isEmpty, reason: 'Move these texts to lib/l10n/app_en.arb:\n${offenders.join('\n')}');
    });
  }
}
