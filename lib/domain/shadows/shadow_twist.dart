/// Sombras dadas la vuelta (HU-040): en las últimas rondas, alguna sombra del
/// tablero sale en espejo, boca abajo o tumbada, y el niño busca la sombra de un
/// objeto aunque esté girada. Los objetos de la bandeja nunca se transforman.
library;

import '../settings/game_difficulty.dart';

/// Cómo está transformada una sombra respecto al dibujo de la bandeja.
enum ShadowTwist {
  none,

  /// Reflejada de izquierda a derecha: el 🐘 mira al otro lado.
  mirror,

  /// Girada 180°: la 🦒 está del revés.
  upsideDown,

  /// Girada 90°: el 🐊 está de pie o de lado.
  quarterTurn,
}

/// Qué giros salen en un tablero: entre cuáles se sortea, cuántas sombras y si
/// hay pista (el objeto gira en la bandeja, HU-040 3.3).
final class ShadowTwistPlan {
  const ShadowTwistPlan({required this.kinds, required this.count, required this.hint});

  static const ShadowTwistPlan none = ShadowTwistPlan(kinds: [], count: 0, hint: false);

  final List<ShadowTwist> kinds;

  /// Sombras transformadas en el tablero; con más de una, de giros distintos.
  final int count;
  final bool hint;

  bool get isEmpty => count == 0 || kinds.isEmpty;
}

abstract final class ShadowTwists {
  /// Interruptor de la historia: apagarlo en una versión si la validación con
  /// niños sale mal (HU-040 sección 9).
  static const bool enabled = true;

  /// Entrega 2 (boca abajo en zafiro, 90° en obsidiana y la mezcla de
  /// diamante): se publica **después de la validación** con niños de 4–5 años
  /// (P2). Hasta entonces, las rondas de después de esmeralda siguen con el
  /// espejo, una sombra por tablero y sin pista: así ninguna ronda es más fácil
  /// que la anterior.
  static const bool lateTwistsEnabled = false;

  /// Los primeros niveles de cada ronda calientan con sombras normales (4.2).
  static const int firstLevel = 4;

  /// Tabla 4.1.
  static ShadowTwistPlan planFor(GameDifficulty round, int level) {
    if (!enabled || level < firstLevel || round.index < GameDifficulty.emerald.index) return ShadowTwistPlan.none;
    if (round == GameDifficulty.emerald) {
      return const ShadowTwistPlan(kinds: [ShadowTwist.mirror], count: 1, hint: true);
    }
    if (!lateTwistsEnabled) return const ShadowTwistPlan(kinds: [ShadowTwist.mirror], count: 1, hint: false);
    return switch (round) {
      GameDifficulty.sapphire => const ShadowTwistPlan(kinds: [ShadowTwist.upsideDown], count: 1, hint: true),
      GameDifficulty.obsidian => const ShadowTwistPlan(kinds: [ShadowTwist.quarterTurn], count: 1, hint: true),
      _ => ShadowTwistPlan(
          kinds: const [ShadowTwist.mirror, ShadowTwist.upsideDown, ShadowTwist.quarterTurn],
          count: level <= 5 ? 1 : 2,
          hint: false,
        ),
    };
  }

  /// Objetos que sirven para cada giro (tabla 5): asimétricos para ese giro, y
  /// para el de 90°, alargados o con una dirección clara.
  static const Map<ShadowTwist, Set<String>> valid = {
    ShadowTwist.mirror: {
      '🐘', '🦒', '🐢', '🐌', '🐟', '🐳', '🐊', '🐇', '🐓', '🦆', '🐈', '🦕', '🦖', //
      '🚗', '🚲', '🚁', '🚀', '✈️', '⛵', '🚂', '🚜', '🍌', '🔑', '🔨', '🔧', '☂️',
    },
    ShadowTwist.upsideDown: {
      '🐘', '🦒', '🐢', '🐌', '🐳', '🐊', '🐇', '🐓', '🦆', '🐈', '🦕', '🦖', //
      '🚗', '🚲', '🚁', '⛵', '🚂', '🚜', '🍐', '🍒', '☂️', '🎈', '⏰', '🔑', '🔨',
    },
    ShadowTwist.quarterTurn: {
      '🦒',
      '🐊',
      '🦕',
      '🦖',
      '🐘',
      '🐢',
      '🐌',
      '🐳',
      '🚂',
      '🚜',
      '⛵',
      '🔑',
      '🔨',
      '☂️',
    },
  };

  /// Siluetas que, giradas, se pueden confundir entre sí (4.2): si una está en
  /// el tablero, la otra no se transforma. Se amplía con la validación en el
  /// moto g55 y en Android 8 (sección 5).
  static const List<Set<String>> lookAlikes = [
    {'🦕', '🦖'},
    {'🐟', '🐳'},
    {'🐓', '🦆'},
    {'🔨', '🔧'},
  ];

  /// Si [symbol] puede salir con [twist] en un tablero con estas [shadows].
  static bool fits(String symbol, ShadowTwist twist, Iterable<String> shadows) {
    if (!(valid[twist]?.contains(symbol) ?? false)) return false;
    for (final Set<String> group in lookAlikes) {
      if (group.contains(symbol) && shadows.any((other) => other != symbol && group.contains(other))) return false;
    }
    return true;
  }
}
