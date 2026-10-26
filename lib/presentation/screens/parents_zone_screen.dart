import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../widgets/adult_session_guard.dart';

/// Zona de Padres (HU-004), a la que solo se llega superando el desafío. Cada
/// sección llega con su historia (P4); el «atrás» del sistema vuelve al menú (P5).
/// Se cierra sola al pasar a segundo plano o tras 1 minuto sin tocarla (R7).
class ParentsZoneScreen extends StatelessWidget {
  const ParentsZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AdultSessionGuard(
      child: Scaffold(
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
              const SizedBox(height: 16),
              const _ScreenPinningSection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Fijar pantalla» de Android (parte informativa de HU-009): mantiene el
/// teléfono en la app, porque inicio y recientes no se pueden bloquear (HU-001 T5).
class _ScreenPinningSection extends StatelessWidget {
  const _ScreenPinningSection();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = [l10n.parentsZonePinStep1, l10n.parentsZonePinStep2, l10n.parentsZonePinStep3];

    return Card(
      key: const ValueKey<String>('parents-zone-screen-pinning'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.push_pin_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.parentsZonePinTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.parentsZonePinIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            for (final (index, step) in steps.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 12, child: Text('${index + 1}', style: theme.textTheme.labelMedium)),
                    const SizedBox(width: 12),
                    Expanded(child: Text(step, style: theme.textTheme.bodyMedium)),
                  ],
                ),
              ),
            Text(
              l10n.parentsZonePinNote,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.blueGrey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
