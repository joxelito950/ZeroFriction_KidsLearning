import 'dart:async';

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../screens/parental_gate_screen.dart';
import '../theme/app_palette.dart';
import 'quiet_hint.dart';

/// Acceso a la Zona de Padres con doble toque (HU-004 R1, D-029): el primer
/// toque solo muestra un aviso pequeño, sin botones; el segundo, dentro de
/// [tapWindow], abre el desafío. Lo usan el menú y la pantalla de descanso.
class ParentsZoneButton extends StatefulWidget {
  const ParentsZoneButton({super.key, this.buttonKey = const ValueKey<String>('menu-parents-zone')});

  /// Tiempo para el segundo toque (HU-004 S5).
  static const Duration tapWindow = Duration(seconds: 2);

  final Key buttonKey;

  @override
  State<ParentsZoneButton> createState() => _ParentsZoneButtonState();
}

class _ParentsZoneButtonState extends State<ParentsZoneButton> {
  final OverlayPortalController _tapAgainHint = OverlayPortalController();
  Timer? _window;

  void _onTap() {
    if (_window?.isActive ?? false) {
      _window?.cancel();
      _tapAgainHint.hide();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ParentalGateScreen()),
      );
      return;
    }
    _tapAgainHint.show();
    _window = Timer(ParentsZoneButton.tapWindow, () {
      if (mounted) _tapAgainHint.hide();
    });
  }

  @override
  void dispose() {
    _window?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    // El aviso va en la capa superior para quedar al pie de la pantalla, como el de salida.
    return OverlayPortal(
      controller: _tapAgainHint,
      overlayChildBuilder: (_) => QuietHint(
        key: const ValueKey<String>('parents-zone-tap-again-hint'),
        text: l10n.parentsZoneTapAgainHint,
        helperText: (helper) => helper.parentsZoneTapAgainHint,
      ),
      child: TextButton.icon(
        key: widget.buttonKey,
        onPressed: _onTap,
        icon: const Icon(Icons.security, size: 18),
        label: Text(l10n.menuParentsZone),
        style: TextButton.styleFrom(foregroundColor: AppPalette.petrolBlue),
      ),
    );
  }
}
