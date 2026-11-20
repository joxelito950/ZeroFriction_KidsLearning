import 'package:flutter/material.dart';

import '../../domain/parental/rest_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import 'adult_session_guard.dart';

/// Si las horas se muestran en 24 horas (HU-038 P1): con el teléfono en 24
/// horas, o si el idioma escribe así las horas (español, francés, alemán…).
/// El selector de hora de Flutter usa el formato del idioma en la esfera pero
/// el del teléfono al escribir: en español con el teléfono en a. m./p. m. no
/// dejaba escribir las 15:00 (visto en el moto g55 el 2026-11-19). Por eso la
/// pantalla y el selector usan siempre este mismo formato.
bool use24HourTimes(BuildContext context) =>
    MediaQuery.alwaysUse24HourFormatOf(context) ||
    hourFormat(of: MaterialLocalizations.of(context).timeOfDayFormat()) != HourFormat.h;

/// Una hora del día en el formato de [use24HourTimes].
String formatDayMinute(BuildContext context, int minute) {
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
    alwaysUse24HourFormat: use24HourTimes(context),
  );
}

/// La frase amable que explica por qué no se puede guardar (R7, R7a).
String restProblemText(AppLocalizations l10n, RestScheduleProblem problem) => switch (problem) {
      RestScheduleProblem.sameTimes => l10n.parentsRestProblemSameTimes,
      RestScheduleProblem.napLength => l10n.parentsRestProblemNapLength,
      RestScheduleProblem.napCrossesMidnight => l10n.parentsRestProblemNapMidnight,
      RestScheduleProblem.tooClose => l10n.parentsRestProblemTooClose,
    };

/// La parte «Hora de dormir» de la pantalla «Tiempo de juego» (HU-038 §3.1):
/// primero la recomendación del sistema, después la de sueño de la OMS y,
/// como refuerzo, el horario de la app con hasta dos siestas. Edita un
/// borrador; lo guarda la pantalla con su «Guardar».
class ParentsBedtimeEditor extends StatelessWidget {
  const ParentsBedtimeEditor({super.key, required this.schedule, required this.onChanged});

  final RestSchedule schedule;
  final ValueChanged<RestSchedule> onChanged;

  Future<int?> _pick(BuildContext context, int minute) async {
    final bool use24 = use24HourTimes(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minute ~/ 60, minute: minute % 60),
      // El selector es otra ruta: sus toques también mantienen abierta la
      // Zona de Padres (HU-004 R7). Sin esto, elegir la hora con calma la
      // cerraba al minuto (visto en el moto g55 el 2026-11-19).
      builder: (context, child) => Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => AdultSessionGuard.registerActivity(),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24),
          child: child!,
        ),
      ),
    );
    return picked == null ? null : picked.hour * 60 + picked.minute;
  }

  Future<void> _editNight(BuildContext context, {required bool start}) async {
    final RestWindow night = schedule.night!;
    final int? minute = await _pick(context, start ? night.from : night.until);
    if (minute == null) return;
    onChanged(schedule.withNight(start ? night.copyWith(from: minute) : night.copyWith(until: minute)));
  }

  Future<void> _editNap(BuildContext context, int index, {required bool start}) async {
    final RestWindow nap = schedule.naps[index];
    final int? minute = await _pick(context, start ? nap.from : nap.until);
    if (minute == null) return;
    final List<RestWindow> naps = [...schedule.naps];
    naps[index] = start ? nap.copyWith(from: minute) : nap.copyWith(until: minute);
    onChanged(schedule.withNaps(naps));
  }

  void _toggleNaps(bool on) {
    if (!on) return onChanged(schedule.withNaps(const []));
    onChanged(schedule.withNaps([schedule.suggestedNap() ?? RestSchedule.defaultNap]));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final RestWindow? night = schedule.night;
    final RestScheduleProblem? problem = schedule.problem;
    final RestWindow? suggested = schedule.suggestedNap();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.parentsBedtimeTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(l10n.parentsBedtimeSystem, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 12),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AppPalette.amber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(l10n.parentsBedtimeWho, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          key: const ValueKey<String>('bedtime-enable'),
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.bedtime_rounded),
          title: Text(l10n.parentsBedtimeEnable),
          value: night != null,
          onChanged: (on) => onChanged(schedule.withNight(on ? RestSchedule.defaultNight : null)),
        ),
        if (night != null) ...[
          _TimeRow(
            fromKey: const ValueKey<String>('bedtime-from'),
            untilKey: const ValueKey<String>('bedtime-until'),
            window: night,
            onFrom: () => _editNight(context, start: true),
            onUntil: () => _editNight(context, start: false),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.parentsBedtimeSummary(formatDayMinute(context, night.from), formatDayMinute(context, night.until)),
            key: const ValueKey<String>('bedtime-summary'),
            style: theme.textTheme.bodyMedium,
          ),
        ],
        const SizedBox(height: 8),
        SwitchListTile(
          key: const ValueKey<String>('naps-enable'),
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.wb_twilight_rounded),
          title: Text(l10n.parentsNapsEnable),
          value: schedule.naps.isNotEmpty,
          onChanged: _toggleNaps,
        ),
        for (final (index, nap) in schedule.naps.indexed) ...[
          Row(
            children: [
              Expanded(child: Text(l10n.parentsNapLabel(index + 1), style: theme.textTheme.titleSmall)),
              if (index > 0)
                TextButton.icon(
                  key: ValueKey<String>('nap-$index-remove'),
                  onPressed: () => onChanged(schedule.withNaps([...schedule.naps]..removeAt(index))),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                  label: Text(l10n.parentsNapRemove),
                ),
            ],
          ),
          _TimeRow(
            fromKey: ValueKey<String>('nap-$index-from'),
            untilKey: ValueKey<String>('nap-$index-until'),
            window: nap,
            onFrom: () => _editNap(context, index, start: true),
            onUntil: () => _editNap(context, index, start: false),
          ),
          const SizedBox(height: 8),
        ],
        if (schedule.naps.isNotEmpty && schedule.naps.length < RestSchedule.maxNaps && problem == null)
          TextButton.icon(
            key: const ValueKey<String>('nap-add'),
            onPressed: suggested == null ? null : () => onChanged(schedule.withNaps([...schedule.naps, suggested])),
            icon: const Icon(Icons.add_rounded),
            label: Text(l10n.parentsNapAdd),
          ),
        if (problem != null) ...[
          const SizedBox(height: 8),
          // Sin rojo: la misma frase tranquila que el rango del límite (R1c).
          Text(
            restProblemText(l10n, problem),
            key: const ValueKey<String>('rest-problem'),
            style: theme.textTheme.bodyMedium?.copyWith(color: AppPalette.deepTeal, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}

/// «Desde» y «Hasta» de un descanso, cada uno abre el selector de hora del
/// sistema.
class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.fromKey,
    required this.untilKey,
    required this.window,
    required this.onFrom,
    required this.onUntil,
  });

  final Key fromKey;
  final Key untilKey;
  final RestWindow window;
  final VoidCallback onFrom;
  final VoidCallback onUntil;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _TimeButton(buttonKey: fromKey, label: l10n.parentsBedtimeFrom, minute: window.from, onPressed: onFrom),
        _TimeButton(buttonKey: untilKey, label: l10n.parentsBedtimeUntil, minute: window.until, onPressed: onUntil),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({required this.buttonKey, required this.label, required this.minute, required this.onPressed});

  final Key buttonKey;
  final String label;
  final int minute;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      key: buttonKey,
      onPressed: onPressed,
      child: Text('$label  ${formatDayMinute(context, minute)}'),
    );
  }
}
