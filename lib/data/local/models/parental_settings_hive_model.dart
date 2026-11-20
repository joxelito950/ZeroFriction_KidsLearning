import 'package:hive_ce/hive.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/parental/daily_play_time.dart';
import '../../../domain/parental/rest_schedule.dart';
import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/settings/how_to_play.dart';

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
    this.nightFrom,
    this.nightUntil,
    this.naps,
    this.restAllowedUntil,
    this.moveMode,
    this.playingHand,
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
      nightFrom: entity.restSchedule.night?.from,
      nightUntil: entity.restSchedule.night?.until,
      naps: entity.restSchedule.naps.isEmpty
          ? null
          : [
              for (final RestWindow nap in entity.restSchedule.naps) ...[nap.from, nap.until]
            ],
      restAllowedUntil: entity.restAllowedUntil,
      moveMode: entity.moveMode.name,
      playingHand: entity.playingHand.name,
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

  /// Hora de dormir (HU-038), en minutos desde la medianoche; `null` sin ella.
  @HiveField(8)
  final int? nightFrom;
  @HiveField(9)
  final int? nightUntil;

  /// Siestas: desde y hasta de cada una, seguidos; `null` sin siestas.
  @HiveField(10)
  final List<int>? naps;

  /// Fin de los «15 minutos más» dados en un descanso (HU-038 R5).
  @HiveField(11)
  final DateTime? restAllowedUntil;

  /// Nombre de [MoveMode] (HU-039); `null` en los datos anteriores: «Ambas».
  @HiveField(12)
  final String? moveMode;

  /// Nombre de [PlayingHand] (HU-031); `null` en los datos anteriores: derecha.
  @HiveField(13)
  final String? playingHand;

  /// Un horario dañado (fuera del día o impar) se lee como apagado: la app
  /// nunca se queda bloqueada en la pantalla de noche por un dato raro.
  RestSchedule _restSchedule() {
    bool inDay(int? minute) => minute != null && minute >= 0 && minute < RestWindow.minutesPerDay;
    final List<int> pairs = naps ?? const [];
    if (pairs.length.isOdd || !pairs.every(inDay)) return RestSchedule.off;
    final RestSchedule schedule = RestSchedule(
      night: inDay(nightFrom) && inDay(nightUntil) ? RestWindow(nightFrom!, nightUntil!) : null,
      naps: [for (var i = 0; i < pairs.length; i += 2) RestWindow(pairs[i], pairs[i + 1])],
    );
    return schedule.isValid ? schedule : RestSchedule.off;
  }

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
      restSchedule: _restSchedule(),
      restAllowedUntil: restAllowedUntil?.toLocal(),
      moveMode: MoveMode.fromName(moveMode),
      playingHand: PlayingHand.fromName(playingHand),
    );
  }
}
