import 'dart:math';

import 'shadow_ladder.dart';
import 'shadow_twist.dart';

/// Una temática de Sombras: emojis de **cuerpo entero o de perfil**, con
/// siluetas que se distinguen sin color (HU-007 4.5). Solo Emoji 5.0 o anterior
/// y sin ZWJ, para Android 8 (D-024, D-026).
final class ShadowTheme {
  const ShadowTheme({required this.id, required this.symbols});

  final String id;
  final List<String> symbols;
}

/// Contenido de un tablero: los objetos de la bandeja y todas las sombras (las
/// de los objetos y las libres).
final class ShadowBoardContent {
  const ShadowBoardContent({required this.objects, required this.shadows, this.twists = const {}});

  final List<String> objects;
  final List<String> shadows;

  /// Sombras transformadas (HU-040), por su emoji; las que no están, normales.
  /// Nunca una sombra libre.
  final Map<String, ShadowTwist> twists;

  List<String> get freeShadows => [
        for (final shadow in shadows)
          if (!objects.contains(shadow)) shadow
      ];
}

abstract final class ShadowThemes {
  static const List<ShadowTheme> all = [
    ShadowTheme(
      id: 'animals',
      symbols: ['🐘', '🦒', '🐢', '🐌', '🦋', '🐟', '🐳', '🐊', '🐇', '🐓', '🦆', '🐈'],
    ),
    ShadowTheme(id: 'dinosaurs', symbols: ['🦕', '🦖']),
    ShadowTheme(id: 'vehicles', symbols: ['🚗', '🚲', '🚁', '🚀', '✈️', '⛵', '🚂', '🚜']),
    ShadowTheme(id: 'fruits', symbols: ['🍌', '🍐', '🍇', '🍒', '🍎', '🍉']),
    ShadowTheme(id: 'objects', symbols: ['🔑', '✂️', '☂️', '🔨', '🔧', '🎈', '⏰']),
  ];

  /// Intentos de reparto para que el tablero tenga sus sombras transformadas:
  /// una temática sin objetos que sirvan para el giro (las frutas tumbadas) se
  /// vuelve a sortear.
  static const int _twistAttempts = 30;

  /// Elige el contenido del [level] y, según el [twists] de la ronda, qué
  /// sombras salen transformadas (HU-040 4.1, 4.2).
  static ShadowBoardContent pick(
    Random random,
    ShadowLevel level, {
    bool freeShadows = true,
    ShadowTwistPlan twists = ShadowTwistPlan.none,
  }) {
    ShadowBoardContent content = _pickPlain(random, level, freeShadows: freeShadows);
    if (twists.isEmpty) return content;
    Map<String, ShadowTwist> chosen = _twistsFor(random, content, twists);
    for (var attempt = 1; attempt < _twistAttempts && chosen.length < twists.count; attempt++) {
      content = _pickPlain(random, level, freeShadows: freeShadows);
      chosen = _twistsFor(random, content, twists);
    }
    return ShadowBoardContent(objects: content.objects, shadows: content.shadows, twists: chosen);
  }

  /// Hasta [ShadowTwistPlan.count] objetos del tablero, cada uno con un giro
  /// distinto que le sirva.
  static Map<String, ShadowTwist> _twistsFor(Random random, ShadowBoardContent content, ShadowTwistPlan plan) {
    final List<String> candidates = List.of(content.objects)..shuffle(random);
    final List<ShadowTwist> kinds = List.of(plan.kinds)..shuffle(random);
    final Map<String, ShadowTwist> chosen = {};
    for (final String symbol in candidates) {
      if (chosen.length == plan.count) break;
      for (final ShadowTwist kind in kinds) {
        if (chosen.containsValue(kind) || !ShadowTwists.fits(symbol, kind, content.shadows)) continue;
        chosen[symbol] = kind;
        break;
      }
    }
    return chosen;
  }

  /// En los niveles de una sola temática, todo de una temática con sombras
  /// suficientes; en el nivel 1, objetos de temáticas distintas (formas muy
  /// diferentes); en el resto, mezclados. Las sombras libres salen del mismo
  /// conjunto, salvo sin ellas (Fácil).
  static ShadowBoardContent _pickPlain(Random random, ShadowLevel level, {required bool freeShadows}) {
    final int shadows = freeShadows ? level.shadows : level.objects;
    final List<String> symbols;
    if (level.sameTheme) {
      final candidates = all.where((theme) => theme.symbols.length >= shadows).toList();
      symbols =
          (List.of(candidates[random.nextInt(candidates.length)].symbols)..shuffle(random)).take(shadows).toList();
    } else if (level.number == 1) {
      final themes = List.of(all)..shuffle(random);
      symbols = [for (final theme in themes.take(shadows)) theme.symbols[random.nextInt(theme.symbols.length)]];
    } else {
      symbols = ([for (final theme in all) ...theme.symbols]..shuffle(random)).take(shadows).toList();
    }
    return ShadowBoardContent(
        objects: symbols.take(level.objects).toList(), shadows: List.of(symbols)..shuffle(random));
  }
}
