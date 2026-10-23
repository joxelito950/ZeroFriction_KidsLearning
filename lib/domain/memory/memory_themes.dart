import 'dart:math';

/// Una temática del juego de memoria: emojis de un mismo mundo, fáciles de
/// distinguir entre sí a simple vista (HU-001, R17 y R18).
final class MemoryTheme {
  const MemoryTheme({required this.id, required this.symbols});

  final String id;
  final List<String> symbols;
}

/// Contenido elegido para un tablero.
final class MemoryBoardContent {
  const MemoryBoardContent({required this.themeId, required this.symbols});

  final String themeId;
  final List<String> symbols;
}

/// Catálogo de temáticas (D-024). Solo emojis de Emoji 5.0 o anterior, sin
/// secuencias ZWJ, para que se vean en Android 8 (D-026). Cada temática tiene
/// al menos 8 emojis, los que necesita el tablero 4×4. Los nombres de las
/// temáticas no se muestran en pantalla.
abstract final class MemoryThemes {
  static const List<MemoryTheme> all = [
    MemoryTheme(id: 'farm', symbols: ['🐮', '🐷', '🐑', '🐔', '🐴', '🐶', '🐱', '🦆', '🐰', '🐐']),
    MemoryTheme(id: 'wild', symbols: ['🦁', '🐯', '🐻', '🐼', '🐨', '🦊', '🐵', '🐘', '🦒', '🦓']),
    MemoryTheme(
      id: 'vehicles',
      symbols: ['🚗', '🚌', '🚓', '🚑', '🚒', '🚜', '🚲', '🚀', '🚁', '🚂', '🚢', '🛵'],
    ),
    MemoryTheme(id: 'construction', symbols: ['🔨', '🔧', '🔩', '🚧', '👷', '🏗️', '📏', '📐', '🔦', '🚚']),
    MemoryTheme(id: 'emotions', symbols: ['😀', '😢', '😡', '😱', '😴', '😎', '😍', '🤢', '🤔', '😮']),
    MemoryTheme(id: 'food', symbols: ['🍕', '🍔', '🌭', '🍟', '🍦', '🍩', '🍪', '🎂', '🍿', '🥚', '🧀']),
    MemoryTheme(id: 'fruits', symbols: ['🍎', '🍌', '🍇', '🍓', '🍉', '🍍', '🍒', '🍐', '🍋', '🥝', '🍑']),
    MemoryTheme(id: 'flags', symbols: ['🇨🇴', '🇧🇷', '🇯🇵', '🇺🇸', '🇫🇷', '🇩🇪', '🇰🇷', '🇪🇸', '🇨🇦', '🇬🇧']),
    MemoryTheme(id: 'home', symbols: ['🚪', '🚿', '🛁', '🔑', '⏰', '💡', '📺', '📞', '🔔', '🛏️', '🛋️']),
  ];

  /// Elige al azar una temática y, dentro de ella, [pairs] emojis distintos.
  static MemoryBoardContent pick(Random random, {required int pairs}) {
    final int largest = all.map((theme) => theme.symbols.length).reduce(max);
    if (pairs < 1 || pairs > largest) {
      throw ArgumentError.value(pairs, 'pairs', 'must be between 1 and $largest');
    }
    final candidates = all.where((theme) => theme.symbols.length >= pairs).toList();
    final MemoryTheme theme = candidates[random.nextInt(candidates.length)];
    final symbols = List<String>.of(theme.symbols)..shuffle(random);
    return MemoryBoardContent(themeId: theme.id, symbols: symbols.take(pairs).toList(growable: false));
  }
}
