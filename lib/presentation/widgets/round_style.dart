import 'package:flutter/material.dart';

import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import 'medal_badge.dart';

/// Cómo se ven las rondas y sus medallas (HU-037 P8, P17; HU-048): bronce,
/// plata y oro, que se distinguen por luminosidad y por sus estrellas.
abstract final class RoundStyle {
  static MedalStyle medalStyleOf(GameDifficulty round) => switch (round) {
        GameDifficulty.easy => MedalStyle.bronze,
        GameDifficulty.normal => MedalStyle.silver,
        GameDifficulty.impossible => MedalStyle.gold,
      };

  /// Color de la ronda (puntos de nivel, bordes): el relleno de su medalla.
  /// El oro es ámbar claro con borde dorado (HU-048 P3).
  static Color colorOf(GameDifficulty round) => medalStyleOf(round).fill;

  /// Borde de la ronda: el de su medalla.
  static Color rimOf(GameDifficulty round) => medalStyleOf(round).rim;

  static String medalTitle(AppLocalizations l10n, GameDifficulty round) => switch (round) {
        GameDifficulty.easy => l10n.medalBronzeTitle,
        GameDifficulty.normal => l10n.medalSilverTitle,
        GameDifficulty.impossible => l10n.medalGoldTitle,
      };

  static String medalMessage(AppLocalizations l10n, GameDifficulty round) =>
      round == GameDifficulty.impossible ? l10n.memoryBadgeMessage : l10n.medalNextRoundMessage;
}
