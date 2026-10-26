import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/parental/parental_gate.dart';
import 'parental_gate_state.dart';

/// Desafío para adultos de la Zona de Padres (HU-004, D-029): respuesta con el
/// teclado propio, mensaje de fallo y vuelta automática al menú a los 5 s.
class ParentalGateCubit extends Cubit<ParentalGateState> {
  ParentalGateCubit({ParentalGate? gate})
      : _gate = gate ?? ParentalGate(),
        super(const ParentalGateState());

  /// Tiempo del mensaje de fallo antes de volver solo al menú (R5).
  static const Duration messageTimeout = Duration(seconds: 5);

  final ParentalGate _gate;
  Timer? _messageTimer;

  void start() {
    emit(ParentalGateState(phase: ParentalGatePhase.asking, challenge: _gate.start()));
  }

  void typeDigit(int digit) {
    if (state.phase != ParentalGatePhase.asking || state.input.length >= ParentalGate.maxAnswerDigits) return;
    emit(state.copyWith(input: '${state.input}$digit'));
  }

  void deleteDigit() {
    if (state.phase != ParentalGatePhase.asking || state.input.isEmpty) return;
    emit(state.copyWith(input: state.input.substring(0, state.input.length - 1)));
  }

  void submit() {
    if (!state.canSubmit) return;
    final ParentalGateResult result = _gate.check(state.challenge!, int.parse(state.input));
    switch (result) {
      case ParentalGateResult.passed:
        emit(state.copyWith(phase: ParentalGatePhase.passed));
      case ParentalGateResult.wrong:
        _showMessage(ParentalGatePhase.wrong);
      case ParentalGateResult.exhausted:
        _showMessage(ParentalGatePhase.exhausted);
    }
  }

  /// Pregunta nueva, con el teclado barajado de nuevo (S2).
  void retry() {
    if (state.phase != ParentalGatePhase.wrong) return;
    _messageTimer?.cancel();
    emit(ParentalGateState(phase: ParentalGatePhase.asking, challenge: _gate.retry(state.challenge!)));
  }

  void _showMessage(ParentalGatePhase phase) {
    emit(state.copyWith(phase: phase));
    _messageTimer?.cancel();
    _messageTimer = Timer(messageTimeout, () {
      if (!isClosed) emit(state.copyWith(phase: ParentalGatePhase.timedOut));
    });
  }

  @override
  Future<void> close() {
    _messageTimer?.cancel();
    return super.close();
  }
}
