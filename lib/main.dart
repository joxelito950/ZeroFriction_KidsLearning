import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';

import 'data/local/hive_persistence_config.dart';
import 'data/local/hive_persistence_repository.dart';
import 'data/platform/platform_feedback_channel.dart';
import 'domain/feedback/feedback_email.dart';
import 'domain/repositories/i_persistence_repository.dart';
import 'l10n/app_localizations.dart';
import 'presentation/blocs/app_locale/app_locale_cubit.dart';
import 'presentation/blocs/play_time/play_time_cubit.dart';
import 'presentation/l10n/startup_locale.dart';
import 'presentation/screens/main_menu_screen.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/widgets/play_time_scope.dart';

/// Inicializa el repositorio y abre las cajas de Hive de forma asíncrona.
Future<HivePersistenceRepository> createRepository({required String hivePath}) async {
  await HivePersistenceConfig.initialize(hivePath: hivePath);
  return HivePersistenceRepository(
    levelStateBox: HivePersistenceConfig.levelStateBox,
    userProfileBox: HivePersistenceConfig.userProfileBox,
    memoryProgressBox: HivePersistenceConfig.memoryProgressBox,
    parentalSettingsBox: HivePersistenceConfig.parentalSettingsBox,
    shadowProgressBox: HivePersistenceConfig.shadowProgressBox,
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

class ToddlerLogicApp extends StatefulWidget {
  final IPersistenceRepository repository;

  /// Idioma de arranque; uno de [AppLocalizations.supportedLocales]. Después se
  /// puede cambiar desde la Zona de Padres (HU-012).
  final Locale locale;

  /// Reloj del tiempo de juego diario; inyectable para tests (HU-009).
  final DateTime Function()? now;

  const ToddlerLogicApp({
    super.key,
    required this.repository,
    required this.locale,
    this.now,
  });

  @override
  State<ToddlerLogicApp> createState() => _ToddlerLogicAppState();
}

class _ToddlerLogicAppState extends State<ToddlerLogicApp> {
  /// La pantalla de descanso se abre desde fuera de las pantallas (HU-009).
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final IPersistenceRepository repository = widget.repository;
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<IPersistenceRepository>.value(value: repository),
        // Correo de comentarios (HU-032): datos técnicos y app de correo.
        RepositoryProvider<IFeedbackChannel>(create: (_) => PlatformFeedbackChannel()),
      ],
      child: MultiBlocProvider(
        providers: [
          // El idioma cambia en caliente desde la Zona de Padres (HU-012).
          BlocProvider<AppLocaleCubit>(
            create: (_) => AppLocaleCubit(repository: repository, initial: widget.locale),
          ),
          // Tiempo de juego diario y descanso (HU-009).
          BlocProvider<PlayTimeCubit>(
            create: (_) => PlayTimeCubit(repository: repository, now: widget.now)..start(),
          ),
        ],
        child: BlocBuilder<AppLocaleCubit, Locale>(
          builder: (context, locale) => MaterialApp(
            navigatorKey: _navigatorKey,
            builder: (context, child) => PlayTimeScope(navigatorKey: _navigatorKey, child: child!),
            onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: const MainMenuScreen(),
          ),
        ),
      ),
    );
  }
}
