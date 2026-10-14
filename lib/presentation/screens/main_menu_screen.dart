import 'package:flutter/material.dart';

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

/// Encabezado amigable con la mascota y el nombre de la app.
class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🧸',
          style: TextStyle(fontSize: 80),
        ),
        const SizedBox(height: 8),
        Text(
          'ToddlerLogic',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Juegos de lógica y atención',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.blueGrey[500],
          ),
        ),
      ],
    );
  }
}

/// Niveles del juego de memoria y acceso a la zona de padres.
class _MenuActions extends StatelessWidget {
  const _MenuActions();

  // Set de emojis temáticos locales (zero-assets)
  static const List<String> _farmAnimals = ['🐶', '🐱', '🐷', '🐮', '🐑', '🐔'];
  static const List<String> _wildAnimals = ['🦁', '🐯', '🐼', '🐨', '🦊', '🐵'];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Botón de Categoría: Animales de la Granja (Fácil - 4 cartas)
        _MenuButton(
          title: 'Animales de la Granja',
          subtitle: 'Nivel Inicial (2x2)',
          emojiIcon: '🚜',
          backgroundColor: const Color(0xFFFFEBEE), // Rojo pastel
          textColor: Colors.red[800]!,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MemoryGameScreen(
                  levelId: 'farm_easy',
                  emojis: _farmAnimals.take(2).toList(), // 2 parejas (4 cartas)
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Botón de Categoría: Animales Salvajes (Medio - 6 cartas)
        _MenuButton(
          title: 'Selva Sorpresa',
          subtitle: 'Nivel Explorador (2x3)',
          emojiIcon: '🌴',
          backgroundColor: const Color(0xFFE8F5E9), // Verde pastel
          textColor: Colors.green[800]!,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MemoryGameScreen(
                  levelId: 'wild_medium',
                  emojis: _wildAnimals.take(3).toList(), // 3 parejas (6 cartas)
                ),
              ),
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
                const SnackBar(
                  content: Text('🔒 Zona de padres (Próximamente)'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            icon: const Icon(Icons.security, size: 18),
            label: const Text('Zona de Padres'),
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
  final String emojiIcon;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const _MenuButton({
    required this.title,
    required this.subtitle,
    required this.emojiIcon,
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
            Text(
              emojiIcon,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 16),
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
