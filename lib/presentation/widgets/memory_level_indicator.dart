import 'package:flutter/material.dart';

import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'medal_badge.dart';
import 'round_style.dart';

/// Indicador de nivel (HU-001, S4): un punto por nivel; los alcanzados, rellenos.
/// Muestra el alcance del juego y el avance logrado. Sombras lo usa también,
/// con su último nivel bloqueado sin Premium (HU-007 R11).
class MemoryLevelIndicator extends StatelessWidget {
  const MemoryLevelIndicator({
    super.key,
    required this.level,
    required this.total,
    this.lockedLevel,
    this.color,
    this.rim,
    this.round,
  });

  final int level;
  final int total;

  /// Nivel que se ve con un candado sutil en vez de un punto; no se puede tocar
  /// ni invita a comprar nada (R11).
  final int? lockedLevel;

  /// Color de los puntos alcanzados: el de la ronda (HU-037 P8). Sin él, dorado.
  final Color? color;

  /// Borde de los puntos alcanzados: el de la medalla de la ronda (HU-048 P3).
  final Color? rim;

  /// La ronda en juego: se muestra encima de los puntos, con su medalla y su
  /// nombre. Los testers no sabían en qué ronda estaban hasta salir del juego
  /// o terminarla (2026-11-19).
  final GameDifficulty? round;

  static const Color _reached = AppPalette.gold;

  // Sufijos de las claves de test de cada punto.
  static const String _reachedKey = 'reached';
  static const String _pendingKey = 'pending';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final int? locked = lockedLevel;
    final GameDifficulty? round = this.round;
    final Widget dots = _dots();
    return Semantics(
      label: [
        if (round != null) l10n.gameRoundIndicator(RoundStyle.roundName(l10n, round)),
        l10n.memoryLevelIndicator(level, total),
        if (locked != null) l10n.levelLockedSemantics(locked),
      ].join('. '),
      excludeSemantics: true,
      child: round == null
          ? dots
          : Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  key: const ValueKey<String>('level-indicator-round'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MedalBadge(style: RoundStyle.medalStyleOf(round), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      l10n.gameRoundIndicator(RoundStyle.roundName(l10n, round)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppPalette.deepTeal),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                dots,
              ],
            ),
    );
  }

  Widget _dots() {
    final int? locked = lockedLevel;
    return Row(
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
                    color: dot <= level ? (color ?? _reached) : (color ?? _reached).withValues(alpha: 0.2),
                    border: dot <= level && rim != null ? Border.all(color: rim!, width: 1.5) : null,
                  ),
                ),
              ),
        ],
      );
  }
}
