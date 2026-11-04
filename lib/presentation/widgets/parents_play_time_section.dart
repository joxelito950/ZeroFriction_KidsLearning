import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/parental_settings.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../theme/app_palette.dart';

/// «Tiempo de juego» en la Zona de Padres (HU-009 R1): primero los controles
/// parentales del sistema, después la recomendación de la OMS y, para
/// reforzarlos, el límite diario de la app y los 15 minutos más (R6). Los
/// cambios se aplican al instante (R7).
class ParentsPlayTimeSection extends StatefulWidget {
  const ParentsPlayTimeSection({super.key});

  @override
  State<ParentsPlayTimeSection> createState() => _ParentsPlayTimeSectionState();
}

class _ParentsPlayTimeSectionState extends State<ParentsPlayTimeSection> {
  final TextEditingController _custom = TextEditingController();
  bool _customOpen = false;
  bool _customInvalid = false;

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _choose(int? minutes) {
    setState(() {
      _customOpen = false;
      _customInvalid = false;
    });
    context.read<PlayTimeCubit>().setLimit(minutes);
  }

  void _openCustom(int? current) {
    setState(() {
      _customOpen = true;
      _customInvalid = false;
      if (current != null) _custom.text = '$current';
    });
  }

  /// Un valor fuera de 5–720 no se aplica; se repite el rango sin tono de error (R1c).
  void _applyCustom() {
    final int? minutes = int.tryParse(_custom.text);
    if (minutes == null || !ParentalSettings.isValidLimit(minutes)) {
      setState(() => _customInvalid = true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _customInvalid = false);
    context.read<PlayTimeCubit>().setLimit(minutes);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cubit = context.read<PlayTimeCubit?>();
    if (cubit == null) return const SizedBox.shrink();

    return BlocBuilder<PlayTimeCubit, PlayTimeState>(
      bloc: cubit,
      builder: (context, state) {
        final int? limit = state.limitMinutes;
        final bool isPreset = limit == null || ParentalSettings.presetLimitMinutes.contains(limit);
        final bool customSelected = _customOpen || !isPreset;

        return Card(
          key: const ValueKey<String>('parents-zone-play-time'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.timer_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.parentsZonePlayTimeTitle,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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
                      selected: limit == null && !customSelected,
                      onSelected: (_) => _choose(null),
                    ),
                    for (final minutes in ParentalSettings.presetLimitMinutes)
                      ChoiceChip(
                        key: ValueKey<String>('play-time-limit-$minutes'),
                        label: Text(l10n.parentsZonePlayTimeMinutes(minutes)),
                        selected: limit == minutes && !customSelected,
                        onSelected: (_) => _choose(minutes),
                      ),
                    ChoiceChip(
                      key: const ValueKey<String>('play-time-limit-custom'),
                      label: Text(l10n.parentsZonePlayTimeCustom),
                      selected: customSelected,
                      onSelected: (_) => _openCustom(limit),
                    ),
                  ],
                ),
                if (customSelected) ...[
                  const SizedBox(height: 12),
                  _CustomLimitField(
                    controller: _custom,
                    invalid: _customInvalid,
                    onApply: _applyCustom,
                  ),
                ],
                if (limit != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    l10n.parentsZonePlayTimeToday(
                      state.today.played.inMinutes,
                      state.today.allowance(limit)!.inMinutes,
                    ),
                    key: const ValueKey<String>('play-time-today'),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    key: const ValueKey<String>('play-time-extra'),
                    onPressed: cubit.grantExtra,
                    icon: const Icon(Icons.more_time_rounded),
                    label: Text(l10n.parentsZonePlayTimeExtra),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Minutos personalizados: solo cifras; el rango se muestra siempre y, si el
/// valor no vale, se resalta en negrita, sin rojo (R1c).
class _CustomLimitField extends StatelessWidget {
  const _CustomLimitField({required this.controller, required this.invalid, required this.onApply});

  final TextEditingController controller;
  final bool invalid;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En columna: con el texto ampliado, el botón al lado no dejaba sitio al campo.
        TextField(
          key: const ValueKey<String>('play-time-custom-field'),
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
          decoration: InputDecoration(
            labelText: l10n.parentsZonePlayTimeCustomField,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (_) => onApply(),
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
        const SizedBox(height: 8),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: FilledButton(
            key: const ValueKey<String>('play-time-custom-apply'),
            onPressed: onApply,
            child: Text(l10n.parentsZonePlayTimeCustomApply),
          ),
        ),
      ],
    );
  }
}
