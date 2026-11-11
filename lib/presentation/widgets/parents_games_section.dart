import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/progress/game_progress.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/game_settings/game_settings_cubit.dart';
import '../theme/app_palette.dart';
import 'round_style.dart';

/// Sección «Juegos» de la Zona de Padres: la ronda de cada juego (HU-037 P1),
/// «Mantener las estrellas» (HU-016) y «Jugar sin tiempo» (HU-030, Premium).
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
                Text(l10n.parentsZoneRoundsLabel, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  l10n.parentsZoneRoundsHint,
                  key: const ValueKey<String>('rounds-hint'),
                  style: theme.textTheme.bodySmall?.copyWith(color: AppPalette.deepTeal),
                ),
                for (final (GameId game, String name) in [
                  (GameId.memory, l10n.menuMemoryTitle),
                  (GameId.shadows, l10n.shadowsGameTitle),
                  (GameId.oddOneOut, l10n.oddOneOutTitle),
                ]) ...[
                  const SizedBox(height: 12),
                  Text(name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  // Chips que saltan de línea: con el texto ampliado no se desbordan.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final round in GameDifficulty.values)
                        // En «¿Cuál es diferente?», Imposible es de Premium (HU-025 P1): sin
                        // Premium no se muestra, como todo lo que aún no se puede comprar.
                        if (game != GameId.oddOneOut || round != GameDifficulty.impossible || state.isPremium)
                          ChoiceChip(
                            key: ValueKey<String>('round-${game.name}-${round.name}'),
                            avatar: Icon(Icons.military_tech_rounded, color: RoundStyle.colorOf(round), size: 18),
                            label: Text(_label(l10n, round)),
                            selected: state.rounds[game] == round,
                            onSelected: state.loaded ? (_) => cubit.setRound(game, round) : null,
                          ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                // Gratuito: protege al niño (HU-016 R6).
                SwitchListTile(
                  key: const ValueKey<String>('games-keep-stars'),
                  contentPadding: EdgeInsets.zero,
                  value: state.keepStars,
                  onChanged: state.loaded ? cubit.setKeepStars : null,
                  title: Text(l10n.parentsZoneKeepStarsTitle),
                  subtitle: Text(l10n.parentsZoneKeepStarsHint),
                ),
                // Solo con Premium (R4). Mientras no se pueda comprar (HU-006), sin
                // Premium ni se muestra: no se enseña algo que no se puede conseguir
                // (decidido el 2026-11-09 para la primera publicación).
                if (state.isPremium)
                  SwitchListTile(
                    key: const ValueKey<String>('games-no-time'),
                    contentPadding: EdgeInsets.zero,
                    value: state.timerDisabled,
                    onChanged: state.loaded ? cubit.setTimerDisabled : null,
                    title: Text(l10n.parentsZoneNoTimeTitle),
                    subtitle: Text(l10n.parentsZoneNoTimeHint),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
