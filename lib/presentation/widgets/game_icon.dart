import 'package:flutter/material.dart';

import '../../brand/brand_assets.dart';
import '../theme/app_palette.dart';

/// Icono de un juego (HU-013 entregable 5). Es decorativo: el nombre del juego ya
/// lo dice el botón o la cabecera, así que el lector de pantalla lo ignora.
///
/// [goldFraction] prepara el dorado de HU-002 (D-030, P5 de HU-013): la silueta
/// se llena de dorado de abajo arriba, del 0 al 1.
class GameIcon extends StatelessWidget {
  const GameIcon({super.key, required this.asset, required this.size, this.goldFraction = 0})
      : assert(goldFraction >= 0 && goldFraction <= 1);

  /// Icono del juego de memoria.
  const GameIcon.memory({Key? key, required double size, double goldFraction = 0})
      : this(key: key, asset: BrandAssets.memoryIcon, size: size, goldFraction: goldFraction);

  final String asset;
  final double size;
  final double goldFraction;

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

    return ExcludeSemantics(
      child: Stack(
        children: [
          image,
          // Solo pinta donde hay icono (srcATop): la silueta, nunca el fondo.
          ShaderMask(
            key: const ValueKey<String>('game-icon-gold'),
            blendMode: BlendMode.srcATop,
            shaderCallback: (bounds) => LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              stops: [goldFraction, goldFraction],
              colors: [AppPalette.gold.withValues(alpha: 0.85), AppPalette.gold.withValues(alpha: 0)],
            ).createShader(bounds),
            child: image,
          ),
        ],
      ),
    );
  }
}
