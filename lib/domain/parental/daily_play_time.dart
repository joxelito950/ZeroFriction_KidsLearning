/// Tiempo de juego de un día (HU-009 R2, R3, R8): cuánto se ha jugado hoy y
/// cuántos minutos extra ha dado un adulto. El día empieza a las 00:00 de la
/// hora del teléfono; al cambiar de día, el contador vuelve a cero.
final class DailyPlayTime {
  DailyPlayTime({required DateTime day, this.played = Duration.zero, this.extraMinutes = 0}) : day = dayOf(day) {
    if (played.isNegative) throw RangeError.value(played.inSeconds, 'played');
    RangeError.checkNotNegative(extraMinutes, 'extraMinutes');
  }

  /// Un día sin nada jugado.
  factory DailyPlayTime.startOf(DateTime now) => DailyPlayTime(day: now);

  /// Minutos que suma cada «15 minutos más» (HU-009 P4).
  static const int extraStepMinutes = 15;

  /// Medianoche del día de [moment], en la hora del teléfono.
  static DateTime dayOf(DateTime moment) => DateTime(moment.year, moment.month, moment.day);

  final DateTime day;
  final Duration played;
  final int extraMinutes;

  /// El tiempo de hoy visto en [now]: si ya es otro día, empieza de cero (R3).
  DailyPlayTime on(DateTime now) => dayOf(now) == day ? this : DailyPlayTime.startOf(now);

  /// Suma [elapsed] al día de [now].
  DailyPlayTime add(Duration elapsed, DateTime now) {
    final DailyPlayTime today = on(now);
    return DailyPlayTime(day: today.day, played: today.played + elapsed, extraMinutes: today.extraMinutes);
  }

  /// Tiempo permitido hoy con un límite de [limitMinutes]; `null` sin límite.
  Duration? allowance(int? limitMinutes) =>
      limitMinutes == null ? null : Duration(minutes: limitMinutes + extraMinutes);

  /// Si ya se jugó todo lo permitido hoy. Sin límite, nunca (criterio 8).
  bool isOver(int? limitMinutes) {
    final Duration? allowed = allowance(limitMinutes);
    return allowed != null && played >= allowed;
  }

  /// Da [extraStepMinutes] más **desde ahora** (R6, criterio 5): si ya se jugó
  /// más de lo permitido, el extra cuenta a partir de lo jugado.
  DailyPlayTime grantExtra(int limitMinutes, DateTime now) {
    final DailyPlayTime today = on(now);
    final int playedMinutes = (today.played.inSeconds / Duration.secondsPerMinute).ceil();
    final int allowed = limitMinutes + today.extraMinutes;
    final int base = playedMinutes > allowed ? playedMinutes : allowed;
    return DailyPlayTime(
      day: today.day,
      played: today.played,
      extraMinutes: base + extraStepMinutes - limitMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DailyPlayTime && other.day == day && other.played == played && other.extraMinutes == extraMinutes;

  @override
  int get hashCode => Object.hash(day, played, extraMinutes);
}
