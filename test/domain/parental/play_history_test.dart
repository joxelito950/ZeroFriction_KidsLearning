import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/play_history.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';

void main() {
  const Duration minute = Duration(minutes: 1);
  final DateTime wednesday = DateTime(2026, 11, 18, 10, 30);

  group('PlayDay', () {
    test('adds time to a game or, without one, outside the games', () {
      final PlayDay day = PlayDay(day: wednesday)
          .add(GameId.shadows, minute * 3)
          .add(GameId.shadows, minute)
          .add(GameId.memory, minute * 2)
          .add(null, minute);

      expect(day.day, DateTime(2026, 11, 18));
      expect(day.playedIn(GameId.shadows), minute * 4);
      expect(day.playedIn(GameId.memory), minute * 2);
      expect(day.playedIn(GameId.oddOneOut), Duration.zero);
      expect(day.outsideGames, minute);
      expect(day.total, minute * 7);
    });

    test('rejects negative times', () {
      expect(() => PlayDay(day: wednesday, outsideGames: -minute), throwsRangeError);
      expect(() => PlayDay(day: wednesday, byGame: {GameId.memory: -minute}), throwsRangeError);
    });

    test('two days with the same times are equal', () {
      final PlayDay a = PlayDay(day: wednesday, byGame: {GameId.memory: minute});
      final PlayDay b = PlayDay(day: DateTime(2026, 11, 18, 22), byGame: {GameId.memory: minute});
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(PlayDay(day: wednesday, byGame: {GameId.shadows: minute})));
      expect(a.toString(), contains('memory'));
    });
  });

  group('PlayHistory (R3: today and the 5 days before)', () {
    test('keeps 6 days and forgets the older ones by themselves', () {
      PlayHistory history = PlayHistory(const []);
      for (var offset = 9; offset >= 0; offset--) {
        history = history.add(GameId.memory, minute * (offset + 1), DateTime(2026, 11, 18 - offset, 9));
      }

      expect(history.days, hasLength(PlayHistory.keptDays));
      expect(history.days.first.day, DateTime(2026, 11, 13));
      expect(history.days.last.day, DateTime(2026, 11, 18));
      expect(history.dayAt(wednesday).total, minute);
      expect(history.dayAt(DateTime(2026, 11, 12)).total, Duration.zero, reason: 'forgotten');
    });

    test('sums on the same day and sorts the days', () {
      final PlayHistory history = PlayHistory([
        PlayDay(day: DateTime(2026, 11, 17), outsideGames: minute),
        PlayDay(day: DateTime(2026, 11, 15), outsideGames: minute),
      ]).add(GameId.oddOneOut, minute, wednesday).add(GameId.oddOneOut, minute, wednesday);

      expect([for (final PlayDay day in history.days) day.day.day], [15, 17, 18]);
      expect(history.dayAt(wednesday).playedIn(GameId.oddOneOut), minute * 2);
    });

    test('counts calendar days, also across the daylight saving change', () {
      expect(PlayHistory.firstKeptDay(DateTime(2026, 3, 31, 1)), DateTime(2026, 3, 26));
      expect(PlayHistory.firstKeptDay(DateTime(2026, 1, 2)), DateTime(2025, 12, 28));
    });

    test('days in the future (clock moved back) are left out of the window', () {
      final PlayHistory history = PlayHistory([PlayDay(day: DateTime(2026, 11, 20), outsideGames: minute)]);
      expect(history.keptOn(wednesday).days, isEmpty);
    });

    test('equality looks at every day', () {
      final PlayHistory a = PlayHistory([PlayDay(day: wednesday, outsideGames: minute)]);
      expect(a, PlayHistory([PlayDay(day: wednesday, outsideGames: minute)]));
      expect(a.hashCode, PlayHistory([PlayDay(day: wednesday, outsideGames: minute)]).hashCode);
      expect(a, isNot(PlayHistory(const [])));
    });
  });
}
