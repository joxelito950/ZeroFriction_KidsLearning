import 'dart:math';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/parental_gate.dart';
import 'package:toddler_logic/presentation/blocs/parental_gate/parental_gate_cubit.dart';
import 'package:toddler_logic/presentation/blocs/parental_gate/parental_gate_state.dart';

ParentalGateCubit _startedCubit() => ParentalGateCubit(gate: ParentalGate(random: Random(1)))..start();

void _type(ParentalGateCubit cubit, int value) {
  for (final char in '$value'.split('')) {
    cubit.typeDigit(int.parse(char));
  }
}

void _answerWrong(ParentalGateCubit cubit) {
  _type(cubit, cubit.state.challenge!.answer + 1);
  cubit.submit();
}

void main() {
  group('ParentalGateCubit (HU-004)', () {
    test('starts loading and then asks a question with 3 attempts', () {
      final cubit = ParentalGateCubit();
      expect(cubit.state.phase, ParentalGatePhase.loading);

      cubit.start();
      expect(cubit.state.phase, ParentalGatePhase.asking);
      expect(cubit.state.challenge!.attemptsLeft, 3);
      expect(cubit.state.input, isEmpty);
      cubit.close();
    });

    test('types up to two digits and deletes the last one', () {
      final cubit = _startedCubit();
      cubit.typeDigit(4);
      cubit.typeDigit(2);
      cubit.typeDigit(7);
      expect(cubit.state.input, '42');

      cubit.deleteDigit();
      expect(cubit.state.input, '4');
      cubit.deleteDigit();
      cubit.deleteDigit();
      expect(cubit.state.input, isEmpty);
      cubit.close();
    });

    test('cannot submit without an answer', () {
      final cubit = _startedCubit();
      expect(cubit.state.canSubmit, isFalse);
      cubit.submit();
      expect(cubit.state.phase, ParentalGatePhase.asking);
      cubit.close();
    });

    test('the right answer passes (criterio 2)', () {
      final cubit = _startedCubit();
      _type(cubit, cubit.state.challenge!.answer);
      cubit.submit();
      expect(cubit.state.phase, ParentalGatePhase.passed);
      cubit.close();
    });

    test('a wrong answer shows the message with the attempts left (criterio 3)', () {
      final cubit = _startedCubit();
      _answerWrong(cubit);
      expect(cubit.state.phase, ParentalGatePhase.wrong);
      expect(cubit.state.attemptsLeftAfterFailure, 2);
      cubit.close();
    });

    test('ignores the keypad while the message is shown', () {
      final cubit = _startedCubit();
      _answerWrong(cubit);
      final String input = cubit.state.input;
      cubit.typeDigit(1);
      cubit.deleteDigit();
      cubit.submit();
      expect(cubit.state.input, input);
      expect(cubit.state.phase, ParentalGatePhase.wrong);
      cubit.close();
    });

    test('goes back to the menu after 5 seconds without choosing (criterio 4, R5)', () {
      fakeAsync((async) {
        final cubit = _startedCubit();
        _answerWrong(cubit);

        async.elapse(ParentalGateCubit.messageTimeout - const Duration(milliseconds: 1));
        expect(cubit.state.phase, ParentalGatePhase.wrong);
        async.elapse(const Duration(milliseconds: 1));
        expect(cubit.state.phase, ParentalGatePhase.timedOut);
        cubit.close();
      });
    });

    test('retry gives a new question with a new keypad and stops the countdown (S2)', () {
      fakeAsync((async) {
        final cubit = _startedCubit();
        final ParentalGateChallenge first = cubit.state.challenge!;
        _answerWrong(cubit);

        cubit.retry();
        final ParentalGateChallenge second = cubit.state.challenge!;
        expect(cubit.state.phase, ParentalGatePhase.asking);
        expect(cubit.state.input, isEmpty);
        expect(second.attemptsLeft, 2);
        expect(second.keypad, isNot(orderedEquals(first.keypad)));

        async.elapse(ParentalGateCubit.messageTimeout * 2);
        expect(cubit.state.phase, ParentalGatePhase.asking);
        cubit.close();
      });
    });

    test('the third wrong answer exhausts the entry, without retry (S1, criterio 11)', () {
      fakeAsync((async) {
        final cubit = _startedCubit();
        _answerWrong(cubit);
        cubit.retry();
        _answerWrong(cubit);
        cubit.retry();
        _answerWrong(cubit);

        expect(cubit.state.phase, ParentalGatePhase.exhausted);
        expect(cubit.state.attemptsLeftAfterFailure, 0);
        cubit.retry();
        expect(cubit.state.phase, ParentalGatePhase.exhausted);

        async.elapse(ParentalGateCubit.messageTimeout);
        expect(cubit.state.phase, ParentalGatePhase.timedOut);
        cubit.close();
      });
    });

    test('closing the cubit cancels the countdown', () {
      fakeAsync((async) {
        final cubit = _startedCubit();
        _answerWrong(cubit);
        cubit.close();

        async.elapse(ParentalGateCubit.messageTimeout);
        expect(async.pendingTimers, isEmpty);
      });
    });
  });

  group('ParentalGateState', () {
    test('compares by value and copies fields', () {
      final challenge = ParentalGate(random: Random(2)).start();
      final state = ParentalGateState(phase: ParentalGatePhase.asking, challenge: challenge, input: '1');

      expect(state, ParentalGateState(phase: ParentalGatePhase.asking, challenge: challenge, input: '1'));
      expect(state.hashCode, state.copyWith().hashCode);
      expect(state.copyWith(input: '12').input, '12');
      expect(state.copyWith(phase: ParentalGatePhase.wrong).challenge, same(challenge));
      expect(state, isNot(state.copyWith(input: '')));
    });

    test('without a challenge there is nothing to submit', () {
      const state = ParentalGateState();
      expect(state.canSubmit, isFalse);
      expect(state.attemptsLeftAfterFailure, 0);
    });
  });
}
