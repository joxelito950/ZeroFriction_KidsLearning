import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../brand/brand_assets.dart';
import '../../domain/memory/memory_ladder.dart';
import '../../domain/odd_one_out/odd_one_out.dart';
import '../../domain/vehicles/vehicle_ladder.dart';
import '../../domain/parental/play_history.dart';
import '../../domain/parental/progress_summary.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/progress/level_record.dart';
import '../../domain/progress/round_ladder.dart';
import '../../domain/settings/game_difficulty.dart';
import '../../domain/shadows/shadow_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/game_settings/game_settings_cubit.dart';
import '../blocs/parents_progress/parents_progress_cubit.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../theme/app_palette.dart';
import 'game_icon.dart';
import 'medal_badge.dart';
import 'parents_games_section.dart';
import 'parents_setting_page.dart';
import 'play_week_chart.dart';
import 'round_style.dart';

/// Escalera e icono de cada juego, para las tarjetas y el detalle de estrellas.
abstract final class ProgressGames {
  static RoundLadder ladderOf(GameId game) => switch (game) {
        GameId.memory => MemoryLadder.rounds,
        GameId.shadows => ShadowLadder.rounds,
        GameId.oddOneOut => OddOneOut.rounds,
        GameId.vehicles => VehicleLadder.rounds,
      };

  static String iconOf(GameId game) => switch (game) {
        GameId.memory => BrandAssets.memoryIcon,
        GameId.shadows => BrandAssets.shadowsIcon,
        GameId.oddOneOut => BrandAssets.oddOneOutIcon,
        GameId.vehicles => BrandAssets.vehiclesIcon,
      };
}

/// Resumen de la fila «Su progreso» (HU-034 §3): el juego favorito y el tiempo
/// de estos días, o una frase neutra si no ha jugado.
String parentsProgressRowSummary(AppLocalizations l10n, ProgressSummary summary) {
  final GameId? favorite = summary.favoriteGame;
  if (favorite == null) return l10n.parentsProgressRowEmpty;
  return l10n.parentsProgressRowSummary(
      ParentsGamesTexts.game(l10n, favorite), PlayWeekChart.duration(l10n, summary.total));
}

/// Arma el resumen con el historial de [PlayTimeCubit] (si lo hay) y el
/// progreso leído.
ProgressSummary progressSummaryOf(BuildContext context, ParentsProgressState progress, {DateTime? now}) {
  final PlayHistory history = context.read<PlayTimeCubit?>()?.state.history ?? PlayHistory(const []);
  return ProgressSummary(history: history, now: now ?? DateTime.now(), progress: progress.progress);
}

/// Pantalla «Su progreso» (HU-034): una frase, la sugerencia si la hay, una
/// tarjeta por juego y el gráfico de la semana. Solo lectura, salvo la
/// sugerencia (R1). Usa los cubits de la Zona de Padres.
class ParentsProgressPage extends StatelessWidget {
  const ParentsProgressPage({super.key, this.now});

  /// Para los tests; por defecto, la hora del teléfono.
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return BlocBuilder<ParentsProgressCubit, ParentsProgressState>(
      builder: (context, state) {
        final ProgressSummary summary = progressSummaryOf(context, state, now: now?.call());
        final GameId? favorite = summary.favoriteGame;
        final GameDifficulty? medal = favorite == null ? null : state.progress[favorite]?.bestMedal;
        final String sentence = switch ((favorite, medal)) {
          (null, _) => l10n.parentsProgressSentenceEmpty,
          (final GameId game, null) => l10n.parentsProgressSentence(ParentsGamesTexts.game(l10n, game)),
          (final GameId game, final GameDifficulty medal) =>
            l10n.parentsProgressSentenceMedal(ParentsGamesTexts.game(l10n, game), RoundStyle.roundName(l10n, medal)),
        };
        return ParentsSettingPage(
          key: const ValueKey<String>('parents-zone-progress'),
          title: l10n.parentsProgressTitle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(sentence, key: const ValueKey<String>('progress-sentence'), style: theme.textTheme.titleMedium),
              for (final GameId game in summary.stuckGames) _Suggestion(game: game, progress: state.progress[game]!),
              const SizedBox(height: 8),
              if (state.loaded)
                for (final GameId game in GameId.values) _GameCard(game: game, progress: state.progress[game]!),
              const SizedBox(height: 16),
              Text(l10n.parentsProgressWeekTitle, style: theme.textTheme.titleSmall),
              const SizedBox(height: 12),
              PlayWeekChart(slots: summary.week(MaterialLocalizations.of(context).firstDayOfWeekIndex)),
              const SizedBox(height: 12),
              Text(
                l10n.parentsProgressWeekTotal(PlayWeekChart.duration(l10n, summary.total)),
                key: const ValueKey<String>('progress-week-total'),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Tarjeta de un juego (§4.2): medallas conseguidas, lo que está explorando y
/// el total de estrellas, que abre el detalle.
class _GameCard extends StatelessWidget {
  const _GameCard({required this.game, required this.progress});

  final GameId game;
  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final RoundLadder ladder = ProgressGames.ladderOf(game);
    final bool undiscovered = ProgressSummary.undiscovered(progress);
    final List<GameDifficulty> medals = [
      for (final GameDifficulty round in GameDifficulty.values)
        if (progress.medals.contains(round)) round,
    ];

    return Card(
      key: ValueKey<String>('progress-card-${game.name}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GameIcon(asset: ProgressGames.iconOf(game), size: 44, goldFraction: progress.goldFraction(ladder)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ParentsGamesTexts.game(l10n, game),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  if (undiscovered)
                    Text(l10n.parentsProgressUndiscovered,
                        key: ValueKey<String>('progress-undiscovered-${game.name}'), style: theme.textTheme.bodyMedium)
                  else ...[
                    // Solo las medallas conseguidas; las que faltan no aparecen.
                    if (medals.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final GameDifficulty medal in medals)
                              MedalBadge(
                                key: ValueKey<String>('progress-medal-${game.name}-${medal.name}'),
                                style: RoundStyle.medalStyleOf(medal),
                                size: 28,
                                semanticLabel: RoundStyle.medalTitle(l10n, medal),
                              ),
                          ],
                        ),
                      ),
                    Text(
                      l10n.parentsProgressExploring(
                          RoundStyle.roundName(l10n, progress.position.round), progress.position.level),
                      key: ValueKey<String>('progress-exploring-${game.name}'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    Semantics(
                      button: true,
                      label: l10n.parentsProgressStarsSemantics(progress.stars, ladder.maxStars),
                      excludeSemantics: true,
                      child: TextButton(
                        key: ValueKey<String>('progress-stars-${game.name}'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppPalette.gold,
                          padding: EdgeInsets.zero,
                          alignment: AlignmentDirectional.centerStart,
                        ),
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => ProgressStarsDialog(game: game, progress: progress),
                        ),
                        child: Text(l10n.parentsProgressStars(progress.stars, ladder.maxStars),
                            style: theme.textTheme.titleSmall?.copyWith(color: AppPalette.gold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Detalle de estrellas por ronda y nivel (§4.4): las conseguidas en dorado,
/// las posibles en contorno; los niveles sin jugar, «por descubrir». Solo
/// lectura.
class ProgressStarsDialog extends StatelessWidget {
  const ProgressStarsDialog({super.key, required this.game, required this.progress});

  final GameId game;
  final GameProgress progress;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final RoundLadder ladder = ProgressGames.ladderOf(game);
    return AlertDialog(
      key: const ValueKey<String>('progress-stars-dialog'),
      title: Text(l10n.parentsProgressStarsTitle(ParentsGamesTexts.game(l10n, game))),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.parentsProgressStarsIntro, style: theme.textTheme.bodyMedium),
            for (final GameDifficulty round in GameDifficulty.values) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  MedalBadge(style: RoundStyle.medalStyleOf(round), size: 24),
                  const SizedBox(width: 6),
                  Text(RoundStyle.roundName(l10n, round),
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
              _roundLevels(context, round, ladder),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey<String>('progress-stars-close'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.parentalGateClose),
        ),
      ],
    );
  }

  Widget _roundLevels(BuildContext context, GameDifficulty round, RoundLadder ladder) {
    final l10n = AppLocalizations.of(context);
    final TextStyle? style = Theme.of(context).textTheme.bodySmall;
    final bool played = progress.records.keys.any((key) => key.round == round);
    // Una ronda sin jugar se dice una vez, no nivel a nivel.
    if (!played) {
      return Text(l10n.parentsProgressUndiscovered,
          key: ValueKey<String>('progress-round-new-${round.name}'), style: style);
    }
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (var level = RoundLadder.firstTimedLevel; level <= ladder.levels; level++)
          switch (progress.records[RoundLevel(round, level)]) {
            final LevelRecord record => Semantics(
                label: l10n.parentsProgressLevelSemantics(level, record.bestStars),
                excludeSemantics: true,
                child: Row(
                  key: ValueKey<String>('progress-level-${round.name}-$level'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.parentsProgressLevel(level), style: style),
                    const SizedBox(width: 2),
                    for (var star = 0; star < LevelRecord.maxStars; star++)
                      star < record.bestStars
                          ? const Icon(Icons.star_rounded, size: 16, color: AppPalette.gold)
                          : Icon(Icons.star_outline_rounded,
                              size: 16, color: AppPalette.deepTeal.withValues(alpha: 0.5)),
                  ],
                ),
              ),
            null => Text(
                '${l10n.parentsProgressLevel(level)} · ${l10n.parentsProgressToDiscover}',
                key: ValueKey<String>('progress-level-${round.name}-$level-new'),
                style: style,
              ),
          },
      ],
    );
  }
}

/// «Este nivel le está costando» (§4.5): propone la ronda anterior o, en
/// bronce, jugar sin tiempo. Propone, no decide: pide confirmación.
class _Suggestion extends StatelessWidget {
  const _Suggestion({required this.game, required this.progress});

  final GameId game;
  final GameProgress progress;

  Future<void> _lower(BuildContext context, GameDifficulty round) async {
    final l10n = AppLocalizations.of(context);
    final GameSettingsCubit games = context.read<GameSettingsCubit>();
    final ParentsProgressCubit cubit = context.read<ParentsProgressCubit>();
    final String gameName = ParentsGamesTexts.game(l10n, game);
    final String roundName = RoundStyle.roundName(l10n, round);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const ValueKey<String>('progress-lower-dialog'),
        content: Text(l10n.parentsProgressLowerConfirm(gameName, roundName)),
        actions: [
          TextButton(
            key: const ValueKey<String>('progress-lower-cancel'),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.parentsProgressCancel),
          ),
          FilledButton(
            key: const ValueKey<String>('progress-lower-confirm'),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.parentsProgressLowerButton(roundName)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    // Lo mismo que cambiar la ronda en «Juegos» (HU-037 R5): sin perder logros.
    await games.setRound(game, round);
    await cubit.load();
  }

  Future<void> _playWithoutTime(BuildContext context) async {
    final ParentsProgressCubit cubit = context.read<ParentsProgressCubit>();
    await context.read<GameSettingsCubit>().setTimerDisabled(true);
    await cubit.dismiss(game);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final GameSettingsState settings = context.watch<GameSettingsCubit>().state;
    final GameDifficulty? previous = progress.position.round.previousRound;
    // En bronce no hay ronda más baja: «Jugar sin tiempo» si está disponible;
    // si no, nada (§4.5).
    final bool offerNoTime = previous == null && settings.isPremium && !settings.timerDisabled;
    if (previous == null && !offerNoTime) return const SizedBox.shrink();
    final String body = previous == null
        ? l10n.parentsProgressStuckNoTime
        : l10n.parentsProgressStuckLower(RoundStyle.roundName(l10n, previous));

    return Card(
      key: ValueKey<String>('progress-suggestion-${game.name}'),
      color: AppPalette.warmCream,
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.parentsProgressStuckTitle(ParentsGamesTexts.game(l10n, game)),
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppPalette.deepTeal)),
            const SizedBox(height: 4),
            Text(body, style: theme.textTheme.bodyMedium?.copyWith(color: AppPalette.deepTeal)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: ValueKey<String>('progress-suggestion-act-${game.name}'),
                  onPressed: () => previous == null ? _playWithoutTime(context) : _lower(context, previous),
                  child: Text(previous == null
                      ? l10n.parentsZoneNoTimeTitle
                      : l10n.parentsProgressLowerButton(RoundStyle.roundName(l10n, previous))),
                ),
                TextButton(
                  key: ValueKey<String>('progress-suggestion-dismiss-${game.name}'),
                  onPressed: () => context.read<ParentsProgressCubit>().dismiss(game),
                  child: Text(l10n.parentsProgressNotNow),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
