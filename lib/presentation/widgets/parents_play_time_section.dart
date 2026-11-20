import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/parental_settings.dart';
import '../../domain/parental/rest_schedule.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../theme/app_palette.dart';
import 'parents_bedtime_editor.dart';
import 'parents_setting_page.dart';

/// Resumen de la fila «Tiempo de juego» (HU-046 §4.1).
String parentsPlayTimeSummary(AppLocalizations l10n, int? limitMinutes) =>
    limitMinutes == null ? l10n.parentsZonePlayTimeNoLimit : l10n.parentsZonePlayTimePerDay(limitMinutes);

/// El resumen con la hora de dormir: «60 min al día · Dormir de 19:30 a 7:00»
/// (HU-038 §3.1).
String parentsPlayTimeRowSummary(BuildContext context, PlayTimeState state) {
  final l10n = AppLocalizations.of(context);
  final String limit = parentsPlayTimeSummary(l10n, state.limitMinutes);
  final RestWindow? night = state.schedule.night;
  if (night == null) return limit;
  final String bedtime =
      l10n.parentsBedtimeRowSummary(formatDayMinute(context, night.from), formatDayMinute(context, night.until));
  return '$limit · $bedtime';
}

/// Pantalla «Tiempo de juego» (HU-009 R1, HU-046): primero los controles
/// parentales del sistema, después la recomendación de la OMS y, para
/// reforzarlos, el límite diario de la app; debajo, la hora de dormir y las
/// siestas (HU-038). Se elige un borrador y se aplica con «Guardar»; los «15
/// minutos más» están arriba de la Zona de Padres.
class ParentsPlayTimePage extends StatefulWidget {
  const ParentsPlayTimePage({super.key});

  @override
  State<ParentsPlayTimePage> createState() => _ParentsPlayTimePageState();
}

class _ParentsPlayTimePageState extends State<ParentsPlayTimePage> {
  final TextEditingController _custom = TextEditingController();
  late int? _limit;
  late bool _customSelected;
  late RestSchedule _schedule;
  bool _customInvalid = false;

  /// El adulto ya ha tocado algo: el borrador es suyo.
  bool _touched = false;
  String _lastText = '';

  @override
  void initState() {
    super.initState();
    final PlayTimeState state = context.read<PlayTimeCubit>().state;
    _resetTo(state.limitMinutes);
    _schedule = state.schedule;
    _custom.addListener(_onCustomChanged);
  }

  void _resetTo(int? limit) {
    _limit = limit;
    _customSelected = !_isPreset(limit);
    _custom.text = _customSelected ? '$limit' : '';
    _lastText = _custom.text;
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  /// Escribir otra cifra quita el resaltado; perder el foco (al tocar
  /// «Guardar») también avisa al controlador, pero no cambia el texto.
  void _onCustomChanged() {
    if (_custom.text == _lastText) return;
    _lastText = _custom.text;
    setState(() {
      _touched = true;
      _customInvalid = false;
    });
  }

  static bool _isPreset(int? limit) => limit == null || ParentalSettings.presetLimitMinutes.contains(limit);

  /// El límite elegido; con «Personalizado», lo escrito (`null` si no es un número).
  int? get _chosen => _customSelected ? int.tryParse(_custom.text) : _limit;

  bool _limitDirty(int? saved) => _customSelected ? _custom.text.isNotEmpty && _chosen != saved : _limit != saved;

  bool _dirty(PlayTimeState state) => _limitDirty(state.limitMinutes) || _schedule != state.schedule;

  void _changeSchedule(RestSchedule schedule) => setState(() {
        _touched = true;
        _schedule = schedule;
      });

  void _choose(int? minutes) => setState(() {
        _touched = true;
        _customSelected = false;
        _customInvalid = false;
        _limit = minutes;
      });

  void _openCustom() => setState(() {
        _touched = true;
        _customSelected = true;
        if (_custom.text.isEmpty && _limit != null) _custom.text = '$_limit';
      });

  /// Un valor fuera de 5–720 no se guarda: se resalta el rango, sin tono de
  /// error (R1c), y la pantalla sigue abierta. Un horario que no cumple R7 o
  /// R7a tampoco: su frase ya está a la vista (HU-038).
  Future<bool> _save() async {
    final int? minutes = _chosen;
    if (_customSelected && (minutes == null || !ParentalSettings.isValidLimit(minutes))) {
      setState(() => _customInvalid = true);
      return false;
    }
    if (!_schedule.isValid) return false;
    final PlayTimeCubit cubit = context.read<PlayTimeCubit>();
    await cubit.setLimit(minutes);
    if (_schedule != cubit.state.schedule) await cubit.setSchedule(_schedule);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocConsumer<PlayTimeCubit, PlayTimeState>(
      // El límite guardado llega después de abrir (se lee al arrancar) o cambia
      // desde fuera: si el adulto aún no ha tocado nada, el borrador lo sigue.
      listenWhen: (previous, current) =>
          previous.limitMinutes != current.limitMinutes || previous.schedule != current.schedule,
      listener: (context, state) {
        if (_touched) return;
        setState(() {
          _resetTo(state.limitMinutes);
          _schedule = state.schedule;
        });
      },
      builder: (context, state) {
        final int? saved = state.limitMinutes;
        return ParentsSettingPage(
          key: const ValueKey<String>('parents-zone-play-time'),
          title: l10n.parentsZonePlayTimeTitle,
          dirty: _dirty(state),
          onSave: _save,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.parentsZonePlayTimeSystemFirst, style: theme.textTheme.bodyMedium),
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
                      Expanded(child: Text(l10n.parentsZonePlayTimeWho, style: theme.textTheme.bodySmall)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n.parentsZonePlayTimeLimitLabel, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    key: const ValueKey<String>('play-time-limit-none'),
                    label: Text(l10n.parentsZonePlayTimeNoLimit),
                    selected: _limit == null && !_customSelected,
                    onSelected: (_) => _choose(null),
                  ),
                  for (final minutes in ParentalSettings.presetLimitMinutes)
                    ChoiceChip(
                      key: ValueKey<String>('play-time-limit-$minutes'),
                      label: Text(l10n.parentsZonePlayTimeMinutes(minutes)),
                      selected: _limit == minutes && !_customSelected,
                      onSelected: (_) => _choose(minutes),
                    ),
                  ChoiceChip(
                    key: const ValueKey<String>('play-time-limit-custom'),
                    label: Text(l10n.parentsZonePlayTimeCustom),
                    selected: _customSelected,
                    onSelected: (_) => _openCustom(),
                  ),
                ],
              ),
              if (_customSelected) ...[
                const SizedBox(height: 12),
                _CustomLimitField(controller: _custom, invalid: _customInvalid),
              ],
              if (saved != null) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.parentsZonePlayTimeToday(
                    state.today.played.inMinutes,
                    state.today.allowance(saved)!.inMinutes,
                  ),
                  key: const ValueKey<String>('play-time-today'),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
              const Divider(height: 40),
              ParentsBedtimeEditor(schedule: _schedule, onChanged: _changeSchedule),
            ],
          ),
        );
      },
    );
  }
}

/// Minutos personalizados: solo cifras; el rango se muestra siempre y, si el
/// valor no vale, se resalta en negrita, sin rojo (R1c). Se aplica con «Guardar».
class _CustomLimitField extends StatelessWidget {
  const _CustomLimitField({required this.controller, required this.invalid});

  final TextEditingController controller;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: const ValueKey<String>('play-time-custom-field'),
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
          decoration: InputDecoration(
            labelText: l10n.parentsZonePlayTimeCustomField,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.parentsZonePlayTimeCustomRange,
          key: const ValueKey<String>('play-time-custom-range'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppPalette.deepTeal,
            fontWeight: invalid ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
