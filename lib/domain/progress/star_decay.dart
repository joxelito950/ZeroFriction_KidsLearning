/// Pérdida gradual de logros (D-031, HU-002 R7–R12), igual para todos los juegos.
///
/// Tras [grace] sin jugar, se pierde una estrella cada [step]. Se calcula y se
/// guarda al empezar cada juego, nunca en el menú (D-037).
abstract final class StarDecay {
  /// Periodo de gracia: sin jugar hasta 7 días no se pierde nada (R7).
  static const Duration grace = Duration(days: 7);

  /// Después, una estrella cada 3 días (R8).
  static const Duration step = Duration(days: 3);

  /// Estrellas perdidas entre [since] (la última partida, o la última vez que un
  /// adulto volvió a activar la pérdida, HU-016) y [now]. Desde el 100 % de la
  /// memoria (15★) se llega a 0 en 7 + 15 × 3 = 52 días.
  static int starsLost({required DateTime since, required DateTime now}) {
    final Duration idle = now.difference(since);
    if (idle <= grace) return 0;
    return (idle - grace).inMinutes ~/ step.inMinutes;
  }

  /// La fecha desde la que se cuenta: la más reciente entre la última partida y
  /// la reactivación de la pérdida (HU-016 R3). `null` si nunca se jugó.
  static DateTime? since({DateTime? lastPlayedAt, DateTime? resumedAt}) {
    if (lastPlayedAt == null) return null;
    if (resumedAt == null || resumedAt.isBefore(lastPlayedAt)) return lastPlayedAt;
    return resumedAt;
  }
}
