import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/activities/activity.dart';

/// El contenido de «Actividades sin pantallas» (HU-047): cada idioma que exista
/// en `assets/activities/` cumple las reglas de la sección 13 y de seguridad.
void main() {
  final Directory folder = Directory('assets/activities');
  Map<String, dynamic> read(String name) =>
      jsonDecode(File('${folder.path}/$name.json').readAsStringSync()) as Map<String, dynamic>;

  final Map<String, dynamic> catalog = read('catalog');
  final List<Map<String, dynamic>> entries = [
    for (final Object? entry in catalog['activities'] as List) (entry as Map).cast<String, dynamic>(),
  ];
  final List<String> ids = [for (final Map<String, dynamic> entry in entries) entry['id'] as String];
  final List<String> languages = [
    for (final FileSystemEntity file in folder.listSync())
      if (file.path.endsWith('.json') && !file.path.endsWith('catalog.json'))
        file.uri.pathSegments.last.replaceAll('.json', ''),
  ]..sort();

  test('24 activities, 4 per category, with allowed times and ages (P7)', () {
    expect(ids, hasLength(24));
    expect(ids.toSet(), hasLength(24));
    for (final ActivityCategory category in ActivityCategory.values) {
      expect(entries.where((entry) => entry['category'] == category.name), hasLength(4), reason: category.name);
    }
    for (final Map<String, dynamic> entry in entries) {
      expect(Activity.durations, contains(entry['minutes']), reason: entry['id'] as String);
      expect([2, 3], contains(entry['ageFrom']), reason: entry['id'] as String);
    }
  });

  test('each one recommends 3 others, and every one is recommended by someone (P11)', () {
    final Set<String> recommended = {};
    for (final Map<String, dynamic> entry in entries) {
      final List<Object?> list = entry['recommended'] as List;
      expect(list.toSet(), hasLength(3), reason: entry['id'] as String);
      expect(list, isNot(contains(entry['id'])));
      expect(ids, containsAll(list));
      recommended.addAll(list.cast<String>());
    }
    expect(recommended, containsAll(ids));
  });

  test('Spanish and English exist; every language has all the texts', () {
    expect(languages, containsAll(['en', 'es']));
    for (final String language in languages) {
      final ActivityLibrary library = ActivityLibrary.fromJson(catalog, read(language));
      expect(library.activities.map((a) => a.id), ids, reason: '$language has every activity');
      for (final Activity activity in library.activities) {
        final String where = '$language/${activity.id}';
        expect(activity.title.trim(), isNotEmpty, reason: where);
        expect(activity.goal.trim(), isNotEmpty, reason: where);
        expect(activity.safety.trim(), isNotEmpty, reason: '$where: its own warning (D6)');
        expect(activity.materials, isNotEmpty, reason: where);
        expect(activity.steps.length, inInclusiveRange(3, 5), reason: where);
        expect(activity.variants, hasLength(2), reason: where);
        expect(activity.tags.length, inInclusiveRange(5, 8), reason: where);
      }
      expect(library.noResults.trim(), isNotEmpty, reason: language);
    }
  });

  test('every search suggestion finds at least two activities (P12)', () {
    for (final String language in languages) {
      final ActivityLibrary library = ActivityLibrary.fromJson(catalog, read(language));
      expect(library.searchHints.length, greaterThanOrEqualTo(6), reason: language);
      for (final String hint in library.searchHints) {
        expect(library.search(hint).length, greaterThanOrEqualTo(2), reason: '$language: «$hint»');
      }
    }
  });

  test('no risky material is proposed: small parts, batteries, plastic bags, balloons… (R6)', () {
    const Map<String, List<String>> forbidden = {
      'es': ['boton', 'canica', 'moneda', 'globo', 'bolsa de plastico', 'pila', 'cuenta de collar', 'frijol', 'arroz'],
      'en': ['button', 'marble', 'coin', 'balloon', 'plastic bag', 'battery', 'batteries', 'bead', 'beans', 'rice'],
    };
    for (final MapEntry<String, List<String>> words in forbidden.entries) {
      final ActivityLibrary library = ActivityLibrary.fromJson(catalog, read(words.key));
      for (final Activity activity in library.activities) {
        // La advertencia sí puede nombrarlos para prohibirlos.
        final String proposed = ActivityLibrary.normalize(
          [activity.title, ...activity.materials, ...activity.steps, ...activity.variants, ...activity.tags].join(' '),
        );
        for (final String word in words.value) {
          expect(RegExp('\\b$word').hasMatch(proposed), isFalse, reason: '${words.key}/${activity.id}: «$word»');
        }
      }
    }
  });
}
