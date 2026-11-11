import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../blocs/sound/sound_cubit.dart';

/// Interruptor «Sonido» de la Zona de Padres (HU-005 R4): se aplica al instante
/// y se guarda. Sin el sonido disponible (algunos tests), no se muestra.
class ParentsSoundSection extends StatelessWidget {
  const ParentsSoundSection({super.key});

  @override
  Widget build(BuildContext context) {
    final SoundCubit? sound = context.read<SoundCubit?>();
    if (sound == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<SoundCubit, bool>(
      bloc: sound,
      builder: (context, enabled) => Card(
        key: const ValueKey<String>('parents-zone-sound'),
        child: SwitchListTile(
          key: const ValueKey<String>('parents-zone-sound-switch'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          secondary: Icon(enabled ? Icons.volume_up_rounded : Icons.volume_off_rounded),
          title: Text(
            l10n.parentsZoneSoundTitle,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(l10n.parentsZoneSoundHint),
          value: enabled,
          onChanged: sound.setEnabled,
        ),
      ),
    );
  }
}
