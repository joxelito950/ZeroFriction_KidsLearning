import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/shadow_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/star_decay.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';

/// HU-007 entrega 2: progreso de Sombras (R14) y lo común a todos los juegos.
void main() {
  final DateTime day = DateTime(2026, 11, 9, 10);
  const premium = ShadowRules(premium: true);

  group('ShadowProgress', () {
    test('starts at level 1 with nothing, and rejects levels outside the ladder', () {
      expect(ShadowProgress.initial.currentLevel, 1);
      expect(ShadowProgress.initial.stars, 0);
      expect(ShadowProgress.initial.goldFraction, 0);
      expect(() => ShadowProgress(currentLevel: 9), throwsRangeError);
      expect(
        () => ShadowProgress(currentLevel: 1, levelRecords: {9: LevelRecord(bestStars: 1, achievedAt: day)}),
        throwsRangeError,
      );
    });

    test('a win moves up and keeps the best result with its date', () {
      final ShadowProgress first = ShadowProgress.initial
          .recordWin(level: 1, stars: 2, step: ShadowLadder.afterWin(ShadowLadder.start, premium), at: day);
      expect(first.currentLevel, 2);
      expect(first.lastPlayedAt, day);
      expect(first.levelRecords[1], LevelRecord(bestStars: 2, achievedAt: day));

      final DateTime later = day.add(const Duration(days: 1));
      final ShadowProgress worse = first.recordWin(
          level: 1, stars: 1, step: ShadowLadder.afterWin(ShadowLadder.start, premium), at: later);
      expect(worse.levelRecords[1], LevelRecord(bestStars: 2, achievedAt: day));
      expect(worse.lastPlayedAt, later);
    });

    test('level 8 with Premium gives the permanent medal and goes back to level 1', () {
      final ShadowProgress won = ShadowProgress(currentLevel: 8).recordWin(
          level: 8, stars: 3, step: ShadowLadder.afterWin(const ShadowPosition(level: 8), premium), at: day);
      expect(won.hasMedal, isTrue);
      expect(won.currentLevel, 1);
      expect(won.loseStars(3).hasMedal, isTrue);
    });

    test('a loss only changes the level and the play date', () {
      final ShadowProgress before =
          ShadowProgress(currentLevel: 5, levelRecords: {4: LevelRecord(bestStars: 3, achievedAt: day)});
      final ShadowProgress after = before.recordLoss(
          step: ShadowLadder.afterLoss(const ShadowPosition(level: 5, timeLimit: Duration(seconds: 40))), at: day);
      expect(after.currentLevel, 4);
      expect(after.levelRecords, before.levelRecords);
      expect(after.lastPlayedAt, day);
    });

    test('gold: 24 stars in all; without Premium it stops at 14 (section 3)', () {
      expect(ShadowProgress.maxStars, 24);
      final ShadowProgress free = ShadowProgress(currentLevel: 1, levelRecords: {
        for (var level = 1; level <= 7; level++) level: LevelRecord(bestStars: 2, achievedAt: day),
      });
      expect(free.stars, 14);
      expect(free.goldFraction, closeTo(14 / 24, 1e-9));
    });

    test('equality looks at every field', () {
      ShadowProgress build({bool medal = false}) => ShadowProgress(
            currentLevel: 3,
            hasMedal: medal,
            levelRecords: {1: LevelRecord(bestStars: 1, achievedAt: day)},
            lastPlayedAt: day,
          );
      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(build(), isNot(build(medal: true)));
      expect(build(), isNot(ShadowProgress.initial));
    });
  });

  group('LevelRecord (common to every game)', () {
    test('accepts 0 to 3 stars', () {
      expect(() => LevelRecord(bestStars: 4, achievedAt: day), throwsRangeError);
      expect(() => LevelRecord(bestStars: -1, achievedAt: day), throwsRangeError);
    });

    test('loses from the oldest achievement first, and never below zero', () {
      final records = {
        1: LevelRecord(bestStars: 2, achievedAt: day),
        2: LevelRecord(bestStars: 3, achievedAt: day.subtract(const Duration(days: 1))),
      };
      final Map<int, LevelRecord> after = LevelRecord.loseOldest(records, 4);
      expect(after[2]!.bestStars, 0);
      expect(after[1]!.bestStars, 1);
      expect(LevelRecord.totalStars(LevelRecord.loseOldest(records, 99)), 0);
      expect(() => LevelRecord.loseOldest(records, -1), throwsRangeError);
    });
  });

  group('StarDecay.settle', () {
    final DateTime now = DateTime(2026, 11, 30, 10);
    final ShadowProgress full = ShadowProgress(
      currentLevel: 1,
      levelRecords: {for (var level = 1; level <= 8; level++) level: LevelRecord(bestStars: 3, achievedAt: day)},
      lastPlayedAt: now.subtract(const Duration(days: 20)),
    );

    test('applies the loss and marks the game as played now', () {
      final ShadowProgress settled = StarDecay.settle(full, settings: ParentalSettings.initial, now: now);
      expect(settled.stars, 24 - 4);
      expect(settled.lastPlayedAt, now);
    });

    test('keeps everything with «Keep the stars», and with no previous game', () {
      expect(StarDecay.settle(full, settings: ParentalSettings(keepStars: true), now: now).stars, 24);
      expect(StarDecay.settle(ShadowProgress.initial, settings: ParentalSettings.initial, now: now).lastPlayedAt, now);
    });
  });

  group('layout (P13, P14)', () {
    test('Easy and Normal always put the shadows first; Impossible picks both at random', () {
      for (var seed = 0; seed < 10; seed++) {
        expect(const ShadowRules(difficulty: GameDifficulty.easy).layoutFor(Random(seed)), ShadowLayout.shadowsFirst);
        expect(const ShadowRules().layoutFor(Random(seed)), ShadowLayout.shadowsFirst);
      }
      const impossible = ShadowRules(difficulty: GameDifficulty.impossible);
      final Random random = Random(3);
      expect({for (var i = 0; i < 30; i++) impossible.layoutFor(random)}, ShadowLayout.values.toSet());
    });
  });
}
