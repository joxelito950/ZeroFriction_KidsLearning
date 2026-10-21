import 'package:flutter/widgets.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/i_persistence_repository.dart';

const UserProfile _defaultProfile = UserProfile(isPremium: false, isSoundEnabled: true);

/// Idioma con el que arranca la app (HU-011, reglas R2 y R3):
/// - si hay uno guardado y soportado, se usa aunque el del teléfono haya cambiado;
/// - si no, se toma el primer idioma soportado de [systemLocales] (o inglés) y se guarda.
///
/// Un fallo al guardar no impide arrancar: se reintenta en el siguiente arranque.
Future<Locale> resolveStartupLocale({
  required IPersistenceRepository repository,
  required List<Locale> systemLocales,
}) async {
  final UserProfile profile = await repository.readUserProfile() ?? _defaultProfile;
  final String? savedLanguage = profile.languageCode;
  if (AppLanguage.isSupported(savedLanguage)) {
    return Locale(savedLanguage!);
  }

  final String languageCode = AppLanguage.resolve(
    systemLocales.map((locale) => locale.toLanguageTag()),
  );
  try {
    await repository.saveUserProfile(profile.copyWith(languageCode: languageCode));
  } catch (_) {
    // Sin persistencia el idioma sigue siendo correcto en esta sesión.
  }
  return Locale(languageCode);
}
