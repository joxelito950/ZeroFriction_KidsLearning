/// Las ocho rondas de cada juego (HU-051, D-042), con el nombre de su medalla:
/// de bronce (el antiguo Fácil) a diamante (el antiguo Reto máximo). La
/// dificultad, las ayudas y los tiempos se reparten entre ellas en pasos
/// pequeños; cada juego define qué cambia en cada una.
enum GameDifficulty {
  bronze,
  silver,
  gold,
  ruby,
  emerald,
  sapphire,
  obsidian,
  diamond;

  /// Nombres guardados antes de HU-051 (tres rondas) y la ronda a la que pasan
  /// (HU-051 sección 6): Fácil → bronce, Normal → oro, Reto máximo → diamante.
  static const Map<String, GameDifficulty> legacyNames = {
    'easy': bronze,
    'normal': gold,
    'impossible': diamond,
  };

  /// Las rondas antiguas en su orden de entonces: las claves de los récords
  /// guardados antes de HU-051 son `ronda antigua × 10 + nivel`.
  static const List<GameDifficulty> _legacyOrder = [bronze, gold, diamond];

  static bool isLegacyName(String? name) => legacyNames.containsKey(name);

  /// Lee el valor guardado, también los nombres de antes de HU-051. Uno
  /// desconocido (o ninguno) es oro, la antigua Normal.
  static GameDifficulty fromName(String? name) =>
      legacyNames[name] ?? values.firstWhere((value) => value.name == name, orElse: () => gold);

  /// Medallas que vale una medalla guardada antes de HU-051: todas las rondas
  /// hasta la suya (la de Normal da bronce, plata y oro). Un nombre nuevo vale
  /// solo su medalla.
  static Set<GameDifficulty> medalsFromSaved(String name) {
    final GameDifficulty? legacy = legacyNames[name];
    if (legacy == null) return {fromName(name)};
    return {for (final GameDifficulty round in values) if (round.index <= legacy.index) round};
  }

  /// Ronda de una clave de récord guardada antes de HU-051.
  static GameDifficulty fromLegacyIndex(int index) => _legacyOrder[index.clamp(0, _legacyOrder.length - 1)];
}
