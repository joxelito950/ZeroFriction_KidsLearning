import '../parental/daily_play_time.dart';
import '../settings/game_difficulty.dart';

/// Ajustes de la Zona de Padres y el tiempo jugado hoy (HU-009), la dificultad
/// y «Jugar sin tiempo» (HU-030) y «Mantener las estrellas» (HU-016). Más
/// adelante, la mano dominante (HU-031).
final class ParentalSettings {
  ParentalSettings({
    this.dailyLimitMinutes,
    this.playTime,
    this.difficulty = GameDifficulty.normal,
    this.timerDisabled = false,
    this.keepStars = false,
    this.starDecayResumedAt,
  }) {
    if (dailyLimitMinutes case final int minutes) {
      RangeError.checkValueInInterval(minutes, minLimitMinutes, maxLimitMinutes, 'dailyLimitMinutes');
    }
  }

  const ParentalSettings._initial()
      : dailyLimitMinutes = null,
        playTime = null,
        difficulty = GameDifficulty.normal,
        timerDisabled = false,
        keepStars = false,
        starDecayResumedAt = null;

  /// Sin límite y sin nada jugado: el valor por defecto (R1c).
  static const ParentalSettings initial = ParentalSettings._initial();

  /// Límite personalizado: de 5 minutos a 12 horas (R1c).
  static const int minLimitMinutes = 5;
  static const int maxLimitMinutes = 720;

  /// Opciones del selector, además de «sin límite» y «personalizado» (R1c).
  static const List<int> presetLimitMinutes = [15, 30, 45, 60, 90, 120];

  static bool isValidLimit(int minutes) => minutes >= minLimitMinutes && minutes <= maxLimitMinutes;

  /// Límite diario en minutos; `null` es «sin límite».
  final int? dailyLimitMinutes;

  /// Lo jugado el último día que se jugó; `null` si nunca.
  final DailyPlayTime? playTime;

  /// Dificultad de todos los juegos (HU-030); Normal por defecto.
  final GameDifficulty difficulty;

  /// «Jugar sin tiempo» (HU-030 R3, R4): lo cambia un adulto con Premium.
  /// Se guarda aquí; solo se aplica con Premium (HU-030 R4).
  final bool timerDisabled;

  /// «Mantener las estrellas» (HU-016): con él, no se pierde ninguna. Gratuito.
  final bool keepStars;

  /// Cuándo se volvió a activar la pérdida (HU-016 R3): la gracia de 7 días
  /// empieza de nuevo desde ese momento.
  final DateTime? starDecayResumedAt;

  ParentalSettings withLimit(int? minutes) => _copy(dailyLimitMinutes: () => minutes);

  ParentalSettings withPlayTime(DailyPlayTime time) => _copy(playTime: time);

  ParentalSettings withDifficulty(GameDifficulty value) => _copy(difficulty: value);

  ParentalSettings withTimerDisabled(bool value) => _copy(timerDisabled: value);

  /// Activar «Mantener las estrellas» las congela; desactivarlo reinicia la
  /// gracia desde [at] (HU-016 R2, R3).
  ParentalSettings withKeepStars(bool value, {required DateTime at}) =>
      value == keepStars ? this : _copy(keepStars: value, starDecayResumedAt: value ? null : at);

  ParentalSettings _copy({
    int? Function()? dailyLimitMinutes,
    DailyPlayTime? playTime,
    GameDifficulty? difficulty,
    bool? timerDisabled,
    bool? keepStars,
    DateTime? starDecayResumedAt,
  }) {
    return ParentalSettings(
      dailyLimitMinutes: dailyLimitMinutes == null ? this.dailyLimitMinutes : dailyLimitMinutes(),
      playTime: playTime ?? this.playTime,
      difficulty: difficulty ?? this.difficulty,
      timerDisabled: timerDisabled ?? this.timerDisabled,
      keepStars: keepStars ?? this.keepStars,
      starDecayResumedAt: starDecayResumedAt ?? this.starDecayResumedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ParentalSettings &&
      other.dailyLimitMinutes == dailyLimitMinutes &&
      other.playTime == playTime &&
      other.difficulty == difficulty &&
      other.timerDisabled == timerDisabled &&
      other.keepStars == keepStars &&
      other.starDecayResumedAt == starDecayResumedAt;

  @override
  int get hashCode =>
      Object.hash(dailyLimitMinutes, playTime, difficulty, timerDisabled, keepStars, starDecayResumedAt);
}
