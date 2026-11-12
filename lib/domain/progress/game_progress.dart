import '../settings/game_difficulty.dart';
import 'level_record.dart';
import 'round_ladder.dart';
import 'star_decay.dart';

/// Los juegos con progreso guardado.
enum GameId { memory, shadows, oddOneOut }

/// Progreso común de cualquier juego con rondas (HU-037, sección 10.1): dónde
/// se sigue, las medallas y el mejor resultado de cada ronda y nivel.
final class GameProgress implements DecayingProgress<GameProgress> {
  GameProgress({
    required this.position,
    Set<GameDifficulty> medals = const {},
    Map<RoundLevel, LevelRecord> records = const {},
    this.lastPlayedAt,
  })  : medals = Set.unmodifiable(medals),
        records = Map.unmodifiable(records) {
    for (final RoundLevel key in records.keys) {
      if (key.level == RoundLadder.tutorial) {
        throw ArgumentError.value(key, 'records', 'the tutorial gives no stars (HU-037 P2)');
      }
    }
  }

  /// Quien nunca ha jugado: el tutorial de Fácil (R1), sin medallas.
  factory GameProgress.initial() =>
      GameProgress(position: const RoundPosition(round: GameDifficulty.easy, level: RoundLadder.tutorial));

  /// Lo guardado antes de HU-037 (P7): se sigue en **Normal**, en el mismo
  /// nivel; la insignia o medalla única pasa a bronce y plata, y las estrellas,
  /// a la ronda Normal, salvo las del nivel 1, que ahora es el tutorial (P2).
  factory GameProgress.migrate({
    required int currentLevel,
    required bool hadBadge,
    required Map<int, LevelRecord> levelRecords,
    DateTime? lastPlayedAt,
  }) =>
      GameProgress(
        position: RoundPosition(round: GameDifficulty.normal, level: currentLevel),
        medals: hadBadge ? const {GameDifficulty.easy, GameDifficulty.normal} : const {},
        records: {
          for (final MapEntry<int, LevelRecord> entry in levelRecords.entries)
            if (entry.key != RoundLadder.tutorial) RoundLevel(GameDifficulty.normal, entry.key): entry.value,
        },
        lastPlayedAt: lastPlayedAt,
      );

  /// Ronda, nivel y caídas al tutorial. El tiempo no se guarda: se deduce de la
  /// escalera al volver (como HU-001 R12).
  final RoundPosition position;

  /// Rondas completadas: bronce (Fácil), plata (Normal) y oro (Imposible).
  /// No se pierden nunca (P5).
  final Set<GameDifficulty> medals;

  final Map<RoundLevel, LevelRecord> records;

  @override
  final DateTime? lastPlayedAt;

  /// La medalla más alta, para el menú; `null` si no hay ninguna.
  GameDifficulty? get bestMedal {
    for (final GameDifficulty round in GameDifficulty.values.reversed) {
      if (medals.contains(round)) return round;
    }
    return null;
  }

  int get stars => records.values.fold(0, (sum, record) => sum + record.bestStars);

  /// Dorado de 0 a 1 sobre las tres rondas de [ladder] (sección 10.3).
  double goldFraction(RoundLadder ladder) => stars / ladder.maxStars;

  /// Registra una victoria en [at]: estrellas del nivel ganado (salvo el
  /// tutorial), medalla si completó la ronda y la posición siguiente.
  GameProgress recordWin({required RoundPosition won, required int stars, required RoundStep step, required DateTime at}) {
    final Map<RoundLevel, LevelRecord> next = Map.of(records);
    if (!won.isTutorial) {
      // Un resultado igual o mejor renueva el récord con su fecha (D-030).
      final key = RoundLevel(won.round, won.level);
      final LevelRecord? previous = records[key];
      if (previous == null || stars >= previous.bestStars) next[key] = LevelRecord(bestStars: stars, achievedAt: at);
    }
    return GameProgress(
      position: step.next,
      medals: {...medals, if (step.medal case final GameDifficulty medal) medal},
      records: next,
      lastPlayedAt: at,
    );
  }

  /// Registra una derrota por tiempo: solo cambian la posición y la fecha.
  GameProgress recordLoss({required RoundStep step, required DateTime at}) =>
      GameProgress(position: step.next, medals: medals, records: records, lastPlayedAt: at);

  /// El adulto cambia la ronda (P1): se empieza por su tutorial, sin perder
  /// estrellas ni medallas (R5).
  GameProgress withRound(GameDifficulty round) => GameProgress(
        position: RoundPosition(round: round, level: RoundLadder.tutorial),
        medals: medals,
        records: records,
        lastPlayedAt: lastPlayedAt,
      );

  /// Quita estrellas empezando por el logro más antiguo, en cualquier ronda (R6).
  @override
  GameProgress loseStars(int count) {
    final List<RoundLevel> keys = records.keys.toList();
    final Map<int, LevelRecord> flat = {for (var i = 0; i < keys.length; i++) i: records[keys[i]]!};
    final Map<int, LevelRecord> left = LevelRecord.loseOldest(flat, count);
    return GameProgress(
      position: position,
      medals: medals,
      records: {for (var i = 0; i < keys.length; i++) keys[i]: left[i]!},
      lastPlayedAt: lastPlayedAt,
    );
  }

  @override
  GameProgress playedAt(DateTime at) =>
      GameProgress(position: position, medals: medals, records: records, lastPlayedAt: at);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameProgress &&
          other.position == position &&
          other.lastPlayedAt == lastPlayedAt &&
          other.medals.length == medals.length &&
          other.medals.containsAll(medals) &&
          other.records.length == records.length &&
          records.entries.every((entry) => other.records[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
        position,
        lastPlayedAt,
        Object.hashAllUnordered(medals),
        Object.hashAllUnordered(records.entries.map((entry) => Object.hash(entry.key, entry.value))),
      );
}

/// Clave de un resultado: ronda y nivel. Se guarda como `ronda * 10 + nivel`
/// (sección 10.1).
final class RoundLevel {
  const RoundLevel(this.round, this.level);

  factory RoundLevel.fromKey(int key) => RoundLevel(GameDifficulty.values[key ~/ 10], key % 10);

  final GameDifficulty round;
  final int level;

  int get key => round.index * 10 + level;

  @override
  bool operator ==(Object other) => other is RoundLevel && other.round == round && other.level == level;

  @override
  int get hashCode => Object.hash(round, level);

  @override
  String toString() => '${round.name}/$level';
}
