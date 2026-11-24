/// Actividades sin pantallas (HU-047): ideas para jugar en casa con
/// materiales cotidianos. Son contenido editorial: la estructura viene de
/// `assets/activities/catalog.json` y los textos, del archivo de cada idioma.
library;

/// Las 6 categorías (HU-047 D5).
enum ActivityCategory {
  search,
  sort,
  move,
  art,
  language,
  routine;

  static ActivityCategory fromName(String name) =>
      ActivityCategory.values.firstWhere((category) => category.name == name);
}

/// Una actividad con sus textos en un idioma.
final class Activity {
  const Activity({
    required this.id,
    required this.category,
    required this.minutes,
    required this.ageFrom,
    required this.recommended,
    required this.title,
    required this.goal,
    required this.materials,
    required this.steps,
    required this.variants,
    required this.safety,
    required this.tags,
  });

  /// Filtros de tiempo «hasta N minutos» (P12). Una actividad puede durar
  /// cualquier número de minutos.
  static const List<int> durations = [5, 10, 15, 30];

  /// Cuántas se recomiendan para seguir jugando (P11).
  static const int recommendedCount = 3;

  final String id;
  final ActivityCategory category;
  final int minutes;

  /// Edad mínima recomendada, en años.
  final int ageFrom;

  /// Las 3 para seguir jugando elegidas a mano (P11). Puede venir vacía: con
  /// cientos de actividades, las que falten se eligen solas
  /// ([ActivityLibrary.recommendedFor]).
  final List<String> recommended;

  final String title;

  /// Qué practica el niño, en una frase.
  final String goal;
  final List<String> materials;
  final List<String> steps;
  final List<String> variants;

  /// La advertencia de esta actividad (D6).
  final String safety;

  /// Materiales, gustos y momentos con los que se la encuentra (P12).
  final List<String> tags;
}

/// Las actividades de un idioma, con la sugerencia del día y la búsqueda.
final class ActivityLibrary {
  ActivityLibrary({required List<Activity> activities, required this.searchHints, required this.noResults})
      : activities = List.unmodifiable(activities),
        _byId = {for (final Activity activity in activities) activity.id: activity};

  /// Lee la estructura (`catalog.json`) y los textos de un idioma. Una
  /// actividad que aún no está traducida a ese idioma usa los textos de
  /// [fallback] (el inglés); si tampoco está ahí, no se muestra. Así se puede
  /// traducir poco a poco.
  factory ActivityLibrary.fromJson(
    Map<String, dynamic> catalog,
    Map<String, dynamic> texts, {
    Map<String, dynamic>? fallback,
  }) {
    Map<String, dynamic> activitiesOf(Map<String, dynamic>? file) =>
        ((file?['activities'] as Map?) ?? const {}).cast<String, dynamic>();
    final Map<String, dynamic> byId = activitiesOf(texts);
    final Map<String, dynamic> fallbackById = activitiesOf(fallback);
    List<String> strings(Object? value) => [for (final Object? item in (value as List?) ?? const []) item as String];
    return ActivityLibrary(
      activities: [
        for (final Object? raw in catalog['activities'] as List)
          if ((byId[(raw as Map)['id']] ?? fallbackById[raw['id']]) case final Map<dynamic, dynamic> text)
            Activity(
              id: raw['id'] as String,
              category: ActivityCategory.fromName(raw['category'] as String),
              minutes: raw['minutes'] as int,
              ageFrom: raw['ageFrom'] as int,
              recommended: strings(raw['recommended']),
              title: text['title'] as String,
              goal: text['goal'] as String,
              materials: strings(text['materials']),
              steps: strings(text['steps']),
              variants: strings(text['variants']),
              safety: text['safety'] as String,
              tags: strings(text['tags']),
            ),
      ],
      searchHints: strings(texts['searchHints'] ?? fallback?['searchHints']),
      noResults: (texts['noResults'] ?? fallback?['noResults'] ?? '') as String,
    );
  }

  /// En el orden del catálogo: por categorías.
  final List<Activity> activities;

  /// Búsquedas de ejemplo que se tocan: materiales, gustos e ideas (P12).
  final List<String> searchHints;

  /// La frase cuando no hay resultados (P12).
  final String noResults;

  final Map<String, Activity> _byId;

  Activity? byId(String id) => _byId[id];

  /// Las 3 para seguir jugando (P11): primero las elegidas a mano; si faltan,
  /// una de la misma categoría y el resto de otras, las que más materiales y
  /// etiquetas comparten con [activity]. A igualdad, en el orden del catálogo.
  List<Activity> recommendedFor(Activity activity) {
    final List<Activity> chosen = [
      for (final String id in activity.recommended)
        if (_byId[id] case final Activity other when other.id != activity.id) other,
    ];
    if (chosen.length >= Activity.recommendedCount) return chosen.take(Activity.recommendedCount).toList();
    final Set<String> words = _wordsOf(activity);
    int shared(Activity other) => _wordsOf(other).intersection(words).length;
    final List<Activity> ranked = [
      for (final Activity other in activities)
        if (other.id != activity.id && !chosen.contains(other)) other,
    ];
    // Estable: a igualdad de palabras compartidas, se respeta el catálogo.
    final Map<Activity, int> order = {for (final (index, other) in ranked.indexed) other: index};
    ranked.sort((a, b) {
      final int byShared = shared(b).compareTo(shared(a));
      return byShared != 0 ? byShared : order[a]!.compareTo(order[b]!);
    });
    if (!chosen.any((other) => other.category == activity.category)) {
      final Activity? same = ranked.where((other) => other.category == activity.category).firstOrNull;
      if (same != null) chosen.add(same);
    }
    for (final Activity other in ranked) {
      if (chosen.length >= Activity.recommendedCount) break;
      if (other.category != activity.category && !chosen.contains(other)) chosen.add(other);
    }
    return chosen;
  }

  final Map<String, Set<String>> _words = {};

  /// Palabras de los materiales y las etiquetas, para comparar actividades.
  Set<String> _wordsOf(Activity activity) => _words[activity.id] ??= {
        for (final String word in normalize([...activity.materials, ...activity.tags].join(' ')).split(' '))
          if (word.length > 3) word,
      };

  /// El orden de las sugerencias del día: una de cada categoría por turno,
  /// para no repetir categoría dos días seguidos ni actividad hasta
  /// recorrerlas todas (P10).
  late final List<Activity> dailyOrder = _dailyOrder();

  List<Activity> _dailyOrder() {
    final Map<ActivityCategory, List<Activity>> byCategory = {
      for (final ActivityCategory category in ActivityCategory.values)
        category: activities.where((activity) => activity.category == category).toList(),
    };
    final int rounds = byCategory.values.fold(0, (longest, list) => list.length > longest ? list.length : longest);
    return [
      for (var round = 0; round < rounds; round++)
        for (final ActivityCategory category in ActivityCategory.values)
          if (round < byCategory[category]!.length) byCategory[category]![round],
    ];
  }

  /// La sugerencia del día [day]: la misma todo el día, sin guardar nada
  /// (P10, R9). `null` sin actividades.
  Activity? suggestionFor(DateTime day) {
    final List<Activity> order = dailyOrder;
    if (order.isEmpty) return null;
    final int days = DateTime.utc(day.year, day.month, day.day).difference(DateTime.utc(2026)).inDays;
    return order[days % order.length];
  }

  /// Busca por texto en el título, el objetivo, los materiales y las
  /// etiquetas; todas las palabras tienen que aparecer. Sin distinguir
  /// mayúsculas ni tildes. Además, por categoría y por tiempo: las que duran
  /// como mucho [maxMinutes] (P12).
  List<Activity> search(String query, {ActivityCategory? category, int? maxMinutes}) {
    final List<String> words = normalize(query).split(' ').where((word) => word.isNotEmpty).toList();
    return [
      for (final Activity activity in activities)
        if ((category == null || activity.category == category) &&
            (maxMinutes == null || activity.minutes <= maxMinutes) &&
            words.every(_haystackOf(activity).contains))
          activity,
    ];
  }

  final Map<String, String> _haystacks = {};

  String _haystackOf(Activity activity) => _haystacks[activity.id] ??=
      normalize([activity.title, activity.goal, ...activity.materials, ...activity.tags].join(' '));

  /// Minúsculas, sin tildes ni diéresis y con un solo espacio entre palabras.
  static String normalize(String text) {
    final StringBuffer out = StringBuffer();
    for (final int rune in text.toLowerCase().runes) {
      final String char = String.fromCharCode(rune);
      out.write(_plain[char] ?? char);
    }
    return out.toString().replaceAll(RegExp(r'[\s,.;:¡!¿?«»"()]+'), ' ').trim();
  }

  static const Map<String, String> _plain = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ä': 'a', 'ã': 'a', //
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', //
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', //
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', //
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', //
    'ñ': 'n', 'ç': 'c', 'ß': 'ss', 'œ': 'oe', 'æ': 'ae',
  };
}

/// De dónde salen las actividades de un idioma (en `data/`, de los assets).
abstract interface class IActivitySource {
  /// Las actividades en [languageCode]; si ese idioma aún no tiene textos, las
  /// del inglés.
  Future<ActivityLibrary> load(String languageCode);
}
