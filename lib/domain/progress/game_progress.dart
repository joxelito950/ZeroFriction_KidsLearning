import '../settings/game_difficulty.dart';
import 'level_record.dart';
import 'round_ladder.dart';
import 'star_decay.dart';

/// Los juegos con progreso guardado.
enum GameId { memory, shadows, oddOneOut, vehicles, sorting }

/// Progreso común de cualquier juego con rondas (HU-037, sección 10.1): dónde
/// se sigue, las medallas y el mejor resultado de cada ronda y nivel.
final class GameProgress implements DecayingProgress<GameProgress> {
  GameProgress({
    required this.position,
    Set<GameDifficulty> medals = const {},
    Map<RoundLevel, LevelRecord> records = const {},
    this.lastPlayedAt,
    this.stuckLevel,
    this.stuckFalls = 0,
  })  : medals = Set.unmodifiable(medals),
        records = Map.unmodifiable(records) {
    RangeError.checkNotNegative(stuckFalls, 'stuckFalls');
    if ((stuckLevel == null) != (stuckFalls == 0)) {
      throw ArgumentError('stuckLevel and stuckFalls go together (HU-034 R4)');
    }
    for (final RoundLevel key in records.keys) {
      if (key.level == RoundLadder.tutorial) {
        throw ArgumentError.value(key, 'records', 'the tutorial gives no stars (HU-037 P2)');
      }
    }
  }

  /// Quien nunca ha jugado: el tutorial, al principio del bronce (R1; HU-051
  /// R1), sin medallas.
  factory GameProgress.initial() =>
      GameProgress(position: const RoundPosition(round: GameDifficulty.bronze, level: RoundLadder.tutorial));

  /// Lo leído del teléfono. El tutorial solo se juega al empezar el juego
  /// (HU-051 P5, P8): quien está en él pero ya jugó (tiene estrellas o
  /// medallas), o está en otra ronda, sigue en el primer nivel con tiempo.
  factory GameProgress.restored({
    required RoundPosition position,
    Set<GameDifficulty> medals = const {},
    Map<RoundLevel, LevelRecord> records = const {},
    DateTime? lastPlayedAt,
    int? stuckLevel,
    int stuckFalls = 0,
  }) {
    final bool skipTutorial = position.isTutorial &&
        (position.round != GameDifficulty.bronze || medals.isNotEmpty || records.isNotEmpty);
    return GameProgress(
      position: skipTutorial
          ? RoundPosition(round: position.round, level: RoundLadder.firstTimedLevel, tutorialFalls: position.tutorialFalls)
          : position,
      medals: medals,
      records: records,
      lastPlayedAt: lastPlayedAt,
      stuckLevel: stuckLevel,
      stuckFalls: stuckFalls,
    );
  }

  /// Lo guardado antes de HU-037 (P7): se sigue en la antigua **Normal**, que
  /// con HU-051 es el **oro**, en el mismo nivel; la insignia única vale las
  /// medallas hasta el oro, y las estrellas pasan al oro, salvo las del nivel 1,
  /// que ahora es el tutorial (P2).
  factory GameProgress.migrate({
    required int currentLevel,
    required bool hadBadge,
    required Map<int, LevelRecord> levelRecords,
    DateTime? lastPlayedAt,
  }) =>
      GameProgress.restored(
        position: RoundPosition(round: GameDifficulty.gold, level: currentLevel),
        medals: hadBadge ? GameDifficulty.medalsFromSaved('normal') : const {},
        records: {
          for (final MapEntry<int, LevelRecord> entry in levelRecords.entries)
            if (entry.key != RoundLadder.tutorial) RoundLevel(GameDifficulty.gold, entry.key): entry.value,
        },
        lastPlayedAt: lastPlayedAt,
      );

  /// Ronda, nivel y caídas al tutorial. El tiempo no se guarda: se deduce de la
  /// escalera al volver (como HU-001 R12).
  final RoundPosition position;

  /// Rondas completadas, cada una con su medalla (de bronce a diamante, HU-051).
  /// No se pierden nunca (P5).
  final Set<GameDifficulty> medals;

  final Map<RoundLevel, LevelRecord> records;

  @override
  final DateTime? lastPlayedAt;

  /// Veces que hay que llegar al mismo nivel y volver a bajar sin superarlo
  /// para sugerir al adulto una ronda más tranquila (HU-034 P7).
  static const int stuckThreshold = 3;

  /// Nivel de la ronda actual al que el niño llega y del que vuelve a bajar sin
  /// superarlo (HU-034 R4); `null` si no hay ninguno.
  final int? stuckLevel;

  /// Veces que ha perdido en [stuckLevel] desde la última vez que lo superó.
  final int stuckFalls;

  /// El niño está atascado: toca sugerir una ronda más tranquila (§4.5).
  bool get isStuck => stuckFalls >= stuckThreshold;

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
    // Superar el nivel donde se atascaba, o pasar de ronda, borra la cuenta.
    final int? stuck = stuckLevel;
    final bool cleared = stuck == null || won.level >= stuck || step.next.round != won.round;
    return GameProgress(
      position: step.next,
      medals: {...medals, if (step.medal case final GameDifficulty medal) medal},
      records: next,
      lastPlayedAt: at,
      stuckLevel: cleared ? null : stuck,
      stuckFalls: cleared ? 0 : stuckFalls,
    );
  }

  /// Registra una derrota por tiempo en [lost]: cambian la posición y la fecha,
  /// y la cuenta de «atascado» (HU-034 R4): perder en el mismo nivel suma;
  /// perder en uno más alto empieza la cuenta allí; en uno más bajo, no cambia.
  /// Bajar de ronda (HU-037 R10) la borra.
  GameProgress recordLoss({required RoundPosition lost, required RoundStep step, required DateTime at}) {
    final int? stuck = stuckLevel;
    final (int?, int) next = switch (stuck) {
      _ when step.next.round != lost.round => (null, 0),
      null => (lost.level, 1),
      _ when lost.level == stuck => (stuck, stuckFalls + 1),
      _ when lost.level > stuck => (lost.level, 1),
      _ => (stuck, stuckFalls),
    };
    return GameProgress(
      position: step.next,
      medals: medals,
      records: records,
      lastPlayedAt: at,
      stuckLevel: next.$1,
      stuckFalls: next.$2,
    );
  }

  /// El adulto cambia la ronda (P1): se empieza por su primer nivel con tiempo
  /// (HU-051 R3b), sin perder estrellas ni medallas (R5). La cuenta de
  /// «atascado» empieza de cero.
  GameProgress withRound(GameDifficulty round) => GameProgress(
        position: RoundPosition(round: round, level: RoundLadder.firstTimedLevel),
        medals: medals,
        records: records,
        lastPlayedAt: lastPlayedAt,
      );

  /// El adulto responde «Ahora no» a la sugerencia (HU-034 §4.5): la cuenta de
  /// «atascado» vuelve a cero y no reaparece hasta otras 3 caídas.
  GameProgress withoutStuck() => GameProgress(
        position: position,
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
      stuckLevel: stuckLevel,
      stuckFalls: stuckFalls,
    );
  }

  @override
  GameProgress playedAt(DateTime at) => GameProgress(
        position: position,
        medals: medals,
        records: records,
        lastPlayedAt: at,
        stuckLevel: stuckLevel,
        stuckFalls: stuckFalls,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameProgress &&
          other.position == position &&
          other.lastPlayedAt == lastPlayedAt &&
          other.stuckLevel == stuckLevel &&
          other.stuckFalls == stuckFalls &&
          other.medals.length == medals.length &&
          other.medals.containsAll(medals) &&
          other.records.length == records.length &&
          records.entries.every((entry) => other.records[entry.key] == entry.value);

  @override
  int get hashCode => Object.hash(
        position,
        lastPlayedAt,
        stuckLevel,
        stuckFalls,
        Object.hashAllUnordered(medals),
        Object.hashAllUnordered(records.entries.map((entry) => Object.hash(entry.key, entry.value))),
      );
}

/// Clave de un resultado: ronda y nivel. Se guarda como `ronda * 10 + nivel`
/// (sección 10.1).
final class RoundLevel {
  const RoundLevel(this.round, this.level);

  factory RoundLevel.fromKey(int key) => RoundLevel(GameDifficulty.values[key ~/ 10], key % 10);

  /// Clave guardada antes de HU-051, con las tres rondas antiguas.
  factory RoundLevel.fromLegacyKey(int key) => RoundLevel(GameDifficulty.fromLegacyIndex(key ~/ 10), key % 10);

  /// Lee una clave guardada: [legacy] si es de antes de HU-051.
  factory RoundLevel.fromSaved(int key, {required bool legacy}) =>
      legacy ? RoundLevel.fromLegacyKey(key) : RoundLevel.fromKey(key);

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
