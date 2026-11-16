import '../progress/game_progress.dart';
import 'daily_play_time.dart';

/// Tiempo jugado en un día (HU-034 R3): por juego y, aparte, el que pasa en el
/// menú. Lo que suma es lo mismo que cuenta el límite diario (HU-009): la app
/// en primer plano y fuera de las pantallas de adultos.
final class PlayDay {
  PlayDay({required DateTime day, Map<GameId, Duration> byGame = const {}, this.outsideGames = Duration.zero})
      : day = DailyPlayTime.dayOf(day),
        byGame = Map.unmodifiable(byGame) {
    if (outsideGames.isNegative) throw RangeError.value(outsideGames.inSeconds, 'outsideGames');
    for (final Duration played in byGame.values) {
      if (played.isNegative) throw RangeError.value(played.inSeconds, 'byGame');
    }
  }

  /// Medianoche del día, en la hora del teléfono.
  final DateTime day;

  final Map<GameId, Duration> byGame;

  /// Tiempo en el menú y en las pantallas comunes, sin un juego abierto.
  final Duration outsideGames;

  /// Lo jugado ese día, con el tiempo fuera de los juegos.
  Duration get total => byGame.values.fold(outsideGames, (sum, played) => sum + played);

  Duration playedIn(GameId game) => byGame[game] ?? Duration.zero;

  /// Suma [elapsed] a [game], o fuera de los juegos si es `null`.
  PlayDay add(GameId? game, Duration elapsed) {
    if (game == null) return PlayDay(day: day, byGame: byGame, outsideGames: outsideGames + elapsed);
    return PlayDay(day: day, byGame: {...byGame, game: playedIn(game) + elapsed}, outsideGames: outsideGames);
  }

  @override
  bool operator ==(Object other) =>
      other is PlayDay &&
      other.day == day &&
      other.outsideGames == outsideGames &&
      other.byGame.length == byGame.length &&
      byGame.entries.every((entry) => other.byGame[entry.key] == entry.value);

  @override
  int get hashCode =>
      Object.hash(day, outsideGames, Object.hashAllUnordered(byGame.entries.map((e) => Object.hash(e.key, e.value))));

  @override
  String toString() => 'PlayDay($day, $byGame, outside: $outsideGames)';
}

/// Historial de los últimos días (HU-034 R3, P2): **hoy y los 5 anteriores**.
/// Lo más antiguo se olvida solo; nunca sale del teléfono (R2).
final class PlayHistory {
  PlayHistory(Iterable<PlayDay> days) : days = List.unmodifiable(_byDay(days));

  /// Días que se guardan y se muestran: hoy y los 5 anteriores (el séptimo
  /// hueco del gráfico separa esta semana de la pasada, sección 4.3).
  static const int keptDays = 6;

  /// De más antiguo a más reciente, sin días repetidos.
  final List<PlayDay> days;

  static List<PlayDay> _byDay(Iterable<PlayDay> days) {
    final Map<DateTime, PlayDay> unique = {for (final PlayDay day in days) day.day: day};
    return unique.values.toList()..sort((a, b) => a.day.compareTo(b.day));
  }

  /// El primer día que se conserva visto en [now]. Se cuenta por fechas del
  /// calendario, no restando horas, para no fallar con el cambio de hora.
  static DateTime firstKeptDay(DateTime now) => DateTime(now.year, now.month, now.day - (keptDays - 1));

  /// Solo los días de la ventana que termina en [now].
  PlayHistory keptOn(DateTime now) {
    final DateTime first = firstKeptDay(now);
    final DateTime today = DailyPlayTime.dayOf(now);
    return PlayHistory(days.where((day) => !day.day.isBefore(first) && !day.day.isAfter(today)));
  }

  /// El día de [moment], vacío si no se jugó.
  PlayDay dayAt(DateTime moment) {
    final DateTime day = DailyPlayTime.dayOf(moment);
    for (final PlayDay saved in days) {
      if (saved.day == day) return saved;
    }
    return PlayDay(day: day);
  }

  /// Suma [elapsed] en el día de [now] y olvida lo que sale de la ventana.
  PlayHistory add(GameId? game, Duration elapsed, DateTime now) =>
      PlayHistory([...days, dayAt(now).add(game, elapsed)]).keptOn(now);

  @override
  bool operator ==(Object other) =>
      other is PlayHistory &&
      other.days.length == days.length &&
      Iterable<int>.generate(days.length).every((i) => other.days[i] == days[i]);

  @override
  int get hashCode => Object.hashAll(days);
}
