import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// La capa cálida de la preparación para dormir (HU-038 R11): un velo ámbar
/// transparente sobre toda la app, que aparece poco a poco en los 30 minutos
/// antes de la noche o la siesta. Reduce la luz fría, como la «Luz nocturna»
/// de Android, sin avisos (R12). No se toca ni la lee el lector de pantalla.
class WarmVeil extends StatelessWidget {
  const WarmVeil({super.key, required this.progress});

  /// Transparencia máxima (P7: hasta un 15 %, ajustada midiendo el contraste).
  /// Con un 15 % el azul petróleo sobre el crema bajaba a 4,47:1; con un 14 %
  /// queda en 4,54:1 y todos los textos siguen cumpliendo AA (test de la paleta).
  static const double maxOpacity = 0.14;

  /// De 0 (sin capa) a 1 (al máximo).
  final double progress;

  /// El color de la capa a [progress].
  static Color colorAt(double progress) => AppPalette.amber.withValues(alpha: maxOpacity * progress.clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: ColoredBox(key: const ValueKey<String>('warm-veil'), color: colorAt(progress)),
      ),
    );
  }
}
