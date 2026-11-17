import 'package:flutter/material.dart';

import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'medal_badge.dart';

/// Cómo se ven las rondas y sus medallas (HU-037 P8, P17; HU-048): bronce,
/// plata y oro, que se distinguen por luminosidad y por sus estrellas.
abstract final class RoundStyle {
  static MedalStyle medalStyleOf(GameDifficulty round) => switch (round) {
        GameDifficulty.bronze => MedalStyle.bronze,
        GameDifficulty.silver => MedalStyle.silver,
        GameDifficulty.gold => MedalStyle.gold,
        GameDifficulty.ruby => MedalStyle.ruby,
        GameDifficulty.emerald => MedalStyle.emerald,
        GameDifficulty.sapphire => MedalStyle.sapphire,
        GameDifficulty.obsidian => MedalStyle.obsidian,
        GameDifficulty.diamond => MedalStyle.diamond,
      };

  /// Nombre de la ronda, el de su medalla (HU-051 R4).
  static String roundName(AppLocalizations l10n, GameDifficulty round) => switch (round) {
        GameDifficulty.bronze => l10n.roundBronze,
        GameDifficulty.silver => l10n.roundSilver,
        GameDifficulty.gold => l10n.roundGold,
        GameDifficulty.ruby => l10n.roundRuby,
        GameDifficulty.emerald => l10n.roundEmerald,
        GameDifficulty.sapphire => l10n.roundSapphire,
        GameDifficulty.obsidian => l10n.roundObsidian,
        GameDifficulty.diamond => l10n.roundDiamond,
      };

  /// Color de la ronda (puntos de nivel, bordes): el relleno de su medalla. El
  /// oro es ámbar claro con borde dorado (HU-048 P3). Rubí y esmeralda son
  /// exclusivos de las medallas (HU-051): sus rondas usan el dorado del
  /// progreso fuera de la medalla.
  static Color colorOf(GameDifficulty round) => switch (round) {
        GameDifficulty.ruby || GameDifficulty.emerald => AppPalette.gold,
        _ => medalStyleOf(round).fill,
      };

  /// Borde de la ronda: el de su medalla.
  static Color rimOf(GameDifficulty round) => medalStyleOf(round).rim;

  static String medalTitle(AppLocalizations l10n, GameDifficulty round) => switch (round) {
        GameDifficulty.bronze => l10n.medalBronzeTitle,
        GameDifficulty.silver => l10n.medalSilverTitle,
        GameDifficulty.gold => l10n.medalGoldTitle,
        GameDifficulty.ruby => l10n.medalRubyTitle,
        GameDifficulty.emerald => l10n.medalEmeraldTitle,
        GameDifficulty.sapphire => l10n.medalSapphireTitle,
        GameDifficulty.obsidian => l10n.medalObsidianTitle,
        GameDifficulty.diamond => l10n.medalDiamondTitle,
      };

  static String medalMessage(AppLocalizations l10n, GameDifficulty round) =>
      round == GameDifficulty.diamond ? l10n.memoryBadgeMessage : l10n.medalNextRoundMessage;
}
