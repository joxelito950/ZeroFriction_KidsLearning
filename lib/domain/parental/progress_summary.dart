import '../progress/game_progress.dart';
import 'daily_play_time.dart';
import 'play_history.dart';

/// Una columna del gráfico semanal de «Su progreso» (HU-034 §4.3).
final class WeekSlot {
  const WeekSlot({required this.day, required this.played, required this.isToday, required this.currentWeek})
      : isGap = false;

  /// El día siguiente a hoy: separa esta semana de la pasada y no tiene barra.
  const WeekSlot.gap({required this.day})
      : played = Duration.zero,
        isToday = false,
        currentWeek = false,
        isGap = true;

  /// Medianoche del día que ocupa la columna (en el hueco, el que tendría).
  final DateTime day;
  final Duration played;
  final bool isToday;

  /// Esta semana (barra llena) o la pasada (barra transparente).
  final bool currentWeek;
  final bool isGap;

  @override
  bool operator ==(Object other) =>
      other is WeekSlot &&
      other.day == day &&
      other.played == played &&
      other.isToday == isToday &&
      other.currentWeek == currentWeek &&
      other.isGap == isGap;

  @override
  int get hashCode => Object.hash(day, played, isToday, currentWeek, isGap);

  @override
  String toString() => isGap ? 'WeekSlot.gap($day)' : 'WeekSlot($day, $played, today: $isToday, current: $currentWeek)';
}

/// Lo que muestra la pantalla «Su progreso» (HU-034): el barrido de la semana,
/// el total de estos días y el juego favorito. Solo logros y tiempo, nada que
/// preocupe (sección 2).
final class ProgressSummary {
  ProgressSummary({required PlayHistory history, required DateTime now, required Map<GameId, GameProgress> progress})
      : history = history.keptOn(now),
        today = DailyPlayTime.dayOf(now),
        progress = Map.unmodifiable(progress);

  final PlayHistory history;
  final DateTime today;
  final Map<GameId, GameProgress> progress;

  /// Las 7 columnas de la semana en el orden en que se leen, empezando por el
  /// día [firstDayOfWeekIndex] (0 domingo, 1 lunes, como
  /// `MaterialLocalizations.firstDayOfWeekIndex`). Hoy y los 5 días anteriores
  /// tienen barra; el día siguiente a hoy es el hueco (P2).
  List<WeekSlot> week(int firstDayOfWeekIndex) {
    RangeError.checkValueInInterval(firstDayOfWeekIndex, 0, 6, 'firstDayOfWeekIndex');
    // Posición de hoy en la fila: `weekday` va de 1 (lunes) a 7 (domingo).
    final int todayAt = (today.weekday % 7 - firstDayOfWeekIndex) % 7;
    return [
      for (var slot = 0; slot < 7; slot++) _slot(slot, todayAt),
    ];
  }

  WeekSlot _slot(int slot, int todayAt) {
    // Días después de hoy en el barrido: 0 hoy, 1 el hueco, 2 a 6 la semana pasada.
    final int ahead = (slot - todayAt) % 7;
    // Se cuenta por fechas del calendario, no restando horas (cambio de hora).
    final int back = ahead == 0 ? 0 : 7 - ahead;
    final DateTime day = DateTime(today.year, today.month, today.day - back);
    if (ahead == 1) return WeekSlot.gap(day: day);
    return WeekSlot(
      day: day,
      played: history.dayAt(day).total,
      isToday: ahead == 0,
      currentWeek: slot <= todayAt,
    );
  }

  /// Total de los 6 días (§4.3): la suma de los minutos enteros de cada día,
  /// para que coincida con lo que dicen las barras (cada una sin segundos).
  Duration get total =>
      Duration(minutes: history.days.fold(0, (sum, day) => sum + day.total.inMinutes));

  /// Tiempo de estos días en [game].
  Duration playedIn(GameId game) => history.days.fold(Duration.zero, (sum, day) => sum + day.playedIn(game));

  /// El juego al que más ha jugado estos días; `null` si no ha jugado a
  /// ninguno. Con empate, el primero del menú.
  GameId? get favoriteGame {
    GameId? favorite;
    Duration most = Duration.zero;
    for (final GameId game in GameId.values) {
      final Duration played = playedIn(game);
      if (played > most) {
        favorite = game;
        most = played;
      }
    }
    return favorite;
  }

  /// Un juego que nunca se ha abierto: se muestra «por descubrir» (§4.2).
  static bool undiscovered(GameProgress progress) =>
      progress.lastPlayedAt == null && progress.records.isEmpty && progress.medals.isEmpty;

  /// Juegos en los que el niño está atascado (§4.5), en el orden del menú.
  List<GameId> get stuckGames => [
        for (final GameId game in GameId.values)
          if (progress[game]?.isStuck ?? false) game,
      ];
}
