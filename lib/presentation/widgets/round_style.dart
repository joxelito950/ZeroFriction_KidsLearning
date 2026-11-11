import 'package:flutter/material.dart';

import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

/// Cómo se ven las rondas y sus medallas (HU-037 P8, P17): bronce, plata y oro
/// con tonos de la paleta (D-032): el dorado de siempre y un bronce y una plata
/// cercanos a sus colores, añadidos solo para las medallas.
abstract final class RoundStyle {
  static Color colorOf(GameDifficulty round) => switch (round) {
        GameDifficulty.easy => AppPalette.medalBronze,
        GameDifficulty.normal => AppPalette.medalSilver,
        GameDifficulty.impossible => AppPalette.gold,
      };

  static String medalTitle(AppLocalizations l10n, GameDifficulty round) => switch (round) {
        GameDifficulty.easy => l10n.medalBronzeTitle,
        GameDifficulty.normal => l10n.medalSilverTitle,
        GameDifficulty.impossible => l10n.medalGoldTitle,
      };

  static String medalMessage(AppLocalizations l10n, GameDifficulty round) =>
      round == GameDifficulty.impossible ? l10n.memoryBadgeMessage : l10n.medalNextRoundMessage;
}
