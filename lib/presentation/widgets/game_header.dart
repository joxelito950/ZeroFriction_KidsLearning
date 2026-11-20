import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

/// Cabecera común de los juegos (HU-039 R9): icono, título e instrucciones
/// arriba; debajo, la ronda con los puntos de nivel y el contador de
/// movimientos. Los cuatro juegos la enseñan igual.
class GameHeader extends StatelessWidget {
  const GameHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.instructions,
    required this.levelIndicator,
    required this.moves,
    this.instructionsMaxLines,
  });

  /// Icono del juego (HU-013), sin dorado: el dorado se ve en el menú (HU-002 R16).
  final Widget icon;
  final String title;
  final String instructions;

  /// Ronda y puntos de nivel (HU-034, sección 10).
  final Widget levelIndicator;

  /// Movimientos del tablero en juego.
  final int moves;

  /// Líneas de las instrucciones antes de cortarlas; `null`, sin límite.
  final int? instructionsMaxLines;

  @override
  Widget build(BuildContext context) {
    final int? maxLines = instructionsMaxLines;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        // El contador va en la fila de los puntos de nivel: junto al título le
        // quitaba el ancho y, con el texto ampliado, el título se partía letra
        // a letra (TD-007).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                icon,
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(
                        instructions,
                        maxLines: maxLines,
                        overflow: maxLines == null ? null : TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                levelIndicator,
                const SizedBox(width: 12),
                // Se encoge antes que desbordarse con textos largos (árabe).
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FittedBox(fit: BoxFit.scaleDown, child: GameMovesCounter(moves: moves)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// «Movimientos: N» (HU-039 R9): solo se enseña; el lector de pantalla lo lee
/// tal cual, como en Memoria.
class GameMovesCounter extends StatelessWidget {
  const GameMovesCounter({super.key, required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const ValueKey<String>('game-moves-counter'),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: AppPalette.deepTeal, borderRadius: BorderRadius.circular(20)),
      child: Text(
        l10n.memoryGameMovesCounter(moves),
        style: const TextStyle(color: AppPalette.white, fontSize: 14, fontWeight: FontWeight.w800),
      ),
    );
  }
}
