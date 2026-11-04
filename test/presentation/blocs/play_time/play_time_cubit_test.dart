import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
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
}
