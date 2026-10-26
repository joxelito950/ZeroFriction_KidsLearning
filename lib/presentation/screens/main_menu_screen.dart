import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../widgets/protected_exit.dart';
import '../widgets/quiet_hint.dart';
import 'memory_game_screen.dart';
import 'parental_gate_screen.dart';

/// Menú principal súper visual y simplificado para niños de 3 años.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  /// Tiempo para el segundo toque en «Zona de Padres» (HU-004 R1, S5).
  static const Duration parentsZoneTapWindow = Duration(seconds: 2);

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  /// Cierra la app; el gesto «atrás» del menú pide repetirlo antes (HU-001 R19).
  static void _closeApp() => SystemNavigator.pop();

  @override
  Widget build(BuildContext context) {
    return ProtectedExit(
      onExit: _closeApp,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // En horizontal el alto útil es muy bajo: encabezado y botones van lado a lado.
              final bool isLandscape = constraints.maxWidth > constraints.maxHeight;

              // El scroll es solo una red de seguridad para pantallas muy pequeñas;
              // el mínimo de alto mantiene el contenido centrado cuando sí cabe.
              return SingleChildScrollView(
                padding: _padding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - _padding.vertical,
                  ),
                  child: isLandscape
                      ? const Row(
                          children: [
                            Expanded(child: _MenuHeader()),
                            SizedBox(width: 32),
                            Expanded(child: _MenuActions()),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _MenuHeader(),
                            SizedBox(height: 48),
                            _MenuActions(),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Encabezado con el nombre de la app. La mascota llegará con la identidad visual (HU-013).
class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.appTitle,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.menuTagline,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[500],
          ),
        ),
      ],
    );
  }
}

/// Juego de memoria, acceso a la zona de padres y salida de la app.
class _MenuActions extends StatefulWidget {
  const _MenuActions();

  @override
  State<_MenuActions> createState() => _MenuActionsState();
}

class _MenuActionsState extends State<_MenuActions> {
  bool _hasBadge = false;
  final OverlayPortalController _tapAgainHint = OverlayPortalController();
  Timer? _parentsZoneWindow;

  @override
  void initState() {
    super.initState();
    _loadBadge();
  }

  /// La medalla aparece con la insignia del juego de memoria (HU-001 R9). Si no
  /// se puede leer el progreso, el menú se muestra sin ella.
  Future<void> _loadBadge() async {
    bool hasBadge;
    try {
      hasBadge = (await context.read<IPersistenceRepository>().readMemoryProgress()).hasBadge;
    } catch (_) {
      hasBadge = false;
    }
    if (mounted && hasBadge != _hasBadge) setState(() => _hasBadge = hasBadge);
  }

  Future<void> _openMemoryGame() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const MemoryGameScreen()),
    );
    // Al volver, la insignia puede haberse conseguido.
    await _loadBadge();
  }

  /// El primer toque solo muestra un aviso pequeño, sin botones; el segundo,
  /// dentro de [MainMenuScreen.parentsZoneTapWindow], abre el desafío.
  void _onParentsZoneTap() {
    if (_parentsZoneWindow?.isActive ?? false) {
      _parentsZoneWindow?.cancel();
      _tapAgainHint.hide();
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ParentalGateScreen()),
      );
      return;
    }
    _tapAgainHint.show();
    _parentsZoneWindow = Timer(MainMenuScreen.parentsZoneTapWindow, () {
      if (mounted) _tapAgainHint.hide();
    });
  }

  @override
  void dispose() {
    _parentsZoneWindow?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ButtonStyle smallButtonStyle = TextButton.styleFrom(foregroundColor: Colors.blueGrey[600]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Un solo botón: el juego retoma el nivel alcanzado (HU-001 R1).
        _MenuButton(
          title: l10n.menuMemoryTitle,
          subtitle: l10n.menuMemorySubtitle,
          backgroundColor: const Color(0xFFFFF3C4), // Dorado pastel (D-023)
          textColor: const Color(0xFF8D6E00),
          badge: _hasBadge
              ? Semantics(
                  label: l10n.menuBadgeSemantics,
                  excludeSemantics: true,
                  child: const Icon(
                    Icons.military_tech_rounded,
                    key: ValueKey<String>('menu-memory-badge'),
                    color: Color(0xFFFFB300),
                    size: 32,
                  ),
                )
              : null,
          onTap: _openMemoryGame,
        ),
        const SizedBox(height: 40),

        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16,
          children: [
            // Doble toque y desafío para adultos (HU-004 R1). El aviso va en la
            // capa superior para quedar al pie de la pantalla, como el de salida.
            OverlayPortal(
              controller: _tapAgainHint,
              overlayChildBuilder: (_) => QuietHint(
                key: const ValueKey<String>('parents-zone-tap-again-hint'),
                text: l10n.parentsZoneTapAgainHint,
              ),
              child: TextButton.icon(
                key: const ValueKey<String>('menu-parents-zone'),
                onPressed: _onParentsZoneTap,
                icon: const Icon(Icons.security, size: 18),
                label: Text(l10n.menuParentsZone),
                style: smallButtonStyle,
              ),
            ),
            // La única salida sin confirmación (HU-001 R21).
            TextButton.icon(
              onPressed: MainMenuScreen._closeApp,
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(l10n.menuExit),
              style: smallButtonStyle,
            ),
          ],
        ),
      ],
    );
  }
}

/// Widget auxiliar para los botones interactivos del menú
class _MenuButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  /// Distintivo opcional junto a la flecha (la medalla de la insignia).
  final Widget? badge;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (badge case final Widget badge) ...[badge, const SizedBox(width: 8)],
            Icon(
              Icons.chevron_right_rounded,
              color: textColor,
              size: 28,
            )
          ],
        ),
      ),
    );
  }
}
