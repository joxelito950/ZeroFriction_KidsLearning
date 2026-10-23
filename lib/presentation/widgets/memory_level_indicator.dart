import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Indicador de nivel (HU-001, S4): un punto por nivel; los alcanzados, rellenos.
/// Muestra el alcance del juego y el avance logrado.
class MemoryLevelIndicator extends StatelessWidget {
  const MemoryLevelIndicator({super.key, required this.level, required this.total});

  final int level;
  final int total;

  static const Color _reached = Color(0xFFFB923C);
  static const Color _pending = Color(0x33FB923C);

  // Sufijos de las claves de test de cada punto.
  static const String _reachedKey = 'reached';
  static const String _pendingKey = 'pending';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).memoryLevelIndicator(level, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var dot = 1; dot <= total; dot++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: Container(
                key: ValueKey<String>('memory-level-dot-$dot-${dot <= level ? _reachedKey : _pendingKey}'),
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dot <= level ? _reached : _pending,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
