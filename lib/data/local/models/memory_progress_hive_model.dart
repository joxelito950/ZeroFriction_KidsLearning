import 'package:hive_ce/hive.dart';

import '../../../domain/entities/memory_progress.dart';

part 'memory_progress_hive_model.g.dart';

/// Formato de guardado de [MemoryProgress] (HU-001). typeId 2 e índices de
/// campo fijos: NO deben cambiar (SPECIFICATION 3.4). Los resultados por nivel
/// se guardan como dos mapas con la misma clave (número de nivel).
@HiveType(typeId: 2)
class MemoryProgressHiveModel {
  const MemoryProgressHiveModel({
    required this.currentLevel,
    required this.hasBadge,
    required this.bestStarsByLevel,
    required this.achievedAtByLevel,
    this.lastPlayedAt,
  });

  factory MemoryProgressHiveModel.fromEntity(MemoryProgress entity) {
    return MemoryProgressHiveModel(
      currentLevel: entity.currentLevel,
      hasBadge: entity.hasBadge,
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
  final bool hasBadge;
  @HiveField(2)
  final Map<int, int> bestStarsByLevel;
  @HiveField(3)
  final Map<int, DateTime> achievedAtByLevel;
  @HiveField(4)
  final DateTime? lastPlayedAt;

  /// Las reglas (nivel válido, estrellas entre 0 y 3) las valida la entidad.
  MemoryProgress toEntity() {
    return MemoryProgress(
      currentLevel: currentLevel,
      hasBadge: hasBadge,
      levelRecords: {
        for (final entry in bestStarsByLevel.entries)
          if (achievedAtByLevel[entry.key] case final DateTime achievedAt)
            entry.key: MemoryLevelRecord(bestStars: entry.value, achievedAt: achievedAt),
      },
      lastPlayedAt: lastPlayedAt,
    );
  }
}
