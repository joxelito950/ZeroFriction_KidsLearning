import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/parental_gate.dart';

/// Devuelve siempre la misma secuencia de [nextInt], para forzar repeticiones.
class _ScriptedRandom implements Random {
  _ScriptedRandom(this._values);

  final List<int> _values;
  var _index = 0;

  @override
  int nextInt(int max) => _values[_index++ % _values.length] % max;

  @override
  bool nextBool() => throw UnimplementedError();

  @override
  double nextDouble() => throw UnimplementedError();
}

ParentalGateChallenge _challenge({int first = 7, int second = 3, int attemptsLeft = 3}) =>
    ParentalGateChallenge(
      firstFactor: first,
      secondFactor: second,
      keypad: const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      attemptsLeft: attemptsLeft,
    );

void main() {
  group('ParentalGate questions (HU-004 R2)', () {
    test('factors are always between 3 and 9 and every pair can appear', () {
      final gate = ParentalGate(random: Random(1));
      final seen = <(int, int)>{};
      for (var i = 0; i < 2000; i++) {
        final challenge = gate.start();
        expect(challenge.firstFactor, inInclusiveRange(3, 9));
        expect(challenge.secondFactor, inInclusiveRange(3, 9));
        seen.add((challenge.firstFactor, challenge.secondFactor));
      }
      expect(seen, hasLength(49));
    });

    test('answers go from 9 to 81 and fit in two digits', () {
      expect(ParentalGate.minFactor * ParentalGate.minFactor, 9);
      expect(ParentalGate.maxFactor * ParentalGate.maxFactor, 81);
      expect('${ParentalGate.maxFactor * ParentalGate.maxFactor}'.length, ParentalGate.maxAnswerDigits);
    });

    test('the answer is the product of both factors', () {
      expect(_challenge(first: 7, second: 3).answer, 21);
    });
  });

  group('ParentalGate keypad (R3)', () {
    test('contains each digit from 0 to 9 exactly once', () {
      final gate = ParentalGate(random: Random(2));
      for (var i = 0; i < 100; i++) {
        final keypad = gate.start().keypad;
        expect(keypad, hasLength(10));
        expect(keypad.toSet(), {0, 1, 2, 3, 4, 5, 6, 7, 8, 9});
      }
    });

    test('is shuffled: not always in natural order', () {
      final gate = ParentalGate(random: Random(3));
      final orders = {for (var i = 0; i < 20; i++) gate.start().keypad.join()};
      expect(orders.length, greaterThan(1));
      expect(orders, isNot(contains('0123456789')));
    });

    test('cannot be modified from outside', () {
      expect(() => ParentalGate(random: Random(4)).start().keypad[0] = 5, throwsUnsupportedError);
    });
  });

  group('ParentalGate answers (R4, S1)', () {
    final gate = ParentalGate(random: Random(5));

    test('the right answer passes, in any attempt', () {
      for (final attempts in [3, 2, 1]) {
        expect(gate.check(_challenge(attemptsLeft: attempts), 21), ParentalGateResult.passed);
      }
    });

    test('a wrong or empty answer leaves attempts while there are more than one', () {
      expect(gate.check(_challenge(attemptsLeft: 3), 12), ParentalGateResult.wrong);
      expect(gate.check(_challenge(attemptsLeft: 2), null), ParentalGateResult.wrong);
    });

    test('a wrong answer in the last attempt exhausts the entry', () {
      expect(gate.check(_challenge(attemptsLeft: 1), 12), ParentalGateResult.exhausted);
    });

    test('a new entry always starts with 3 attempts', () {
      expect(gate.start().attemptsLeft, ParentalGate.attemptsPerEntry);
      expect(ParentalGate.attemptsPerEntry, 3);
    });
  });

  group('ParentalGate retry (S2, criterio 10)', () {
    test('gives a new question and keypad order, with one attempt less', () {
      final gate = ParentalGate(random: Random(6));
      var challenge = gate.start();
      for (final expectedAttempts in [2, 1]) {
        final next = gate.retry(challenge);
        expect(next.attemptsLeft, expectedAttempts);
        expect(
          (next.firstFactor, next.secondFactor),
          isNot((challenge.firstFactor, challenge.secondFactor)),
        );
        expect(next.keypad, isNot(orderedEquals(challenge.keypad)));
        challenge = next;
      }
    });

    test('draws again when the random repeats the same question and keypad', () {
      // Con nextInt siempre a 0 sale 3 × 3 y un barajado fijo (9 llamadas).
      final first = ParentalGate(random: _ScriptedRandom([0])).start();
      final repeating = ParentalGate(
        random: _ScriptedRandom([
          // Pregunta repetida (3 × 3) y luego otra (4 × 3).
          0, 0, 1, 0,
          // Teclado igual al anterior (9 ceros) y luego otro distinto.
          0, 0, 0, 0, 0, 0, 0, 0, 0,
          1, 0, 0, 0, 0, 0, 0, 0, 0,
        ]),
      );
      final next = repeating.retry(first);
      expect((next.firstFactor, next.secondFactor), (4, 3));
      expect(next.keypad, isNot(orderedEquals(first.keypad)));
    });

    test('is not allowed once the entry is exhausted', () {
      expect(() => ParentalGate().retry(_challenge(attemptsLeft: 1)), throwsStateError);
    });
  });

  test('random answers of 1 or 2 digits pass about 1 % of the time (criterio 7)', () {
    final gate = ParentalGate(random: Random(7));
    final child = Random(8);
    const tries = 10000;
    var passed = 0;
    for (var i = 0; i < tries; i++) {
      // Un niño que toca al azar: una o dos cifras cualesquiera.
      final int value = child.nextBool() ? child.nextInt(10) : child.nextInt(100);
      if (gate.check(gate.start(), value) == ParentalGateResult.passed) passed++;
    }
    expect(passed / tries, lessThan(0.02));
  });
}
