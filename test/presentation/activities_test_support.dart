import 'package:toddler_logic/domain/activities/activity.dart';

/// Actividades de ejemplo para los tests de las pantallas (HU-047): 7, de las
/// 6 categorías, con tiempos de 5 a 30 minutos.
ActivityLibrary sampleActivityLibrary() {
  Map<String, dynamic> entry(String id, String category, int minutes, List<String> recommended) =>
      {'id': id, 'category': category, 'minutes': minutes, 'ageFrom': 2, 'recommended': recommended};

  Map<String, dynamic> text(String title, {List<String> materials = const [], List<String> tags = const []}) => {
        'title': title,
        'goal': 'Objetivo de $title.',
        'materials': materials,
        'steps': ['Primer paso de $title.', 'Segundo paso de $title.', 'Tercer paso de $title.'],
        'variants': ['Más fácil: $title.', 'Más difícil: $title.'],
        'safety': 'Cuidado especial en $title.',
        'tags': tags,
      };

  return ActivityLibrary.fromJson(
    {
      'activities': [
        entry('search-red', 'search', 5, ['sort-socks', 'move-cushions', 'art-water']),
        entry('search-soft', 'search', 10, ['search-red', 'move-cushions', 'art-water']),
        entry('sort-socks', 'sort', 10, ['search-red', 'language-spoons', 'routine-toys']),
        entry('move-cushions', 'move', 15, ['search-red', 'sort-socks', 'art-water']),
        entry('art-water', 'art', 30, ['search-red', 'sort-socks', 'move-cushions']),
        entry('language-spoons', 'language', 5, ['search-red', 'sort-socks', 'move-cushions']),
        entry('routine-toys', 'routine', 10, ['search-red', 'sort-socks', 'move-cushions']),
      ],
    },
    {
      'activities': {
        'search-red': text('Busca algo rojo', materials: ['Tazas', 'Cajas'], tags: ['colores', 'día de lluvia']),
        'search-soft': text('Tesoro suave', materials: ['Cojines', 'Toallas'], tags: ['texturas']),
        'sort-socks': text('Parejas de calcetines', materials: ['Calcetines'], tags: ['ropa', 'colores']),
        'move-cushions': text('De cojín en cojín', materials: ['Cojines'], tags: ['saltar', 'día de lluvia']),
        'art-water': text('Pintar con agua', materials: ['Brocha', 'Agua', 'Vaso', 'Pared'], tags: ['agua']),
        'language-spoons': text('Cuento con cucharas', materials: ['Cucharas'], tags: ['cuentos']),
        'routine-toys': text('Cada juguete a su casa', materials: ['Cajas'], tags: ['orden', 'coches']),
      },
      'searchHints': ['calcetines', 'día de lluvia', 'cajas'],
      'noResults': 'Prueba con otra palabra o toca una idea.',
    },
  );
}

/// Las actividades de [library] en cualquier idioma; cuenta las cargas.
class FakeActivitySource implements IActivitySource {
  FakeActivitySource([ActivityLibrary? library]) : library = library ?? sampleActivityLibrary();

  final ActivityLibrary library;
  final List<String> loadedLanguages = [];

  @override
  Future<ActivityLibrary> load(String languageCode) async {
    loadedLanguages.add(languageCode);
    return library;
  }
}
