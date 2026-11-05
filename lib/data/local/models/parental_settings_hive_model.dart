import 'package:hive_ce/hive.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/parental/daily_play_time.dart';

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
  });

  factory ParentalSettingsHiveModel.fromEntity(ParentalSettings entity) {
    final DailyPlayTime? time = entity.playTime;
    return ParentalSettingsHiveModel(
      dailyLimitMinutes: entity.dailyLimitMinutes,
      playDay: time?.day,
      playedSeconds: time?.played.inSeconds ?? 0,
      extraMinutes: time?.extraMinutes ?? 0,
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
    );
  }
}
