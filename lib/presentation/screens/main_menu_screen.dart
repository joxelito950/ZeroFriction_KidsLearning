import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'memory_game_screen.dart';

/// Menú principal súper visual y simplificado para niños de 3 años.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  static const EdgeInsets _padding = EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

/// Juego de memoria y acceso a la zona de padres.
class _MenuActions extends StatelessWidget {
  const _MenuActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryGameScreen()),
            );
          },
        ),
        const SizedBox(height: 40),

        // Botón de Control Parental (Acceso de seguridad con gatekeeper)
        Center(
          child: TextButton.icon(
            onPressed: () {
              // Aquí se integrará el Gatekeeper en el futuro
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.menuParentsZoneComingSoon),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.security, size: 18),
            label: Text(l10n.menuParentsZone),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blueGrey[600],
            ),
          ),
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

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
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
