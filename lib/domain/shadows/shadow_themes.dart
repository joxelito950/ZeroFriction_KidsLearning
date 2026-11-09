import 'dart:math';

import 'shadow_ladder.dart';

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
  const ShadowBoardContent({required this.objects, required this.shadows});

  final List<String> objects;
  final List<String> shadows;

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

  /// Elige el contenido del [level]: en los niveles de una sola temática, todo
  /// de una temática con sombras suficientes; en el nivel 1, objetos de
  /// temáticas distintas (formas muy diferentes); en el resto, mezclados. Las
  /// sombras libres salen del mismo conjunto, salvo sin ellas (Fácil).
  static ShadowBoardContent pick(Random random, ShadowLevel level, {bool freeShadows = true}) {
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
