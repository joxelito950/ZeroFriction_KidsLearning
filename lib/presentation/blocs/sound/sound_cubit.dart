import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/sound/game_sound.dart';

/// El sonido de la app (HU-005): el estado dice si está activado
/// (`UserProfile.isSoundEnabled`, activado por defecto, P2) y [play] solo suena
/// si lo está.
class SoundCubit extends Cubit<bool> {
  SoundCubit({required IPersistenceRepository repository, required ISoundEffects effects})
      : _repository = repository,
        _effects = effects,
        super(true);

  final IPersistenceRepository _repository;
  final ISoundEffects _effects;

  /// Lee el ajuste guardado. Si no se puede leer, el sonido sigue activado.
  Future<void> load() async {
    try {
      final UserProfile? profile = await _repository.readUserProfile();
      if (!isClosed && profile != null) emit(profile.isSoundEnabled);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  /// Activa o silencia la app al instante y lo guarda (R4).
  Future<void> setEnabled(bool enabled) async {
    emit(enabled);
    try {
      final UserProfile profile =
          await _repository.readUserProfile() ?? const UserProfile(isPremium: false, isSoundEnabled: true);
      await _repository.saveUserProfile(profile.copyWith(isSoundEnabled: enabled));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  /// Reproduce [sound] si el sonido está activado, sin esperar a que termine.
  void play(GameSound sound) {
    if (state) unawaited(_effects.play(sound));
  }
}
