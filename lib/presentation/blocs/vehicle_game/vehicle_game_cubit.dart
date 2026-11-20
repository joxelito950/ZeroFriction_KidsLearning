import 'dart:async';
import 'dart:math';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/news/edition_check.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/progress/round_ladder.dart';
import '../../../domain/progress/star_decay.dart';
import '../../../domain/repositories/i_persistence_repository.dart';
import '../../../domain/settings/access_policy.dart';
import '../../../domain/settings/game_difficulty.dart';
import '../../../domain/shadows/shadow_drop.dart';
import '../../../domain/vehicles/vehicle_board.dart';
import '../../../domain/vehicles/vehicle_catalog.dart';
import '../../../domain/vehicles/vehicle_drop.dart';
import '../../../domain/vehicles/vehicle_ladder.dart';
import 'vehicle_game_state.dart';

/// «A su sitio» (HU-052): tableros por nivel y ronda, encaje por la parte del
/// vehículo que cae sobre su sitio, fallos, estrellas, tiempo desde el oro,
/// guardado del progreso y paso automático, como Sombras.
class VehicleGameCubit extends Cubit<VehicleGameState> {
  VehicleGameCubit({
    required IPersistenceRepository repository,
    Random? random,
    DateTime Function()? now,
    bool Function(DateTime now)? christmas,
  })  : _repository = repository,
        _random = random ?? Random(),
        _now = now ?? DateTime.now,
        _christmas = christmas,
        super(const VehicleGameState());

  static const Duration tick = Duration(milliseconds: 100);
  static const Duration celebrationDuration = Duration(seconds: 2);
  static const Duration invitationDuration = Duration(milliseconds: 1500);
  static const Duration timeUpDuration = Duration(milliseconds: 2500);

  final IPersistenceRepository _repository;
  final Random _random;
  final DateTime Function() _now;

  /// Para los tests: si la edición de Navidad está abierta. Sin él, se mira
  /// el perfil con la protección del reloj (HU-042 R7 a R9).
  final bool Function(DateTime now)? _christmas;

  /// La edición está abierta en esta partida.
  bool _edition = false;

  /// Premium (o todo gratis durante la prueba cerrada, D-040).
  bool _premium = false;

  static final RoundLadder _ladder = VehicleLadder.rounds;

  GameProgress _progress = GameProgress.initial();
  RoundPosition _position = GameProgress.initial().position;
  VehicleRules _rules = const VehicleRules(round: GameDifficulty.bronze);
  Timer? _ticker;
  Timer? _transition;
  bool _paused = false;

  /// Lee el progreso, aplica la pérdida de estrellas (D-037) y reparte el
  /// tablero guardado.
  Future<void> start() async {
    try {
      _progress = await _repository.readGameProgress(GameId.vehicles);
      await _settleStars();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    final bool Function(DateTime now)? christmas = _christmas;
    _edition = christmas != null
        ? christmas(_now())
        : (await EditionCheck.openNow(_repository, now: _now())).contains(GameId.vehicles);
    final bool timerDisabled = await _readTimerDisabled();
    if (isClosed) return;
    _deal(_progress.position, timerDisabled: timerDisabled);
  }

  Future<void> _settleStars() async {
    ParentalSettings settings = ParentalSettings.initial;
    try {
      settings = await _repository.readParentalSettings();
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
    _progress = StarDecay.settle(_progress, settings: settings, now: _now());
    await _saveProgress();
  }

  /// «Jugar sin tiempo» solo cuenta con Premium (HU-030 R11).
  Future<bool> _readTimerDisabled() async {
    try {
      final ParentalSettings settings = await _repository.readParentalSettings();
      final bool premium =
          AccessPolicy.hasPremium(purchased: (await _repository.readUserProfile())?.isPremium ?? false);
      _premium = premium;
      return settings.timerDisabled && premium;
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
      return false;
    }
  }

  /// El niño toca un vehículo de la bandeja: arranca el cronómetro.
  void grab(Vehicle vehicle) {
    if (state.canDrag(vehicle)) _startTimerIfNeeded();
  }

  /// Suelta [vehicle] en [box]. [placeBoxes] son las cajas en pantalla de los
  /// sitios. Devuelve qué pasó para que la pantalla lo anime.
  ShadowDropOutcome drop(Vehicle vehicle, {required ShadowBox box, required Map<Place, ShadowBox> placeBoxes}) {
    final VehicleBoard? board = state.board;
    if (board == null || !state.canDrag(vehicle)) return ShadowDropOutcome.missed;
    _startTimerIfNeeded();
    final ShadowDropOutcome outcome = VehicleDrop.evaluate(
      target: board.targetOf(vehicle),
      vehicle: box,
      places: placeBoxes,
      threshold: state.coverageToSnap,
    );
    _apply(vehicle, outcome);
    return outcome;
  }

  /// Sin arrastrar (lector de pantalla): se eligió [vehicle] y después [place].
  ShadowDropOutcome match(Vehicle vehicle, Place place) {
    final VehicleBoard? board = state.board;
    if (board == null || !state.canDrag(vehicle) || !board.places.contains(place)) return ShadowDropOutcome.missed;
    _startTimerIfNeeded();
    final ShadowDropOutcome outcome =
        board.accepts(place, vehicle) ? ShadowDropOutcome.snapped : ShadowDropOutcome.wrongShadow;
    _apply(vehicle, outcome);
    return outcome;
  }

  /// Un acierto o un fallo es un movimiento; soltar fuera de los sitios, no
  /// (HU-039 R7).
  void _apply(Vehicle vehicle, ShadowDropOutcome outcome) {
    switch (outcome) {
      case ShadowDropOutcome.snapped:
        final Set<Vehicle> placed = {...state.placed, vehicle};
        emit(state.copyWith(placed: placed, moves: state.moves + 1));
        if (state.vehicles.every(placed.contains)) _win();
      case ShadowDropOutcome.wrongShadow:
        emit(state.copyWith(fails: state.fails + 1, moves: state.moves + 1));
      case ShadowDropOutcome.missed:
        break;
    }
  }

  void pause() => _paused = true;

  void resume() => _paused = false;

  void _deal(RoundPosition saved, {required bool timerDisabled}) {
    _stopTimer();
    // Sin Premium y fuera de la edición, del oro en adelante se juega la plata
    // (D-043); lo ganado se conserva.
    final GameDifficulty round = VehicleLadder.playableRound(saved.round, premium: _premium, edition: _edition);
    final bool downgraded = round != saved.round;
    _rules = VehicleRules(round: round, timerDisabled: timerDisabled, christmas: _edition);
    final int level = downgraded ? RoundLadder.firstTimedLevel : saved.level.clamp(1, VehicleLadder.maxLevel);
    _position = RoundPosition(
      round: round,
      level: level,
      timeLimit: _ladder.limitFor(round, level, timed: _rules.timed),
      tutorialFalls: downgraded ? 0 : saved.tutorialFalls,
    );
    emit(VehicleGameState(
      phase: VehiclePhase.playing,
      round: state.round + 1,
      level: level,
      timeLimit: _position.timeLimit,
      board: VehicleBoard.pick(_random, VehicleLadder.levelAt(level), _rules),
      placesFirst: !_rules.randomLayout || _random.nextBool(),
      coverageToSnap: _rules.coverageToSnap,
      gameRound: round,
      christmas: _rules.christmas,
    ));
  }

  void _startTimerIfNeeded() {
    if (state.timeLimit == null || state.timerStarted) return;
    emit(state.copyWith(timerStarted: true));
    _ticker = Timer.periodic(tick, (_) => _onTick());
  }

  void _onTick() {
    if (_paused || state.phase != VehiclePhase.playing) return;
    final Duration elapsed = state.elapsed + tick;
    if (elapsed >= state.timeLimit!) {
      _timeUp();
    } else {
      emit(state.copyWith(elapsed: elapsed));
    }
  }

  void _win() {
    _stopTimer();
    final RoundPosition won = _position;
    // El tutorial no da estrellas (HU-037 P2).
    final int stars = won.isTutorial
        ? 0
        : VehicleStars.forWin(vehicles: VehicleLadder.levelAt(won.level).vehicles, fails: state.fails);
    final RoundStep step = _ladder.afterWin(won, timed: _rules.timed);
    _progress = _progress.recordWin(won: won, stars: stars, step: step, at: _now());
    unawaited(_saveProgress());
    if (step.fromTutorial) {
      emit(state.copyWith(phase: VehiclePhase.inviting));
      _scheduleNext(invitationDuration, step.next);
      return;
    }
    emit(state.copyWith(phase: VehiclePhase.celebrating, stars: stars, medal: step.medal));
    _scheduleNext(celebrationDuration, step.next);
  }

  void _timeUp() {
    _stopTimer();
    final RoundStep step = _ladder.afterLoss(_position, timed: _rules.timed);
    _progress = _progress.recordLoss(lost: _position, step: step, at: _now());
    unawaited(_saveProgress());
    emit(state.copyWith(
      phase: VehiclePhase.timeUp,
      elapsed: state.timeLimit,
      lossKind: step.droppedRound
          ? VehicleLoss.easierRound
          : step.retry
              ? VehicleLoss.restart
              : VehicleLoss.fewerVehicles,
    ));
    _scheduleNext(timeUpDuration, step.next);
  }

  /// Antes del tablero siguiente se vuelve a leer «Jugar sin tiempo».
  void _scheduleNext(Duration delay, RoundPosition next) {
    _transition?.cancel();
    _transition = Timer(delay, () async {
      if (isClosed) return;
      final bool timerDisabled = await _readTimerDisabled();
      if (isClosed) return;
      _deal(next, timerDisabled: timerDisabled);
    });
  }

  Future<void> _saveProgress() async {
    try {
      await _repository.saveGameProgress(GameId.vehicles, _progress);
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  void _stopTimer() {
    _ticker?.cancel();
    _ticker = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    _transition?.cancel();
    return super.close();
  }
}
