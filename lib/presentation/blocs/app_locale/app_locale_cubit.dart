import 'dart:ui';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/app_language.dart';
import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/i_persistence_repository.dart';

const UserProfile _defaultProfile = UserProfile(isPremium: false, isSoundEnabled: true);

/// Idioma de la app en caliente (HU-012): arranca con el de [resolveStartupLocale]
/// y cambia al elegir otro en la Zona de Padres, que se guarda en el perfil.
class AppLocaleCubit extends Cubit<Locale> {
  AppLocaleCubit({required IPersistenceRepository repository, required Locale initial})
      : _repository = repository,
        super(initial);

  final IPersistenceRepository _repository;

  /// Cambia el idioma al instante (R3) y lo guarda. Si no se puede guardar, el
  /// cambio vale para esta sesión y el error se reporta sin molestar al niño (R6).
  Future<void> select(String languageCode) async {
    if (!AppLanguage.isSupported(languageCode) || languageCode == state.languageCode) return;
    emit(Locale(languageCode));
    try {
      final UserProfile profile = await _repository.readUserProfile() ?? _defaultProfile;
      await _repository.saveUserProfile(profile.copyWith(languageCode: languageCode));
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
  }
}
