import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Zona de Padres (HU-004), a la que solo se llega superando el desafío. Cada
/// sección llega con su historia (P4); el «atrás» del sistema vuelve al menú (P5).
class ParentsZoneScreen extends StatelessWidget {
  const ParentsZoneScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          ],
        ),
      ),
    );
  }
}
