import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/app_locale/app_locale_cubit.dart';
import 'package:toddler_logic/presentation/blocs/play_time/play_time_cubit.dart';

import 'memory_game_test_support.dart';

/// Idioma de los tests que buscan textos: el español del catálogo (HU-011).
const Locale testLocale = Locale('es');

/// [MaterialApp] con el catálogo de textos cargado, para montar pantallas sueltas.
/// Incluye el [AppLocaleCubit] que usa la Zona de Padres (HU-012); el idioma de
/// la app queda fijo en [locale]: el cambio en caliente se prueba con la app real.
/// Incluye también el [PlayTimeCubit] del tiempo diario (HU-009), sin la pantalla
/// de descanso, que se prueba con la app real.
Widget localizedApp({required Widget home, Locale locale = testLocale, MockPersistenceRepository? repository}) {
  registerMemoryGameFallbacks();
  final MockPersistenceRepository repo = repository ?? _stubbedRepository();

  final Widget app = MultiBlocProvider(
    providers: [
      BlocProvider<AppLocaleCubit>(create: (_) => AppLocaleCubit(repository: repo, initial: locale)),
      BlocProvider<PlayTimeCubit>(create: (_) => PlayTimeCubit(repository: repo)..start()),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
  // Con un repositorio propio, también se ofrece a las pantallas que lo leen
  // (la sección «Juegos», HU-030). Sin él, manda el que ponga el test por fuera.
  return repository == null
      ? app
      : RepositoryProvider<IPersistenceRepository>.value(value: repository, child: app);
}

MockPersistenceRepository _stubbedRepository() {
  final repository = MockPersistenceRepository();
  stubPersistenceRepository(repository);
  return repository;
}
