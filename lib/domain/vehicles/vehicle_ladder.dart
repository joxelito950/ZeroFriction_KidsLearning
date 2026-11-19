/// Escalera de «A su sitio» (HU-052 7.3 y 7.4): 8 niveles (el 1 es el
/// tutorial), las ocho rondas de HU-051 y sus estrellas.
library;

import '../progress/round_ladder.dart';
import '../settings/game_difficulty.dart';
import '../shadows/shadow_ladder.dart';
import 'vehicle_catalog.dart';

/// Un nivel: cuántos vehículos y sitios con vehículo hay, si lleva un sitio
/// libre (desde la ronda de oro) y si mezcla vehículos parecidos.
final class VehicleLevel {
  const VehicleLevel({
    required this.number,
    required this.vehicles,
    required this.places,
    this.freePlace = false,
    this.lookalikes = false,
  });

  final int number;
  final int vehicles;

  /// Sitios a los que va algún vehículo del tablero.
  final int places;

  /// Un sitio más de la familia al que no va ninguno (distrae, como las
  /// sombras libres). Solo cuenta desde la ronda de oro.
  final bool freePlace;

  /// Vehículos de forma parecida, cada uno a un sitio distinto (solo con la
  /// familia «A qué se dedica»).
  final bool lookalikes;
}

/// Cómo se juega una ronda (HU-052 7.4).
final class VehicleRules {
  const VehicleRules({required this.round, this.timerDisabled = false, this.christmas = false});

  final GameDifficulty round;

  /// «Jugar sin tiempo» (HU-030 R3).
  final bool timerDisabled;

  /// Edición de Navidad activa (HU-042): el trineo entra en todos los tableros.
  final bool christmas;

  bool get _fromGold => round.index >= GameDifficulty.gold.index;

  /// Bronce y plata, solo «Por dónde va»; desde oro, las dos (P6).
  List<VehicleFamily> get families => _fromGold ? VehicleFamily.values : const [VehicleFamily.route];

  /// Sitios libres desde oro.
  bool get freePlaces => _fromGold;

  /// Sin tiempo en bronce y plata, la muestra gratis para los más pequeños
  /// (D-043); desde oro, salvo «Jugar sin tiempo».
  bool get timed => _fromGold && !timerDisabled;

  /// Parte de su sitio que el vehículo tiene que cubrir para encajar (el imán
  /// de Sombras, HU-050).
  double get coverageToSnap => ShadowRules(difficulty: round).coverageToSnap;

  /// En obsidiana y diamante, los sitios cambian de lado en cada tablero.
  bool get randomLayout => round.index >= GameDifficulty.obsidian.index;

  @override
  bool operator ==(Object other) =>
      other is VehicleRules && other.round == round && other.timerDisabled == timerDisabled && other.christmas == christmas;

  @override
  int get hashCode => Object.hash(round, timerDisabled, christmas);
}

abstract final class VehicleLadder {
  static const List<VehicleLevel> levels = [
    VehicleLevel(number: 1, vehicles: 2, places: 2),
    VehicleLevel(number: 2, vehicles: 3, places: 2),
    VehicleLevel(number: 3, vehicles: 3, places: 3),
    VehicleLevel(number: 4, vehicles: 4, places: 3, freePlace: true),
    VehicleLevel(number: 5, vehicles: 4, places: 4, freePlace: true),
    VehicleLevel(number: 6, vehicles: 5, places: 4, freePlace: true, lookalikes: true),
    VehicleLevel(number: 7, vehicles: 6, places: 4, freePlace: true, lookalikes: true),
    VehicleLevel(number: 8, vehicles: 6, places: 5, freePlace: true, lookalikes: true),
  ];

  static int get maxLevel => levels.last.number;

  /// Sin Premium y fuera de su edición se juegan bronce y plata (D-043).
  static const GameDifficulty lastFreeRound = GameDifficulty.silver;

  /// Las ocho rondas con los tiempos de Sombras (HU-052 7.4). En bronce y plata
  /// no se usan: se juegan sin tiempo.
  static final RoundLadder rounds = RoundLadder(
    levels: levels.length,
    timeLimits: {for (final GameDifficulty round in GameDifficulty.values) round: ShadowLadder.timeLimitsFor(round)},
  );

  static VehicleLevel levelAt(int number) {
    RangeError.checkValueInInterval(number, 1, maxLevel, 'number');
    return levels[number - 1];
  }
}

/// Estrellas de un tablero (HU-052 7.4): cuenta como fallo cada vehículo
/// soltado en un sitio equivocado. Con N vehículos, 3★ con N fallos o menos,
/// 2★ hasta 2N y 1★ con más. A diferencia de Sombras, sin pedir Premium.
abstract final class VehicleStars {
  static const int max = 3;

  static int forWin({required int vehicles, required int fails}) {
    RangeError.checkValueInInterval(vehicles, 1, 99, 'vehicles');
    RangeError.checkNotNegative(fails, 'fails');
    if (fails <= vehicles) return 3;
    if (fails <= vehicles * 2) return 2;
    return 1;
  }
}
