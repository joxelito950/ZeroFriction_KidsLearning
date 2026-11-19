import 'package:meta/meta.dart';

import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/vehicles/vehicle_board.dart';
import '../../../domain/vehicles/vehicle_catalog.dart';

/// Fase de un tablero de «A su sitio» (HU-052).
enum VehiclePhase {
  /// Leyendo el progreso guardado.
  loading,

  /// Tablero en juego.
  playing,

  /// Tablero completado: celebración con las estrellas.
  celebrating,

  /// Se acabó el tiempo: aviso antes de bajar de nivel.
  timeUp,

  /// Tutorial superado (HU-037 R9): invitación a jugar, sin estrellas.
  inviting,
}

/// Qué pasa tras perder por tiempo (HU-037), como en Sombras.
enum VehicleLoss { fewerVehicles, restart, easierRound }

/// Estado inmutable de la pantalla de «A su sitio».
@immutable
class VehicleGameState {
  const VehicleGameState({
    this.phase = VehiclePhase.loading,
    this.round = 0,
    this.level = 1,
    this.timeLimit,
    this.board,
    this.placesFirst = true,
    this.placed = const {},
    this.fails = 0,
    this.elapsed = Duration.zero,
    this.timerStarted = false,
    this.coverageToSnap = 0.4,
    this.stars,
    this.medal,
    this.gameRound = GameDifficulty.bronze,
    this.lossKind,
  });

  final VehiclePhase phase;

  /// Número de tablero repartido; cambia con cada tablero nuevo.
  final int round;
  final int level;

  /// Límite del tablero, o `null` sin tiempo (bronce, plata, tutorial o
  /// «Jugar sin tiempo»).
  final Duration? timeLimit;
  final VehicleBoard? board;

  /// Sitios arriba o a la izquierda (siempre, salvo al azar en obsidiana y
  /// diamante, HU-052 7.4).
  final bool placesFirst;

  /// Vehículos ya en su sitio: no se pueden mover.
  final Set<Vehicle> placed;

  /// Vehículos soltados en un sitio equivocado (las estrellas, 7.4).
  final int fails;
  final Duration elapsed;

  /// El cronómetro arranca al tocar el primer vehículo.
  final bool timerStarted;

  /// Parte del vehículo que tiene que caer sobre su sitio para encajar.
  final double coverageToSnap;

  /// Estrellas del tablero recién completado.
  final int? stars;

  /// Medalla de la ronda recién completada.
  final GameDifficulty? medal;

  /// Ronda en juego: da color a los puntos de nivel.
  final GameDifficulty gameRound;
  final VehicleLoss? lossKind;

  List<Vehicle> get vehicles => board?.vehicles ?? const [];

  List<Vehicle> get trayVehicles => [
        for (final Vehicle vehicle in vehicles)
          if (!placed.contains(vehicle)) vehicle,
      ];

  /// Vehículos ya colocados en [place], en el orden en que llegaron: el
  /// primero ocupa el primer hueco.
  List<Vehicle> placedAt(Place place) => [
        for (final Vehicle vehicle in placed)
          if (board!.targetOf(vehicle) == place) vehicle,
      ];

  bool canDrag(Vehicle vehicle) =>
      phase == VehiclePhase.playing && vehicles.contains(vehicle) && !placed.contains(vehicle);

  /// Fracción de tiempo restante (1 = barra llena), o `null` sin tiempo.
  double? get remainingFraction {
    final Duration? limit = timeLimit;
    if (limit == null) return null;
    final Duration left = limit - elapsed;
    return left.isNegative ? 0 : left.inMilliseconds / limit.inMilliseconds;
  }

  VehicleGameState copyWith({
    VehiclePhase? phase,
    Set<Vehicle>? placed,
    int? fails,
    Duration? elapsed,
    bool? timerStarted,
    int? stars,
    GameDifficulty? medal,
    VehicleLoss? lossKind,
  }) =>
      VehicleGameState(
        phase: phase ?? this.phase,
        round: round,
        level: level,
        timeLimit: timeLimit,
        board: board,
        placesFirst: placesFirst,
        placed: placed ?? this.placed,
        fails: fails ?? this.fails,
        elapsed: elapsed ?? this.elapsed,
        timerStarted: timerStarted ?? this.timerStarted,
        coverageToSnap: coverageToSnap,
        stars: stars ?? this.stars,
        medal: medal ?? this.medal,
        gameRound: gameRound,
        lossKind: lossKind ?? this.lossKind,
      );
}
