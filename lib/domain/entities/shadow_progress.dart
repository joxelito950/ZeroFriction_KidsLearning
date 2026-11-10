import '../progress/level_record.dart';
import '../progress/star_decay.dart';
import '../shadows/shadow_ladder.dart';

/// Progreso guardado de Sombras (HU-007 R14), con el mismo formato que la
/// memoria (P8). No incluye el tiempo ni la partida en curso: al volver se juega
/// un tablero nuevo con el límite de llegada del nivel.
final class ShadowProgress implements DecayingProgress<ShadowProgress> {
  ShadowProgress({
    required this.currentLevel,
    this.hasMedal = false,
    Map<int, LevelRecord> levelRecords = const {},
    this.lastPlayedAt,
  }) : levelRecords = Map.unmodifiable(levelRecords) {
    ShadowLadder.levelAt(currentLevel);
    levelRecords.keys.forEach(ShadowLadder.levelAt);
  }

  const ShadowProgress._initial()
      : currentLevel = 1,
        hasMedal = false,
        levelRecords = const {},
        lastPlayedAt = null;

  /// Quien nunca ha jugado: nivel 1, sin medalla ni resultados.
  static const ShadowProgress initial = ShadowProgress._initial();

  /// Nivel en el que se sigue. Puede ser el 8 aunque ya no haya Premium: la
  /// escalera lo juega como el 7 (`ShadowLadder.arrivalPosition`).
  final int currentLevel;

  /// Medalla por superar el nivel 8 con Premium. Es permanente (R10).
  final bool hasMedal;

  /// Mejor resultado por número de nivel.
  final Map<int, LevelRecord> levelRecords;

  /// Última partida jugada, ganada o perdida (para D-031).
  @override
  final DateTime? lastPlayedAt;

  /// Estrellas posibles en Sombras: 8 niveles × 3. Sin Premium se llega como
  /// mucho a 14 (7 niveles × 2, sección 3).
  static int get maxStars => ShadowLadder.maxLevel * LevelRecord.maxStars;

  /// Estrellas acumuladas: la mejor de cada nivel.
  int get stars => LevelRecord.totalStars(levelRecords);

  /// Dorado del juego, de 0 a 1 (HU-002).
  double get goldFraction => stars / maxStars;

  /// Registra una victoria en [level] con [stars]. Un resultado igual o mejor
  /// renueva el récord con su fecha; uno peor lo deja como estaba.
  ShadowProgress recordWin({
    required int level,
    required int stars,
    required ShadowStep step,
    required DateTime at,
  }) {
    ShadowLadder.levelAt(level);
    return ShadowProgress(
      currentLevel: step.next.level,
      hasMedal: hasMedal || step.medalEarned,
      levelRecords: LevelRecord.improve(levelRecords, level: level, stars: stars, at: at),
      lastPlayedAt: at,
    );
  }

  /// Registra una derrota por tiempo: solo cambia el nivel y la fecha de juego.
  ShadowProgress recordLoss({required ShadowStep step, required DateTime at}) =>
      _copy(currentLevel: step.next.level, lastPlayedAt: at);

  /// La medalla no se pierde nunca (HU-002 R10).
  @override
  ShadowProgress loseStars(int count) => _copy(levelRecords: LevelRecord.loseOldest(levelRecords, count));

  @override
  ShadowProgress playedAt(DateTime at) => _copy(lastPlayedAt: at);

  ShadowProgress _copy({int? currentLevel, Map<int, LevelRecord>? levelRecords, DateTime? lastPlayedAt}) =>
      ShadowProgress(
        currentLevel: currentLevel ?? this.currentLevel,
        hasMedal: hasMedal,
        levelRecords: levelRecords ?? this.levelRecords,
        lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShadowProgress &&
          other.currentLevel == currentLevel &&
          other.hasMedal == hasMedal &&
          other.lastPlayedAt == lastPlayedAt &&
          LevelRecord.sameRecords(other.levelRecords, levelRecords);

  @override
  int get hashCode => Object.hash(currentLevel, hasMedal, lastPlayedAt, LevelRecord.hashRecords(levelRecords));
}
