import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/play_history.dart';
import 'package:toddler_logic/domain/parental/progress_summary.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

/// HU-034 entrega 3: lo que muestra «Su progreso».
void main() {
  const Duration minute = Duration(minutes: 1);
  const int monday = 1;
  const int sunday = 0;

  PlayDay day(DateTime at, {int memory = 0, int shadows = 0, int odd = 0, int outside = 0}) => PlayDay(
        day: at,
        byGame: {
          if (memory > 0) GameId.memory: minute * memory,
          if (shadows > 0) GameId.shadows: minute * shadows,
          if (odd > 0) GameId.oddOneOut: minute * odd,
        },
        outsideGames: minute * outside,
      );

  ProgressSummary summaryOn(DateTime now,
          [List<PlayDay> days = const [], Map<GameId, GameProgress> progress = const {}]) =>
      ProgressSummary(history: PlayHistory(days), now: now, progress: progress);

  List<String> layout(List<WeekSlot> slots) => [
        for (final WeekSlot slot in slots)
          slot.isGap
              ? 'gap ${slot.day.day}'
              : '${slot.isToday ? 'today' : slot.currentWeek ? 'this' : 'last'} ${slot.day.day}',
      ];

  group('week sweep (§4.3, criterion 5)', () {
    test(
        'on a Wednesday: Monday to Wednesday, Thursday empty (the day that left the window), Friday to Sunday of last week',
        () {
      final DateTime wednesday = DateTime(2026, 11, 18, 10);
      expect(layout(summaryOn(wednesday).week(monday)),
          ['this 16', 'this 17', 'today 18', 'gap 12', 'last 13', 'last 14', 'last 15']);
    });

    test('on a Monday: Monday, the Tuesday gap, then Wednesday to Sunday of last week', () {
      final DateTime mondayNow = DateTime(2026, 11, 16, 9);
      expect(layout(summaryOn(mondayNow).week(monday)),
          ['today 16', 'gap 10', 'last 11', 'last 12', 'last 13', 'last 14', 'last 15']);
    });

    test('on a Sunday the gap is the first column (Monday, six days ago)', () {
      final DateTime sundayNow = DateTime(2026, 11, 22, 20);
      expect(layout(summaryOn(sundayNow).week(monday)),
          ['gap 16', 'this 17', 'this 18', 'this 19', 'this 20', 'this 21', 'today 22']);
    });

    test('weeks that start on Sunday follow the language (R6)', () {
      final DateTime wednesday = DateTime(2026, 11, 18, 10);
      expect(layout(summaryOn(wednesday).week(sunday)),
          ['this 15', 'this 16', 'this 17', 'today 18', 'gap 12', 'last 13', 'last 14']);
    });

    test('each bar carries the time of its day, menu time included', () {
      final DateTime wednesday = DateTime(2026, 11, 18, 10);
      final List<WeekSlot> week = summaryOn(wednesday, [
        day(DateTime(2026, 11, 18), shadows: 10, outside: 2),
        day(DateTime(2026, 11, 14), memory: 5),
      ]).week(monday);
      expect(week[2].played, minute * 12);
      expect(week[5].played, minute * 5);
      expect(week[3].played, Duration.zero);
      expect(week[0].played, Duration.zero);
    });

    test('rejects a first day out of range', () {
      expect(() => summaryOn(DateTime(2026, 11, 18)).week(7), throwsRangeError);
    });

    test('slots compare by value', () {
      final DateTime at = DateTime(2026, 11, 18);
      expect(WeekSlot.gap(day: at), WeekSlot.gap(day: at));
      expect(WeekSlot.gap(day: at).hashCode, WeekSlot.gap(day: at).hashCode);
      expect(WeekSlot(day: at, played: minute, isToday: true, currentWeek: true),
          isNot(WeekSlot(day: at, played: minute, isToday: false, currentWeek: true)));
      expect(WeekSlot.gap(day: at).toString(), contains('gap'));
      expect(WeekSlot(day: at, played: minute, isToday: true, currentWeek: true).toString(), contains('today: true'));
    });
  });

  group('totals and favourite', () {
    final DateTime wednesday = DateTime(2026, 11, 18, 10);

    test('the total adds the 6 kept days only', () {
      final ProgressSummary summary = summaryOn(wednesday, [
        day(DateTime(2026, 11, 18), shadows: 30),
        day(DateTime(2026, 11, 13), memory: 40),
        day(DateTime(2026, 11, 12), memory: 99), // séptimo día: ya no cuenta
      ]);
      expect(summary.total, minute * 70);
      expect(summary.playedIn(GameId.memory), minute * 40);
      expect(summary.favoriteGame, GameId.memory);
    });

    test('no favourite without game time; a tie goes to the first game of the menu', () {
      expect(summaryOn(wednesday, [day(wednesday, outside: 5)]).favoriteGame, isNull);
      expect(summaryOn(wednesday, [day(wednesday, shadows: 5, odd: 5)]).favoriteGame, GameId.shadows);
    });
  });

  group('games', () {
    final DateTime wednesday = DateTime(2026, 11, 18, 10);

    test('a game never opened is still to discover (§4.2)', () {
      expect(ProgressSummary.undiscovered(GameProgress.initial()), isTrue);
      expect(ProgressSummary.undiscovered(GameProgress.initial().playedAt(wednesday)), isFalse);
      expect(
        ProgressSummary.undiscovered(GameProgress(
          position: const RoundPosition(round: GameDifficulty.bronze, level: 2),
          records: {RoundLevel(GameDifficulty.bronze, 2): LevelRecord(bestStars: 1, achievedAt: wednesday)},
        )),
        isFalse,
      );
    });

    test('lists the stuck games in menu order (§4.5)', () {
      GameProgress stuck() => GameProgress(
            position: const RoundPosition(round: GameDifficulty.gold, level: 4),
            stuckLevel: 4,
            stuckFalls: GameProgress.stuckThreshold,
          );
      final ProgressSummary summary = summaryOn(wednesday, const [], {
        GameId.oddOneOut: stuck(),
        GameId.memory: GameProgress.initial(),
        GameId.shadows: stuck(),
      });
      expect(summary.stuckGames, [GameId.shadows, GameId.oddOneOut]);
    });

    test('«Not now» clears the stuck count and keeps everything else', () {
      final GameProgress stuck = GameProgress(
        position: const RoundPosition(round: GameDifficulty.gold, level: 4),
        medals: const {GameDifficulty.bronze},
        lastPlayedAt: wednesday,
        stuckLevel: 4,
        stuckFalls: 3,
      );
      final GameProgress cleared = stuck.withoutStuck();
      expect(cleared.isStuck, isFalse);
      expect(cleared.stuckLevel, isNull);
      expect(cleared.position, stuck.position);
      expect(cleared.medals, stuck.medals);
      expect(cleared.lastPlayedAt, wednesday);
    });
  });
}
