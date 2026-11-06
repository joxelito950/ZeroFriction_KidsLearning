import '../parental/daily_play_time.dart';
import '../settings/game_difficulty.dart';

/// Ajustes de la Zona de Padres y el tiempo jugado hoy (HU-009), la dificultad
/// y «Jugar sin tiempo» (HU-030). Más adelante guardará también «Mantener las
/// estrellas» (HU-016) y la mano dominante (HU-031).
final class ParentalSettings {
  ParentalSettings({
    this.dailyLimitMinutes,
    this.playTime,
    this.difficulty = GameDifficulty.normal,
    this.timerDisabled = false,
  }) {
    if (dailyLimitMinutes case final int minutes) {
      RangeError.checkValueInInterval(minutes, minLimitMinutes, maxLimitMinutes, 'dailyLimitMinutes');
    }
  }

  const ParentalSettings._initial()
      : dailyLimitMinutes = null,
        playTime = null,
        difficulty = GameDifficulty.normal,
        timerDisabled = false;

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

  ParentalSettings withLimit(int? minutes) => _copy(dailyLimitMinutes: () => minutes);

  ParentalSettings withPlayTime(DailyPlayTime time) => _copy(playTime: time);

  ParentalSettings withDifficulty(GameDifficulty value) => _copy(difficulty: value);

  ParentalSettings withTimerDisabled(bool value) => _copy(timerDisabled: value);

  ParentalSettings _copy({
    int? Function()? dailyLimitMinutes,
    DailyPlayTime? playTime,
    GameDifficulty? difficulty,
    bool? timerDisabled,
  }) {
    return ParentalSettings(
      dailyLimitMinutes: dailyLimitMinutes == null ? this.dailyLimitMinutes : dailyLimitMinutes(),
      playTime: playTime ?? this.playTime,
      difficulty: difficulty ?? this.difficulty,
      timerDisabled: timerDisabled ?? this.timerDisabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ParentalSettings &&
      other.dailyLimitMinutes == dailyLimitMinutes &&
      other.playTime == playTime &&
      other.difficulty == difficulty &&
      other.timerDisabled == timerDisabled;

  @override
  int get hashCode => Object.hash(dailyLimitMinutes, playTime, difficulty, timerDisabled);
}
