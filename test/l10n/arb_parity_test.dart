import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Paridad del catálogo (HU-011, criterio 6): todos los idiomas tienen las mismas
/// claves, conservan las variables y completan las formas plurales de su idioma.
void main() {
  const templateName = 'app_en.arb';
  const brandKey = 'appTitle';
  const brandName = 'ToddlerLogic';
  const arabicPluralForms = ['zero{', 'one{', 'two{', 'few{', 'many{', 'other{'];

  Map<String, dynamic> readArb(File file) =>
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

  Iterable<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((key) => !key.startsWith('@'));

  Set<String> placeholdersOf(String message) =>
      RegExp(r'\{(\w+)[,}]').allMatches(message).map((match) => match.group(1)!).toSet();

  final arbFiles = Directory('lib/l10n')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.arb'))
      .toList();
  final File templateFile =
      arbFiles.singleWhere((file) => file.uri.pathSegments.last == templateName);
  final Map<String, dynamic> template = readArb(templateFile);
  final Set<String> templateKeys = messageKeys(template).toSet();

  test('there is one ARB per supported language (9)', () {
    expect(arbFiles, hasLength(9));
  });

  test('every template key documents its context for translators', () {
    for (final key in templateKeys) {
      final metadata = template['@$key'] as Map<String, dynamic>?;
      expect(metadata?['description'], isA<String>(), reason: '@$key needs a description');
    }
  });

  for (final file in arbFiles) {
    final String name = file.uri.pathSegments.last;
    final Map<String, dynamic> arb = readArb(file);
    final String locale = arb['@@locale'] as String;

    group(name, () {
      test('@@locale matches the file name', () {
        expect(name, 'app_$locale.arb');
      });

      test('has exactly the template keys', () {
        expect(messageKeys(arb).toSet(), templateKeys);
      });

      test('keeps every placeholder of the template', () {
        for (final key in templateKeys) {
          final String translated = arb[key] as String;
          expect(
            placeholdersOf(translated).containsAll(placeholdersOf(template[key] as String)),
            isTrue,
            reason: '$name · $key: $translated',
          );
        }
      });

      test('completes plural messages for its language', () {
        for (final key in templateKeys.where((key) => (template[key] as String).contains('plural,'))) {
          final String translated = arb[key] as String;
          expect(translated, contains('plural,'), reason: '$name · $key');
          expect(translated, contains('other{'), reason: '$name · $key');
          if (locale == 'ar') {
            for (final form in arabicPluralForms) {
              expect(translated, contains(form), reason: 'ar · $key needs $form');
            }
          }
        }
      });

      test('does not translate the brand name', () {
        expect(arb[brandKey], brandName);
      });
    });
  }
}
