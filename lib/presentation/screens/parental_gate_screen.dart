import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/parental/parental_gate.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/parental_gate/parental_gate_cubit.dart';
import '../blocs/parental_gate/parental_gate_state.dart';
import '../widgets/parental_gate_message.dart';
import '../widgets/parental_keypad.dart';
import 'parents_zone_screen.dart';

/// Desafío para adultos antes de la Zona de Padres (HU-004, D-029). El «atrás»
/// del sistema vuelve al menú directamente: es una pantalla de adultos (P5).
class ParentalGateScreen extends StatelessWidget {
  const ParentalGateScreen({super.key, this.gate});

  /// Permite inyectar el azar en los tests.
  final ParentalGate? gate;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ParentalGateCubit>(
      create: (_) => ParentalGateCubit(gate: gate)..start(),
      child: const _ParentalGateView(),
    );
  }
}

class _ParentalGateView extends StatelessWidget {
  const _ParentalGateView();

  void _onPhase(BuildContext context, ParentalGateState state) {
    final NavigatorState navigator = Navigator.of(context);
    switch (state.phase) {
      case ParentalGatePhase.passed:
        navigator.pushReplacement(MaterialPageRoute<void>(builder: (_) => const ParentsZoneScreen()));
      case ParentalGatePhase.timedOut:
        navigator.pop();
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ParentalGateCubit, ParentalGateState>(
      listenWhen: (previous, current) => previous.phase != current.phase,
      listener: _onPhase,
      builder: (context, state) {
        final ParentalGateChallenge? challenge = state.challenge;
        final cubit = context.read<ParentalGateCubit>();
        final bool showMessage =
            state.phase == ParentalGatePhase.wrong || state.phase == ParentalGatePhase.exhausted;

        return Scaffold(
          body: Stack(
            // El mensaje cubre toda la pantalla, no solo el alto del contenido.
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: challenge == null ? const SizedBox.shrink() : _GateContent(state: state, challenge: challenge),
              ),
              if (showMessage)
                Positioned.fill(
                  child: ParentalGateMessage(
                    attemptsLeft: state.attemptsLeftAfterFailure,
                    timeout: ParentalGateCubit.messageTimeout,
                    onRetry: cubit.retry,
                    onBackToMenu: () => Navigator.of(context).pop(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _GateContent extends StatelessWidget {
  const _GateContent({required this.state, required this.challenge});

  final ParentalGateState state;
  final ParentalGateChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ParentalGateCubit>();
    final keypad = ParentalKeypad(
      // La key cambia con cada desafío para que el lector de pantalla no
      // conserve el foco en una tecla que ahora tiene otra cifra.
      key: ValueKey<String>('parental-keypad-${challenge.keypad.join()}'),
      digits: challenge.keypad,
      onDigit: cubit.typeDigit,
      onDelete: cubit.deleteDigit,
      onAccept: cubit.submit,
      canAccept: state.canSubmit,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isLandscape = constraints.maxWidth > constraints.maxHeight;
        final question = _QuestionPanel(state: state, challenge: challenge);

        if (isLandscape) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              children: [
                Expanded(child: SingleChildScrollView(child: question)),
                const SizedBox(width: 32),
                Expanded(child: Center(child: keypad)),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              question,
              const SizedBox(height: 24),
              Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 360), child: keypad)),
            ],
          ),
        );
      },
    );
  }
}

/// Botón «Volver», título, pregunta en palabras y la respuesta escrita.
class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.state, required this.challenge});

  final ParentalGateState state;
  final ParentalGateChallenge challenge;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton.icon(
          key: const ValueKey<String>('parental-gate-back'),
          onPressed: () => Navigator.of(context).pop(),
          // Sin etiqueta propia: el lector de pantalla ya lee el texto (visto en el emulador).
          icon: const Icon(Icons.arrow_back),
          label: Text(l10n.parentalGateBack),
        ),
        const SizedBox(height: 8),
        Text(l10n.parentalGateTitle, style: theme.textTheme.titleMedium?.copyWith(color: Colors.blueGrey[600])),
        const SizedBox(height: 8),
        Text(
          l10n.parentalGateQuestion(
            numberInWords(l10n, challenge.firstFactor),
            numberInWords(l10n, challenge.secondFactor),
          ),
          key: const ValueKey<String>('parental-gate-question'),
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Semantics(
          label: state.input.isEmpty
              ? l10n.parentalGateAnswerEmptySemantics
              : l10n.parentalGateAnswerSemantics(state.input),
          excludeSemantics: true,
          child: Container(
            key: const ValueKey<String>('parental-gate-answer'),
            height: 56,
            width: 140,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(state.input, style: theme.textTheme.headlineMedium),
          ),
        ),
      ],
    );
  }
}

/// El factor [number] (del 3 al 9) escrito con palabras en el idioma de la app (R2).
String numberInWords(AppLocalizations l10n, int number) {
  return switch (number) {
    3 => l10n.parentalGateNumber3,
    4 => l10n.parentalGateNumber4,
    5 => l10n.parentalGateNumber5,
    6 => l10n.parentalGateNumber6,
    7 => l10n.parentalGateNumber7,
    8 => l10n.parentalGateNumber8,
    9 => l10n.parentalGateNumber9,
    _ => throw RangeError.range(number, ParentalGate.minFactor, ParentalGate.maxFactor),
  };
}
