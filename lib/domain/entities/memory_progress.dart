import '../memory/memory_ladder.dart';
import '../memory/memory_stars.dart';
import '../progress/level_record.dart';
import '../progress/star_decay.dart';

/// Mejor resultado de un nivel de la memoria (HU-001 R12): el mismo de todos
/// los juegos.
typedef MemoryLevelRecord = LevelRecord;

/// Progreso guardado del juego de memoria. No incluye el tiempo ni la partida en
/// curso: al volver se juega un tablero nuevo con el límite de llegada del nivel.
final class MemoryProgress implements DecayingProgress<MemoryProgress> {
  MemoryProgress({
    required this.currentLevel,
    this.hasBadge = false,
    Map<int, MemoryLevelRecord> levelRecords = const {},
    this.lastPlayedAt,
  }) : levelRecords = Map.unmodifiable(levelRecords) {
    MemoryLadder.levelAt(currentLevel);
  }

  const MemoryProgress._initial()
      : currentLevel = 1,
        hasBadge = false,
        levelRecords = const {},
        lastPlayedAt = null;

  /// Quien nunca ha jugado: nivel 1, sin insignia ni resultados.
  static const MemoryProgress initial = MemoryProgress._initial();

  final int currentLevel;

  /// Insignia por superar el último nivel. Es permanente (R8).
  final bool hasBadge;

  /// Mejor resultado por número de nivel.
  final Map<int, MemoryLevelRecord> levelRecords;

  /// Última partida jugada, ganada o perdida (para D-031).
  @override
  final DateTime? lastPlayedAt;

  /// Registra una victoria en [level] con [stars]. Un resultado igual o mejor
  /// renueva el récord con su fecha; uno peor lo deja como estaba.
  MemoryProgress recordWin({
    required int level,
    required int stars,
    required MemoryLadderStep step,
    required DateTime at,
  }) {
    MemoryLadder.levelAt(level);
    return MemoryProgress(
      currentLevel: step.next.level,
      hasBadge: hasBadge || step.badgeEarned,
      levelRecords: LevelRecord.improve(levelRecords, level: level, stars: stars, at: at),
      lastPlayedAt: at,
    );
  }

  /// Estrellas posibles en el juego de memoria: 5 niveles × 3 (HU-002 R2).
  static int get maxStars => MemoryLadder.maxLevel * MemoryStars.max;

  /// Estrellas acumuladas: la mejor de cada nivel (R2).
  int get stars => LevelRecord.totalStars(levelRecords);

  /// Porcentaje dorado del juego, de 0 a 1 (R2, R3).
  double get goldFraction => stars / maxStars;

  /// Quita [count] estrellas empezando por el logro más antiguo que aún tenga
  /// alguna; su fecha no cambia, así que se vacía entero antes de pasar al
  /// siguiente (R8, R14). La insignia no se pierde nunca (R10).
  @override
  MemoryProgress loseStars(int count) => MemoryProgress(
        currentLevel: currentLevel,
        hasBadge: hasBadge,
        levelRecords: LevelRecord.loseOldest(levelRecords, count),
        lastPlayedAt: lastPlayedAt,
      );

  /// Abrir el juego cuenta como jugar: detiene la pérdida desde ese momento
  /// (R9, R13).
  @override
  MemoryProgress playedAt(DateTime at) => MemoryProgress(
        currentLevel: currentLevel,
        hasBadge: hasBadge,
        levelRecords: levelRecords,
        lastPlayedAt: at,
      );

  /// Registra una derrota por tiempo: solo cambia el nivel y la fecha de juego.
  MemoryProgress recordLoss({required MemoryLadderStep step, required DateTime at}) {
    return MemoryProgress(
      currentLevel: step.next.level,
      hasBadge: hasBadge,
      levelRecords: levelRecords,
      lastPlayedAt: at,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryProgress &&
          other.currentLevel == currentLevel &&
          other.hasBadge == hasBadge &&
          other.lastPlayedAt == lastPlayedAt &&
          LevelRecord.sameRecords(other.levelRecords, levelRecords);

  @override
  int get hashCode => Object.hash(currentLevel, hasBadge, lastPlayedAt, LevelRecord.hashRecords(levelRecords));
}
