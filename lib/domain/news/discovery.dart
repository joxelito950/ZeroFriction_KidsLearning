import '../progress/game_progress.dart';
import '../settings/game_difficulty.dart';

/// Opciones de la Zona de Padres, para destacar las nuevas (HU-041 R7).
enum ParentsFeature { progress, language, sound, games, playTime, pin, feedback, privacy }

/// Lo que el niño y el adulto ya han descubierto (HU-041): cuántas veces se ha
/// abierto cada juego y qué opciones de la Zona de Padres se han visto. No se
/// guarda la versión (R1): así funciona con cualquier actualización.
final class Discovery {
  Discovery({Map<GameId, int> gameOpens = const {}, Set<ParentsFeature> seenFeatures = const {}})
      : gameOpens = Map.unmodifiable(gameOpens),
        seenFeatures = Set.unmodifiable(seenFeatures) {
    for (final int opens in gameOpens.values) {
      RangeError.checkValueInInterval(opens, 0, opensToSee, 'gameOpens');
    }
  }

  /// Instalación nueva (R2): todo lo que existe ya cuenta como visto.
  factory Discovery.allSeen() => Discovery(
        gameOpens: {for (final GameId game in GameId.values) game: opensToSee},
        seenFeatures: ParentsFeature.values.toSet(),
      );

  /// Perfil guardado antes de HU-041: había visto lo que existía en
  /// `1.0.0-rc.5` (sección 5), para no destacar nada viejo al actualizar.
  factory Discovery.beforeNews() => Discovery(
        gameOpens: {for (final GameId game in gamesInRc5) game: opensToSee},
        seenFeatures: featuresInRc5,
      );

  /// Veces que hay que abrir un juego nuevo para que deje de destacarse (P1).
  static const int opensToSee = 3;

  /// Juegos de la versión `1.0.0-rc.5`. **No cambiar** al añadir juegos.
  static const Set<GameId> gamesInRc5 = {GameId.memory, GameId.shadows, GameId.oddOneOut};

  /// Filas de la Zona de Padres en `1.0.0-rc.5` («Su progreso» llegó después).
  /// **No cambiar** al añadir opciones.
  static const Set<ParentsFeature> featuresInRc5 = {
    ParentsFeature.language,
    ParentsFeature.sound,
    ParentsFeature.games,
    ParentsFeature.playTime,
    ParentsFeature.pin,
    ParentsFeature.feedback,
    ParentsFeature.privacy,
  };

  /// Veces abierto, hasta [opensToSee] (después ya no importa).
  final Map<GameId, int> gameOpens;
  final Set<ParentsFeature> seenFeatures;

  int opensOf(GameId game) => gameOpens[game] ?? 0;

  /// El juego se destaca en el menú hasta abrirlo por tercera vez o superar la
  /// ronda plata en él (R4, P1).
  bool isNewGame(GameId game, GameProgress progress) =>
      opensOf(game) < opensToSee && !progress.medals.contains(GameDifficulty.silver);

  /// El niño abre [game].
  Discovery openedGame(GameId game) {
    if (opensOf(game) >= opensToSee) return this;
    return Discovery(gameOpens: {...gameOpens, game: opensOf(game) + 1}, seenFeatures: seenFeatures);
  }

  /// La fila de [feature] lleva «Nuevo» hasta que el adulto la abre (R7).
  bool isNewFeature(ParentsFeature feature) => !seenFeatures.contains(feature);

  Discovery sawFeature(ParentsFeature feature) => seenFeatures.contains(feature)
      ? this
      : Discovery(gameOpens: gameOpens, seenFeatures: {...seenFeatures, feature});

  @override
  bool operator ==(Object other) =>
      other is Discovery &&
      other.gameOpens.length == gameOpens.length &&
      gameOpens.entries.every((entry) => other.gameOpens[entry.key] == entry.value) &&
      other.seenFeatures.length == seenFeatures.length &&
      other.seenFeatures.containsAll(seenFeatures);

  @override
  int get hashCode => Object.hash(
        Object.hashAllUnordered(gameOpens.entries.map((entry) => Object.hash(entry.key, entry.value))),
        Object.hashAllUnordered(seenFeatures),
      );

  @override
  String toString() => 'Discovery($gameOpens, $seenFeatures)';
}
