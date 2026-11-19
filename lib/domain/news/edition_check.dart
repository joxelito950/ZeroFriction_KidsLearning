import '../entities/user_profile.dart';
import '../progress/game_progress.dart';
import '../repositories/i_persistence_repository.dart';
import '../settings/app_release.dart';
import 'special_edition.dart';

/// Las ediciones abiertas hoy (HU-042), con la fecha más alta vista guardada
/// en el perfil (R7, R8). Si no se puede leer o guardar, ninguna edición se
/// abre: lo gratis de siempre no depende de ella (R9).
abstract final class EditionCheck {
  static Future<Set<GameId>> refresh(IPersistenceRepository repository, {required DateTime now, DateTime? builtOn}) async {
    try {
      final UserProfile profile =
          await repository.readUserProfile() ?? const UserProfile(isPremium: false, isSoundEnabled: true);
      final DateTime? seen = profile.highestSeenDate;
      final Set<GameId> open =
          SpecialEditions.openGames(now: now, highestSeen: seen, builtOn: builtOn ?? AppRelease.builtOn);
      final DateTime highest = SpecialEditions.highest(seen, now);
      if (highest != seen) await repository.saveUserProfile(profile.copyWith(highestSeenDate: highest));
      return open;
    } catch (_) {
      return const {};
    }
  }

  /// Como [refresh], pero sin guardar nada: para los juegos, que se abren justo
  /// cuando el menú cuenta la apertura en el mismo perfil (HU-041) y no deben
  /// pisarla. La fecha la guarda el menú.
  static Future<Set<GameId>> openNow(IPersistenceRepository repository, {required DateTime now, DateTime? builtOn}) async {
    try {
      final UserProfile? profile = await repository.readUserProfile();
      return SpecialEditions.openGames(
          now: now, highestSeen: profile?.highestSeenDate, builtOn: builtOn ?? AppRelease.builtOn);
    } catch (_) {
      return const {};
    }
  }
}
