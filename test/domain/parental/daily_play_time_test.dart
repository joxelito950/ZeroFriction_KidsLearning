import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';

void main() {
  final DateTime morning = DateTime(2026, 11, 4, 9, 30);

  group('DailyPlayTime', () {
    test('keeps only the day, from midnight in the phone time (R3)', () {
      final time = DailyPlayTime(day: morning);

      expect(time.day, DateTime(2026, 11, 4));
      expect(time.played, Duration.zero);
      expect(time.extraMinutes, 0);
    });

    test('rejects negative values', () {
      expect(() => DailyPlayTime(day: morning, played: const Duration(seconds: -1)), throwsRangeError);
      expect(() => DailyPlayTime(day: morning, extraMinutes: -1), throwsRangeError);
    });

    test('adds play time on the same day', () {
      final time = DailyPlayTime.startOf(morning)
          .add(const Duration(minutes: 10), morning)
          .add(const Duration(seconds: 30), morning.add(const Duration(hours: 2)));

      expect(time.played, const Duration(minutes: 10, seconds: 30));
    });

    test('starts from zero on the next day, extra time included (criterion 7)', () {
      final yesterday = DailyPlayTime(day: morning, played: const Duration(minutes: 40), extraMinutes: 15);
      final DateTime tomorrow = DateTime(2026, 11, 5, 0, 0, 1);

      expect(yesterday.on(tomorrow), DailyPlayTime.startOf(tomorrow));
      expect(yesterday.add(const Duration(seconds: 1), tomorrow).played, const Duration(seconds: 1));
      expect(yesterday.on(morning), same(yesterday));
    });

    test('without a limit is never over (criterion 8)', () {
      final time = DailyPlayTime(day: morning, played: const Duration(hours: 20));

      expect(time.allowance(null), isNull);
      expect(time.isOver(null), isFalse);
    });

    test('is over once the limit plus the extra time is played (criterion 3)', () {
      final time = DailyPlayTime(day: morning, played: const Duration(minutes: 15));

      expect(time.isOver(15), isTrue);
      expect(time.isOver(16), isFalse);
      expect(DailyPlayTime(day: morning, played: const Duration(minutes: 15), extraMinutes: 15).isOver(15), isFalse);
    });

    test('15 more minutes count from what was already played (criterion 5)', () {
      final atLimit = DailyPlayTime(day: morning, played: const Duration(minutes: 31, seconds: 20));

      final DailyPlayTime extended = atLimit.grantExtra(30, morning);

      // Jugó 31:20 con un límite de 30: puede jugar hasta los 47 minutos.
      expect(extended.allowance(30), const Duration(minutes: 47));
      expect(extended.isOver(30), isFalse);
      expect(extended.grantExtra(30, morning).allowance(30), const Duration(minutes: 62));
    });

    test('15 more minutes before reaching the limit add to the allowance', () {
      final early = DailyPlayTime(day: morning, played: const Duration(minutes: 5));

      expect(early.grantExtra(30, morning).allowance(30), const Duration(minutes: 45));
    });

    test('extra time given on a new day starts that day from zero', () {
      final yesterday = DailyPlayTime(day: morning, played: const Duration(minutes: 40));
      final DateTime tomorrow = morning.add(const Duration(days: 1));

      final DailyPlayTime extended = yesterday.grantExtra(30, tomorrow);

      expect(extended.day, DateTime(2026, 11, 5));
      expect(extended.played, Duration.zero);
      expect(extended.allowance(30), const Duration(minutes: 45));
    });

    test('equality by value', () {
      expect(DailyPlayTime(day: morning, played: const Duration(minutes: 1)),
          DailyPlayTime(day: DateTime(2026, 11, 4), played: const Duration(minutes: 1)));
      expect(DailyPlayTime(day: morning).hashCode, DailyPlayTime(day: DateTime(2026, 11, 4)).hashCode);
      expect(DailyPlayTime(day: morning), isNot(DailyPlayTime(day: morning, extraMinutes: 15)));
    });
  });

  group('ParentalSettings', () {
    test('defaults to no limit and nothing played (R1c)', () {
      expect(ParentalSettings.initial.dailyLimitMinutes, isNull);
      expect(ParentalSettings.initial.playTime, isNull);
      expect(ParentalSettings(), ParentalSettings.initial);
    });

    test('accepts a custom limit from 5 minutes to 12 hours only (criterion 2)', () {
      expect(ParentalSettings.isValidLimit(3), isFalse);
      expect(ParentalSettings.isValidLimit(5), isTrue);
      expect(ParentalSettings.isValidLimit(25), isTrue);
      expect(ParentalSettings.isValidLimit(720), isTrue);
      expect(ParentalSettings.isValidLimit(800), isFalse);
      expect(() => ParentalSettings(dailyLimitMinutes: 4), throwsRangeError);
      expect(() => ParentalSettings(dailyLimitMinutes: 721), throwsRangeError);
      expect(ParentalSettings.presetLimitMinutes.every(ParentalSettings.isValidLimit), isTrue);
    });

    test('changes the limit and the play time independently', () {
      final time = DailyPlayTime(day: morning, played: const Duration(minutes: 3));
      final settings = ParentalSettings(dailyLimitMinutes: 30).withPlayTime(time);

      expect(settings.withLimit(null), ParentalSettings(playTime: time));
      expect(settings.withLimit(60).dailyLimitMinutes, 60);
      expect(settings.withLimit(60).playTime, time);
      expect(settings.hashCode, ParentalSettings(dailyLimitMinutes: 30, playTime: time).hashCode);
    });
  });

  group('ParentalSettingsHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      final entity = ParentalSettings(
        dailyLimitMinutes: 90,
        playTime: DailyPlayTime(day: morning, played: const Duration(seconds: 61), extraMinutes: 30),
      );

      final model = ParentalSettingsHiveModel.fromEntity(entity);

      expect(model.dailyLimitMinutes, 90);
      expect(model.playDay, DateTime(2026, 11, 4));
      expect(model.playedSeconds, 61);
      expect(model.extraMinutes, 30);
      expect(model.toEntity(), entity);
    });

    test('the defaults round-trip', () {
      expect(ParentalSettingsHiveModel.fromEntity(ParentalSettings.initial).toEntity(), ParentalSettings.initial);
    });

    test('reads a day stored in UTC as the same local day', () {
      final DateTime localMidnight = DateTime(2026, 11, 4);
      final model = ParentalSettingsHiveModel(playDay: localMidnight.toUtc(), playedSeconds: 5);

      expect(model.toEntity().playTime!.day, localMidnight);
    });
  });
}
