import 'package:hive_ce/hive.dart';

import '../../../domain/entities/shadow_progress.dart';

import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/level_record.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/settings/game_difficulty.dart';

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
    this.round,
    this.medals,
    this.bestStarsByRoundLevel,
    this.achievedAtByRoundLevel,
    this.tutorialFalls,
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

  /// Guarda el progreso con rondas (HU-037). [currentLevel] es el nivel dentro
  /// de la ronda y [hasMedal] dice si hay alguna medalla; los mapas
  /// antiguos se dejan vacíos.
  factory ShadowProgressHiveModel.fromGameProgress(GameProgress progress) {
    return ShadowProgressHiveModel(
      currentLevel: progress.position.level,
      hasMedal: progress.medals.isNotEmpty,
      bestStarsByLevel: const {},
      achievedAtByLevel: const {},
      lastPlayedAt: progress.lastPlayedAt,
      round: progress.position.round.name,
      medals: [for (final GameDifficulty medal in progress.medals) medal.name],
      bestStarsByRoundLevel: {for (final entry in progress.records.entries) entry.key.key: entry.value.bestStars},
      achievedAtByRoundLevel: {for (final entry in progress.records.entries) entry.key.key: entry.value.achievedAt},
      tutorialFalls: progress.position.tutorialFalls,
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

  // HU-037 (rondas): campos nuevos, opcionales. Sin ellos, lo guardado es de
  // antes de las rondas y se migra (P7). Los campos 2 y 3 ya no se escriben.
  @HiveField(5)
  final String? round;
  @HiveField(6)
  final List<String>? medals;
  @HiveField(7)
  final Map<int, int>? bestStarsByRoundLevel;
  @HiveField(8)
  final Map<int, DateTime>? achievedAtByRoundLevel;
  @HiveField(9)
  final int? tutorialFalls;

  /// El progreso con rondas (HU-037). Lo guardado antes se migra a Normal.
  GameProgress toGameProgress() {
    final String? savedRound = round;
    if (savedRound == null) {
      return GameProgress.migrate(
        currentLevel: currentLevel,
        hadBadge: hasMedal,
        levelRecords: {
          for (final entry in bestStarsByLevel.entries)
            if (achievedAtByLevel[entry.key] case final DateTime achievedAt)
              entry.key: LevelRecord(bestStars: entry.value, achievedAt: achievedAt),
        },
        lastPlayedAt: lastPlayedAt,
      );
    }
    final Map<int, DateTime> dates = achievedAtByRoundLevel ?? const {};
    return GameProgress(
      position: RoundPosition(
        round: GameDifficulty.fromName(savedRound),
        level: currentLevel,
        tutorialFalls: tutorialFalls ?? 0,
      ),
      medals: {for (final String name in medals ?? const []) GameDifficulty.fromName(name)},
      records: {
        for (final entry in (bestStarsByRoundLevel ?? const <int, int>{}).entries)
          if (dates[entry.key] case final DateTime achievedAt)
            RoundLevel.fromKey(entry.key): LevelRecord(bestStars: entry.value, achievedAt: achievedAt),
      },
      lastPlayedAt: lastPlayedAt,
    );
  }

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
