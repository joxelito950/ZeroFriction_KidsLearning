/// Mejor resultado de un nivel y cuándo se consiguió, igual en todos los juegos
/// (D-030): de 0 a 3 estrellas. HU-002 lo usa para el dorado y para la pérdida
/// gradual de logros (D-031).
final class LevelRecord {
  LevelRecord({required this.bestStars, required this.achievedAt}) {
    RangeError.checkValueInInterval(bestStars, 0, maxStars, 'bestStars');
  }

  /// Estrellas por nivel en todos los juegos (D-030).
  static const int maxStars = 3;

  final int bestStars;
  final DateTime achievedAt;

  /// Guarda [stars] en [level] si igualan o mejoran el récord, con su fecha; si
  /// no, devuelve los récords como estaban.
  static Map<int, LevelRecord> improve(
    Map<int, LevelRecord> records, {
    required int level,
    required int stars,
    required DateTime at,
  }) {
    final LevelRecord? previous = records[level];
    if (previous != null && stars < previous.bestStars) return records;
    return {...records, level: LevelRecord(bestStars: stars, achievedAt: at)};
  }

  /// Quita [count] estrellas empezando por el logro más antiguo que aún tenga
  /// alguna; su fecha no cambia, así que se vacía entero antes de pasar al
  /// siguiente (HU-002 R8, R14).
  static Map<int, LevelRecord> loseOldest(Map<int, LevelRecord> records, int count) {
    RangeError.checkNotNegative(count, 'count');
    final result = Map<int, LevelRecord>.of(records);
    var left = count;
    while (left > 0) {
      final List<MapEntry<int, LevelRecord>> withStars =
          result.entries.where((entry) => entry.value.bestStars > 0).toList();
      if (withStars.isEmpty) break;
      final MapEntry<int, LevelRecord> oldest = withStars.reduce(
        (a, b) => b.value.achievedAt.isBefore(a.value.achievedAt) ? b : a,
      );
      final int taken = left < oldest.value.bestStars ? left : oldest.value.bestStars;
      result[oldest.key] = LevelRecord(bestStars: oldest.value.bestStars - taken, achievedAt: oldest.value.achievedAt);
      left -= taken;
    }
    return result;
  }

  /// Suma de los mejores resultados.
  static int totalStars(Map<int, LevelRecord> records) =>
      records.values.fold(0, (sum, record) => sum + record.bestStars);

  /// Compara dos mapas de récords sin importar el orden.
  static bool sameRecords(Map<int, LevelRecord> a, Map<int, LevelRecord> b) =>
      a.length == b.length && a.entries.every((entry) => b[entry.key] == entry.value);

  static int hashRecords(Map<int, LevelRecord> records) =>
      Object.hashAllUnordered(records.entries.map((entry) => Object.hash(entry.key, entry.value)));

  @override
  bool operator ==(Object other) =>
      other is LevelRecord && other.bestStars == bestStars && other.achievedAt == achievedAt;

  @override
  int get hashCode => Object.hash(bestStars, achievedAt);
}
