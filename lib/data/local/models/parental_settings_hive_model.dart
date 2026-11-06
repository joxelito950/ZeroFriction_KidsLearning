import 'package:hive_ce/hive.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/parental/daily_play_time.dart';
import '../../../domain/settings/game_difficulty.dart';

part 'parental_settings_hive_model.g.dart';

/// Formato de guardado de [ParentalSettings] (HU-009). typeId 3 e índices de
/// campo fijos: NO deben cambiar (SPECIFICATION 3.4). El tiempo de hoy se
/// guarda en segundos, con su día.
@HiveType(typeId: 3)
class ParentalSettingsHiveModel {
  const ParentalSettingsHiveModel({
    this.dailyLimitMinutes,
    this.playDay,
    this.playedSeconds = 0,
    this.extraMinutes = 0,
    this.difficulty,
    this.timerDisabled = false,
    this.keepStars = false,
    this.starDecayResumedAt,
  });

  factory ParentalSettingsHiveModel.fromEntity(ParentalSettings entity) {
    final DailyPlayTime? time = entity.playTime;
    return ParentalSettingsHiveModel(
      dailyLimitMinutes: entity.dailyLimitMinutes,
      playDay: time?.day,
      playedSeconds: time?.played.inSeconds ?? 0,
      extraMinutes: time?.extraMinutes ?? 0,
      difficulty: entity.difficulty.name,
      timerDisabled: entity.timerDisabled,
      keepStars: entity.keepStars,
      starDecayResumedAt: entity.starDecayResumedAt,
    );
  }

  @HiveField(0)
  final int? dailyLimitMinutes;
  @HiveField(1)
  final DateTime? playDay;
  @HiveField(2, defaultValue: 0)
  final int playedSeconds;
  @HiveField(3, defaultValue: 0)
  final int extraMinutes;

  /// Nombre de [GameDifficulty] (HU-030). Los datos anteriores no lo tienen: Normal.
  @HiveField(4)
  final String? difficulty;
  @HiveField(5, defaultValue: false)
  final bool timerDisabled;

  /// «Mantener las estrellas» (HU-016).
  @HiveField(6, defaultValue: false)
  final bool keepStars;
  @HiveField(7)
  final DateTime? starDecayResumedAt;

  /// Las reglas (límite entre 5 y 720 minutos) las valida la entidad.
  ParentalSettings toEntity() {
    return ParentalSettings(
      dailyLimitMinutes: dailyLimitMinutes,
      playTime: switch (playDay) {
        // Medianoche local: Hive puede devolver la fecha en UTC.
        final DateTime day =>
          DailyPlayTime(day: day.toLocal(), played: Duration(seconds: playedSeconds), extraMinutes: extraMinutes),
        null => null,
      },
      difficulty: GameDifficulty.fromName(difficulty),
      timerDisabled: timerDisabled,
      keepStars: keepStars,
      starDecayResumedAt: starDecayResumedAt?.toLocal(),
    );
  }
}
