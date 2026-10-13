import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';

void main() {
  group('LevelState', () {
    test('accepts stars within the 0..3 range', () {
      for (var stars = LevelState.minStars; stars <= LevelState.maxStars; stars++) {
        expect(
          LevelState(levelId: 'level', isCompleted: false, stars: stars).stars,
          stars,
        );
      }
    });

    test('rejects stars outside the 0..3 range', () {
      expect(
        () => LevelState(levelId: 'level', isCompleted: false, stars: -1),
        throwsRangeError,
      );
      expect(
        () => LevelState(levelId: 'level', isCompleted: true, stars: 4),
        throwsRangeError,
      );
    });

    test('copyWith replaces only the provided fields', () {
      final original = LevelState(levelId: 'farm_easy', isCompleted: false, stars: 1);

      final updated = original.copyWith(isCompleted: true, stars: 3);

      expect(updated.levelId, 'farm_easy');
      expect(updated.isCompleted, isTrue);
      expect(updated.stars, 3);
      expect(original.copyWith(), original);
      expect(original.copyWith(levelId: 'wild_medium').levelId, 'wild_medium');
    });

    test('copyWith rejects invalid stars', () {
      final original = LevelState(levelId: 'farm_easy', isCompleted: false, stars: 1);

      expect(() => original.copyWith(stars: 5), throwsRangeError);
    });

    test('implements value equality and a consistent hashCode', () {
      final a = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 3);
      final b = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 3);
      final different = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 2);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(different));
    });
  });
}
