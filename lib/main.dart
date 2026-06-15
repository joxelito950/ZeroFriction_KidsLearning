import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'data/local/hive_persistence_config.dart';
import 'data/local/hive_persistence_repository.dart';
import 'domain/repositories/i_persistence_repository.dart';
import 'presentation/screens/memory_game_screen.dart';

/// Inicializa el repositorio y abre las cajas de Hive de forma asíncrona.
Future<HivePersistenceRepository> createRepository({required String hivePath}) async {
  await HivePersistenceConfig.initialize(hivePath: hivePath);
  return HivePersistenceRepository(
    levelStateBox: HivePersistenceConfig.levelStateBox,
    userProfileBox: HivePersistenceConfig.userProfileBox,
  );
}

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar Hive
  WidgetsFlutterBinding.ensureInitialized();

  // Obtiene la ruta del directorio del sistema para almacenar la base de datos local
  final directory = await getApplicationDocumentsDirectory();

  // Inicializa el repositorio local-first
  final repository = await createRepository(hivePath: directory.path);

  runApp(
    ToddlerLogicApp(repository: repository),
  );
}

class ToddlerLogicApp extends StatelessWidget {
  final IPersistenceRepository repository;

  const ToddlerLogicApp({
    super.key,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IPersistenceRepository>.value(
      value: repository,
      child: MaterialApp(
        title: 'ToddlerLogic',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF98FFD9), // Pastel menta amigable
            surface: const Color(0xFFF9F9FB), // Fondo limpio y claro
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}

/// Menú principal súper visual y simplificado para niños de 3 años.
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Set de emojis temáticos locales (zero-assets)
    final List<String> farmAnimals = ['🐶', '🐱', '🐷', '🐮', '🐑', '🐔'];
    final List<String> wildAnimals = ['🦁', '🐯', '🐼', '🐨', '🦊', '🐵'];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado amigable
              Column(
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
              ),
              const SizedBox(height: 48),

              // Botón de Categoría: Animales de la Granja (Fácil - 4 cartas)
              _MenuButton(
                title: 'Animales de la Granja',
                subtitle: 'Nivel Inicial (2x2)',
                emojiIcon: '🚜',
                backgroundColor: const Color(0xFFFFEBEE), // Rojo pastel
                textColor: Colors.red[800]!,
                onTap: () {
                  final repository = context.read<IPersistenceRepository>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemoryGameScreen(
                        persistenceRepository: repository,
                        levelId: 'farm_easy',
                        imageAssets: farmAnimals.take(2).toList(), // 2 parejas (4 cartas)
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
                  final repository = context.read<IPersistenceRepository>();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MemoryGameScreen(
                        persistenceRepository: repository,
                        levelId: 'wild_medium',
                        imageAssets: wildAnimals.take(3).toList(), // 3 parejas (6 cartas)
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
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: onTap,
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