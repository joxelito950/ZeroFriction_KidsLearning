import '../memory/memory_ladder.dart';
import '../memory/memory_stars.dart';

/// Mejor resultado de un nivel y cuándo se consiguió (HU-001 R12; HU-002 lo
/// usa para el dorado y para la pérdida gradual de logros, D-030 y D-031).
final class MemoryLevelRecord {
  MemoryLevelRecord({required this.bestStars, required this.achievedAt}) {
    RangeError.checkValueInInterval(bestStars, 0, MemoryStars.max, 'bestStars');
  }

  final int bestStars;
  final DateTime achievedAt;

  @override
  bool operator ==(Object other) =>
      other is MemoryLevelRecord && other.bestStars == bestStars && other.achievedAt == achievedAt;

  @override
  int get hashCode => Object.hash(bestStars, achievedAt);
}

/// Progreso guardado del juego de memoria. No incluye el tiempo ni la partida en
/// curso: al volver se juega un tablero nuevo con el límite de llegada del nivel.
final class MemoryProgress {
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
    final record = MemoryLevelRecord(bestStars: stars, achievedAt: at);
    final MemoryLevelRecord? previous = levelRecords[level];
    final bool improves = previous == null || stars >= previous.bestStars;
    return MemoryProgress(
      currentLevel: step.next.level,
      hasBadge: hasBadge || step.badgeEarned,
      levelRecords: improves ? {...levelRecords, level: record} : levelRecords,
      lastPlayedAt: at,
    );
  }

  /// Estrellas posibles en el juego de memoria: 5 niveles × 3 (HU-002 R2).
  static int get maxStars => MemoryLadder.maxLevel * MemoryStars.max;

  /// Estrellas acumuladas: la mejor de cada nivel (R2).
  int get stars => levelRecords.values.fold(0, (sum, record) => sum + record.bestStars);

  /// Porcentaje dorado del juego, de 0 a 1 (R2, R3).
  double get goldFraction => stars / maxStars;

  /// Quita [count] estrellas empezando por el logro más antiguo que aún tenga
  /// alguna; su fecha no cambia, así que se vacía entero antes de pasar al
  /// siguiente (R8, R14). La insignia no se pierde nunca (R10).
  MemoryProgress loseStars(int count) {
    RangeError.checkNotNegative(count, 'count');
    final records = Map<int, MemoryLevelRecord>.of(levelRecords);
    var left = count;
    while (left > 0) {
      final List<MapEntry<int, MemoryLevelRecord>> withStars =
          records.entries.where((entry) => entry.value.bestStars > 0).toList();
      if (withStars.isEmpty) break;
      final MapEntry<int, MemoryLevelRecord> oldest = withStars.reduce(
        (a, b) => b.value.achievedAt.isBefore(a.value.achievedAt) ? b : a,
      );
      final int taken = left < oldest.value.bestStars ? left : oldest.value.bestStars;
      records[oldest.key] =
          MemoryLevelRecord(bestStars: oldest.value.bestStars - taken, achievedAt: oldest.value.achievedAt);
      left -= taken;
    }
    return MemoryProgress(
      currentLevel: currentLevel,
      hasBadge: hasBadge,
      levelRecords: records,
      lastPlayedAt: lastPlayedAt,
    );
  }

  /// Abrir el juego cuenta como jugar: detiene la pérdida desde ese momento
  /// (R9, R13).
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
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! MemoryProgress ||
        other.currentLevel != currentLevel ||
        other.hasBadge != hasBadge ||
        other.lastPlayedAt != lastPlayedAt ||
        other.levelRecords.length != levelRecords.length) {
      return false;
    }
    return levelRecords.entries.every((entry) => other.levelRecords[entry.key] == entry.value);
  }

  @override
  int get hashCode => Object.hash(
        currentLevel,
        hasBadge,
        lastPlayedAt,
        Object.hashAllUnordered(levelRecords.entries.map((entry) => Object.hash(entry.key, entry.value))),
      );
}
