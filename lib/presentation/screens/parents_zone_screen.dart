import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/adult_session_guard.dart';
import '../widgets/parents_feedback_section.dart';
import '../widgets/parents_games_section.dart';
import '../widgets/parents_language_section.dart';
import '../widgets/parents_play_time_section.dart';
import '../widgets/parents_privacy_section.dart';
import '../widgets/parents_sound_section.dart';

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
              const ParentsLanguageSection(),
              const SizedBox(height: 16),
              // Sonido (HU-005): junto al idioma, lo que se oye y lo que se lee.
              const ParentsSoundSection(),
              const SizedBox(height: 16),
              const ParentsGamesSection(),
              const SizedBox(height: 16),
              const ParentsPlayTimeSection(),
              const SizedBox(height: 16),
              const _ScreenPinningSection(),
              const SizedBox(height: 16),
              // Ayuda y comentarios (HU-032), antes de la privacidad (P3).
              const ParentsFeedbackSection(),
              const SizedBox(height: 16),
              const ParentsPrivacySection(),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Fijar pantalla» de Android (parte informativa de HU-009; el botón es HU-020): mantiene el
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
      ),
    );
  }
}
