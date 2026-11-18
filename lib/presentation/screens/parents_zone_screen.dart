import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/app_locale/app_locale_cubit.dart';
import '../blocs/game_settings/game_settings_cubit.dart';
import '../blocs/parents_progress/parents_progress_cubit.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../theme/app_palette.dart';
import '../widgets/adult_session_guard.dart';
import '../widgets/parents_feedback_section.dart';
import '../widgets/parents_games_section.dart';
import '../widgets/parents_language_section.dart';
import '../widgets/parents_play_time_section.dart';
import '../widgets/parents_progress_page.dart';
import '../widgets/parents_privacy_section.dart';
import '../widgets/parents_setting_page.dart';
import '../widgets/parents_sound_section.dart';

/// Zona de Padres (HU-004), a la que solo se llega superando el desafío. Desde
/// HU-046 es una lista de filas con lo elegido en cada opción; las que tienen
/// más de un control abren su pantalla, un solo nivel por debajo. El «atrás»
/// del sistema vuelve al menú (P5). Se cierra sola al pasar a segundo plano o
/// tras 1 minuto sin tocarla (R7).
class ParentsZoneScreen extends StatelessWidget {
  const ParentsZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final IPersistenceRepository? repository = context.read<IPersistenceRepository?>();
    final Widget zone = AdultSessionGuard(child: const _ParentsZoneList());
    if (repository == null) return zone;
    // Los ajustes de los juegos se leen una vez: dan el resumen de la fila y
    // los usa su pantalla.
    return MultiBlocProvider(
      providers: [
        BlocProvider<GameSettingsCubit>(create: (_) => GameSettingsCubit(repository: repository)..load()),
        // El progreso de cada juego, para la fila y la pantalla «Su progreso» (HU-034).
        BlocProvider<ParentsProgressCubit>(create: (_) => ParentsProgressCubit(repository: repository)..load()),
      ],
      child: zone,
    );
  }
}

class _ParentsZoneList extends StatelessWidget {
  const _ParentsZoneList();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final GameSettingsCubit? games = context.read<GameSettingsCubit?>();
    final ParentsProgressCubit? progress = context.read<ParentsProgressCubit?>();
    final PlayTimeCubit? playTime = context.read<PlayTimeCubit?>();
    final String language = context.watch<AppLocaleCubit>().state.languageCode;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.parentsZoneTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: FilledButton.tonalIcon(
                key: const ValueKey<String>('parents-zone-back-to-menu'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.home_rounded),
                label: Text(l10n.parentsZoneBackToMenu),
              ),
            ),
            if (playTime != null) _ExtraTime(cubit: playTime),
            const SizedBox(height: 16),
            // «Su progreso», la primera fila (HU-034 §3, HU-046 P1).
            if (progress != null && games != null)
              BlocBuilder<ParentsProgressCubit, ParentsProgressState>(
                bloc: progress,
                builder: (context, state) => ParentsSettingRow(
                  key: const ValueKey<String>('parents-row-progress'),
                  icon: Icons.emoji_events_outlined,
                  title: l10n.parentsProgressTitle,
                  summary: parentsProgressRowSummary(l10n, progressSummaryOf(context, state)),
                  dot: state.hasSuggestion,
                  onTap: () => ParentsSettingPage.open(
                    context,
                    MultiBlocProvider(
                      providers: [
                        BlocProvider<ParentsProgressCubit>.value(value: progress),
                        BlocProvider<GameSettingsCubit>.value(value: games),
                      ],
                      child: const ParentsProgressPage(),
                    ),
                  ),
                ),
              ),
            ParentsSettingRow(
              key: const ValueKey<String>('parents-row-language'),
              icon: Icons.translate_rounded,
              title: l10n.parentsZoneLanguageTitle,
              summary: AppLanguage.nativeNames[language] ?? language,
              onTap: () => ParentsSettingPage.open(context, const ParentsLanguagePage()),
            ),
            // Sonido (HU-005): un solo interruptor, se cambia en la fila (HU-046 R1).
            const ParentsSoundSection(),
            if (games != null)
              BlocBuilder<GameSettingsCubit, GameSettingsState>(
                bloc: games,
                builder: (context, state) => ParentsSettingRow(
                  key: const ValueKey<String>('parents-row-games'),
                  icon: Icons.extension_outlined,
                  title: l10n.parentsZoneGamesTitle,
                  summary: ParentsGamesTexts.summary(l10n, state),
                  // Cambiar la ronda cambia lo que muestra «Su progreso».
                  onTap: () => ParentsSettingPage.open(
                    context,
                    BlocProvider<GameSettingsCubit>.value(value: games, child: const ParentsGamesPage()),
                  ).then((_) => progress?.load()),
                ),
              ),
            if (playTime != null)
              BlocBuilder<PlayTimeCubit, PlayTimeState>(
                bloc: playTime,
                buildWhen: (previous, current) => previous.limitMinutes != current.limitMinutes,
                builder: (context, state) => ParentsSettingRow(
                  key: const ValueKey<String>('parents-row-play-time'),
                  icon: Icons.timer_outlined,
                  title: l10n.parentsZonePlayTimeTitle,
                  summary: parentsPlayTimeSummary(l10n, state.limitMinutes),
                  onTap: () => ParentsSettingPage.open(context, const ParentsPlayTimePage()),
                ),
              ),
            ParentsSettingRow(
              key: const ValueKey<String>('parents-row-pin'),
              icon: Icons.push_pin_outlined,
              title: l10n.parentsZonePinTitle,
              summary: l10n.parentsZonePinSummary,
              onTap: () => ParentsSettingPage.open(context, const _ScreenPinningPage()),
            ),
            // Ayuda y comentarios (HU-032), antes de la privacidad (P3).
            ParentsSettingRow(
              key: const ValueKey<String>('parents-row-feedback'),
              icon: Icons.mail_outline_rounded,
              title: l10n.parentsFeedbackTitle,
              summary: l10n.parentsFeedbackSummary,
              onTap: () => ParentsSettingPage.open(context, const ParentsFeedbackPage()),
            ),
            // Se despliega aquí mismo: leerla cuenta como actividad (HU-014 R5).
            const ParentsPrivacySection(),
          ],
        ),
      ),
    );
  }
}

/// «15 minutos más» (HU-009 R6): arriba de la Zona de Padres, solo cuando el
/// niño ya no puede jugar hoy, que es cuando el adulto lo busca (HU-046 §4.1).
class _ExtraTime extends StatelessWidget {
  const _ExtraTime({required this.cubit});

  final PlayTimeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<PlayTimeCubit, PlayTimeState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.limitMinutes == null || !state.limitReached) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 16),
          child: FilledButton.icon(
            key: const ValueKey<String>('play-time-extra'),
            onPressed: cubit.grantExtra,
            icon: const Icon(Icons.more_time_rounded),
            label: Text(l10n.parentsZonePlayTimeExtra),
          ),
        );
      },
    );
  }
}

/// «Fijar pantalla» de Android (parte informativa de HU-009; el botón es HU-020): mantiene el
/// teléfono en la app, porque inicio y recientes no se pueden bloquear (HU-001 T5).
/// Pantalla de solo lectura (HU-046 R6).
class _ScreenPinningPage extends StatelessWidget {
  const _ScreenPinningPage();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = [l10n.parentsZonePinStep1, l10n.parentsZonePinStep2, l10n.parentsZonePinStep3];

    return ParentsSettingPage(
      key: const ValueKey<String>('parents-zone-screen-pinning'),
      title: l10n.parentsZonePinTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.parentsZonePinIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 12),
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Número blanco sobre azul petróleo (6,16:1): sobre el color por
                  // defecto del tema apenas se leía (visto en el moto g55).
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppPalette.petrolBlue,
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelMedium?.copyWith(color: AppPalette.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
                ],
              ),
            ),
          Text(
            l10n.parentsZonePinNote,
            style: theme.textTheme.bodySmall?.copyWith(color: AppPalette.deepTeal),
          ),
        ],
      ),
    );
  }
}
