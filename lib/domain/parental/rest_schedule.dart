/// Un tramo del día para descansar (HU-038): desde y hasta, en minutos desde
/// la medianoche. Si [until] es menor que [from], cruza la medianoche (R7).
final class RestWindow {
  const RestWindow(this.from, this.until)
      : assert(from >= 0 && from < minutesPerDay),
        assert(until >= 0 && until < minutesPerDay);

  static const int minutesPerDay = 24 * 60;

  final int from;
  final int until;

  bool get crossesMidnight => until < from;

  /// Minutos que dura; 0 si desde y hasta son iguales.
  int get length => (until - from) % minutesPerDay;

  /// Minuto del día de [at], en la hora del teléfono (R8).
  static int minuteOf(DateTime at) => at.hour * 60 + at.minute;

  bool containsMinute(int minute) =>
      crossesMidnight ? minute >= from || minute < until : minute >= from && minute < until;

  bool contains(DateTime at) => containsMinute(minuteOf(at));

  /// Minutos que faltan, desde [at], para que empiece (de 0 a 1439).
  int minutesUntilStart(DateTime at) => (from - minuteOf(at)) % minutesPerDay;

  RestWindow copyWith({int? from, int? until}) => RestWindow(from ?? this.from, until ?? this.until);

  @override
  bool operator ==(Object other) => other is RestWindow && other.from == from && other.until == until;

  @override
  int get hashCode => Object.hash(from, until);
}

/// Qué descanso toca: la noche o una siesta.
enum RestKind { night, nap }

/// Por qué no se puede guardar un horario (R7, R7a). La pantalla lo explica
/// con una frase amable.
enum RestScheduleProblem {
  /// «Desde» y «Hasta» son iguales.
  sameTimes,

  /// Una siesta dura menos de 30 minutos o más de 2 horas.
  napLength,

  /// Una siesta cruza la medianoche.
  napCrossesMidnight,

  /// Dos descansos se solapan o quedan a menos de 2 horas.
  tooClose,
}

/// La hora de dormir y las siestas (HU-038): la noche puede cruzar la
/// medianoche; las siestas, como mucho dos, duran de 30 minutos a 2 horas y
/// dejan al menos 2 horas libres entre ellas y con la noche (R7a). El mismo
/// horario todos los días (R9).
final class RestSchedule {
  const RestSchedule({this.night, this.naps = const []});

  /// Sin hora de dormir ni siestas: el valor por defecto.
  static const RestSchedule off = RestSchedule();

  /// 19:30 a 7:00 (P1).
  static const RestWindow defaultNight = RestWindow(19 * 60 + 30, 7 * 60);

  /// 13:00 a 15:00 (P1, P6).
  static const RestWindow defaultNap = RestWindow(13 * 60, 15 * 60);

  static const int maxNaps = 2;
  static const int minNapMinutes = 30;
  static const int maxNapMinutes = 120;
  static const int minGapMinutes = 120;

  /// `null`: sin hora de dormir.
  final RestWindow? night;

  /// Las siestas activas, de 0 a [maxNaps].
  final List<RestWindow> naps;

  bool get isOff => night == null && naps.isEmpty;

  List<RestWindow> get _windows => [if (night case final RestWindow window) window, ...naps];

  /// El descanso que toca a [at], o `null`.
  RestKind? activeAt(DateTime at) {
    if (night?.contains(at) ?? false) return RestKind.night;
    for (final RestWindow nap in naps) {
      if (nap.contains(at)) return RestKind.nap;
    }
    return null;
  }

  /// La preparación para dormir dura 30 minutos (P5).
  static const int windDownMinutes = 30;

  /// Cuánto ha avanzado la preparación a [at] (R10, R11): 0 fuera de ella;
  /// sube poco a poco hasta 1 en los 30 minutos antes de la noche o de una
  /// siesta, y vale 1 durante el descanso, hasta la hora «Hasta».
  double windDownAt(DateTime at) {
    const int secondsPerDay = RestWindow.minutesPerDay * 60;
    const int span = windDownMinutes * 60;
    final int second = at.hour * 3600 + at.minute * 60 + at.second;
    double progress = 0;
    for (final RestWindow window in _windows) {
      if (window.contains(at)) return 1;
      final int untilStart = (window.from * 60 - second) % secondsPerDay;
      if (untilStart <= span) {
        final double here = 1 - untilStart / span;
        if (here > progress) progress = here;
      }
    }
    return progress;
  }

  /// El primer problema que impide guardarlo, o `null` si vale.
  RestScheduleProblem? get problem {
    if (naps.length > maxNaps) return RestScheduleProblem.tooClose;
    for (final RestWindow window in _windows) {
      if (window.length == 0) return RestScheduleProblem.sameTimes;
    }
    for (final RestWindow nap in naps) {
      if (nap.crossesMidnight) return RestScheduleProblem.napCrossesMidnight;
      if (nap.length < minNapMinutes || nap.length > maxNapMinutes) return RestScheduleProblem.napLength;
    }
    final List<RestWindow> windows = _windows;
    for (var i = 0; i < windows.length; i++) {
      for (var j = i + 1; j < windows.length; j++) {
        if (_gap(windows[i], windows[j]) < minGapMinutes) return RestScheduleProblem.tooClose;
      }
    }
    return null;
  }

  bool get isValid => problem == null;

  /// Minutos libres entre dos descansos, por el lado más corto; -1 si se solapan.
  static int _gap(RestWindow a, RestWindow b) {
    if (a.containsMinute(b.from) || b.containsMinute(a.from)) return -1;
    final int afterA = (b.from - a.until) % RestWindow.minutesPerDay;
    final int afterB = (a.from - b.until) % RestWindow.minutesPerDay;
    return afterA < afterB ? afterA : afterB;
  }

  /// La siesta que se propone al añadir otra (P6): 13:00–15:00 si cabe; si no,
  /// la primera de una hora, en pasos de media hora desde las 6:00, que cumpla
  /// las reglas. `null` si no cabe ninguna.
  RestWindow? suggestedNap() {
    if (naps.length >= maxNaps) return null;
    if (RestSchedule(night: night, naps: [...naps, defaultNap]).isValid) return defaultNap;
    for (var start = 6 * 60; start + 60 < RestWindow.minutesPerDay; start += 30) {
      final RestWindow nap = RestWindow(start, start + 60);
      if (RestSchedule(night: night, naps: [...naps, nap]).isValid) return nap;
    }
    return null;
  }

  RestSchedule withNight(RestWindow? value) => RestSchedule(night: value, naps: naps);

  RestSchedule withNaps(List<RestWindow> value) => RestSchedule(night: night, naps: List.unmodifiable(value));

  @override
  bool operator ==(Object other) =>
      other is RestSchedule &&
      other.night == night &&
      other.naps.length == naps.length &&
      Iterable<int>.generate(naps.length).every((i) => other.naps[i] == naps[i]);

  @override
  int get hashCode => Object.hash(night, Object.hashAll(naps));
}
