import 'package:meta/meta.dart';

import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/shadows/shadow_ladder.dart';

/// Fase de un tablero de Sombras (HU-007).
enum ShadowRoundPhase {
  /// Leyendo el progreso guardado.
  loading,

  /// Animación de inicio (R19, solo Fácil y Normal): los objetos salen de sus
  /// sombras hacia la bandeja. Arrastrar no hace nada.
  introducing,

  /// Tablero en juego.
  playing,

  /// Tablero completado: celebración automática con las estrellas (R8).
  celebrating,

  /// Se acabó el tiempo: aviso antes de bajar de nivel.
  timeUp,

  /// Tutorial superado (HU-037 R9): invitación a jugar, sin estrellas.
  inviting,
}

/// Qué pasa tras perder por tiempo (HU-037).
enum ShadowLoss {
  /// Se baja un nivel: «Probemos con menos dibujos».
  fewerObjects,

  /// Se vuelve al tutorial: «Empecemos de nuevo, sin prisa».
  restart,

  /// Segunda caída al tutorial: se baja a la ronda anterior (R10).
  easierRound,
}

/// Estado inmutable de la pantalla de Sombras.
@immutable
class ShadowGameState {
  const ShadowGameState({
    this.phase = ShadowRoundPhase.loading,
    this.round = 0,
    this.position = ShadowLadder.start,
    this.layout = ShadowLayout.shadowsFirst,
    this.objects = const [],
    this.shadows = const [],
    this.placed = const {},
    this.fails = 0,
    this.elapsed = Duration.zero,
    this.timerStarted = false,
    this.premium = false,
    this.stars,
    this.medalEarned = false,
    this.hasMedal = false,
    this.goldFraction = 0,
    this.gameRound = GameDifficulty.easy,
    this.medal,
    this.lossKind,
  });

  final ShadowRoundPhase phase;

  /// Número de tablero repartido; cambia con cada tablero nuevo.
  final int round;
  final ShadowPosition position;

  /// Dónde van las sombras en este tablero (P13, P14).
  final ShadowLayout layout;

  /// Objetos de la bandeja, en su orden (emojis).
  final List<String> objects;

  /// Todas las sombras de la zona de sombras, en su orden: las de los objetos y
  /// las libres.
  final List<String> shadows;

  /// Objetos ya encajados en su sombra (R17: no se pueden mover).
  final Set<String> placed;

  /// Fallos de forma del tablero (R9).
  final int fails;

  final Duration elapsed;

  /// El cronómetro arranca al tocar el primer objeto (R7).
  final bool timerStarted;

  /// Reglas Premium en este tablero: el indicador muestra el nivel 8 con
  /// candado si es `false` (R11).
  final bool premium;

  /// Estrellas del tablero recién completado (fase [ShadowRoundPhase.celebrating]).
  final int? stars;

  /// El tablero recién completado dio la medalla (R10).
  final bool medalEarned;

  /// El niño ya tiene la medalla (permanente).
  final bool hasMedal;

  /// Dorado del juego, de 0 a 1 (HU-002).
  final double goldFraction;

  /// Ronda en juego (HU-037): da color a los puntos de nivel (P8).
  final GameDifficulty gameRound;

  /// Medalla de la ronda recién completada (fase [ShadowRoundPhase.celebrating]).
  final GameDifficulty? medal;

  /// Qué pasa tras perder (fase [ShadowRoundPhase.timeUp]), para el mensaje.
  final ShadowLoss? lossKind;

  int get level => position.level;

  /// Objetos que quedan en la bandeja.
  List<String> get trayObjects => [for (final object in objects) if (!placed.contains(object)) object];

  /// Si el objeto se puede arrastrar ahora.
  bool canDrag(String symbol) =>
      phase == ShadowRoundPhase.playing && objects.contains(symbol) && !placed.contains(symbol);

  /// Tiempo restante, o `null` si el tablero no tiene tiempo.
  Duration? get remaining {
    final Duration? limit = position.timeLimit;
    if (limit == null) return null;
    final Duration left = limit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }

  /// Fracción de tiempo restante (1 = barra llena), o `null` si no hay tiempo.
  double? get remainingFraction {
    final Duration? limit = position.timeLimit;
    final Duration? left = remaining;
    if (limit == null || left == null) return null;
    return left.inMilliseconds / limit.inMilliseconds;
  }

  ShadowGameState copyWith({
    ShadowRoundPhase? phase,
    Set<String>? placed,
    int? fails,
    Duration? elapsed,
    bool? timerStarted,
    int? stars,
    bool? medalEarned,
    bool? hasMedal,
    double? goldFraction,
    GameDifficulty? medal,
    ShadowLoss? lossKind,
  }) {
    return ShadowGameState(
      phase: phase ?? this.phase,
      round: round,
      position: position,
      layout: layout,
      objects: objects,
      shadows: shadows,
      placed: placed ?? this.placed,
      fails: fails ?? this.fails,
      elapsed: elapsed ?? this.elapsed,
      timerStarted: timerStarted ?? this.timerStarted,
      premium: premium,
      stars: stars ?? this.stars,
      medalEarned: medalEarned ?? this.medalEarned,
      hasMedal: hasMedal ?? this.hasMedal,
      goldFraction: goldFraction ?? this.goldFraction,
      gameRound: gameRound,
      medal: medal ?? this.medal,
      lossKind: lossKind ?? this.lossKind,
    );
  }
}
