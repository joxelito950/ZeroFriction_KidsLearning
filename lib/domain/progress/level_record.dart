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

  @override
  bool operator ==(Object other) =>
      other is LevelRecord && other.bestStars == bestStars && other.achievedAt == achievedAt;

  @override
  int get hashCode => Object.hash(bestStars, achievedAt);
}
