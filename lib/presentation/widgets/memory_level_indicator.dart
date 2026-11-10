import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

/// Indicador de nivel (HU-001, S4): un punto por nivel; los alcanzados, rellenos.
/// Muestra el alcance del juego y el avance logrado. Sombras lo usa también,
/// con su último nivel bloqueado sin Premium (HU-007 R11).
class MemoryLevelIndicator extends StatelessWidget {
  const MemoryLevelIndicator({super.key, required this.level, required this.total, this.lockedLevel});

  final int level;
  final int total;

  /// Nivel que se ve con un candado sutil en vez de un punto; no se puede tocar
  /// ni invita a comprar nada (R11).
  final int? lockedLevel;

  static const Color _reached = AppPalette.gold;
  static final Color _pending = AppPalette.gold.withValues(alpha: 0.2);

  // Sufijos de las claves de test de cada punto.
  static const String _reachedKey = 'reached';
  static const String _pendingKey = 'pending';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int? locked = lockedLevel;
    return Semantics(
      label: [
        l10n.memoryLevelIndicator(level, total),
        if (locked != null) l10n.levelLockedSemantics(locked),
      ].join('. '),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var dot = 1; dot <= total; dot++)
            if (dot == locked)
              Icon(
                Icons.lock_rounded,
                key: ValueKey<String>('memory-level-dot-$dot-locked'),
                size: 12,
                color: AppPalette.deepTeal.withValues(alpha: 0.35),
              )
            else
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
