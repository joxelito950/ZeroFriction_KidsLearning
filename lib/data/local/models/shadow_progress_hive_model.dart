import 'package:hive_ce/hive.dart';

import '../../../domain/entities/shadow_progress.dart';
import '../../../domain/progress/level_record.dart';

part 'shadow_progress_hive_model.g.dart';

/// Formato de guardado de [ShadowProgress] (HU-007 R14, P8). typeId 4 e índices
/// de campo fijos: NO deben cambiar (SPECIFICATION 3.4). Mismo formato que la
/// memoria: los resultados por nivel, en dos mapas con la misma clave.
@HiveType(typeId: 4)
class ShadowProgressHiveModel {
  const ShadowProgressHiveModel({
    required this.currentLevel,
    required this.hasMedal,
    required this.bestStarsByLevel,
    required this.achievedAtByLevel,
    this.lastPlayedAt,
  });

  factory ShadowProgressHiveModel.fromEntity(ShadowProgress entity) {
    return ShadowProgressHiveModel(
      currentLevel: entity.currentLevel,
      hasMedal: entity.hasMedal,
      bestStarsByLevel: {
        for (final entry in entity.levelRecords.entries) entry.key: entry.value.bestStars,
      },
      achievedAtByLevel: {
        for (final entry in entity.levelRecords.entries) entry.key: entry.value.achievedAt,
      },
      lastPlayedAt: entity.lastPlayedAt,
    );
  }

  @HiveField(0)
  final int currentLevel;
  @HiveField(1)
  final bool hasMedal;
  @HiveField(2)
  final Map<int, int> bestStarsByLevel;
  @HiveField(3)
  final Map<int, DateTime> achievedAtByLevel;
  @HiveField(4)
  final DateTime? lastPlayedAt;

  /// Las reglas (nivel válido, estrellas entre 0 y 3) las valida la entidad.
  ShadowProgress toEntity() {
    return ShadowProgress(
      currentLevel: currentLevel,
      hasMedal: hasMedal,
      levelRecords: {
        for (final entry in bestStarsByLevel.entries)
          if (achievedAtByLevel[entry.key] case final DateTime achievedAt)
            entry.key: LevelRecord(bestStars: entry.value, achievedAt: achievedAt),
      },
      lastPlayedAt: lastPlayedAt,
    );
  }
}
