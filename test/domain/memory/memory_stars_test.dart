import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/memory/memory_stars.dart';

void main() {
  group('MemoryStars.forWin (D-030)', () {
    // Tabla de HU-002: 3★ ≤ mínimo + nivel, 2★ ≤ 2·mínimo, 1★ ≤ 3·mínimo, si no 0.
    const thresholds = {
      // nivel: (pares, último movimiento con 3★, con 2★, con 1★)
      1: (2, 3, 4, 6),
      2: (3, 5, 6, 9),
      3: (4, 7, 8, 12),
      4: (6, 10, 12, 18),
      5: (8, 13, 16, 24),
    };

    thresholds.forEach((level, limits) {
      final (pairs, three, two, one) = limits;

      test('level $level: boundaries of every star band', () {
        expect(MemoryStars.forWin(level: level, moves: pairs), 3, reason: 'perfect game');
        expect(MemoryStars.forWin(level: level, moves: three), 3);
        expect(MemoryStars.forWin(level: level, moves: three + 1), two > three ? 2 : 1);
        expect(MemoryStars.forWin(level: level, moves: two), 2);
        expect(MemoryStars.forWin(level: level, moves: two + 1), 1);
        expect(MemoryStars.forWin(level: level, moves: one), 1);
        expect(MemoryStars.forWin(level: level, moves: one + 1), 0);
        expect(MemoryStars.forWin(level: level, moves: 500), 0);
      });
    });

    test('there is a 2-star band on every level', () {
      for (var level = 1; level <= 5; level++) {
        final hasTwoStars = List.generate(60, (moves) => moves + 1)
            .where((moves) => moves >= thresholds[level]!.$1)
            .any((moves) => MemoryStars.forWin(level: level, moves: moves) == 2);
        expect(hasTwoStars, isTrue, reason: 'level $level');
      }
    });

    test('fewer moves than pairs is impossible and rejected', () {
      expect(() => MemoryStars.forWin(level: 3, moves: 3), throwsArgumentError);
    });

    test('rejects unknown levels', () {
      expect(() => MemoryStars.forWin(level: 0, moves: 4), throwsRangeError);
      expect(() => MemoryStars.forWin(level: 6, moves: 20), throwsRangeError);
    });

    test('the maximum is 3 stars per level', () {
      expect(MemoryStars.max, 3);
    });
  });
}
