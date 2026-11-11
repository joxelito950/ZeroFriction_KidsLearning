import 'package:flutter/material.dart';

import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

/// Cómo se ven las rondas y sus medallas (HU-037 P8): bronce, plata y oro con
/// los colores de la paleta (D-032). La paleta no tiene plata ni bronce; se usan
/// el coral (cobrizo) y el azul petróleo (frío) hasta que se decida otra cosa
/// (HU-037 P17).
abstract final class RoundStyle {
  static Color colorOf(GameDifficulty round) => switch (round) {
        GameDifficulty.easy => AppPalette.softCoral,
        GameDifficulty.normal => AppPalette.petrolBlue,
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
