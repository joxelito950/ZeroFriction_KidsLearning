import 'package:flutter/material.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';

/// Idioma de los tests que buscan textos: el español del catálogo (HU-011).
const Locale testLocale = Locale('es');

/// [MaterialApp] con el catálogo de textos cargado, para montar pantallas sueltas.
Widget localizedApp({required Widget home, Locale locale = testLocale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}
