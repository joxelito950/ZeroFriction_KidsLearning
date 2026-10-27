import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

/// Aviso pequeño, sin botones, al pie de la pantalla (D-025): no ocupa la
/// pantalla ni recibe toques, así que lo de debajo sigue funcionando. Va como
/// hijo de un [Stack].
class QuietHint extends StatelessWidget {
  const QuietHint({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      start: 24,
      end: 24,
      bottom: 32,
      child: IgnorePointer(
        child: SafeArea(
          child: Center(
            // El aviso puede quedar fuera del Scaffold de la pantalla: su propio
            // Material le da el estilo de texto (sin él sale subrayado).
            child: Material(
              color: AppPalette.deepTeal.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppPalette.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
