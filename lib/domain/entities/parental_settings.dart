import '../parental/daily_play_time.dart';

/// Ajustes de la Zona de Padres y el tiempo jugado hoy (HU-009). Más adelante
/// guardará también la dificultad (HU-030), «Mantener las estrellas» (HU-016) y
/// la mano dominante (HU-031).
final class ParentalSettings {
  ParentalSettings({this.dailyLimitMinutes, this.playTime}) {
    if (dailyLimitMinutes case final int minutes) {
      RangeError.checkValueInInterval(minutes, minLimitMinutes, maxLimitMinutes, 'dailyLimitMinutes');
    }
  }

  const ParentalSettings._initial()
      : dailyLimitMinutes = null,
        playTime = null;

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

  ParentalSettings withLimit(int? minutes) => ParentalSettings(dailyLimitMinutes: minutes, playTime: playTime);

  ParentalSettings withPlayTime(DailyPlayTime time) =>
      ParentalSettings(dailyLimitMinutes: dailyLimitMinutes, playTime: time);

  @override
  bool operator ==(Object other) =>
      other is ParentalSettings && other.dailyLimitMinutes == dailyLimitMinutes && other.playTime == playTime;

  @override
  int get hashCode => Object.hash(dailyLimitMinutes, playTime);
}
