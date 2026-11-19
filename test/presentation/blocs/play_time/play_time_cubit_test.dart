import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/domain/parental/play_history.dart';
import 'package:toddler_logic/domain/parental/rest_schedule.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';

import '../../memory_game_test_support.dart';

void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime startTime = DateTime(2026, 11, 4, 10);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  void storeSettings(ParentalSettings settings) {
    when(() => repository.readParentalSettings()).thenAnswer((_) async => settings);
  }

  /// Ejecuta [body] con un reloj que avanza con el tiempo simulado.
  void run(void Function(FakeAsync async, PlayTimeCubit cubit) body, {DateTime? from}) {
    fakeAsync((async) {
      final DateTime origin = from ?? startTime;
      final cubit = PlayTimeCubit(repository: repository, now: () => origin.add(async.elapsed));
      cubit.start();
      async.flushMicrotasks();
      body(async, cubit);
      cubit.close();
      async.flushMicrotasks();
    });
  }

  ParentalSettings lastSaved() =>
      verify(() => repository.saveParentalSettings(captureAny())).captured.last as ParentalSettings;

  test('starts with no limit and nothing played when nothing is stored', () {
    run((async, cubit) {
      expect(cubit.state.limitMinutes, isNull);
      expect(cubit.state.today, DailyPlayTime.startOf(startTime));
      expect(cubit.state.limitReached, isFalse);
    });
  });

  test('keeps what was played today, and starts from zero on another day (R3)', () {
    storeSettings(ParentalSettings(
      dailyLimitMinutes: 30,
      playTime: DailyPlayTime(day: startTime, played: const Duration(minutes: 12)),
    ));
    run((async, cubit) {
      expect(cubit.state.limitMinutes, 30);
      expect(cubit.state.today.played, const Duration(minutes: 12));
    });

    storeSettings(ParentalSettings(
      dailyLimitMinutes: 30,
      playTime: DailyPlayTime(day: startTime.subtract(const Duration(days: 1)), played: const Duration(minutes: 29)),
    ));
    run((async, cubit) => expect(cubit.state.today.played, Duration.zero));
  });

  test('a failed read starts with the defaults', () {
    when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
    run((async, cubit) {
      expect(cubit.state.limitMinutes, isNull);
      async.elapse(const Duration(seconds: 3));
      expect(cubit.state.today.played, const Duration(seconds: 3));
    });
  });

  test('counts only in the foreground (R2, criterion 6) and saves when leaving it', () {
    run((async, cubit) {
      async.elapse(const Duration(seconds: 10));
      expect(cubit.state.today.played, const Duration(seconds: 10));

      cubit.setForeground(false);
      async.flushMicrotasks();
      expect(lastSaved().playTime!.played, const Duration(seconds: 10));
      async.elapse(const Duration(minutes: 5));
      expect(cubit.state.today.played, const Duration(seconds: 10));

      cubit.setForeground(false);
      cubit.setForeground(true);
      async.elapse(const Duration(seconds: 2));
      expect(cubit.state.today.played, const Duration(seconds: 12));
    });
  });

  test('does not count while an adult screen is open, even when two overlap (R2)', () {
    run((async, cubit) {
      cubit.enterAdultArea(); // desafío
      cubit.enterAdultArea(); // Zona de Padres, durante la transición
      cubit.leaveAdultArea();
      expect(cubit.state.inAdultArea, isTrue);
      async.elapse(const Duration(minutes: 1));
      expect(cubit.state.today.played, Duration.zero);

      cubit.leaveAdultArea();
      cubit.leaveAdultArea(); // de más: no pasa nada
      expect(cubit.state.inAdultArea, isFalse);
      async.elapse(const Duration(seconds: 4));
      expect(cubit.state.today.played, const Duration(seconds: 4));
    });
  });

  test('saves while playing every 30 seconds (R8)', () {
    run((async, cubit) {
      async.elapse(const Duration(seconds: 29));
      verifyNever(() => repository.saveParentalSettings(any()));
      async.elapse(const Duration(seconds: 1));
      expect(lastSaved().playTime!.played, const Duration(seconds: 30));
    });
  });

  test('reaching the limit asks for a rest only once no board is in progress (R4)', () {
    storeSettings(ParentalSettings(
      dailyLimitMinutes: 15,
      playTime: DailyPlayTime(day: startTime, played: const Duration(minutes: 14, seconds: 58)),
    ));
    run((async, cubit) {
      cubit.setBoardInProgress(true);
      async.elapse(const Duration(seconds: 5));
      expect(cubit.state.limitReached, isTrue);
      expect(cubit.state.mustRest, isFalse);
      // El tablero en curso sigue contando hasta terminar.
      expect(cubit.state.today.played, const Duration(minutes: 15, seconds: 3));

      cubit.setBoardInProgress(false);
      expect(cubit.state.mustRest, isTrue);
      // Frente a la pantalla de descanso ya no se suma tiempo.
      async.elapse(const Duration(minutes: 10));
      expect(cubit.state.today.played, const Duration(minutes: 15, seconds: 3));

      cubit.enterAdultArea();
      expect(cubit.state.mustRest, isFalse);
    });
  });

  test('15 more minutes let the child play again (R6, criterion 5)', () {
    storeSettings(ParentalSettings(
      dailyLimitMinutes: 15,
      playTime: DailyPlayTime(day: startTime, played: const Duration(minutes: 15)),
    ));
    run((async, cubit) {
      expect(cubit.state.mustRest, isTrue);

      cubit.grantExtra();
      async.flushMicrotasks();
      expect(cubit.state.limitReached, isFalse);
      expect(lastSaved().playTime!.extraMinutes, 15);

      async.elapse(const Duration(minutes: 14, seconds: 59));
      expect(cubit.state.limitReached, isFalse);
      async.elapse(const Duration(seconds: 1));
      expect(cubit.state.limitReached, isTrue);
    });
  });

  test('extra time without a limit does nothing', () {
    run((async, cubit) {
      cubit.grantExtra();
      async.flushMicrotasks();
      expect(cubit.state.today.extraMinutes, 0);
      verifyNever(() => repository.saveParentalSettings(any()));
    });
  });

  test('changing the limit applies at once and is saved (R7)', () {
    storeSettings(ParentalSettings(
      dailyLimitMinutes: 60,
      playTime: DailyPlayTime(day: startTime, played: const Duration(minutes: 20)),
    ));
    run((async, cubit) {
      cubit.setLimit(15);
      async.flushMicrotasks();
      expect(cubit.state.limitReached, isTrue);
      expect(lastSaved(), ParentalSettings(dailyLimitMinutes: 15, playTime: cubit.state.today));

      cubit.setLimit(null);
      async.flushMicrotasks();
      expect(cubit.state.limitReached, isFalse);
      expect(lastSaved().dailyLimitMinutes, isNull);

      expect(() => cubit.setLimit(3), throwsRangeError);
      expect(() => cubit.setLimit(721), throwsRangeError);
    });
  });

  test('a new day ends the rest while the app stays open (criterion 7)', () {
    final DateTime lateEvening = DateTime(2026, 11, 4, 23, 59, 50);
    storeSettings(ParentalSettings(
      dailyLimitMinutes: 15,
      playTime: DailyPlayTime(day: lateEvening, played: const Duration(minutes: 20)),
    ));
    run(from: lateEvening, (async, cubit) {
      expect(cubit.state.mustRest, isTrue);
      async.elapse(const Duration(seconds: 9));
      expect(cubit.state.mustRest, isTrue);
      async.elapse(const Duration(seconds: 2));
      expect(cubit.state.mustRest, isFalse);
      expect(cubit.state.today.day, DateTime(2026, 11, 5));
    });
  });

  test('coming back to the foreground on another day starts from zero', () {
    run((async, cubit) {
      async.elapse(const Duration(seconds: 5));
      cubit.setForeground(false);
      async.elapse(const Duration(days: 1));
      cubit.setForeground(true);
      expect(cubit.state.today.played, Duration.zero);
      expect(cubit.state.today.day, DateTime(2026, 11, 5));
    });
  });

  test('a failed save does not stop the count', () {
    when(() => repository.saveParentalSettings(any())).thenThrow(StateError('disk full'));
    run((async, cubit) {
      final errors = <Object>[];
      cubit.stream.listen((_) {}, onError: errors.add);
      async.elapse(const Duration(seconds: 31));
      expect(cubit.state.today.played, const Duration(seconds: 31));
    });
  });

  test('closing saves what was played', () {
    fakeAsync((async) {
      final cubit = PlayTimeCubit(repository: repository, now: () => startTime.add(async.elapsed));
      cubit.start();
      async.flushMicrotasks();
      async.elapse(const Duration(seconds: 7));
      cubit.close();
      async.flushMicrotasks();
      expect(lastSaved().playTime!.played, const Duration(seconds: 7));
      cubit.setForeground(false); // tras cerrar, no hace nada
      cubit.setBoardInProgress(true);
      expect(cubit.state.boardInProgress, isFalse);
    });
  });

  test('state equality by value', () {
    final today = DailyPlayTime.startOf(startTime);
    expect(PlayTimeState(today: today, limitMinutes: 5), PlayTimeState(today: today, limitMinutes: 5));
    expect(PlayTimeState(today: today).hashCode, PlayTimeState(today: today).hashCode);
    expect(PlayTimeState(today: today), isNot(PlayTimeState(today: today, inAdultArea: true)));
  });

  group('history by day and by game (HU-034 R3)', () {
    test('adds the time to the open game, or outside the games in the menu', () {
      run((async, cubit) {
        async.elapse(const Duration(seconds: 2));
        cubit.setCurrentGame(GameId.shadows);
        async.elapse(const Duration(seconds: 5));
        cubit.setCurrentGame(null);
        async.elapse(const Duration(seconds: 1));

        final PlayDay today = cubit.state.history!.dayAt(startTime);
        expect(today.playedIn(GameId.shadows), const Duration(seconds: 5));
        expect(today.outsideGames, const Duration(seconds: 3));
        expect(today.total, cubit.state.today.played, reason: 'the same time the daily limit counts');
      });
    });

    test('starts from what was saved and saves the day with the play time', () {
      when(() => repository.readPlayHistory(any())).thenAnswer((_) async => PlayHistory([
            PlayDay(day: startTime, byGame: {GameId.memory: const Duration(minutes: 4)}),
          ]));
      run((async, cubit) {
        cubit.setCurrentGame(GameId.memory);
        async.elapse(PlayTimeCubit.saveEvery);
        final PlayDay saved = verify(() => repository.savePlayDay(captureAny())).captured.last as PlayDay;
        expect(saved.playedIn(GameId.memory), const Duration(minutes: 4) + PlayTimeCubit.saveEvery);
      });
    });

    test('nothing played, nothing saved; a failed read starts an empty history', () {
      when(() => repository.readPlayHistory(any())).thenThrow(StateError('disk'));
      run((async, cubit) {
        expect(cubit.state.history, PlayHistory(const []));
        cubit.setForeground(false);
        async.flushMicrotasks();
      });
      verifyNever(() => repository.savePlayDay(any()));
    });

    test('a new day starts its own entry', () {
      run((async, cubit) {
        async.elapse(const Duration(hours: 14, seconds: 1));
        final PlayHistory history = cubit.state.history!;
        expect(history.days.map((day) => day.day), [DateTime(2026, 11, 4), DateTime(2026, 11, 5)]);
      });
    });
  });

  group('bedtime and naps (HU-038)', () {
    const RestSchedule nightOnly = RestSchedule(night: RestSchedule.defaultNight);
    final DateTime evening = DateTime(2026, 11, 20, 19, 29, 50);

    test('opening the app at night asks for the night rest at once (R1)', () {
      storeSettings(ParentalSettings(restSchedule: nightOnly));
      run((async, cubit) {
        expect(cubit.state.schedule, nightOnly);
        expect(cubit.state.scheduledRest, RestKind.night);
        expect(cubit.state.restDue, isTrue);
        expect(cubit.state.mustRest, isTrue);
        expect(cubit.state.limitReached, isFalse);
      }, from: DateTime(2026, 11, 20, 22));
    });

    test('a nap is its own kind of rest', () {
      storeSettings(ParentalSettings(restSchedule: const RestSchedule(naps: [RestSchedule.defaultNap])));
      run((async, cubit) => expect(cubit.state.scheduledRest, RestKind.nap), from: DateTime(2026, 11, 20, 14));
    });

    test('the night starts while playing: the board in progress ends first (R2), and no time is counted', () {
      storeSettings(ParentalSettings(restSchedule: nightOnly));
      run((async, cubit) {
        cubit.setBoardInProgress(true);
        expect(cubit.state.scheduledRest, isNull);
        async.elapse(const Duration(seconds: 15));
        expect(cubit.state.scheduledRest, RestKind.night);
        expect(cubit.state.mustRest, isFalse, reason: 'the board is not cut');
        cubit.setBoardInProgress(false);
        expect(cubit.state.mustRest, isTrue);
        final Duration played = cubit.state.today.played;
        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.today.played, played, reason: 'the rest screen does not use up play time');
      }, from: evening);
    });

    test('at the end of the night the app is normal again (R6)', () {
      storeSettings(ParentalSettings(restSchedule: nightOnly));
      run((async, cubit) {
        expect(cubit.state.mustRest, isTrue);
        async.elapse(const Duration(seconds: 15));
        expect(cubit.state.scheduledRest, isNull);
        expect(cubit.state.mustRest, isFalse);
      }, from: DateTime(2026, 11, 21, 6, 59, 50));
    });

    test('15 more minutes at night let the child play, are saved and end on time (R5)', () {
      storeSettings(ParentalSettings(restSchedule: nightOnly));
      final DateTime night = DateTime(2026, 11, 20, 22);
      run((async, cubit) {
        cubit.grantExtra();
        async.flushMicrotasks();
        expect(cubit.state.scheduledRest, isNull);
        expect(cubit.state.limitMinutes, isNull, reason: 'no daily limit is invented');
        expect(lastSaved().restAllowedUntil, night.add(PlayTimeCubit.extraTime));
        async.elapse(const Duration(minutes: 14));
        expect(cubit.state.scheduledRest, isNull);
        async.elapse(const Duration(minutes: 1, seconds: 1));
        expect(cubit.state.scheduledRest, RestKind.night);
      }, from: night);
    });

    test('the 15 minutes survive closing the app', () {
      final DateTime night = DateTime(2026, 11, 20, 22);
      storeSettings(
          ParentalSettings(restSchedule: nightOnly, restAllowedUntil: night.add(const Duration(minutes: 10))));
      run((async, cubit) => expect(cubit.state.scheduledRest, isNull), from: night);
    });

    test('with both the limit and the night, one tap gives 15 minutes for both; the first to come rules', () {
      final DateTime night = DateTime(2026, 11, 20, 22);
      storeSettings(ParentalSettings(
        dailyLimitMinutes: 15,
        playTime: DailyPlayTime(day: night, played: const Duration(minutes: 20)),
        restSchedule: nightOnly,
      ));
      run((async, cubit) {
        expect(cubit.state.limitReached, isTrue);
        expect(cubit.state.scheduledRest, RestKind.night);
        cubit.grantExtra();
        async.flushMicrotasks();
        expect(cubit.state.restDue, isFalse);
      }, from: night);
    });

    test('at night with the limit not reached, only the night is extended', () {
      final DateTime night = DateTime(2026, 11, 20, 22);
      storeSettings(ParentalSettings(dailyLimitMinutes: 60, restSchedule: nightOnly));
      run((async, cubit) {
        cubit.grantExtra();
        async.flushMicrotasks();
        expect(cubit.state.today.extraMinutes, 0);
        expect(cubit.state.restDue, isFalse);
      }, from: night);
    });

    test('a new schedule applies at once and is saved; an invalid one is refused', () {
      run((async, cubit) {
        cubit.setSchedule(nightOnly);
        async.flushMicrotasks();
        expect(cubit.state.scheduledRest, RestKind.night);
        expect(lastSaved().restSchedule, nightOnly);
        expect(
          () => cubit.setSchedule(RestSchedule(night: RestWindow(20 * 60, 20 * 60))),
          throwsArgumentError,
        );
      }, from: DateTime(2026, 11, 20, 21));
    });

    test('a failed save of the schedule is reported, and the schedule still applies', () {
      when(() => repository.updateParentalSettings(any())).thenThrow(StateError('disk'));
      run((async, cubit) {
        final errors = <Object>[];
        cubit.stream.listen((_) {}, onError: errors.add);
        cubit.setSchedule(nightOnly);
        async.flushMicrotasks();
        expect(cubit.state.schedule, nightOnly);
      }, from: DateTime(2026, 11, 20, 12));
    });

    test('coming back to the foreground looks at the time again', () {
      storeSettings(ParentalSettings(restSchedule: nightOnly));
      run((async, cubit) {
        cubit.setForeground(false);
        async.elapse(const Duration(minutes: 1));
        expect(cubit.state.scheduledRest, isNull);
        cubit.setForeground(true);
        expect(cubit.state.scheduledRest, RestKind.night);
      }, from: evening);
    });
  });
}
