import 'package:hive_ce/hive.dart';

import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/level_record.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/settings/game_difficulty.dart';

part 'game_progress_hive_model.g.dart';

/// Formato de guardado común del progreso con rondas (HU-037, HU-025 P5), para
/// los juegos que nacen con las rondas: una caja (`game_progress`) con una clave
/// por juego. typeId 5 e índices de campo fijos: NO deben cambiar
/// (SPECIFICATION 3.4). La memoria y Sombras siguen en sus modelos (typeId 2 y 4)
/// por los datos que ya existen en los teléfonos.
@HiveType(typeId: 5)
class GameProgressHiveModel {
  const GameProgressHiveModel({
    required this.round,
    required this.level,
    required this.medals,
    required this.bestStarsByRoundLevel,
    required this.achievedAtByRoundLevel,
    this.lastPlayedAt,
    this.tutorialFalls = 0,
  });

  factory GameProgressHiveModel.fromGameProgress(GameProgress progress) => GameProgressHiveModel(
        round: progress.position.round.name,
        level: progress.position.level,
        medals: [for (final GameDifficulty medal in progress.medals) medal.name],
        bestStarsByRoundLevel: {for (final entry in progress.records.entries) entry.key.key: entry.value.bestStars},
        achievedAtByRoundLevel: {for (final entry in progress.records.entries) entry.key.key: entry.value.achievedAt},
        lastPlayedAt: progress.lastPlayedAt,
        tutorialFalls: progress.position.tutorialFalls,
      );

  @HiveField(0)
  final String round;
  @HiveField(1)
  final int level;
  @HiveField(2)
  final List<String> medals;

  /// Clave `ronda × 10 + nivel`.
  @HiveField(3)
  final Map<int, int> bestStarsByRoundLevel;
  @HiveField(4)
  final Map<int, DateTime> achievedAtByRoundLevel;
  @HiveField(5)
  final DateTime? lastPlayedAt;
  @HiveField(6)
  final int tutorialFalls;

  /// Un récord sin su fecha se ignora en vez de inventarla.
  GameProgress toGameProgress() => GameProgress(
        position: RoundPosition(round: GameDifficulty.fromName(round), level: level, tutorialFalls: tutorialFalls),
        medals: {for (final String name in medals) GameDifficulty.fromName(name)},
        records: {
          for (final entry in bestStarsByRoundLevel.entries)
            if (achievedAtByRoundLevel[entry.key] case final DateTime achievedAt)
              RoundLevel.fromKey(entry.key): LevelRecord(bestStars: entry.value, achievedAt: achievedAt),
        },
        lastPlayedAt: lastPlayedAt,
      );
}
