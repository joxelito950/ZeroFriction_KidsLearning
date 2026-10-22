import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/memory/memory_themes.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_cubit.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_state.dart';

import '../../memory_game_test_support.dart';

final _now = DateTime.utc(2026, 10, 22, 9);

class _ErrorRecordingCubit extends MemoryLadderCubit {
  _ErrorRecordingCubit({required super.repository, super.random, super.now});

  final errors = <Object>[];

  @override
  void onError(Object error, StackTrace stackTrace) {
    errors.add(error);
    super.onError(error, stackTrace);
  }
}

/// Índices de las parejas del tablero actual, agrupados por emoji.
List<List<int>> _pairs(MemoryLadderState state) {
  final bySymbol = <String, List<int>>{};
  for (var i = 0; i < state.cards.length; i++) {
    bySymbol.putIfAbsent(state.cards[i].assetPath, () => []).add(i);
  }
  return bySymbol.values.toList();
}

/// Gana la ronda sin fallos (movimientos = parejas).
void _winPerfectly(FakeAsync async, MemoryLadderCubit cubit) {
  for (final pair in _pairs(cubit.state)) {
    cubit.flipCard(pair[0]);
    cubit.flipCard(pair[1]);
    async.flushMicrotasks();
  }
}

/// Hace un intento fallido: dos cartas de parejas distintas.
void _miss(FakeAsync async, MemoryLadderCubit cubit) {
  final pairs = _pairs(cubit.state);
  cubit.flipCard(pairs[0][0]);
  cubit.flipCard(pairs[1][0]);
  async.elapse(MemoryLadderCubit.mismatchDelay);
}

void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  MemoryLadderCubit startedCubit(FakeAsync async, {MemoryProgress? saved, int seed = 1}) {
    if (saved != null) {
      when(() => repository.readMemoryProgress()).thenAnswer((_) async => saved);
    }
    final cubit = MemoryLadderCubit(repository: repository, random: Random(seed), now: () => _now);
    cubit.start();
    async.flushMicrotasks();
    return cubit;
  }

  MemoryProgress lastSavedProgress() =>
      verify(() => repository.saveMemoryProgress(captureAny())).captured.last as MemoryProgress;

  group('start', () {
    test('a child who never played gets a 2x2 board without time (criterion 2)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);

        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.position, MemoryLadder.start);
        expect(cubit.state.cards, hasLength(4));
        expect(cubit.state.remainingFraction, isNull);
      });
    });

    test('starts at the saved level with its arrival time limit (criterion 12)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 3));

        expect(cubit.state.position, MemoryLadder.arrivalPosition(3));
        expect(cubit.state.cards, hasLength(8));
        expect(cubit.state.remainingFraction, 1);
      });
    });

    test('all cards of a board belong to one theme, two of each emoji (criterion 14)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 5), seed: 9);
        final symbols = cubit.state.cards.map((card) => card.assetPath).toList();
        final theme = MemoryThemes.all.where((theme) => theme.symbols.toSet().containsAll(symbols));

        expect(theme, hasLength(1));
        expect(_pairs(cubit.state).every((pair) => pair.length == 2), isTrue);
      });
    });

    test('a failure reading the progress is reported and the game starts from the beginning', () {
      fakeAsync((async) {
        when(() => repository.readMemoryProgress()).thenThrow(StateError('corrupt'));
        final cubit = _ErrorRecordingCubit(repository: repository, random: Random(1));
        cubit.start();
        async.flushMicrotasks();

        expect(cubit.errors, [isA<StateError>()]);
        expect(cubit.state.position, MemoryLadder.start);
      });
    });
  });

  group('timer', () {
    test('a level without time never runs out, whatever the wait', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);
        cubit.flipCard(0);
        async.elapse(const Duration(minutes: 10));

        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.timerStarted, isFalse);
      });
    });

    test('starts with the first touched card, not when the board appears (criterion 3)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 2));
        async.elapse(const Duration(seconds: 20));
        expect(cubit.state.elapsed, Duration.zero);

        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 9));

        expect(cubit.state.timerStarted, isTrue);
        expect(cubit.state.elapsed, const Duration(seconds: 9));
        expect(cubit.state.remainingFraction, closeTo(0.9, 0.001));
      });
    });

    test('pauses in the background and continues where it was (criterion 11)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 2));
        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 5));

        cubit.pause();
        async.elapse(const Duration(minutes: 5));
        expect(cubit.state.elapsed, const Duration(seconds: 5));

        cubit.resume();
        async.elapse(const Duration(seconds: 2));
        expect(cubit.state.elapsed, const Duration(seconds: 7));
      });
    });
  });

  group('winning', () {
    test('a perfect round celebrates 3 stars, saves the record and moves up on its own (criteria 4, 5, 20, 21)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 2));
        _winPerfectly(async, cubit);

        expect(cubit.state.phase, MemoryRoundPhase.celebrating);
        expect(cubit.state.stars, 3);
        final saved = lastSavedProgress();
        expect(saved.currentLevel, 3);
        expect(saved.levelRecords[2], MemoryLevelRecord(bestStars: 3, achievedAt: _now));
        expect(saved.lastPlayedAt, _now);

        async.elapse(MemoryLadderCubit.celebrationDuration);
        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.position, const MemoryLadderPosition(level: 3, timeLimit: Duration(seconds: 60)));
        expect(cubit.state.moves, 0);
        expect(cubit.state.timerStarted, isFalse);
      });
    });

    test('the first win without time moves to 2x3 with 90 s (criterion 4)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);
        _winPerfectly(async, cubit);
        async.elapse(MemoryLadderCubit.celebrationDuration);

        expect(cubit.state.position, MemoryLadder.arrivalPosition(2));
      });
    });

    test('more moves give fewer stars (D-030)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);
        _miss(async, cubit);
        _miss(async, cubit);
        _winPerfectly(async, cubit);

        expect(cubit.state.moves, 4);
        expect(cubit.state.stars, 2);
      });
    });

    test('winning the 4x4 earns the badge and restarts at 2x2 without time (criterion 8)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 5));
        _winPerfectly(async, cubit);

        expect(cubit.state.badgeEarned, isTrue);
        expect(cubit.state.hasBadge, isTrue);
        expect(lastSavedProgress().hasBadge, isTrue);

        async.elapse(MemoryLadderCubit.celebrationDuration);
        expect(cubit.state.position, MemoryLadder.start);
        expect(cubit.state.hasBadge, isTrue);
        expect(cubit.state.badgeEarned, isFalse);
      });
    });
  });

  group('losing by time', () {
    test('goes down one level keeping the limit, on its own (criterion 6)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 4));
        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 45));

        expect(cubit.state.phase, MemoryRoundPhase.timeUp);
        expect(cubit.state.loss, MemoryLoss.fewerCards);
        expect(cubit.state.remainingFraction, 0);
        expect(lastSavedProgress().currentLevel, 3);

        async.elapse(MemoryLadderCubit.timeUpDuration);
        expect(cubit.state.phase, MemoryRoundPhase.playing);
        expect(cubit.state.position, const MemoryLadderPosition(level: 3, timeLimit: Duration(seconds: 45)));
      });
    });

    test('losing the timed 2x2 restarts without time (criterion 7)', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 2));
        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 90));
        async.elapse(MemoryLadderCubit.timeUpDuration);
        expect(cubit.state.position, const MemoryLadderPosition(level: 1, timeLimit: Duration(seconds: 90)));

        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 90));
        expect(cubit.state.loss, MemoryLoss.restart);

        async.elapse(MemoryLadderCubit.timeUpDuration);
        expect(cubit.state.position, MemoryLadder.start);
      });
    });

    test('time running out during a mismatch does not touch the next board', () {
      fakeAsync((async) {
        final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 5));
        cubit.flipCard(0);
        async.elapse(const Duration(seconds: 29, milliseconds: 500));
        final pairs = _pairs(cubit.state);
        final second = pairs.firstWhere((pair) => !pair.contains(0))[0];
        cubit.flipCard(second);
        async.elapse(const Duration(seconds: 1));

        expect(cubit.state.phase, MemoryRoundPhase.timeUp);
        async.elapse(MemoryLadderCubit.timeUpDuration);
        expect(cubit.state.cards.every((card) => !card.isFaceUp), isTrue);
      });
    });
  });

  group('cards', () {
    test('two different cards are shown and then hidden after a moment', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);
        final pairs = _pairs(cubit.state);
        cubit.flipCard(pairs[0][0]);
        cubit.flipCard(pairs[1][0]);

        expect(cubit.state.isProcessing, isTrue);
        expect(cubit.state.moves, 1);
        cubit.flipCard(pairs[0][1]);
        expect(cubit.state.cards[pairs[0][1]].isFaceUp, isFalse, reason: 'taps are ignored meanwhile');

        async.elapse(MemoryLadderCubit.mismatchDelay);
        expect(cubit.state.cards.every((card) => !card.isFaceUp), isTrue);
        expect(cubit.state.isProcessing, isFalse);
      });
    });

    test('ignores taps outside the board, on matched cards and during the celebration', () {
      fakeAsync((async) {
        final cubit = startedCubit(async);
        final pairs = _pairs(cubit.state);
        cubit.flipCard(-1);
        cubit.flipCard(99);
        cubit.flipCard(pairs[0][0]);
        cubit.flipCard(pairs[0][1]);
        final afterMatch = cubit.state;
        cubit.flipCard(pairs[0][0]);
        expect(cubit.state, same(afterMatch));

        cubit.flipCard(pairs[1][0]);
        cubit.flipCard(pairs[1][1]);
        final celebrating = cubit.state;
        cubit.flipCard(0);
        expect(cubit.state, same(celebrating));
      });
    });
  });

  test('a failure saving the progress is reported and the game goes on (D-010)', () {
    fakeAsync((async) {
      when(() => repository.saveMemoryProgress(any())).thenThrow(StateError('disk full'));
      final cubit = _ErrorRecordingCubit(repository: repository, random: Random(3), now: () => _now);
      cubit.start();
      async.flushMicrotasks();
      _winPerfectly(async, cubit);
      async.elapse(MemoryLadderCubit.celebrationDuration);

      expect(cubit.errors, [isA<StateError>()]);
      expect(cubit.state.position, MemoryLadder.arrivalPosition(2));
    });
  });

  test('closing the screen stops every pending timer', () {
    fakeAsync((async) {
      final cubit = startedCubit(async, saved: MemoryProgress(currentLevel: 2));
      cubit.flipCard(0);
      cubit.close();
      async.elapse(const Duration(minutes: 5));

      expect(async.pendingTimers, isEmpty);
    });
  });
}
