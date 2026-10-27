import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/app_locale/app_locale_cubit.dart';

import 'memory_game_test_support.dart';

/// Idioma de los tests que buscan textos: el español del catálogo (HU-011).
const Locale testLocale = Locale('es');

/// [MaterialApp] con el catálogo de textos cargado, para montar pantallas sueltas.
/// Incluye el [AppLocaleCubit] que usa la Zona de Padres (HU-012); el idioma de
/// la app queda fijo en [locale]: el cambio en caliente se prueba con la app real.
Widget localizedApp({required Widget home, Locale locale = testLocale}) {
  registerMemoryGameFallbacks();
  final repository = MockPersistenceRepository();
  stubPersistenceRepository(repository);

  return BlocProvider<AppLocaleCubit>(
    create: (_) => AppLocaleCubit(repository: repository, initial: locale),
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
