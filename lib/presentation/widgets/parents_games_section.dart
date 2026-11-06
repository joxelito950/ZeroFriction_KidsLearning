import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/game_settings/game_settings_cubit.dart';
import '../theme/app_palette.dart';

/// Sección «Juegos» de la Zona de Padres (HU-030 3.1): la dificultad y «Jugar
/// sin tiempo», para todos los juegos. Los cambios se ven en el siguiente
/// tablero (R6).
class ParentsGamesSection extends StatelessWidget {
  const ParentsGamesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final IPersistenceRepository? repository = context.read<IPersistenceRepository?>();
    if (repository == null) return const SizedBox.shrink();

    return BlocProvider<GameSettingsCubit>(
      create: (_) => GameSettingsCubit(repository: repository)..load(),
      child: const _GamesCard(),
    );
  }
}

class _GamesCard extends StatelessWidget {
  const _GamesCard();

  static String _label(AppLocalizations l10n, GameDifficulty difficulty) => switch (difficulty) {
        GameDifficulty.easy => l10n.difficultyEasy,
        GameDifficulty.normal => l10n.difficultyNormal,
        GameDifficulty.impossible => l10n.difficultyImpossible,
      };

  static String _hint(AppLocalizations l10n, GameDifficulty difficulty) => switch (difficulty) {
        GameDifficulty.easy => l10n.difficultyEasyHint,
        GameDifficulty.normal => l10n.difficultyNormalHint,
        GameDifficulty.impossible => l10n.difficultyImpossibleHint,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<GameSettingsCubit, GameSettingsState>(
      builder: (context, state) {
        final cubit = context.read<GameSettingsCubit>();
        return Card(
          key: const ValueKey<String>('parents-zone-games'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.extension_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.parentsZoneGamesTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(l10n.parentsZoneGamesIntro, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Text(l10n.parentsZoneDifficultyLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                // Chips que saltan de línea: con el texto ampliado no se desbordan.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final difficulty in GameDifficulty.values)
                      ChoiceChip(
                        key: ValueKey<String>('difficulty-${difficulty.name}'),
                        label: Text(_label(l10n, difficulty)),
                        selected: state.difficulty == difficulty,
                        onSelected: state.loaded ? (_) => cubit.setDifficulty(difficulty) : null,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _hint(l10n, state.difficulty),
                  key: const ValueKey<String>('difficulty-hint'),
                  style: theme.textTheme.bodySmall?.copyWith(color: AppPalette.deepTeal),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  key: const ValueKey<String>('games-no-time'),
                  contentPadding: EdgeInsets.zero,
                  value: state.timerDisabled,
                  // Solo un adulto con Premium puede cambiarlo (R4).
                  onChanged: state.loaded && state.isPremium ? cubit.setTimerDisabled : null,
                  title: Text(l10n.parentsZoneNoTimeTitle),
                  subtitle: Text(
                    state.isPremium
                        ? l10n.parentsZoneNoTimeHint
                        : '${l10n.parentsZoneNoTimeHint} ${l10n.parentsZonePremiumOnly}',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
