import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_drop.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_catalog.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_drop.dart';
import 'package:toddler_logic/presentation/blocs/sound/game_sound_events.dart';
import 'package:toddler_logic/domain/sound/game_sound.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_state.dart';

import '../../memory_game_test_support.dart';

/// HU-052, entrega 2: la partida de «A su sitio».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime now = DateTime(2026, 11, 18, 10);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  void givenProgress(GameProgress progress) =>
      when(() => repository.readGameProgress(GameId.vehicles)).thenAnswer((_) async => progress);
  GameProgress lastSaved() =>
      verify(() => repository.saveGameProgress(GameId.vehicles, captureAny())).captured.last as GameProgress;

  VehicleGameCubit started(FakeAsync async, {bool christmas = false}) {
    final cubit = VehicleGameCubit(repository: repository, random: Random(1), now: () => now, christmas: (_) => christmas);
    cubit.start();
    async.flushMicrotasks();
    return cubit;
  }

  /// Coloca todos los vehículos sin fallos, por la vía del lector de pantalla.
  void placeAll(VehicleGameCubit cubit) {
    for (final Vehicle vehicle in List.of(cubit.state.vehicles)) {
      cubit.match(vehicle, cubit.state.board!.targetOf(vehicle));
    }
  }

  Place wrongPlace(VehicleGameState state, Vehicle vehicle) =>
      state.board!.places.firstWhere((place) => !state.board!.accepts(place, vehicle));

  group('start', () {
    test('first time: the bronze tutorial, «where it goes», no time, and the game counts as played', () {
      fakeAsync((async) {
        givenProgress(GameProgress.initial());
        final cubit = started(async);
        expect(cubit.state.phase, VehiclePhase.playing);
        expect(cubit.state.level, 1);
        expect(cubit.state.gameRound, GameDifficulty.bronze);
        expect(cubit.state.vehicles, hasLength(2));
        expect(cubit.state.timeLimit, isNull);
        expect(cubit.state.placesFirst, isTrue);
        expect(lastSaved().lastPlayedAt, now);
        cubit.close();
      });
    });

    test('from gold the levels after the tutorial have time, unless «play without time»', () {
      fakeAsync((async) {
        givenProgress(progressAt(3, round: GameDifficulty.gold));
        final timed = started(async);
        expect(timed.state.timeLimit, isNotNull);
        timed.close();

        when(() => repository.readParentalSettings())
            .thenAnswer((_) async => ParentalSettings.initial.withTimerDisabled(true));
        when(() => repository.readUserProfile()).thenAnswer((_) async => const UserProfile(isPremium: true, isSoundEnabled: true));
        final untimed = started(async);
        expect(untimed.state.timeLimit, isNull);
        untimed.close();
      });
    });

    test('silver never has time (D-043)', () {
      fakeAsync((async) {
        givenProgress(progressAt(5, round: GameDifficulty.silver));
        final cubit = started(async);
        expect(cubit.state.timeLimit, isNull);
        cubit.close();
      });
    });

    test('at Christmas the sled is on the board (section 6)', () {
      fakeAsync((async) {
        givenProgress(progressAt(3, round: GameDifficulty.bronze));
        final cubit = started(async, christmas: true);
        expect(cubit.state.vehicles, contains(Vehicle.sled));
        cubit.close();
      });
    });

    test('a progress that cannot be read starts from the beginning and reports the error', () {
      fakeAsync((async) {
        when(() => repository.readGameProgress(GameId.vehicles)).thenThrow(Exception('disk'));
        final cubit = started(async);
        expect(cubit.state.level, 1);
        cubit.close();
      });
    });
  });

  group('playing', () {
    test('a vehicle on its place stays; on another place it counts a mistake; dropped outside, nothing', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.bronze));
        final cubit = started(async);
        final Vehicle vehicle = cubit.state.vehicles.first;
        const ShadowBox box = ShadowBox(left: 0, top: 0, width: 10, height: 10);
        const ShadowBox far = ShadowBox(left: 500, top: 500, width: 10, height: 10);
        final Place target = cubit.state.board!.targetOf(vehicle);
        final Place other = wrongPlace(cubit.state, vehicle);

        expect(cubit.drop(vehicle, box: box, placeBoxes: {other: box, target: far}), ShadowDropOutcome.wrongShadow);
        expect(cubit.state.fails, 1);
        expect(cubit.drop(vehicle, box: box, placeBoxes: {other: far, target: far}), ShadowDropOutcome.missed);
        expect(cubit.state.fails, 1);
        expect(cubit.drop(vehicle, box: box, placeBoxes: {target: box}), ShadowDropOutcome.snapped);
        expect(cubit.state.placed, {vehicle});
        expect(cubit.state.placedAt(target), [vehicle]);
        expect(cubit.drop(vehicle, box: box, placeBoxes: {target: box}), ShadowDropOutcome.missed,
            reason: 'a placed vehicle cannot move');
        expect(cubit.match(vehicle, target), ShadowDropOutcome.missed);
        cubit.close();
      });
    });

    test('the screen reader way: a wrong place is a mistake, a place not on the board does nothing', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.bronze));
        final cubit = started(async);
        final Vehicle vehicle = cubit.state.vehicles.first;
        expect(cubit.match(vehicle, wrongPlace(cubit.state, vehicle)), ShadowDropOutcome.wrongShadow);
        final Place absent = Place.values.firstWhere((place) => !cubit.state.board!.places.contains(place));
        expect(cubit.match(vehicle, absent), ShadowDropOutcome.missed);
        expect(cubit.state.fails, 1);
        cubit.close();
      });
    });

    test('placing every vehicle celebrates with 3 stars, saves, and deals the next level', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.bronze));
        final cubit = started(async);
        final int round = cubit.state.round;
        placeAll(cubit);
        expect(cubit.state.phase, VehiclePhase.celebrating);
        expect(cubit.state.stars, 3);
        expect(lastSaved().position.level, 5);
        async.elapse(VehicleGameCubit.celebrationDuration);
        async.flushMicrotasks();
        expect(cubit.state.round, round + 1);
        expect(cubit.state.level, 5);
        cubit.close();
      });
    });

    test('the last level gives the medal and moves to the next round', () {
      fakeAsync((async) {
        givenProgress(progressAt(8, round: GameDifficulty.bronze));
        final cubit = started(async);
        placeAll(cubit);
        expect(cubit.state.medal, GameDifficulty.bronze);
        expect(lastSaved().position.round, GameDifficulty.silver);
        cubit.close();
      });
    });

    test('the tutorial invites to play, without stars', () {
      fakeAsync((async) {
        givenProgress(GameProgress.initial());
        final cubit = started(async);
        placeAll(cubit);
        expect(cubit.state.phase, VehiclePhase.inviting);
        async.elapse(VehicleGameCubit.invitationDuration);
        async.flushMicrotasks();
        expect(cubit.state.level, 2);
        cubit.close();
      });
    });

    test('the clock starts with the first touch, stops in the background and runs out kindly', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.gold));
        final cubit = started(async);
        final Duration limit = cubit.state.timeLimit!;
        async.elapse(const Duration(seconds: 5));
        expect(cubit.state.elapsed, Duration.zero);
        cubit.grab(cubit.state.vehicles.first);
        expect(cubit.state.timerStarted, isTrue);
        cubit.pause();
        async.elapse(const Duration(seconds: 2));
        expect(cubit.state.elapsed, Duration.zero);
        cubit.resume();
        async.elapse(limit);
        expect(cubit.state.phase, VehiclePhase.timeUp);
        expect(cubit.state.lossKind, VehicleLoss.fewerVehicles);
        async.elapse(VehicleGameCubit.timeUpDuration);
        async.flushMicrotasks();
        expect(cubit.state.level, 3);
        cubit.close();
      });
    });

    test('losing the first timed level plays it again', () {
      fakeAsync((async) {
        givenProgress(progressAt(2, round: GameDifficulty.gold));
        final cubit = started(async);
        cubit.grab(cubit.state.vehicles.first);
        async.elapse(cubit.state.timeLimit!);
        expect(cubit.state.lossKind, VehicleLoss.restart);
        cubit.close();
      });
    });

    test('a progress that cannot be saved does not stop the game', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.bronze));
        when(() => repository.saveGameProgress(GameId.vehicles, any())).thenThrow(Exception('disk'));
        final cubit = started(async);
        placeAll(cubit);
        expect(cubit.state.phase, VehiclePhase.celebrating);
        cubit.close();
      });
    });
  });

  group('sounds', () {
    test('placing sounds like a pair, the last one is the board, the medal its own; mistakes are silent', () {
      fakeAsync((async) {
        givenProgress(progressAt(4, round: GameDifficulty.bronze));
        final cubit = started(async);
        final VehicleGameState start = cubit.state;
        final Vehicle first = start.vehicles.first;
        cubit.match(first, wrongPlace(start, first));
        expect(GameSoundEvents.vehicles(start, cubit.state), isNull);
        final VehicleGameState before = cubit.state;
        cubit.match(first, start.board!.targetOf(first));
        expect(GameSoundEvents.vehicles(before, cubit.state), GameSound.match);
        final VehicleGameState beforeLast = cubit.state;
        for (final Vehicle vehicle in start.vehicles.skip(1)) {
          cubit.match(vehicle, start.board!.targetOf(vehicle));
        }
        expect(GameSoundEvents.vehicles(beforeLast, cubit.state), GameSound.complete);
        expect(
          GameSoundEvents.vehicles(beforeLast, cubit.state.copyWith(medal: GameDifficulty.bronze)),
          GameSound.badge,
        );
        cubit.close();
      });
    });
  });

  test('a vehicle snaps by the part of it over its place (7.1)', () {
    const ShadowBox place = ShadowBox(left: 0, top: 0, width: 100, height: 100);
    const ShadowBox half = ShadowBox(left: 80, top: 0, width: 40, height: 40);
    expect(VehicleDrop.overlap(half, place), closeTo(0.5, 0.001));
    expect(
      VehicleDrop.evaluate(target: Place.road, vehicle: half, places: {Place.road: place}, threshold: 0.4),
      ShadowDropOutcome.snapped,
    );
    expect(
      VehicleDrop.evaluate(target: Place.road, vehicle: half, places: {Place.road: place}, threshold: 0.6),
      ShadowDropOutcome.missed,
    );
  });
}
