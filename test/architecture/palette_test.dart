import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';
import 'package:toddler_logic/presentation/theme/app_theme.dart';

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
    };

    test('tiene exactamente los colores de la tabla de PALETA.md', () {
      final row = RegExp(r'^\|[^|]+\|\s*`#([0-9A-Fa-f]{6})`\s*\|\s*`AppPalette\.(\w+)`', multiLine: true);
      final inDocs = {
        for (final match in row.allMatches(File('docs/brand/PALETA.md').readAsStringSync()))
          match.group(2)!: Color(0xFF000000 | int.parse(match.group(1)!, radix: 16)),
      };

      expect(inDocs, hasLength(7));
      expect(inCode, equals(inDocs));
      expect(AppPalette.all, unorderedEquals(inDocs.values));
    });

    test('no define más colores que los 7', () {
      final String source = File(palettePath).readAsStringSync();
      expect(RegExp(r'\bColor\(0x').allMatches(source), hasLength(7));
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
}

/// Relación de contraste de WCAG 2.1 entre dos colores opacos.
double contrastRatio(Color a, Color b) {
  double channel(double value) =>
      value <= 0.04045 ? value / 12.92 : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  double luminance(Color color) => 0.2126 * channel(color.r) + 0.7152 * channel(color.g) + 0.0722 * channel(color.b);

  final double lighter = math.max(luminance(a), luminance(b));
  final double darker = math.min(luminance(a), luminance(b));
  return (lighter + 0.05) / (darker + 0.05);
}
