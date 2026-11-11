import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';

/// Récord por nivel común a todos los juegos y disposición de Sombras.
void main() {
  final DateTime day = DateTime(2026, 11, 9, 10);

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
      expect(LevelRecord.loseOldest(records, 99).values.every((record) => record.bestStars == 0), isTrue);
      expect(() => LevelRecord.loseOldest(records, -1), throwsRangeError);
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
