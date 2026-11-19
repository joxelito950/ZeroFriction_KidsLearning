import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';
import 'package:toddler_logic/presentation/theme/app_theme.dart';
import 'package:toddler_logic/presentation/widgets/warm_veil.dart';

/// La app solo usa los 7 colores de la paleta (D-032, docs/brand/PALETA.md),
/// y todos salen de `AppPalette` (TD-009).
///
/// Fuera de lib/presentation/theme/app_palette.dart no puede aparecer ningún
/// color escrito a mano (`Color(0x…)`, `Color.fromARGB`…), ningún `Colors.*`
/// de Material salvo `Colors.transparent`, ni un tema generado con `fromSeed`,
/// ni nada que fabrique tonos nuevos (`Color.lerp`, `HSLColor`…). Las
/// transparencias (`AppPalette.gold.withValues(alpha: 0.5)`) sí se permiten.
void main() {
  const palettePath = 'lib/presentation/theme/app_palette.dart';

  final files = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => file.path.replaceAll(r'\', '/'))
      .where((path) => path.endsWith('.dart') && !path.endsWith('.g.dart') && !path.startsWith('lib/l10n/'))
      .where((path) => path != palettePath);

  final forbidden = <String, RegExp>{
    'Color(…)': RegExp(r'\bColor\s*\('),
    'Color.from…': RegExp(r'\bColor\.from\w*\s*\('),
    'Color.lerp': RegExp(r'\bColor\.lerp\b'),
    'Colors.*': RegExp(r'\bColors\.(?!transparent\b)\w+'),
    'CupertinoColors.*': RegExp(r'\bCupertinoColors\.'),
    'fromSeed': RegExp(r'\bfromSeed\b'),
    'HSLColor / HSVColor': RegExp(r'\bHS[LV]Color\b'),
    'withRed / withGreen / withBlue': RegExp(r'\.with(Red|Green|Blue)\s*\('),
  };

  String withoutComment(String line) {
    final String trimmed = line.trimLeft();
    if (trimmed.startsWith('//')) return '';
    return line.replaceFirst(RegExp(r'\s//.*$'), '');
  }

  group('Ningún color fuera de AppPalette', () {
    for (final path in files) {
      test('$path solo usa la paleta', () {
        final offenders = <String>[];
        final lines = File(path).readAsLinesSync();

        for (var index = 0; index < lines.length; index++) {
          final String code = withoutComment(lines[index]);
          for (final MapEntry<String, RegExp> rule in forbidden.entries) {
            if (rule.value.hasMatch(code)) offenders.add('$path:${index + 1}: ${rule.key}: ${lines[index].trim()}');
          }
        }

        expect(offenders, isEmpty,
            reason: 'Usa un color de AppPalette (docs/brand/PALETA.md). Un color nuevo exige cambiar '
                'antes la paleta, con su propia decisión:\n${offenders.join('\n')}');
      });
    }
  });

  group('AppPalette', () {
    final inCode = <String, Color>{
      'deepTeal': AppPalette.deepTeal,
      'warmCream': AppPalette.warmCream,
      'softCoral': AppPalette.softCoral,
      'amber': AppPalette.amber,
      'gold': AppPalette.gold,
      'petrolBlue': AppPalette.petrolBlue,
      'white': AppPalette.white,
      'medalBronze': AppPalette.medalBronze,
      'medalSilver': AppPalette.medalSilver,
      'medalRuby': AppPalette.medalRuby,
      'medalEmerald': AppPalette.medalEmerald,
    };

    test('tiene exactamente los colores de la tabla de PALETA.md', () {
      final row = RegExp(r'^\|[^|]+\|\s*`#([0-9A-Fa-f]{6})`\s*\|\s*`AppPalette\.(\w+)`', multiLine: true);
      final inDocs = {
        for (final match in row.allMatches(File('docs/brand/PALETA.md').readAsStringSync()))
          match.group(2)!: Color(0xFF000000 | int.parse(match.group(1)!, radix: 16)),
      };

      expect(inDocs, hasLength(11));
      expect(inCode, equals(inDocs));
      expect(AppPalette.all, unorderedEquals(inDocs.values));
    });

    test('no define más colores que los 11', () {
      final String source = File(palettePath).readAsStringSync();
      expect(RegExp(r'\bColor\(0x').allMatches(source), hasLength(11));
    });

    // HU-051 (decisión del dueño, 2026-11-17): rubí y esmeralda son exclusivos
    // de las medallas; nunca en textos, mensajes, botones ni secciones.
    test('rubí y esmeralda solo se usan en la medalla', () {
      const medalPath = 'lib/presentation/widgets/medal_badge.dart';
      final offenders = [
        for (final path in files)
          if (path != medalPath && RegExp(r'\bmedal(Ruby|Emerald)\b').hasMatch(File(path).readAsStringSync())) path,
      ];
      expect(offenders, isEmpty);
    });
  });

  group('Contraste del tema (WCAG 2.1, 4,5:1 para texto normal)', () {
    final ColorScheme scheme = AppTheme.colorScheme;
    final pairs = <String, (Color, Color)>{
      'onPrimary / primary': (scheme.onPrimary, scheme.primary),
      'onPrimaryContainer / primaryContainer': (scheme.onPrimaryContainer, scheme.primaryContainer),
      'onSecondary / secondary': (scheme.onSecondary, scheme.secondary),
      'onSecondaryContainer / secondaryContainer': (scheme.onSecondaryContainer, scheme.secondaryContainer),
      'onTertiary / tertiary': (scheme.onTertiary, scheme.tertiary),
      'onTertiaryContainer / tertiaryContainer': (scheme.onTertiaryContainer, scheme.tertiaryContainer),
      'onError / error': (scheme.onError, scheme.error),
      'onErrorContainer / errorContainer': (scheme.onErrorContainer, scheme.errorContainer),
      'onSurface / surface': (scheme.onSurface, scheme.surface),
      'onSurfaceVariant / surface': (scheme.onSurfaceVariant, scheme.surface),
      'onSurface / surfaceContainerHighest': (scheme.onSurface, scheme.surfaceContainerHighest),
      'primary / surface': (scheme.primary, scheme.surface),
      'primary / surfaceContainerHighest': (scheme.primary, scheme.surfaceContainerHighest),
      'onInverseSurface / inverseSurface': (scheme.onInverseSurface, scheme.inverseSurface),
      'inversePrimary / inverseSurface': (scheme.inversePrimary, scheme.inverseSurface),
    };

    for (final MapEntry<String, (Color, Color)> pair in pairs.entries) {
      test(pair.key, () {
        expect(contrastRatio(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
      });
    }

    test('todos los roles del tema son colores de la paleta o sus transparencias', () {
      final roles = <Color>[
        scheme.primary, scheme.onPrimary, scheme.primaryContainer, scheme.onPrimaryContainer,
        scheme.secondary, scheme.onSecondary, scheme.secondaryContainer, scheme.onSecondaryContainer,
        scheme.tertiary, scheme.onTertiary, scheme.tertiaryContainer, scheme.onTertiaryContainer,
        scheme.error, scheme.onError, scheme.errorContainer, scheme.onErrorContainer,
        scheme.surface, scheme.onSurface, scheme.onSurfaceVariant, scheme.surfaceDim, scheme.surfaceBright,
        scheme.surfaceContainerLowest, scheme.surfaceContainerLow, scheme.surfaceContainer,
        scheme.surfaceContainerHigh, scheme.surfaceContainerHighest,
        scheme.outline, scheme.outlineVariant, scheme.shadow, scheme.scrim,
        scheme.inverseSurface, scheme.onInverseSurface, scheme.inversePrimary,
        // Las variantes fijas de Material 3 que no se asignan caen en los roles anteriores.
        scheme.primaryFixed, scheme.onPrimaryFixed, scheme.secondaryFixed, scheme.onSecondaryFixed,
        scheme.tertiaryFixed, scheme.onTertiaryFixed,
      ];
      final outside = roles.where((color) => color.a > 0 && !AppPalette.all.contains(color.withValues(alpha: 1)));
      expect(outside, isEmpty);
    });
  });

  group('Contraste de los textos con transparencia (WCAG 2.1, 4,5:1)', () {
    // La línea de ayuda del desafío y del mensaje de fallo (HU-021), sobre el crema y sobre el blanco.
    final Color helper = AppPalette.deepTeal.withValues(alpha: 0.8);
    // El aviso pequeño (QuietHint): fondo teal al 90 % sobre el crema del menú, ayuda en blanco al 85 %.
    final Color hintBackground = blend(AppPalette.deepTeal.withValues(alpha: 0.9), AppPalette.warmCream);

    final pairs = <String, (Color, Color)>{
      'ayuda del desafío sobre el crema': (blend(helper, AppPalette.warmCream), AppPalette.warmCream),
      'ayuda del mensaje sobre el blanco': (blend(helper, AppPalette.white), AppPalette.white),
      'aviso pequeño, texto blanco': (AppPalette.white, hintBackground),
      'aviso pequeño, ayuda en blanco al 85 %': (blend(AppPalette.white.withValues(alpha: 0.85), hintBackground), hintBackground),
    };

    for (final MapEntry<String, (Color, Color)> pair in pairs.entries) {
      test(pair.key, () {
        expect(contrastRatio(pair.value.$1, pair.value.$2), greaterThanOrEqualTo(4.5));
      });
    }
  });

  group('Contraste con la capa cálida al máximo (HU-038 P7, WCAG 2.1, 4,5:1)', () {
    // La capa ámbar se pinta encima de todo: el texto y su fondo cambian a la vez.
    Color veiled(Color color) => blend(WarmVeil.colorAt(1), color);
    final ColorScheme scheme = AppTheme.colorScheme;
    final pairs = <String, (Color, Color)>{
      'texto teal profundo sobre el crema': (AppPalette.deepTeal, AppPalette.warmCream),
      'texto teal profundo sobre el blanco': (AppPalette.deepTeal, AppPalette.white),
      'azul petróleo sobre el crema (Zona de Padres)': (AppPalette.petrolBlue, AppPalette.warmCream),
      'blanco sobre el azul petróleo (botones)': (AppPalette.white, AppPalette.petrolBlue),
      'crema sobre el teal profundo (pantalla de noche)': (AppPalette.warmCream, AppPalette.deepTeal),
      'ayuda del desafío sobre el crema': (blend(AppPalette.deepTeal.withValues(alpha: 0.8), AppPalette.warmCream), AppPalette.warmCream),
      'onPrimary / primary': (scheme.onPrimary, scheme.primary),
      'onSurface / surface': (scheme.onSurface, scheme.surface),
      'primary / surface': (scheme.primary, scheme.surface),
    };

    test('la capa es ámbar de la paleta y no pasa del 15 %', () {
      expect(WarmVeil.maxOpacity, lessThanOrEqualTo(0.15));
      expect(WarmVeil.colorAt(2).withValues(alpha: 1), AppPalette.amber);
      expect(WarmVeil.colorAt(2).a, closeTo(WarmVeil.maxOpacity, 0.001));
    });

    for (final MapEntry<String, (Color, Color)> pair in pairs.entries) {
      test(pair.key, () {
        expect(contrastRatio(veiled(pair.value.$1), veiled(pair.value.$2)), greaterThanOrEqualTo(4.5));
      });
    }
  });
}

/// [color] con transparencia pintado sobre el fondo opaco [background].
Color blend(Color color, Color background) => Color.alphaBlend(color, background);

/// Relación de contraste de WCAG 2.1 entre dos colores opacos.
double contrastRatio(Color a, Color b) {
  double channel(double value) =>
      value <= 0.04045 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color color) => 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);

  final double lighter = math.max(luminance(a), luminance(b));
  final double darker = math.min(luminance(a), luminance(b));
  return (lighter + 0.05) / (darker + 0.05);
}
