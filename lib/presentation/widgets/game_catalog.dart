import 'package:flutter/material.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/odd_one_out/odd_one_out.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/progress/round_ladder.dart';
import '../../domain/shadows/shadow_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../screens/memory_game_screen.dart';
import '../screens/odd_one_out_screen.dart';
import '../screens/shadow_game_screen.dart';
import '../theme/app_palette.dart';
import 'game_icon.dart';

/// Un juego del menú (HU-023 R6): lo que necesita su tarjeta y la pantalla que
/// abre. Añadir un juego es añadir una entrada a [GameCatalog.all].
@immutable
final class MenuGame {
  const MenuGame({
    required this.id,
    required this.keyName,
    required this.title,
    required this.icon,
    required this.rounds,
    required this.background,
    required this.foreground,
    required this.screen,
  });

  final GameId id;

  /// Base de las claves de los tests: `menu-<keyName>`, `menu-<keyName>-icon`
  /// y `menu-<keyName>-badge`.
  final String keyName;
  final String Function(AppLocalizations l10n) title;
  final Widget Function(Key key, double size) icon;

  /// La escalera del juego: da el dorado y el total de estrellas (HU-037).
  final RoundLadder rounds;

  /// Color de la tarjeta y del texto sobre ella (D-032).
  final Color background;
  final Color foreground;
  final Widget Function() screen;
}

abstract final class GameCatalog {
  /// Los juegos en orden fijo, el de llegada (HU-023 R3, P2).
  static final List<MenuGame> all = [
    MenuGame(
      id: GameId.memory,
      keyName: 'memory',
      title: (l10n) => l10n.menuMemoryTitle,
      icon: (key, size) => GameIcon.memory(key: key, size: size),
      rounds: MemoryLadder.rounds,
      // Azul petróleo: lo que se toca (PALETA.md, C6).
      background: AppPalette.petrolBlue,
      foreground: AppPalette.white,
      screen: () => const MemoryGameScreen(),
    ),
    MenuGame(
      id: GameId.shadows,
      keyName: 'shadows',
      title: (l10n) => l10n.shadowsGameTitle,
      icon: (key, size) => GameIcon.shadows(key: key, size: size),
      rounds: ShadowLadder.rounds,
      // Teal profundo: se distingue del azul petróleo de la memoria.
      background: AppPalette.deepTeal,
      foreground: AppPalette.white,
      screen: () => const ShadowGameScreen(),
    ),
    MenuGame(
      id: GameId.oddOneOut,
      keyName: 'odd-one-out',
      title: (l10n) => l10n.oddOneOutTitle,
      icon: (key, size) => GameIcon.oddOneOut(key: key, size: size),
      rounds: OddOneOut.rounds,
      // Blanco con texto teal: se distingue de las dos tarjetas oscuras.
      background: AppPalette.white,
      foreground: AppPalette.deepTeal,
      screen: () => const OddOneOutScreen(),
    ),
  ];
}
