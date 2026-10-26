import '../../../domain/parental/parental_gate.dart';

/// En qué punto está el desafío.
enum ParentalGatePhase {
  /// Preparando el primer desafío.
  loading,

  /// Se muestra la pregunta y se escribe la respuesta.
  asking,

  /// Respuesta incorrecta: mensaje con «Reintentar» (R4).
  wrong,

  /// Respuesta incorrecta en el último intento: mensaje sin «Reintentar» (S1).
  exhausted,

  /// Respuesta correcta: se entra en la Zona de Padres.
  passed,

  /// Pasaron 5 s con el mensaje sin elegir nada: se vuelve al menú (R5).
  timedOut,
}

final class ParentalGateState {
  const ParentalGateState({
    this.phase = ParentalGatePhase.loading,
    this.challenge,
    this.input = '',
  });

  final ParentalGatePhase phase;
  final ParentalGateChallenge? challenge;

  /// Cifras escritas, como texto (como mucho [ParentalGate.maxAnswerDigits]).
  final String input;

  /// Intentos que quedan después del fallo que se está mostrando.
  int get attemptsLeftAfterFailure => (challenge?.attemptsLeft ?? 1) - 1;

  bool get canSubmit => phase == ParentalGatePhase.asking && input.isNotEmpty;

  ParentalGateState copyWith({
    ParentalGatePhase? phase,
    ParentalGateChallenge? challenge,
    String? input,
  }) {
    return ParentalGateState(
      phase: phase ?? this.phase,
      challenge: challenge ?? this.challenge,
      input: input ?? this.input,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ParentalGateState &&
      other.phase == phase &&
      identical(other.challenge, challenge) &&
      other.input == input;

  @override
  int get hashCode => Object.hash(phase, challenge, input);
}
