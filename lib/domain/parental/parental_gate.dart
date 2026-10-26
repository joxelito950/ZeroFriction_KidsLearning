/// Control para adultos de la Zona de Padres (HU-004, D-029): una multiplicación
/// con factores del 3 al 9, escrita con palabras por la presentación, que se
/// responde con un teclado propio cuyas cifras se barajan en cada desafío.
library;

import 'dart:math';

/// Un desafío en curso: la pregunta, el orden del teclado y los intentos que
/// quedan en esta entrada, contando el actual.
final class ParentalGateChallenge {
  ParentalGateChallenge({
    required this.firstFactor,
    required this.secondFactor,
    required List<int> keypad,
    required this.attemptsLeft,
  }) : keypad = List<int>.unmodifiable(keypad);

  final int firstFactor;
  final int secondFactor;

  /// Las cifras del 0 al 9 en el orden en que se muestran (R3).
  final List<int> keypad;

  final int attemptsLeft;

  int get answer => firstFactor * secondFactor;

  bool isCorrect(int? value) => value == answer;
}

/// Resultado de responder un desafío.
enum ParentalGateResult {
  /// Respuesta correcta: se entra en la Zona de Padres.
  passed,

  /// Respuesta incorrecta y quedan intentos: el mensaje ofrece «Reintentar» (R4).
  wrong,

  /// Respuesta incorrecta en el último intento: el mensaje ya no ofrece
  /// «Reintentar» y se vuelve al menú (S1).
  exhausted,
}

final class ParentalGate {
  ParentalGate({Random? random}) : _random = random ?? Random();

  static const int minFactor = 3;
  static const int maxFactor = 9;

  /// Intentos por entrada (S1).
  static const int attemptsPerEntry = 3;

  /// Cifras máximas de la respuesta: el mayor producto es 81.
  static const int maxAnswerDigits = 2;

  static const List<int> _digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  final Random _random;

  /// Primer desafío de una entrada nueva.
  ParentalGateChallenge start() => _next(attemptsLeft: attemptsPerEntry);

  /// Evalúa [value] (`null` si no se escribió nada) contra [challenge].
  ParentalGateResult check(ParentalGateChallenge challenge, int? value) {
    if (challenge.isCorrect(value)) return ParentalGateResult.passed;
    return challenge.attemptsLeft > 1 ? ParentalGateResult.wrong : ParentalGateResult.exhausted;
  }

  /// Desafío nuevo tras un fallo (S2): otra pregunta y otro orden del teclado,
  /// con un intento menos.
  ParentalGateChallenge retry(ParentalGateChallenge failed) {
    if (failed.attemptsLeft <= 1) {
      throw StateError('No attempts left in this entry');
    }
    return _next(attemptsLeft: failed.attemptsLeft - 1, previous: failed);
  }

  ParentalGateChallenge _next({required int attemptsLeft, ParentalGateChallenge? previous}) {
    int first;
    int second;
    do {
      first = _factor();
      second = _factor();
    } while (previous != null && first == previous.firstFactor && second == previous.secondFactor);

    List<int> keypad;
    do {
      keypad = List<int>.of(_digits)..shuffle(_random);
    } while (previous != null && _sameOrder(keypad, previous.keypad));

    return ParentalGateChallenge(
      firstFactor: first,
      secondFactor: second,
      keypad: keypad,
      attemptsLeft: attemptsLeft,
    );
  }

  int _factor() => minFactor + _random.nextInt(maxFactor - minFactor + 1);

  static bool _sameOrder(List<int> a, List<int> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
