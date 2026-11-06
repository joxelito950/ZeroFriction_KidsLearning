import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_cubit.dart';

import '../../memory_game_test_support.dart';

/// HU-002 R13 y HU-016: la pérdida de estrellas se aplica y se guarda al
/// empezar el juego (D-037), salvo con «Mantener las estrellas».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final DateTime now = DateTime(2026, 11, 30, 10);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  MemoryProgress fullProgress({required DateTime lastPlayedAt}) => MemoryProgress(
        currentLevel: 2,
        hasBadge: true,
        levelRecords: {
          for (var level = 1; level <= 5; level++)
            level: MemoryLevelRecord(bestStars: 3, achievedAt: DateTime(2026, 10, level)),
        },
        lastPlayedAt: lastPlayedAt,
      );

  MemoryProgress startAndRead(ParentalSettings settings, MemoryProgress saved) {
    when(() => repository.readMemoryProgress()).thenAnswer((_) async => saved);
    when(() => repository.readParentalSettings()).thenAnswer((_) async => settings);
    late MemoryProgress written;
    fakeAsync((async) {
      final cubit =
          MemoryLadderCubit(repository: repository, random: Random(1), now: () => now, preview: Duration.zero);
      cubit.start();
      async.flushMicrotasks();
      written = verify(() => repository.saveMemoryProgress(captureAny())).captured.last as MemoryProgress;
      expect(cubit.state.goldFraction, written.goldFraction);
      cubit.close();
    });
    return written;
  }

  test('after 20 days without playing, 4 stars are lost from the oldest level and saved (criterion 12)', () {
    final MemoryProgress written =
        startAndRead(ParentalSettings.initial, fullProgress(lastPlayedAt: now.subtract(const Duration(days: 20))));

    expect(written.stars, 11);
    expect(written.levelRecords[1]!.bestStars, 0);
    expect(written.levelRecords[2]!.bestStars, 2);
    expect(written.hasBadge, isTrue);
    expect(written.lastPlayedAt, now);
  });

  test('keeping the stars loses nothing, even after 30 days (HU-016 criterion 1)', () {
    final MemoryProgress written = startAndRead(
      ParentalSettings(keepStars: true),
      fullProgress(lastPlayedAt: now.subtract(const Duration(days: 30))),
    );

    expect(written.stars, 15);
    expect(written.lastPlayedAt, now);
  });

  test('turning the loss back on restarts the 7-day grace (HU-016 criterion 2)', () {
    final MemoryProgress written = startAndRead(
      ParentalSettings(starDecayResumedAt: now.subtract(const Duration(days: 6))),
      fullProgress(lastPlayedAt: now.subtract(const Duration(days: 40))),
    );

    expect(written.stars, 15);
  });

  test('a child who never played loses nothing', () {
    final MemoryProgress written = startAndRead(ParentalSettings.initial, MemoryProgress.initial);

    expect(written.stars, 0);
    expect(written.lastPlayedAt, now);
  });

  test('unreadable settings apply the default loss', () {
    when(() => repository.readMemoryProgress())
        .thenAnswer((_) async => fullProgress(lastPlayedAt: now.subtract(const Duration(days: 10))));
    when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
    fakeAsync((async) {
      final cubit =
          MemoryLadderCubit(repository: repository, random: Random(1), now: () => now, preview: Duration.zero);
      cubit.start();
      async.flushMicrotasks();
      final saved = verify(() => repository.saveMemoryProgress(captureAny())).captured.last as MemoryProgress;
      expect(saved.stars, 14);
      cubit.close();
    });
  });

  test('an unreadable progress is never overwritten', () {
    when(() => repository.readMemoryProgress()).thenThrow(StateError('disk'));
    fakeAsync((async) {
      final cubit =
          MemoryLadderCubit(repository: repository, random: Random(1), now: () => now, preview: Duration.zero);
      cubit.start();
      async.flushMicrotasks();
      verifyNever(() => repository.saveMemoryProgress(any()));
      cubit.close();
    });
  });
}
