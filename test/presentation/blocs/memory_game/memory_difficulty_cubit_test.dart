import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_cubit.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_state.dart';

import '../../memory_game_test_support.dart';

/// HU-030 en el juego de memoria: dificultad, «Jugar sin tiempo» (Premium) y
/// vista previa de las cartas.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;
  late ParentalSettings stored;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    stored = ParentalSettings.initial;
    when(() => repository.readParentalSettings()).thenAnswer((_) async => stored);
    when(() => repository.saveParentalSettings(any())).thenAnswer((invocation) async {
      stored = invocation.positionalArguments.single as ParentalSettings;
    });
  });

  void premium(bool value) {
    when(() => repository.readUserProfile())
        .thenAnswer((_) async => UserProfile(isPremium: value, isSoundEnabled: true));
  }

  MemoryLadderCubit started(FakeAsync async, {int level = 1, Duration? preview = Duration.zero}) {
    when(() => repository.readMemoryProgress()).thenAnswer((_) async => MemoryProgress(currentLevel: level));
    final cubit = MemoryLadderCubit(repository: repository, random: Random(5), preview: preview);
    cubit.start();
    async.flushMicrotasks();
    return cubit;
  }

  void winPerfectly(FakeAsync async, MemoryLadderCubit cubit) {
    final bySymbol = <String, List<int>>{};
    for (var i = 0; i < cubit.state.cards.length; i++) {
      bySymbol.putIfAbsent(cubit.state.cards[i].assetPath, () => []).add(i);
    }
    for (final pair in bySymbol.values) {
      cubit.flipCard(pair[0]);
      cubit.flipCard(pair[1]);
      async.flushMicrotasks();
    }
  }

  group('preview (3.4)', () {
    test('Normal shows every card face up for 1 s, ignoring taps, then flips them all (criterion 11)', () {
      fakeAsync((async) {
        final cubit = started(async, preview: null);

        expect(cubit.state.phase, MemoryRoundPhase.previewing);
        expect(cubit.state.cards.every((card) => card.isFaceUp), isTrue);
        cubit.flipCard(0);
        expect(cubit.state.moves, 0);
        expect(cubit.state.timerStarted, isFalse);

        async.elapse(MemoryLadderCubit.previewDuration);
        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.cards.any((card) => card.isFaceUp), isFalse);
        cubit.close();
      });
    });

    test('Impossible deals face down, without preview (criterion 12)', () {
      stored = ParentalSettings(difficulty: GameDifficulty.impossible);
      fakeAsync((async) {
        final cubit = started(async, preview: null);

        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.cards.any((card) => card.isFaceUp), isFalse);
        cubit.close();
      });
    });

    test('closing during the preview stops it', () {
      fakeAsync((async) {
        final cubit = started(async, preview: const Duration(seconds: 5));
        cubit.close();
        async.elapse(const Duration(seconds: 6));
        expect(cubit.state.phase, MemoryRoundPhase.previewing);
      });
    });
  });

  group('difficulty', () {
    test('Easy arrives at 2x3 with 270 s (criterion 2)', () {
      stored = ParentalSettings(difficulty: GameDifficulty.easy);
      fakeAsync((async) {
        final cubit = started(async, level: 2);
        expect(cubit.state.position, const MemoryLadderPosition(level: 2, timeLimit: Duration(seconds: 270)));
        cubit.close();
      });
    });

    test('a change made during a board is applied on the next one, at the same level (R6, criterion 5)', () {
      fakeAsync((async) {
        final cubit = started(async);
        expect(cubit.state.position, MemoryLadder.start);

        stored = ParentalSettings(difficulty: GameDifficulty.impossible);
        // El tablero en curso no cambia.
        expect(cubit.state.position, MemoryLadder.start);
        winPerfectly(async, cubit);
        async.elapse(MemoryLadderCubit.celebrationDuration);

        expect(cubit.state.position, const MemoryLadderPosition(level: 2, timeLimit: Duration(seconds: 45)));
        cubit.close();
      });
    });

    test('settings that cannot be read leave the game in Normal with time', () {
      when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
      fakeAsync((async) {
        final cubit = started(async, level: 3);
        expect(cubit.state.position, MemoryLadder.arrivalPosition(3));
        cubit.close();
      });
    });
  });

  group('play without time (R3, R4, R11)', () {
    test('with Premium there is no time on any level and the 4x4 still gives the badge (criterion 4)', () {
      stored = ParentalSettings(timerDisabled: true);
      premium(true);
      fakeAsync((async) {
        final cubit = started(async, level: 5);
        expect(cubit.state.position, const MemoryLadderPosition(level: 5));
        expect(cubit.state.remainingFraction, isNull);

        winPerfectly(async, cubit);
        expect(cubit.state.badgeEarned, isTrue);
        cubit.close();
      });
    });

    test('without Premium the game keeps its time and the setting goes back to its default (criteria 4b, 4c)', () {
      stored = ParentalSettings(timerDisabled: true);
      premium(false);
      fakeAsync((async) {
        final cubit = started(async, level: 2);

        expect(cubit.state.position, MemoryLadder.arrivalPosition(2));
        expect(stored.timerDisabled, isFalse);
        cubit.close();
      });
    });
  });
}
