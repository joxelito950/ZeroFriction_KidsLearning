import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'data/local/hive_persistence_config.dart';
import 'data/local/hive_persistence_repository.dart';
import 'domain/repositories/i_persistence_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/l10n/startup_locale.dart';
import 'presentation/screens/main_menu_screen.dart';

/// Inicializa el repositorio y abre las cajas de Hive de forma asíncrona.
Future<HivePersistenceRepository> createRepository({required String hivePath}) async {
  await HivePersistenceConfig.initialize(hivePath: hivePath);
  return HivePersistenceRepository(
    levelStateBox: HivePersistenceConfig.levelStateBox,
    userProfileBox: HivePersistenceConfig.userProfileBox,
    memoryProgressBox: HivePersistenceConfig.memoryProgressBox,
  );
}

void main() async {
  // Asegura que los bindings de Flutter estén listos antes de inicializar Hive
  WidgetsFlutterBinding.ensureInitialized();

  // Obtiene la ruta del directorio del sistema para almacenar la base de datos local
  final directory = await getApplicationDocumentsDirectory();

  // Inicializa el repositorio local-first
  final repository = await createRepository(hivePath: directory.path);

  // Idioma: el guardado o, en el primer arranque, el del teléfono (HU-011)
  final locale = await resolveStartupLocale(
    repository: repository,
    systemLocales: WidgetsBinding.instance.platformDispatcher.locales,
  );

  runApp(
    ToddlerLogicApp(repository: repository, locale: locale),
  );
}

class ToddlerLogicApp extends StatelessWidget {
  final IPersistenceRepository repository;

  /// Idioma de la app; uno de [AppLocalizations.supportedLocales].
  final Locale locale;

  const ToddlerLogicApp({
    super.key,
    required this.repository,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<IPersistenceRepository>.value(
      value: repository,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
