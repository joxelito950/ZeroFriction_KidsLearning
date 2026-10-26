import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Mensaje tras una respuesta incorrecta (HU-004 R4, R5, S1, S3): los intentos
/// que quedan, «Reintentar» (si quedan), una «X» y «Volver al menú», y una barra
/// sin números que se vacía en [timeout]. Sin rojo ni sonidos.
class ParentalGateMessage extends StatelessWidget {
  const ParentalGateMessage({
    super.key,
    required this.attemptsLeft,
    required this.timeout,
    required this.onRetry,
    required this.onBackToMenu,
  });

  /// Intentos que quedan; con 0 no se ofrece «Reintentar».
  final int attemptsLeft;
  final Duration timeout;
  final VoidCallback onRetry;
  final VoidCallback onBackToMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final bool canRetry = attemptsLeft > 0;

    return ColoredBox(
      color: Colors.black26,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                key: const ValueKey<String>('parental-gate-message'),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 8, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: IconButton(
                          key: const ValueKey<String>('parental-gate-close'),
                          onPressed: onBackToMenu,
                          tooltip: l10n.parentalGateClose,
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(end: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              l10n.parentalGateWrongAnswer,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              canRetry ? l10n.parentalGateAttemptsLeft(attemptsLeft) : l10n.parentalGateNoAttemptsLeft,
                              style: theme.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 16),
                            _CountdownBar(timeout: timeout, label: l10n.parentalGateCountdownSemantics),
                            const SizedBox(height: 16),
                            Wrap(
                              alignment: WrapAlignment.end,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                TextButton(
                                  key: const ValueKey<String>('parental-gate-back-to-menu'),
                                  onPressed: onBackToMenu,
                                  child: Text(l10n.parentalGateBackToMenu),
                                ),
                                if (canRetry)
                                  FilledButton(
                                    key: const ValueKey<String>('parental-gate-retry'),
                                    onPressed: onRetry,
                                    child: Text(l10n.parentalGateRetry),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Barra que se vacía de forma continua, como la del juego (D-021).
class _CountdownBar extends StatelessWidget {
  const _CountdownBar({required this.timeout, required this.label});

  final Duration timeout;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 1, end: 0),
        duration: timeout,
        builder: (context, value, _) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            color: const Color(0xFF38BDF8),
            backgroundColor: const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }
}
