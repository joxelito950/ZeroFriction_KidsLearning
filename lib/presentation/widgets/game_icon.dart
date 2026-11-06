import 'package:flutter/material.dart';

import '../../brand/brand_assets.dart';
import 'liquid_gold.dart';

/// Icono de un juego (HU-013 entregable 5). Es decorativo: el nombre del juego ya
/// lo dice el botón o la cabecera, así que el lector de pantalla lo ignora.
///
/// [goldFraction] es el dorado de HU-002 (D-030): la silueta se llena de un
/// líquido dorado de abajo arriba, del 0 al 1. Con [animateGold], la ola se
/// mece y suben burbujas (R15); en la cabecera del juego va quieto.
class GameIcon extends StatelessWidget {
  const GameIcon({
    super.key,
    required this.asset,
    required this.size,
    this.goldFraction = 0,
    this.animateGold = false,
  }) : assert(goldFraction >= 0 && goldFraction <= 1);

  /// Icono del juego de memoria.
  const GameIcon.memory({Key? key, required double size, double goldFraction = 0, bool animateGold = false})
      : this(key: key, asset: BrandAssets.memoryIcon, size: size, goldFraction: goldFraction, animateGold: animateGold);

  final String asset;
  final double size;
  final double goldFraction;
  final bool animateGold;

  @override
  Widget build(BuildContext context) {
    final Widget image = Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      excludeFromSemantics: true,
      // Sin la imagen (no debería pasar), queda el hueco: nunca un error a la vista.
      errorBuilder: (context, error, stackTrace) => SizedBox.square(dimension: size),
    );
    if (goldFraction == 0) return ExcludeSemantics(child: image);

    // Dorado líquido solo sobre la silueta del icono (HU-002 R15, R16).
    return ExcludeSemantics(
      child: LiquidGold(
        key: const ValueKey<String>('game-icon-gold'),
        fraction: goldFraction,
        animate: animateGold,
        child: image,
      ),
    );
  }
}
