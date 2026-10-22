import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';

final _monday = DateTime.utc(2026, 10, 19, 10);
final _tuesday = DateTime.utc(2026, 10, 20, 10);
final _wednesday = DateTime.utc(2026, 10, 21, 10);

void main() {
  group('MemoryProgress (HU-001, R12)', () {
    test('a child who never played starts at level 1 without badge or records', () {
      const progress = MemoryProgress.initial;

      expect(progress.currentLevel, 1);
      expect(progress.hasBadge, isFalse);
      expect(progress.levelRecords, isEmpty);
      expect(progress.lastPlayedAt, isNull);
    });

    test('a win moves to the next level and stores the result with its date', () {
      final step = MemoryLadder.afterWin(MemoryLadder.start);

      final progress = MemoryProgress.initial.recordWin(level: 1, stars: 2, step: step, at: _monday);

      expect(progress.currentLevel, 2);
      expect(progress.levelRecords[1], MemoryLevelRecord(bestStars: 2, achievedAt: _monday));
      expect(progress.lastPlayedAt, _monday);
    });

    test('a better result replaces the record; an equal one renews its date (criterion 21)', () {
      final step = MemoryLadder.afterWin(MemoryLadder.start);
      var progress = MemoryProgress.initial.recordWin(level: 1, stars: 1, step: step, at: _monday);

      progress = progress.recordWin(level: 1, stars: 3, step: step, at: _tuesday);
      expect(progress.levelRecords[1], MemoryLevelRecord(bestStars: 3, achievedAt: _tuesday));

      progress = progress.recordWin(level: 1, stars: 3, step: step, at: _wednesday);
      expect(progress.levelRecords[1], MemoryLevelRecord(bestStars: 3, achievedAt: _wednesday));
    });

    test('a worse result keeps the best record but still counts as played', () {
      final step = MemoryLadder.afterWin(MemoryLadder.start);
      final best = MemoryProgress.initial.recordWin(level: 1, stars: 3, step: step, at: _monday);

      final progress = best.recordWin(level: 1, stars: 1, step: step, at: _tuesday);

      expect(progress.levelRecords[1], MemoryLevelRecord(bestStars: 3, achievedAt: _monday));
      expect(progress.lastPlayedAt, _tuesday);
    });

    test('a loss moves to the level of the ladder step and updates the last play date', () {
      const position = MemoryLadderPosition(level: 3, timeLimit: Duration(seconds: 45));
      final progress = MemoryProgress(currentLevel: 3)
          .recordLoss(step: MemoryLadder.afterLoss(position), at: _tuesday);

      expect(progress.currentLevel, 2);
      expect(progress.lastPlayedAt, _tuesday);
      expect(progress.levelRecords, isEmpty);
    });

    test('winning the last level earns the badge, which is never lost (R8)', () {
      final win = MemoryLadder.afterWin(MemoryLadder.arrivalPosition(5));
      var progress = MemoryProgress(currentLevel: 5).recordWin(level: 5, stars: 2, step: win, at: _monday);

      expect(progress.hasBadge, isTrue);
      expect(progress.currentLevel, 1);

      const timedLevelOne = MemoryLadderPosition(level: 1, timeLimit: Duration(seconds: 30));
      progress = progress.recordLoss(step: MemoryLadder.afterLoss(timedLevelOne), at: _tuesday);
      expect(progress.hasBadge, isTrue);
    });

    test('rejects invalid levels and stars', () {
      final step = MemoryLadder.afterWin(MemoryLadder.start);

      expect(() => MemoryProgress(currentLevel: 0), throwsRangeError);
      expect(() => MemoryProgress(currentLevel: 6), throwsRangeError);
      expect(() => MemoryProgress.initial.recordWin(level: 1, stars: 4, step: step, at: _monday), throwsRangeError);
      expect(() => MemoryProgress.initial.recordWin(level: 9, stars: 1, step: step, at: _monday), throwsRangeError);
      expect(() => MemoryLevelRecord(bestStars: -1, achievedAt: _monday), throwsRangeError);
    });

    test('compares by value', () {
      MemoryProgress build() => MemoryProgress(
            currentLevel: 2,
            hasBadge: true,
            levelRecords: {1: MemoryLevelRecord(bestStars: 3, achievedAt: _monday)},
            lastPlayedAt: _monday,
          );

      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(build(), isNot(MemoryProgress.initial));
      expect(MemoryLevelRecord(bestStars: 3, achievedAt: _monday).hashCode,
          MemoryLevelRecord(bestStars: 3, achievedAt: _monday).hashCode);
    });

    test('the records cannot be modified from outside', () {
      final progress = MemoryProgress(
        currentLevel: 1,
        levelRecords: {1: MemoryLevelRecord(bestStars: 1, achievedAt: _monday)},
      );

      expect(() => progress.levelRecords[2] = MemoryLevelRecord(bestStars: 1, achievedAt: _monday),
          throwsUnsupportedError);
    });
  });
}
