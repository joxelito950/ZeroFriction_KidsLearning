import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/rest_schedule.dart';

/// HU-038: la hora de dormir y las siestas (R7, R7a).
void main() {
  int at(int hour, [int minute = 0]) => hour * 60 + minute;
  DateTime day(int hour, [int minute = 0]) => DateTime(2026, 11, 20, hour, minute);

  group('RestWindow', () {
    test('a night crosses midnight: from 19:30, included, to 7:00, excluded (R7)', () {
      const RestWindow night = RestSchedule.defaultNight;
      expect(night.crossesMidnight, isTrue);
      expect(night.length, at(11, 30));
      expect(night.contains(day(19, 29)), isFalse);
      expect(night.contains(day(19, 30)), isTrue);
      expect(night.contains(day(23, 59)), isTrue);
      expect(night.contains(day(0)), isTrue);
      expect(night.contains(day(6, 59)), isTrue);
      expect(night.contains(day(7)), isFalse);
      expect(night.contains(day(12)), isFalse);
    });

    test('a nap inside the day', () {
      const RestWindow nap = RestSchedule.defaultNap;
      expect(nap.crossesMidnight, isFalse);
      expect(nap.length, 120);
      expect(nap.contains(day(12, 59)), isFalse);
      expect(nap.contains(day(13)), isTrue);
      expect(nap.contains(day(15)), isFalse);
    });

    test('minutes until it starts, going forward', () {
      expect(RestSchedule.defaultNight.minutesUntilStart(day(19)), 30);
      expect(RestSchedule.defaultNight.minutesUntilStart(day(19, 30)), 0);
      expect(RestSchedule.defaultNight.minutesUntilStart(day(20)), at(23, 30));
    });

    test('copy and equality by value', () {
      const RestWindow night = RestSchedule.defaultNight;
      expect(night.copyWith(from: at(20)), RestWindow(at(20), at(7)));
      expect(night.copyWith(until: at(6)), RestWindow(at(19, 30), at(6)));
      expect(night.copyWith(), night);
      expect(night.hashCode, RestWindow(at(19, 30), at(7)).hashCode);
      expect(night == RestSchedule.defaultNap, isFalse);
    });
  });

  group('RestSchedule', () {
    test('off by default: nothing is a rest', () {
      expect(RestSchedule.off.isOff, isTrue);
      expect(RestSchedule.off.activeAt(day(22)), isNull);
      expect(RestSchedule.off.isValid, isTrue);
    });

    test('says whether it is the night or a nap', () {
      const schedule = RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap]);
      expect(schedule.isOff, isFalse);
      expect(schedule.activeAt(day(22)), RestKind.night);
      expect(schedule.activeAt(day(14)), RestKind.nap);
      expect(schedule.activeAt(day(10)), isNull);
      expect(const RestSchedule(naps: [RestSchedule.defaultNap]).activeAt(day(22)), isNull);
    });

    test('the defaults are valid, with one or two naps', () {
      expect(const RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap]).problem, isNull);
      expect(
        RestSchedule(night: RestSchedule.defaultNight, naps: [RestWindow(at(9), at(10)), RestSchedule.defaultNap])
            .problem,
        isNull,
      );
    });

    test('the same start and end cannot be saved (R7)', () {
      expect(RestSchedule(night: RestWindow(at(20), at(20))).problem, RestScheduleProblem.sameTimes);
      expect(RestSchedule(naps: [RestWindow(at(13), at(13))]).problem, RestScheduleProblem.sameTimes);
    });

    test('a nap lasts from 30 minutes to 2 hours and does not cross midnight (R7a)', () {
      expect(RestSchedule(naps: [RestWindow(at(13), at(13, 29))]).problem, RestScheduleProblem.napLength);
      expect(RestSchedule(naps: [RestWindow(at(13), at(13, 30))]).problem, isNull);
      expect(RestSchedule(naps: [RestWindow(at(13), at(15, 1))]).problem, RestScheduleProblem.napLength);
      expect(RestSchedule(naps: [RestWindow(at(23, 30), at(0, 30))]).problem, RestScheduleProblem.napCrossesMidnight);
    });

    test('rests leave at least 2 hours between them and never overlap (R7a)', () {
      const RestWindow night = RestSchedule.defaultNight;
      expect(RestSchedule(night: night, naps: [RestWindow(at(17), at(18))]).problem, RestScheduleProblem.tooClose);
      expect(RestSchedule(night: night, naps: [RestWindow(at(17), at(17, 30))]).problem, isNull, reason: 'exactly 2 h');
      expect(RestSchedule(night: night, naps: [RestWindow(at(17), at(17, 29))]).problem, RestScheduleProblem.napLength);
      expect(RestSchedule(night: night, naps: [RestWindow(at(16), at(17, 30))]).problem, isNull);
      expect(RestSchedule(night: night, naps: [RestWindow(at(8), at(9))]).problem, RestScheduleProblem.tooClose);
      expect(RestSchedule(night: night, naps: [RestWindow(at(9), at(10))]).problem, isNull);
      expect(RestSchedule(night: night, naps: [RestWindow(at(20), at(21))]).problem, RestScheduleProblem.tooClose);
      expect(
        RestSchedule(naps: [RestWindow(at(10), at(11)), RestWindow(at(12), at(13))]).problem,
        RestScheduleProblem.tooClose,
      );
      expect(
        RestSchedule(naps: [RestWindow(at(10), at(11)), RestWindow(at(10, 30), at(11, 30))]).problem,
        RestScheduleProblem.tooClose,
      );
      expect(
        RestSchedule(naps: [RestWindow(at(10), at(11)), RestWindow(at(13), at(14))]).problem,
        isNull,
      );
    });

    test('at most two naps', () {
      final schedule = RestSchedule(
        naps: [RestWindow(at(8), at(9)), RestWindow(at(12), at(13)), RestWindow(at(16), at(17))],
      );
      expect(schedule.problem, RestScheduleProblem.tooClose);
      expect(schedule.suggestedNap(), isNull);
    });

    test('the suggested nap is 13:00-15:00 when it fits, or the first free hour (P6)', () {
      expect(const RestSchedule().suggestedNap(), RestSchedule.defaultNap);
      const RestSchedule withNap = RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap]);
      expect(withNap.suggestedNap(), RestWindow(at(9), at(10)));
      expect(
        RestSchedule(night: RestWindow(at(18), at(10)), naps: const [RestSchedule.defaultNap]).suggestedNap(),
        isNull,
      );
    });

    test('changing the night or the naps, and equality by value', () {
      const schedule = RestSchedule(night: RestSchedule.defaultNight);
      expect(schedule.withNight(null), RestSchedule.off);
      final RestSchedule withNaps = schedule.withNaps([RestSchedule.defaultNap]);
      expect(withNaps, const RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap]));
      expect(withNaps.hashCode,
          const RestSchedule(night: RestSchedule.defaultNight, naps: [RestSchedule.defaultNap]).hashCode);
      expect(withNaps == schedule, isFalse);
      expect(withNaps == schedule.withNaps([RestWindow(at(9), at(10))]), isFalse);
    });
  });
}
