import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/progress/game_progress.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/game_settings/game_settings_cubit.dart';
import '../theme/app_palette.dart';
import 'medal_badge.dart';
import 'parents_setting_page.dart';
import 'round_style.dart';

/// Nombre de cada juego y de cada ronda, para la pantalla y el resumen.
abstract final class ParentsGamesTexts {
  static String round(AppLocalizations l10n, GameDifficulty difficulty) => switch (difficulty) {
        GameDifficulty.easy => l10n.difficultyEasy,
        GameDifficulty.normal => l10n.difficultyNormal,
        GameDifficulty.impossible => l10n.difficultyImpossible,
      };

  static String game(AppLocalizations l10n, GameId game) => switch (game) {
        GameId.memory => l10n.menuMemoryTitle,
        GameId.shadows => l10n.shadowsGameTitle,
        GameId.oddOneOut => l10n.oddOneOutTitle,
      };

  /// Resumen de la fila «Juegos» (HU-046 §4.1): la ronda de cada juego.
  static String summary(AppLocalizations l10n, GameSettingsState state) => [
        for (final GameId id in GameId.values) '${game(l10n, id)}: ${round(l10n, state.rounds[id]!)}',
      ].join(' · ');
}

/// Pantalla «Juegos» (HU-046): la ronda de cada juego (HU-037 P1), «Mantener
/// las estrellas» (HU-016) y «Jugar sin tiempo» (HU-030, Premium). Se cambia un
/// borrador y se aplica con «Guardar». Usa el [GameSettingsCubit] de la Zona de
/// Padres, que ya los ha leído.
class ParentsGamesPage extends StatefulWidget {
  const ParentsGamesPage({super.key});

  @override
  State<ParentsGamesPage> createState() => _ParentsGamesPageState();
}

class _ParentsGamesPageState extends State<ParentsGamesPage> {
  late Map<GameId, GameDifficulty> _rounds;
  late bool _keepStars;
  late bool _timerDisabled;

  @override
  void initState() {
    super.initState();
    _reset(context.read<GameSettingsCubit>().state);
  }

  void _reset(GameSettingsState state) {
    _rounds = Map.of(state.rounds);
    _keepStars = state.keepStars;
    _timerDisabled = state.timerDisabled;
  }

  bool _dirty(GameSettingsState saved) =>
      _keepStars != saved.keepStars ||
      _timerDisabled != saved.timerDisabled ||
      GameId.values.any((game) => _rounds[game] != saved.rounds[game]);

  Future<bool> _save() async {
    final GameSettingsCubit cubit = context.read<GameSettingsCubit>();
    final GameSettingsState saved = cubit.state;
    for (final GameId game in GameId.values) {
      if (_rounds[game] != saved.rounds[game]) await cubit.setRound(game, _rounds[game]!);
    }
    if (_keepStars != saved.keepStars) await cubit.setKeepStars(_keepStars);
    if (_timerDisabled != saved.timerDisabled) await cubit.setTimerDisabled(_timerDisabled);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<GameSettingsCubit, GameSettingsState>(
      // Si los ajustes terminan de leerse con la pantalla abierta, el borrador
      // empieza desde ellos.
      listenWhen: (previous, current) => !previous.loaded && current.loaded,
      listener: (context, state) => setState(() => _reset(state)),
      builder: (context, state) => ParentsSettingPage(
        key: const ValueKey<String>('parents-zone-games'),
        title: l10n.parentsZoneGamesTitle,
        dirty: _dirty(state),
        onSave: _save,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.parentsZoneGamesIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Text(l10n.parentsZoneRoundsLabel, style: theme.textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              l10n.parentsZoneRoundsHint,
              key: const ValueKey<String>('rounds-hint'),
              style: theme.textTheme.bodySmall?.copyWith(color: AppPalette.deepTeal),
            ),
            for (final GameId game in GameId.values) ...[
              const SizedBox(height: 12),
              Text(
                ParentsGamesTexts.game(l10n, game),
                style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
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
                        avatar: MedalBadge(style: RoundStyle.medalStyleOf(round), size: 22),
                        label: Text(ParentsGamesTexts.round(l10n, round)),
                        selected: _rounds[game] == round,
                        onSelected: state.loaded ? (_) => setState(() => _rounds[game] = round) : null,
                      ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            // Gratuito: protege al niño (HU-016 R6).
            SwitchListTile(
              key: const ValueKey<String>('games-keep-stars'),
              contentPadding: EdgeInsets.zero,
              value: _keepStars,
              onChanged: state.loaded ? (value) => setState(() => _keepStars = value) : null,
              title: Text(l10n.parentsZoneKeepStarsTitle),
              subtitle: Text(l10n.parentsZoneKeepStarsHint),
            ),
            // Solo con Premium (R4). Mientras no se pueda comprar (HU-006), sin
            // Premium ni se muestra: no se enseña algo que no se puede conseguir.
            if (state.isPremium)
              SwitchListTile(
                key: const ValueKey<String>('games-no-time'),
                contentPadding: EdgeInsets.zero,
                value: _timerDisabled,
                onChanged: state.loaded ? (value) => setState(() => _timerDisabled = value) : null,
                title: Text(l10n.parentsZoneNoTimeTitle),
                subtitle: Text(l10n.parentsZoneNoTimeHint),
              ),
          ],
        ),
      ),
    );
  }
}
