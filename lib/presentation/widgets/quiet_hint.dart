import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'helper_language_text.dart';

/// Aviso pequeño, sin botones, al pie de la pantalla (D-025): no ocupa la
/// pantalla ni recibe toques, así que lo de debajo sigue funcionando. Va como
/// hijo de un [Stack].
class QuietHint extends StatelessWidget {
  const QuietHint({super.key, required this.text, this.helperText});

  final String text;

  /// El mismo aviso en el idioma de ayuda, en una segunda línea (HU-021 R6).
  final String Function(AppLocalizations l10n)? helperText;

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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppPalette.white, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    if (helperText case final helperText?)
                      HelperLanguageText(
                        key: const ValueKey<String>('quiet-hint-helper'),
                        text: helperText,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppPalette.white.withValues(alpha: 0.85), fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
