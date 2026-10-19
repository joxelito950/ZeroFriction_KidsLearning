import 'package:hive_ce/hive.dart';

import '../../../domain/entities/level_state.dart';

part 'level_state_hive_model.g.dart';

/// Formato de guardado de [LevelState]. El typeId y los índices de campo son
/// los que ya existen en disco: NO deben cambiar (SPECIFICATION 3.4).
@HiveType(typeId: 0)
class LevelStateHiveModel {
  const LevelStateHiveModel({
    required this.levelId,
    required this.isCompleted,
    required this.stars,
  });

  factory LevelStateHiveModel.fromEntity(LevelState entity) {
    return LevelStateHiveModel(
      levelId: entity.levelId,
      isCompleted: entity.isCompleted,
      stars: entity.stars,
    );
  }

  @HiveField(0)
  final String levelId;
  @HiveField(1)
  final bool isCompleted;
  @HiveField(2)
  final int stars;

  /// Las reglas de negocio (p. ej. estrellas entre 0 y 3) las valida la entidad.
  LevelState toEntity() {
    return LevelState(
      levelId: levelId,
      isCompleted: isCompleted,
      stars: stars,
    );
  }
}
