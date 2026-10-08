import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'data/local/hive_persistence_config.dart';
import 'data/local/hive_persistence_repository.dart';
import 'domain/repositories/i_persistence_repository.dart';
import 'presentation/screens/main_menu_screen.dart';

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
