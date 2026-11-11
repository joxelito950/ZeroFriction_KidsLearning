import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_drop.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_state.dart';

import '../../memory_game_test_support.dart';

class _ErrorRecordingCubit extends ShadowGameCubit {
  _ErrorRecordingCubit({required super.repository}) : super(random: Random(1));

  final errors = <Object>[];

  @override
  void onError(Object error, StackTrace stackTrace) {
    errors.add(error);
    super.onError(error, stackTrace);
  }
}

/// HU-007, entrega 2: estado del juego Sombras.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime now = DateTime(2026, 11, 9, 10);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    // Normal por defecto: el juego de antes de las rondas (HU-037).
    when(() => repository.readGameProgress(GameId.shadows)).thenAnswer((_) async => progressAt(1));
  });

  void givenPremium(bool premium) => when(() => repository.readUserProfile())
      .thenAnswer((_) async => UserProfile(isPremium: premium, isSoundEnabled: true));
  void givenSettings(ParentalSettings settings) =>
      when(() => repository.readParentalSettings()).thenAnswer((_) async => settings);
  void givenProgress(GameProgress progress) =>
      when(() => repository.readGameProgress(GameId.shadows)).thenAnswer((_) async => progress);
  GameProgress lastSaved() =>
      verify(() => repository.saveGameProgress(GameId.shadows, captureAny())).captured.last as GameProgress;

  /// Arranca el juego y deja el tablero listo para jugar.
  ShadowGameCubit started(FakeAsync async) {
    final cubit = ShadowGameCubit(repository: repository, random: Random(1), now: () => now);
    cubit.start();
    async.flushMicrotasks();
    cubit.finishIntro();
    return cubit;
  }

  /// Encaja todos los objetos, sin fallos, por la vía del lector de pantalla.
  void placeAll(ShadowGameCubit cubit) {
    for (final object in List.of(cubit.state.objects)) {
      cubit.match(object, object);
    }
  }

  /// Una sombra libre que no es la del objeto.
  String otherShadow(ShadowGameState state, String object) =>
      state.shadows.firstWhere((shadow) => shadow != object && !state.placed.contains(shadow));

  group('start', () {
    test('first time: the Easy tutorial with its start animation, free, no time, and the game counts as played', () {
      fakeAsync((async) {
        givenProgress(GameProgress.initial());
        final cubit = ShadowGameCubit(repository: repository, random: Random(1), now: () => now);
        cubit.start();
        async.flushMicrotasks();

        expect(cubit.state.phase, ShadowRoundPhase.introducing);
        expect(cubit.state.position, ShadowLadder.start);
        expect(cubit.state.objects, hasLength(2));
        expect(cubit.state.shadows, containsAll(cubit.state.objects));
        expect(cubit.state.premium, isFalse);
        expect(cubit.state.layout, ShadowLayout.shadowsFirst);
        expect(lastSaved().lastPlayedAt, now);

        cubit.grab(cubit.state.objects.first);
        expect(cubit.state.timerStarted, isFalse, reason: 'nothing moves during the animation');
        cubit.finishIntro();
        expect(cubit.state.phase, ShadowRoundPhase.playing);
        cubit.finishIntro();
        expect(cubit.state.phase, ShadowRoundPhase.playing);
        cubit.close();
      });
    });

    test('Impossible has no start animation; Easy has no free shadows', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.impossible));
        final cubit = ShadowGameCubit(repository: repository, random: Random(1), now: () => now);
        cubit.start();
        async.flushMicrotasks();
        expect(cubit.state.phase, ShadowRoundPhase.playing);
        expect(cubit.state.shadows, hasLength(5));
        cubit.close();

        givenProgress(progressAt(4, round: GameDifficulty.easy));
        final easy = started(async);
        expect(easy.state.shadows, hasLength(4));
        easy.close();
      });
    });

    test('a level 8 saved without Premium plays level 7', () {
      fakeAsync((async) {
        givenProgress(progressAt(8));
        final cubit = started(async);
        expect(cubit.state.level, 7);
        cubit.close();
      });
    });

    test('applies the star loss when the game starts (D-037)', () {
      fakeAsync((async) {
        givenProgress(progressAt(
          1,
          records: {
            const RoundLevel(GameDifficulty.normal, 2): LevelRecord(bestStars: 2, achievedAt: DateTime(2026, 10, 1)),
          },
          lastPlayedAt: now.subtract(const Duration(days: 13)),
        ));
        final cubit = started(async);
        expect(lastSaved().stars, 0);
        expect(cubit.state.goldFraction, 0);
        cubit.close();
      });
    });

    test('«Play without time» goes back to its default when there is no Premium (HU-030 R11)', () {
      fakeAsync((async) {
        givenSettings(ParentalSettings(timerDisabled: true));
        final cubit = started(async);
        verify(() => repository.updateParentalSettings(any())).called(greaterThan(0));
        cubit.close();
      });
    });
  });

  group('dropping (R4, R5, R9)', () {
    const box = ShadowBox(left: 0, top: 0, width: 100, height: 100);
    ShadowBox shifted(double dx) => ShadowBox(left: dx, top: 0, width: 100, height: 100);

    test('snaps with enough coverage of its own shadow; covering another one is a shape mistake', () {
      fakeAsync((async) {
        final cubit = started(async);
        final String object = cubit.state.objects.first;
        final String other = otherShadow(cubit.state, object);
        final shadows = {object: box, other: shifted(300)};

        // 50 % cubierto: no llega al 60 % de Normal.
        expect(cubit.drop(object, object: shifted(50), shadowBoxes: shadows), ShadowDropOutcome.missed);
        expect(cubit.state.fails, 0);
        expect(cubit.drop(object, object: shifted(300), shadowBoxes: shadows), ShadowDropOutcome.wrongShadow);
        expect(cubit.state.fails, 1);
        expect(cubit.drop(object, object: shifted(30), shadowBoxes: shadows), ShadowDropOutcome.snapped);
        expect(cubit.state.placed, {object});
        expect(cubit.state.trayObjects, isNot(contains(object)));
        expect(cubit.drop(object, object: box, shadowBoxes: shadows), ShadowDropOutcome.missed,
            reason: 'a placed object cannot move again (R17)');
        cubit.close();
      });
    });

    test('Easy snaps at 40 %, and an occupied shadow no longer counts as a mistake', () {
      fakeAsync((async) {
        givenProgress(progressAt(1, round: GameDifficulty.easy));
        final cubit = started(async);
        final [String first, String second] = cubit.state.objects;
        final shadows = {first: box, second: shifted(300)};
        expect(cubit.drop(first, object: shifted(55), shadowBoxes: shadows), ShadowDropOutcome.snapped);
        expect(cubit.drop(second, object: box, shadowBoxes: shadows), ShadowDropOutcome.missed);
        expect(cubit.state.fails, 0);
        cubit.close();
      });
    });

    test('matching without dragging (R16)', () {
      fakeAsync((async) {
        final cubit = started(async);
        final String object = cubit.state.objects.first;
        expect(cubit.match(object, otherShadow(cubit.state, object)), ShadowDropOutcome.wrongShadow);
        expect(cubit.match(object, '🦄'), ShadowDropOutcome.missed);
        expect(cubit.match('🦄', object), ShadowDropOutcome.missed);
        expect(cubit.match(object, object), ShadowDropOutcome.snapped);
        final String last = cubit.state.trayObjects.single;
        expect(cubit.match(last, object), ShadowDropOutcome.missed, reason: 'that shadow is taken');
        expect(cubit.state.fails, 1);
        cubit.close();
      });
    });
  });

  group('winning (R6, R8, R9, R10)', () {
    test('placing everything in the tutorial invites to play, without stars (HU-037 R9)', () {
      fakeAsync((async) {
        final cubit = started(async);
        placeAll(cubit);
        expect(cubit.state.phase, ShadowRoundPhase.inviting);
        expect(lastSaved().stars, 0);
        async.elapse(ShadowGameCubit.invitationDuration);
        expect(cubit.state.level, 2);
        cubit.close();
      });
    });

    test('placing everything celebrates with 3 stars, also for free (HU-037 P16), and moves up', () {
      fakeAsync((async) {
        givenProgress(progressAt(2));
        final cubit = started(async);
        placeAll(cubit);

        expect(cubit.state.phase, ShadowRoundPhase.celebrating);
        expect(cubit.state.stars, 3);
        expect(cubit.state.goldFraction, 3 / 63);
        expect(lastSaved().records[const RoundLevel(GameDifficulty.normal, 2)]!.bestStars, 3);
        expect(cubit.match(cubit.state.objects.first, cubit.state.objects.first), ShadowDropOutcome.missed);

        async.elapse(ShadowGameCubit.celebrationDuration);
        expect(cubit.state.level, 3);
        expect(cubit.state.phase, ShadowRoundPhase.introducing);
        expect(cubit.state.placed, isEmpty);
        cubit.close();
      });
    });

    test('many shape mistakes give fewer stars', () {
      fakeAsync((async) {
        givenProgress(progressAt(2));
        final cubit = started(async);
        final String object = cubit.state.objects.first;
        for (var i = 0; i < 4; i++) {
          cubit.match(object, otherShadow(cubit.state, object));
        }
        placeAll(cubit);
        expect(cubit.state.stars, 1);
        cubit.close();
      });
    });

    test('without Premium, level 7 completes the round with its medal (HU-037 P16)', () {
      fakeAsync((async) {
        givenProgress(progressAt(7));
        final cubit = started(async);
        placeAll(cubit);
        expect(cubit.state.medalEarned, isTrue);
        expect(cubit.state.medal, GameDifficulty.normal);
        async.elapse(ShadowGameCubit.celebrationDuration);
        expect(cubit.state.level, 1);
        expect(cubit.state.gameRound, GameDifficulty.impossible);
        cubit.close();
      });
    });

    test('with Premium, level 8 gives 3 stars and the medal', () {
      fakeAsync((async) {
        givenPremium(true);
        givenProgress(progressAt(8));
        final cubit = started(async);
        expect(cubit.state.premium, isTrue);
        placeAll(cubit);
        expect(cubit.state.stars, 3);
        expect(cubit.state.medalEarned, isTrue);
        expect(cubit.state.hasMedal, isTrue);
        expect(lastSaved().medals, {GameDifficulty.normal});
        cubit.close();
      });
    });

    test('buying Premium mid-board applies on the next board (R12)', () {
      fakeAsync((async) {
        givenProgress(progressAt(2));
        final cubit = started(async);
        expect(cubit.state.premium, isFalse);
        givenPremium(true);
        placeAll(cubit);
        async.elapse(ShadowGameCubit.celebrationDuration);
        expect(cubit.state.position, const ShadowPosition(level: 3, timeLimit: Duration(seconds: 50)));
        expect(cubit.state.premium, isTrue);
        cubit.close();
      });
    });
  });

  group('time (R7, 4.3, HU-037)', () {
    test('starts on the first touch, pauses in the background and moves down when it runs out', () {
      fakeAsync((async) {
        givenProgress(progressAt(2));
        final cubit = started(async);
        expect(cubit.state.position.timeLimit, const Duration(seconds: 60), reason: 'with rounds, free has time too');
        expect(cubit.state.remainingFraction, 1);

        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.elapsed, Duration.zero, reason: 'the timer waits for the first touch');
        cubit.grab(cubit.state.objects.first);
        expect(cubit.state.timerStarted, isTrue);
        async.elapse(const Duration(seconds: 10));
        expect(cubit.state.remaining, const Duration(seconds: 50));

        cubit.pause();
        async.elapse(const Duration(seconds: 30));
        expect(cubit.state.remaining, const Duration(seconds: 50));
        cubit.resume();
        async.elapse(const Duration(seconds: 50));

        expect(cubit.state.phase, ShadowRoundPhase.timeUp);
        expect(cubit.state.remaining, Duration.zero);
        expect(cubit.state.lossKind, ShadowLoss.restart);
        expect(lastSaved().position.level, 1);
        async.elapse(ShadowGameCubit.timeUpDuration);
        expect(cubit.state.position, const ShadowPosition(level: 1), reason: 'the tutorial has no time');
        cubit.close();
      });
    });

    test('Premium with «Play without time» has no timer but keeps level 8 (R18)', () {
      fakeAsync((async) {
        givenPremium(true);
        givenSettings(ParentalSettings(timerDisabled: true));
        givenProgress(progressAt(8));
        final cubit = started(async);
        expect(cubit.state.position, const ShadowPosition(level: 8));
        expect(cubit.state.remainingFraction, isNull);
        cubit.close();
      });
    });
  });

  group('errors (D-010)', () {
    test('an unreadable progress or settings still plays level 1, Normal and free', () {
      fakeAsync((async) {
        when(() => repository.readGameProgress(GameId.shadows)).thenThrow(StateError('disk'));
        when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
        final cubit = _ErrorRecordingCubit(repository: repository);
        cubit.start();
        async.flushMicrotasks();
        expect(cubit.state.position, ShadowLadder.start);
        expect(cubit.errors, hasLength(2));
        verifyNever(() => repository.saveGameProgress(any(), any()));
        cubit.close();
      });
    });

    test('a failed save does not stop the game', () {
      fakeAsync((async) {
        when(() => repository.saveGameProgress(any(), any())).thenThrow(StateError('disk'));
        when(() => repository.readParentalSettings()).thenAnswer((_) async {
          throw StateError('settings');
        });
        final cubit = _ErrorRecordingCubit(repository: repository);
        cubit.start();
        async.flushMicrotasks();
        cubit.finishIntro();
        placeAll(cubit);
        async.flushMicrotasks();
        expect(cubit.state.phase, ShadowRoundPhase.inviting, reason: 'the tutorial still invites to play');
        expect(cubit.errors.whereType<StateError>().map((e) => e.message), containsAll(['disk', 'settings']));
        cubit.close();
        async.elapse(ShadowGameCubit.celebrationDuration);
      });
    });
  });
}
