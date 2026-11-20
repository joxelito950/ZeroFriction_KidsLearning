import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/activities/asset_activity_source.dart';
import 'package:toddler_logic/domain/activities/activity.dart';

/// HU-047: la sugerencia del día y la búsqueda (P10, P12).
void main() {
  Map<String, dynamic> entry(String id, String category, int minutes, List<String> recommended) =>
      {'id': id, 'category': category, 'minutes': minutes, 'ageFrom': 2, 'recommended': recommended};

  Map<String, dynamic> text(String title, {List<String> materials = const [], List<String> tags = const []}) => {
        'title': title,
        'goal': 'Practica algo.',
        'materials': materials,
        'steps': ['Uno.', 'Dos.', 'Tres.'],
        'variants': ['Más fácil.', 'Más difícil.'],
        'safety': 'Siempre con un adulto.',
        'tags': tags,
      };

  final Map<String, dynamic> catalog = {
    'activities': [
      entry('search-a', 'search', 5, ['search-b', 'sort-a', 'missing']),
      entry('search-b', 'search', 10, ['search-a', 'move-a', 'art-a']),
      entry('sort-a', 'sort', 10, ['search-a', 'move-a', 'art-a']),
      entry('move-a', 'move', 5, ['search-a', 'sort-a', 'art-a']),
      entry('art-a', 'art', 15, ['search-a', 'sort-a', 'move-a']),
      entry('language-a', 'language', 5, ['search-a', 'sort-a', 'move-a']),
      entry('routine-a', 'routine', 10, ['search-a', 'sort-a', 'move-a']),
      entry('untranslated', 'routine', 5, ['search-a', 'sort-a', 'move-a']),
    ],
  };
  final Map<String, dynamic> texts = {
    'activities': {
      'search-a': text('Busca algo rojo', materials: ['Tazas de plástico'], tags: ['colores', 'día de lluvia']),
      'search-b': text('Tesoro suave', materials: ['Cojines', 'Toallas'], tags: ['texturas']),
      'sort-a': text('Parejas de calcetines', materials: ['Calcetines'], tags: ['ropa', 'colores']),
      'move-a': text('De cojín en cojín', materials: ['Cojines'], tags: ['saltar', 'día de lluvia']),
      'art-a': text('Pintar con agua', materials: ['Brocha', 'Agua'], tags: ['agua']),
      'language-a': text('Cuento con cucharas', materials: ['Cucharas'], tags: ['cuentos', 'antes de dormir']),
      'routine-a': text('Cada juguete a su casa', materials: ['Cajas'], tags: ['orden', 'coches']),
    },
    'searchHints': ['calcetines', 'día de lluvia'],
    'noResults': 'Prueba con otra palabra.',
  };
  final ActivityLibrary library = ActivityLibrary.fromJson(catalog, texts);

  test('reads the catalog in its order; an activity without texts in this language is not shown', () {
    expect(library.activities.map((a) => a.id), [
      'search-a', 'search-b', 'sort-a', 'move-a', 'art-a', 'language-a', 'routine-a', //
    ]);
    final Activity first = library.byId('search-a')!;
    expect(first.category, ActivityCategory.search);
    expect(first.minutes, 5);
    expect(first.ageFrom, 2);
    expect(first.steps, hasLength(3));
    expect(first.variants, hasLength(2));
    expect(first.safety, isNotEmpty);
    expect(library.byId('untranslated'), isNull);
    expect(library.searchHints, ['calcetines', 'día de lluvia']);
    expect(library.noResults, isNotEmpty);
    expect(Activity.durations, [5, 10, 15]);
    expect(ActivityCategory.fromName('art'), ActivityCategory.art);
  });

  test('recommended ones are the existing ones, in their order (P11)', () {
    expect(library.recommendedFor(library.byId('search-a')!).map((a) => a.id), ['search-b', 'sort-a']);
  });

  group('suggestion of the day (P10)', () {
    test('one category per turn, so the same category never comes two days running', () {
      expect(library.dailyOrder.map((a) => a.id), [
        'search-a', 'sort-a', 'move-a', 'art-a', 'language-a', 'routine-a', 'search-b', //
      ]);
    });

    test('the same all day, another one tomorrow, and the whole cycle before repeating', () {
      final DateTime morning = DateTime(2026, 11, 20, 7);
      expect(library.suggestionFor(DateTime(2026, 11, 20, 22)), same(library.suggestionFor(morning)));
      expect(library.suggestionFor(DateTime(2026, 11, 21)), isNot(same(library.suggestionFor(morning))));
      final Set<String> week = {
        for (var day = 0; day < 7; day++) library.suggestionFor(morning.add(Duration(days: day)))!.id,
      };
      expect(week, hasLength(7));
      expect(library.suggestionFor(morning.add(const Duration(days: 7))), same(library.suggestionFor(morning)));
      expect(library.suggestionFor(DateTime(2025, 12, 31)), isNotNull, reason: 'also before the reference date');
    });

    test('nothing to suggest without activities', () {
      expect(ActivityLibrary(activities: const [], searchHints: const [], noResults: '').suggestionFor(DateTime(2026)),
          isNull);
    });
  });

  group('search (P12)', () {
    List<String> ids(List<Activity> found) => [for (final Activity activity in found) activity.id];

    test('by material, by what they like or by an idea, without caring about accents or capitals', () {
      expect(ids(library.search('calcetines')), ['sort-a']);
      expect(ids(library.search('COJINES')), ['search-b', 'move-a']);
      expect(ids(library.search('dia de LLUVIA')), ['search-a', 'move-a']);
      expect(ids(library.search('coches')), ['routine-a']);
      expect(ids(library.search('  cuento, ')), ['language-a']);
    });

    test('every word has to be there; nothing found is an empty list', () {
      expect(ids(library.search('colores ropa')), ['sort-a']);
      expect(library.search('dinosaurios'), isEmpty);
    });

    test('an empty search shows everything; category and time filter it', () {
      expect(library.search(''), hasLength(7));
      expect(ids(library.search('', category: ActivityCategory.search)), ['search-a', 'search-b']);
      expect(ids(library.search('', minutes: 15)), ['art-a']);
      expect(ids(library.search('colores', category: ActivityCategory.sort, minutes: 10)), ['sort-a']);
    });

    test('normalize folds the accents of the 9 languages that have them', () {
      expect(ActivityLibrary.normalize('Ñandú Ça Grüße ÉTÉ'), 'nandu ca grusse ete');
      expect(ActivityLibrary.normalize('¿Qué «es»?'), 'que es');
    });
  });

  group('AssetActivitySource', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('reads the language asked for, falls back to English, and keeps what it read', () async {
      final _Bundle bundle = _Bundle({
        'assets/activities/catalog.json': jsonEncode(catalog),
        'assets/activities/es.json': jsonEncode(texts),
        'assets/activities/en.json': jsonEncode({
          ...texts,
          'noResults': 'Try another word.',
        }),
      });
      final AssetActivitySource source = AssetActivitySource(bundle: bundle);
      expect((await source.load('es')).noResults, 'Prueba con otra palabra.');
      expect((await source.load('ja')).noResults, 'Try another word.');
      final int reads = bundle.reads;
      await source.load('es');
      expect(bundle.reads, reads, reason: 'cached');
    });
  });
}

class _Bundle extends CachingAssetBundle {
  _Bundle(this.files);

  final Map<String, String> files;
  int reads = 0;

  @override
  Future<ByteData> load(String key) async {
    reads++;
    final String? content = files[key];
    if (content == null) throw FlutterError('Unable to load asset: $key');
    return ByteData.sublistView(utf8.encode(content));
  }
}
