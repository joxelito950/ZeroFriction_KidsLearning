import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Tema de la app (D-032): cada rol del [ColorScheme] se asigna a mano con un
/// color de [AppPalette], sin `fromSeed`, para que Material no derive tonos que
/// no están en la paleta. La paleta no tiene rojo de error (C7).
abstract final class AppTheme {
  static final ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.petrolBlue,
    onPrimary: AppPalette.white,
    primaryContainer: AppPalette.petrolBlue,
    onPrimaryContainer: AppPalette.white,
    secondary: AppPalette.deepTeal,
    onSecondary: AppPalette.white,
    // Botones tonales: blancos sobre el fondo crema, con el texto azul de lo que se toca.
    secondaryContainer: AppPalette.white,
    onSecondaryContainer: AppPalette.petrolBlue,
    tertiary: AppPalette.amber,
    onTertiary: AppPalette.deepTeal,
    tertiaryContainer: AppPalette.amber,
    onTertiaryContainer: AppPalette.deepTeal,
    error: AppPalette.deepTeal,
    onError: AppPalette.white,
    errorContainer: AppPalette.warmCream,
    onErrorContainer: AppPalette.deepTeal,
    surface: AppPalette.warmCream,
    onSurface: AppPalette.deepTeal,
    onSurfaceVariant: AppPalette.deepTeal,
    surfaceDim: AppPalette.warmCream,
    surfaceBright: AppPalette.white,
    surfaceContainerLowest: AppPalette.white,
    surfaceContainerLow: AppPalette.white,
    surfaceContainer: AppPalette.white,
    surfaceContainerHigh: AppPalette.white,
    surfaceContainerHighest: AppPalette.white,
    outline: AppPalette.petrolBlue,
    outlineVariant: AppPalette.deepTeal.withValues(alpha: 0.2),
    shadow: AppPalette.deepTeal,
    scrim: AppPalette.deepTeal,
    inverseSurface: AppPalette.deepTeal,
    onInverseSurface: AppPalette.warmCream,
    inversePrimary: AppPalette.amber,
    surfaceTint: Colors.transparent,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppPalette.warmCream,
        cardTheme: CardThemeData(
          elevation: 2,
          shadowColor: AppPalette.deepTeal.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      );
}
