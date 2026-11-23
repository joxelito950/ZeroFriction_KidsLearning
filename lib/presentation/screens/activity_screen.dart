import 'package:flutter/material.dart';

import '../../domain/activities/activity.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/off_play_time.dart';

/// La pantalla de una actividad sin pantallas (HU-047 D3): título; categoría,
/// minutos y edad; qué practica; su propia advertencia (D6); materiales; pasos
/// numerados; variantes y, al final, las 3 para seguir jugando (P11), que abren
/// su propia pantalla. Es para el adulto: no cuenta como tiempo de juego (P9)
/// y se abre sin desafío (P8).
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key, required this.activity, required this.library});

  final Activity activity;

  /// Para elegir las recomendadas.
  final ActivityLibrary library;

  static Future<void> open(BuildContext context, Activity activity, ActivityLibrary library) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ActivityScreen(activity: activity, library: library)),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final TextStyle? heading = theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
    final List<Activity> recommended = library.recommendedFor(activity);

    // La clave va en el encabezado de cada parte.
    Widget section(String title, Widget body, {required String key}) => Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Text(title, key: ValueKey<String>(key), style: heading), const SizedBox(height: 8), body],
          ),
        );

    return OffPlayTime(
      child: Scaffold(
        key: ValueKey<String>('activity-screen-${activity.id}'),
        appBar: AppBar(title: Text(l10n.activitiesTitle)),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Text(
                activity.title,
                key: const ValueKey<String>('activity-title'),
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                '${activityMeta(l10n, activity)} · ${l10n.activitiesFromAge(activity.ageFrom)}',
                key: const ValueKey<String>('activity-meta'),
                style: theme.textTheme.bodyLarge?.copyWith(color: AppPalette.petrolBlue, fontWeight: FontWeight.w600),
              ),
              section(l10n.activitiesGoal, Text(activity.goal, style: theme.textTheme.bodyLarge), key: 'activity-goal'),
              const SizedBox(height: 20),
              ActivityNotice(
                key: const ValueKey<String>('activity-safety'),
                title: l10n.activitiesSafety,
                text: activity.safety,
              ),
              section(
                l10n.activitiesMaterials,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final String material in activity.materials) _Bullet(text: material)],
                ),
                key: 'activity-materials',
              ),
              section(
                l10n.activitiesSteps,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final (index, step) in activity.steps.indexed) _NumberedStep(number: index + 1, text: step),
                  ],
                ),
                key: 'activity-steps',
              ),
              section(
                l10n.activitiesVariants,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final String variant in activity.variants) _Bullet(text: variant)],
                ),
                key: 'activity-variants',
              ),
              if (recommended.isNotEmpty)
                section(
                  l10n.activitiesKeepPlaying,
                  Column(
                    children: [
                      for (final Activity other in recommended) ActivityCard(activity: other, library: library),
                    ],
                  ),
                  key: 'activity-keep-playing',
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Un material o una variante, con un punto delante.
class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.only(top: 9, end: 10, start: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppPalette.petrolBlue, shape: BoxShape.circle),
              child: SizedBox.square(dimension: 6),
            ),
          ),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}

/// Un paso, con su número en un círculo.
class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: AppPalette.petrolBlue,
            child: Text(
              '$number',
              textScaler: TextScaler.noScaling,
              style: const TextStyle(color: AppPalette.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
