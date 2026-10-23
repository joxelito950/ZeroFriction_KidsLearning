import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';

const _s90 = Duration(seconds: 90);
const _s60 = Duration(seconds: 60);
const _s45 = Duration(seconds: 45);
const _s30 = Duration(seconds: 30);

MemoryLadderPosition _at(int level, [Duration? limit]) =>
    MemoryLadderPosition(level: level, timeLimit: limit);

void main() {
  group('MemoryLadder levels (HU-001, tabla 4.1)', () {
    test('has five boards from 2x2 to 4x4', () {
      expect(MemoryLadder.levels.map((level) => level.cards), [4, 6, 8, 12, 16]);
      expect(MemoryLadder.levels.map((level) => level.number), [1, 2, 3, 4, 5]);
      expect(MemoryLadder.maxLevel, 5);
    });

    test('levelAt returns the level and rejects unknown numbers', () {
      expect(MemoryLadder.levelAt(3).pairs, 4);
      expect(() => MemoryLadder.levelAt(0), throwsRangeError);
      expect(() => MemoryLadder.levelAt(6), throwsRangeError);
    });

    test('time limits are 90, 60, 45 and 30 seconds', () {
      expect(MemoryLadder.timeLimits, [_s90, _s60, _s45, _s30]);
    });

    test('the arrival limit of each level follows the table (R12)', () {
      expect(MemoryLadder.arrivalPosition(1), _at(1));
      expect(MemoryLadder.arrivalPosition(2), _at(2, _s90));
      expect(MemoryLadder.arrivalPosition(3), _at(3, _s60));
      expect(MemoryLadder.arrivalPosition(4), _at(4, _s45));
      expect(MemoryLadder.arrivalPosition(5), _at(5, _s30));
      expect(() => MemoryLadder.arrivalPosition(6), throwsRangeError);
    });

    test('the first game starts at level 1 without time (R3)', () {
      expect(MemoryLadder.start, _at(1));
      expect(MemoryLadder.start.isTimed, isFalse);
    });
  });

  group('afterWin', () {
    test('level 1 without time goes to level 2 with 90 s (R4)', () {
      final step = MemoryLadder.afterWin(_at(1));
      expect(step.next, _at(2, _s90));
      expect(step.badgeEarned, isFalse);
      expect(step.loss, isNull);
    });

    test('a timed win goes up one level with the next limit of the series (R4)', () {
      expect(MemoryLadder.afterWin(_at(2, _s90)).next, _at(3, _s60));
      expect(MemoryLadder.afterWin(_at(3, _s60)).next, _at(4, _s45));
      expect(MemoryLadder.afterWin(_at(4, _s45)).next, _at(5, _s30));
    });

    test('the limit never goes below 30 s', () {
      expect(MemoryLadder.afterWin(_at(3, _s30)).next, _at(4, _s30));
    });

    test('a timed level 1 (after going down) also goes up', () {
      expect(MemoryLadder.afterWin(_at(1, _s45)).next, _at(2, _s30));
    });

    test('winning the last level earns the badge and restarts without time (R7, R8)', () {
      final step = MemoryLadder.afterWin(_at(5, _s30));
      expect(step.badgeEarned, isTrue);
      expect(step.next, MemoryLadder.start);
    });

    test('rejects a limit that is not part of the series', () {
      expect(() => MemoryLadder.afterWin(_at(2, const Duration(seconds: 20))), throwsArgumentError);
    });
  });

  group('afterLoss', () {
    test('goes down one level keeping the current limit (R5)', () {
      final step = MemoryLadder.afterLoss(_at(4, _s45));
      expect(step.next, _at(3, _s45));
      expect(step.loss, MemoryLoss.fewerCards);
      expect(step.badgeEarned, isFalse);
    });

    test('losing the timed level 1 restarts without time (R6)', () {
      final step = MemoryLadder.afterLoss(_at(1, _s60));
      expect(step.next, MemoryLadder.start);
      expect(step.loss, MemoryLoss.restart);
    });

    test('a level without time cannot be lost', () {
      expect(() => MemoryLadder.afterLoss(_at(1)), throwsStateError);
    });
  });

  test('reproduces the example game of HU-001 (sección 4.4)', () {
    var position = MemoryLadder.start;
    position = MemoryLadder.afterWin(position).next;
    expect(position, _at(2, _s90));
    position = MemoryLadder.afterWin(position).next;
    expect(position, _at(3, _s60));
    position = MemoryLadder.afterLoss(position).next;
    expect(position, _at(2, _s60));
    position = MemoryLadder.afterWin(position).next;
    expect(position, _at(3, _s45));
    position = MemoryLadder.afterWin(position).next;
    expect(position, _at(4, _s30));
    position = MemoryLadder.afterWin(position).next;
    expect(position, _at(5, _s30));
    final last = MemoryLadder.afterWin(position);
    expect(last.badgeEarned, isTrue);
    expect(last.next, MemoryLadder.start);
  });

  test('level 5 is always reached with 30 s, whatever happened before (R7)', () {
    final random = Random(2026);
    for (var game = 0; game < 500; game++) {
      var position = MemoryLadder.start;
      for (var round = 0; round < 40; round++) {
        final canLose = position.isTimed;
        final step = canLose && random.nextBool()
            ? MemoryLadder.afterLoss(position)
            : MemoryLadder.afterWin(position);
        position = step.next;
        if (position.level == MemoryLadder.maxLevel) {
          expect(position.timeLimit, _s30);
        }
      }
    }
  });

  test('positions compare by value', () {
    expect(_at(2, _s60), _at(2, _s60));
    expect(_at(2, _s60).hashCode, _at(2, _s60).hashCode);
    expect(_at(2, _s60), isNot(_at(2, _s45)));
    expect(_at(2, _s60).toString(), contains('level: 2'));
  });
}
