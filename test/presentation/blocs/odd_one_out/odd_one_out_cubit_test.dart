import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/presentation/blocs/odd_one_out/odd_one_out_cubit.dart';
import 'package:toddler_logic/presentation/blocs/odd_one_out/odd_one_out_state.dart';

import '../../memory_game_test_support.dart';

class _ErrorRecordingCubit extends OddOneOutCubit {
  _ErrorRecordingCubit({required super.repository}) : super(random: Random(1));

  final errors = <Object>[];

  @override
  void onError(Object error, StackTrace stackTrace) {
    errors.add(error);
    super.onError(error, stackTrace);
  }
}

/// HU-025, entrega 2: estado del juego «¿Cuál es diferente?».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime now = DateTime(2026, 11, 11, 10);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  void givenProgress(GameProgress progress) =>
      when(() => repository.readGameProgress(GameId.oddOneOut)).thenAnswer((_) async => progress);
  void givenPremium(bool premium) => when(() => repository.readUserProfile())
      .thenAnswer((_) async => UserProfile(isPremium: premium, isSoundEnabled: true));
  GameProgress lastSaved() =>
      verify(() => repository.saveGameProgress(GameId.oddOneOut, captureAny())).captured.last as GameProgress;

  OddOneOutCubit started(FakeAsync async) {
    final cubit = OddOneOutCubit(repository: repository, random: Random(3), now: () => now);
    cubit.start();
    async.flushMicrotasks();
    return cubit;
  }

  /// Toca el diferente de los 3 tableros del nivel.
  void solveLevel(FakeAsync async, OddOneOutCubit cubit) {
    for (var board = 0; board < 3; board++) {
      cubit.tap(cubit.state.oddIndex);
      if (board < 2) async.elapse(OddOneOutCubit.solvedDuration);
    }
  }

  int wrongIndex(OddOneOutState state) => state.oddIndex == 0 ? 1 : 0;

  test('a new player starts in the Easy tutorial: 3 objects, no time, and the game counts as played', () {
    fakeAsync((async) {
      final cubit = started(async);
      expect(cubit.state.phase, OddPhase.playing);
      expect(cubit.state.gameRound, GameDifficulty.easy);
      expect(cubit.state.level, 1);
      expect(cubit.state.objects, hasLength(3));
      expect(cubit.state.remainingFraction, isNull);
      expect(lastSaved().lastPlayedAt, now);
      cubit.close();
    });
  });

  test('the right tap jumps to the next board; three boards complete the level (R3, P3)', () {
    fakeAsync((async) {
      givenProgress(progressAt(2));
      final cubit = started(async);
      final int first = cubit.state.round;
      cubit.tap(cubit.state.oddIndex);
      expect(cubit.state.phase, OddPhase.solved);
      cubit.tap(cubit.state.oddIndex);
      expect(cubit.state.board, 0, reason: 'taps are ignored while it jumps');
      async.elapse(OddOneOutCubit.solvedDuration);
      expect(cubit.state.board, 1);
      expect(cubit.state.round, first + 1);
      cubit.tap(cubit.state.oddIndex);
      async.elapse(OddOneOutCubit.solvedDuration);
      cubit.tap(cubit.state.oddIndex);

      expect(cubit.state.phase, OddPhase.celebrating);
      expect(cubit.state.stars, 3);
      async.elapse(OddOneOutCubit.celebrationDuration);
      expect(cubit.state.level, 3);
      expect(cubit.state.board, 0);
      cubit.close();
    });
  });

  test('a wrong tap is a mistake that can be repeated, and mistakes lower the stars (R4)', () {
    fakeAsync((async) {
      givenProgress(progressAt(2));
      final cubit = started(async);
      final int wrong = wrongIndex(cubit.state);
      for (var i = 0; i < 4; i++) {
        cubit.tap(wrong);
      }
      expect(cubit.state.fails, 4);
      expect(cubit.state.wrongIndex, wrong);
      expect(cubit.state.wrongCount, 4);
      cubit.tap(-1);
      cubit.tap(99);
      solveLevel(async, cubit);
      expect(cubit.state.stars, 1);
      cubit.close();
    });
  });

  test('the tutorial gives no stars and invites to play (HU-037 R9)', () {
    fakeAsync((async) {
      final cubit = started(async);
      solveLevel(async, cubit);
      expect(cubit.state.phase, OddPhase.inviting);
      expect(lastSaved().stars, 0);
      async.elapse(OddOneOutCubit.invitationDuration);
      expect(cubit.state.level, 2);
      expect(cubit.state.timeLimit, const Duration(seconds: 60));
      cubit.close();
    });
  });

  test('time runs over the 3 boards, stops while jumping and in the background, and losing goes down', () {
    fakeAsync((async) {
      givenProgress(progressAt(3));
      final cubit = started(async);
      expect(cubit.state.timeLimit, const Duration(seconds: 35));
      async.elapse(const Duration(seconds: 5));
      expect(cubit.state.elapsed, Duration.zero, reason: 'waits for the first touch');

      cubit.tap(cubit.state.oddIndex);
      async.elapse(OddOneOutCubit.solvedDuration);
      expect(cubit.state.elapsed, Duration.zero, reason: 'the jump does not count');
      cubit.tap(wrongIndex(cubit.state));
      async.elapse(const Duration(seconds: 10));
      cubit.pause();
      async.elapse(const Duration(seconds: 30));
      expect(cubit.state.elapsed, const Duration(seconds: 10));
      cubit.resume();
      async.elapse(const Duration(seconds: 25));

      expect(cubit.state.phase, OddPhase.timeUp);
      expect(cubit.state.loss, OddLoss.fewerObjects);
      async.elapse(OddOneOutCubit.timeUpDuration);
      expect(cubit.state.level, 2);
      expect(cubit.state.timeLimit, const Duration(seconds: 35), reason: 'keeps the limit');
      cubit.close();
    });
  });

  test('losing the first timed level goes to the tutorial; a second fall drops a round (HU-037 R10)', () {
    fakeAsync((async) {
      givenProgress(progressAt(2, tutorialFalls: 1));
      final cubit = started(async);
      cubit.tap(wrongIndex(cubit.state));
      async.elapse(const Duration(seconds: 41));
      expect(cubit.state.loss, OddLoss.easierRound);
      async.elapse(OddOneOutCubit.timeUpDuration);
      expect(cubit.state.gameRound, GameDifficulty.easy);
      expect(cubit.state.level, 2);

      cubit.tap(wrongIndex(cubit.state));
      async.elapse(const Duration(seconds: 61));
      expect(cubit.state.loss, OddLoss.restart);
      cubit.close();
    });
  });

  test('without Premium, completing Normal gives silver and stays in Normal (P1, P6)', () {
    fakeAsync((async) {
      givenProgress(progressAt(5));
      final cubit = started(async);
      solveLevel(async, cubit);
      expect(cubit.state.medal, GameDifficulty.normal);
      expect(cubit.state.hasMedal, isTrue);
      async.elapse(OddOneOutCubit.celebrationDuration);
      expect(cubit.state.gameRound, GameDifficulty.normal);
      expect(cubit.state.level, 1);
      cubit.close();
    });
  });

  test('with Premium, Normal leads to Impossible; a saved Impossible without Premium plays Normal', () {
    fakeAsync((async) {
      givenPremium(true);
      givenProgress(progressAt(5));
      final cubit = started(async);
      solveLevel(async, cubit);
      async.elapse(OddOneOutCubit.celebrationDuration);
      expect(cubit.state.gameRound, GameDifficulty.impossible);
      cubit.close();

      givenPremium(false);
      givenProgress(progressAt(3, round: GameDifficulty.impossible));
      final free = started(async);
      expect(free.state.gameRound, GameDifficulty.normal);
      expect(free.state.level, 1);
      free.close();
    });
  });

  test('«Play without time» with Premium removes the timer; without Premium it is reset', () {
    fakeAsync((async) {
      when(() => repository.readParentalSettings()).thenAnswer((_) async => ParentalSettings(timerDisabled: true));
      givenPremium(true);
      givenProgress(progressAt(4));
      final cubit = started(async);
      expect(cubit.state.remainingFraction, isNull);
      cubit.close();

      givenPremium(false);
      final free = started(async);
      expect(free.state.timeLimit, const Duration(seconds: 30));
      verify(() => repository.updateParentalSettings(any())).called(greaterThan(0));
      free.close();
    });
  });

  test('read and save failures are reported and the game still plays (D-010)', () {
    fakeAsync((async) {
      when(() => repository.readGameProgress(GameId.oddOneOut)).thenThrow(StateError('disk'));
      when(() => repository.readParentalSettings()).thenThrow(StateError('settings'));
      final cubit = _ErrorRecordingCubit(repository: repository);
      cubit.start();
      async.flushMicrotasks();
      expect(cubit.state.phase, OddPhase.playing);
      expect(cubit.errors, hasLength(2));

      when(() => repository.saveGameProgress(any(), any())).thenThrow(StateError('full'));
      solveLevel(async, cubit);
      async.flushMicrotasks();
      expect(cubit.errors.length, greaterThan(2));
      cubit.close();
      async.elapse(const Duration(seconds: 5));
      expect(async.pendingTimers, isEmpty);
    });
  });
}
