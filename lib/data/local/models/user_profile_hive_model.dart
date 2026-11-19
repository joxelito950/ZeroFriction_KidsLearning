import 'package:hive_ce/hive.dart';

import '../../../domain/entities/user_profile.dart';
import '../../../domain/news/discovery.dart';
import '../../../domain/progress/game_progress.dart';

part 'user_profile_hive_model.g.dart';

/// Formato de guardado de [UserProfile]. El typeId y los índices de campo son
/// los que ya existen en disco: NO deben cambiar (SPECIFICATION 3.4).
@HiveType(typeId: 1)
class UserProfileHiveModel {
  const UserProfileHiveModel({
    required this.isPremium,
    required this.isSoundEnabled,
    this.languageCode,
    this.gameOpens,
    this.seenFeatures,
    this.highestSeenDate,
  });

  /// Sin nada descubierto aún (instalación nueva), se guarda todo como visto
  /// (HU-041 R2): así no se confunde después con un perfil anterior.
  factory UserProfileHiveModel.fromEntity(UserProfile entity) {
    final Discovery discovery = entity.discovered;
    return UserProfileHiveModel(
      isPremium: entity.isPremium,
      isSoundEnabled: entity.isSoundEnabled,
      languageCode: entity.languageCode,
      gameOpens: {for (final MapEntry<GameId, int> entry in discovery.gameOpens.entries) entry.key.name: entry.value},
      seenFeatures: [for (final ParentsFeature feature in discovery.seenFeatures) feature.name],
      highestSeenDate: entity.highestSeenDate,
    );
  }

  @HiveField(0)
  final bool isPremium;
  @HiveField(1)
  final bool isSoundEnabled;

  /// Añadido en HU-011. Los perfiles guardados antes no lo tienen y se leen como `null`.
  @HiveField(2)
  final String? languageCode;

  /// Añadido en HU-041: veces que se ha abierto cada juego, por el nombre de su
  /// `GameId`. `null` en los perfiles anteriores.
  @HiveField(3)
  final Map<String, int>? gameOpens;

  /// Añadido en HU-041: opciones de la Zona de Padres ya vistas, por nombre.
  @HiveField(4)
  final List<String>? seenFeatures;

  /// Añadido en HU-042: la fecha más alta vista (R7). `null` en los perfiles
  /// anteriores.
  @HiveField(5)
  final DateTime? highestSeenDate;

  UserProfile toEntity() {
    final Map<String, int>? opens = gameOpens;
    final List<String>? features = seenFeatures;
    return UserProfile(
      isPremium: isPremium,
      isSoundEnabled: isSoundEnabled,
      languageCode: languageCode,
      highestSeenDate: highestSeenDate,
      // Un perfil anterior a HU-041 había visto lo de `1.0.0-rc.5` (sección 5).
      discovery: opens == null || features == null
          ? Discovery.beforeNews()
          : Discovery(
              gameOpens: {
                for (final GameId game in GameId.values)
                  if (opens[game.name] case final int count) game: count.clamp(0, Discovery.opensToSee),
              },
              seenFeatures: {
                for (final ParentsFeature feature in ParentsFeature.values)
                  if (features.contains(feature.name)) feature,
              },
            ),
    );
  }
}
