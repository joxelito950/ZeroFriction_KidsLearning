import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/parental/daily_play_time.dart';
import '../../../domain/parental/play_history.dart';
import '../../../domain/parental/rest_schedule.dart';
import '../../../domain/progress/game_progress.dart';
import '../../../domain/repositories/i_persistence_repository.dart';

/// Estado del tiempo de juego diario (HU-009) y de la hora de dormir (HU-038).
final class PlayTimeState {
  const PlayTimeState({
    required this.today,
    this.limitMinutes,
    this.boardInProgress = false,
    this.inAdultArea = false,
    this.history,
    this.schedule = RestSchedule.off,
    this.scheduledRest,
    this.windDown = 0,
  });

  /// Lo jugado hoy y el tiempo extra dado.
  final DailyPlayTime today;

  /// Límite diario; `null` es «sin límite».
  final int? limitMinutes;

  /// Hay un tablero empezado o su celebración: no se corta (R4).
  final bool boardInProgress;

  /// Un adulto está en el desafío o en la Zona de Padres: no cuenta (R2).
  final bool inAdultArea;

  /// Tiempo por día y por juego de hoy y los 5 días anteriores (HU-034 R3);
  /// `null` hasta que se lee. Cuenta lo mismo que [today].
  final PlayHistory? history;

  /// La hora de dormir y las siestas guardadas (HU-038).
  final RestSchedule schedule;

  /// El descanso del horario que toca ahora, sin «15 minutos más» en curso;
  /// `null` fuera del horario (HU-038 R1, R2).
  final RestKind? scheduledRest;

  /// La preparación para dormir (HU-038 R10, R11): 0 fuera de ella, sube
  /// hasta 1 en los 30 minutos antes y vale 1 durante el descanso.
  final double windDown;

  /// En la preparación o en el descanso: sin sonidos de celebración (R10).
  bool get windingDown => windDown > 0;

  /// Ya se jugó todo lo permitido hoy.
  bool get limitReached => today.isOver(limitMinutes);

  /// No se puede jugar: por el límite diario o por el horario. Manda el que
  /// llegue primero (HU-038 R5).
  bool get restDue => limitReached || scheduledRest != null;

  /// Toca la pantalla de descanso: hay que descansar, ningún tablero a medias
  /// y ningún adulto dentro (R4, R5; HU-038 R2).
  bool get mustRest => restDue && !boardInProgress && !inAdultArea;

  PlayTimeState copyWith({
    DailyPlayTime? today,
    int? Function()? limitMinutes,
    bool? boardInProgress,
    bool? inAdultArea,
    PlayHistory? history,
    RestSchedule? schedule,
    RestKind? Function()? scheduledRest,
    double? windDown,
  }) {
    return PlayTimeState(
      today: today ?? this.today,
      limitMinutes: limitMinutes == null ? this.limitMinutes : limitMinutes(),
      boardInProgress: boardInProgress ?? this.boardInProgress,
      inAdultArea: inAdultArea ?? this.inAdultArea,
      history: history ?? this.history,
      schedule: schedule ?? this.schedule,
      scheduledRest: scheduledRest == null ? this.scheduledRest : scheduledRest(),
      windDown: windDown ?? this.windDown,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayTimeState &&
      other.today == today &&
      other.limitMinutes == limitMinutes &&
      other.boardInProgress == boardInProgress &&
      other.inAdultArea == inAdultArea &&
      other.history == history &&
      other.schedule == schedule &&
      other.scheduledRest == scheduledRest &&
      other.windDown == windDown;

  @override
  int get hashCode =>
      Object.hash(today, limitMinutes, boardInProgress, inAdultArea, history, schedule, scheduledRest, windDown);
}

/// Mide el tiempo con la app en primer plano, fuera de las pantallas de
/// adultos (R2), lo guarda en el teléfono (R8) y aplica el límite (R4–R7).
class PlayTimeCubit extends Cubit<PlayTimeState> {
  PlayTimeCubit({
    required IPersistenceRepository repository,
    DateTime Function()? now,
  })  : _repository = repository,
        _now = now ?? DateTime.now,
        super(PlayTimeState(today: DailyPlayTime.startOf((now ?? DateTime.now)())));

  /// Cada cuánto se suma tiempo.
  static const Duration tick = Duration(seconds: 1);

  /// Cada cuánto se guarda mientras se juega; también se guarda al salir.
  static const Duration saveEvery = Duration(seconds: 30);

  /// Los «15 minutos más» (R6; HU-038 R5).
  static const Duration extraTime = Duration(minutes: 15);

  final IPersistenceRepository _repository;
  final DateTime Function() _now;

  ParentalSettings _settings = ParentalSettings.initial;
  Timer? _ticker;
  bool _started = false;
  bool _foreground = true;
  int _adultScreens = 0;
  Duration _unsaved = Duration.zero;

  /// Juego abierto, al que se suma el tiempo (HU-034 R3); `null` en el menú.
  GameId? _currentGame;

  /// Lee el límite y lo jugado hoy, y empieza a contar.
  Future<void> start() async {
    try {
      _settings = await _repository.readParentalSettings();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    PlayHistory history = PlayHistory(const []);
    try {
      history = await _repository.readPlayHistory(_now());
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    final DateTime now = _now();
    emit(state.copyWith(
      today: _settings.playTime?.on(now) ?? DailyPlayTime.startOf(now),
      limitMinutes: () => _settings.dailyLimitMinutes,
      history: history,
      schedule: _settings.restSchedule,
      scheduledRest: () => _restAt(_settings.restSchedule, now),
      windDown: _settings.restSchedule.windDownAt(now),
    ));
    _started = true;
    _updateTicker();
  }

  /// Solo cuenta con la app en primer plano y la pantalla encendida (R2, criterio 6).
  void setForeground(bool foreground) {
    if (isClosed || foreground == _foreground) return;
    _foreground = foreground;
    if (!foreground) {
      unawaited(_save());
    } else if (_started) {
      final DateTime now = _now();
      emit(state.copyWith(
        today: state.today.on(now),
        scheduledRest: () => _restAt(state.schedule, now),
        windDown: state.schedule.windDownAt(now),
      ));
    }
    _updateTicker();
  }

  /// Entra una pantalla de adultos (desafío o Zona de Padres). Se cuentan, porque
  /// al pasar del desafío a la Zona de Padres conviven un momento.
  void enterAdultArea() {
    _adultScreens++;
    if (_adultScreens == 1) _emitAndUpdate(state.copyWith(inAdultArea: true));
  }

  void leaveAdultArea() {
    if (_adultScreens == 0) return;
    _adultScreens--;
    if (_adultScreens == 0) _emitAndUpdate(state.copyWith(inAdultArea: false));
  }

  /// El juego que se abre (o `null` al volver al menú): su tiempo se guarda
  /// aparte en el historial (HU-034 R3).
  void setCurrentGame(GameId? game) => _currentGame = game;

  /// El juego avisa de si hay un tablero empezado (R4).
  void setBoardInProgress(bool inProgress) {
    if (isClosed || inProgress == state.boardInProgress) return;
    emit(state.copyWith(boardInProgress: inProgress));
  }

  /// Cambia el límite al instante (R7). `null` es «sin límite».
  Future<void> setLimit(int? minutes) async {
    if (minutes != null && !ParentalSettings.isValidLimit(minutes)) {
      throw RangeError.range(minutes, ParentalSettings.minLimitMinutes, ParentalSettings.maxLimitMinutes);
    }
    _emitAndUpdate(state.copyWith(limitMinutes: () => minutes));
    await _save();
  }

  /// Cambia la hora de dormir y las siestas al instante (HU-038). Un horario
  /// que no cumple R7 o R7a no se guarda.
  Future<void> setSchedule(RestSchedule schedule) async {
    if (!schedule.isValid) throw ArgumentError.value(schedule.problem, 'schedule');
    final DateTime now = _now();
    _emitAndUpdate(state.copyWith(
      schedule: schedule,
      scheduledRest: () => _restAt(schedule, now),
      windDown: schedule.windDownAt(now),
    ));
    try {
      _settings = await _repository.updateParentalSettings((current) => current.withRestSchedule(schedule));
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  /// «15 minutos más» (R6): durante la hora de dormir o una siesta, deja jugar
  /// 15 minutos (HU-038 R5); con el límite diario, los suma a hoy. Sin límite
  /// ni descanso, no hace nada.
  Future<void> grantExtra() async {
    final DateTime now = _now();
    final int? limit = state.limitMinutes;
    final bool scheduled = state.scheduledRest != null;
    if (limit == null && !scheduled) return;
    PlayTimeState next = state;
    if (scheduled) {
      _settings = _settings.withRestAllowedUntil(now.add(extraTime));
      next = next.copyWith(scheduledRest: () => null);
    }
    if (limit != null && (state.limitReached || !scheduled)) {
      next = next.copyWith(today: next.today.grantExtra(limit, now));
    }
    _emitAndUpdate(next);
    await _save();
  }

  /// El descanso del horario a [now], salvo que haya «15 minutos más» en curso.
  RestKind? _restAt(RestSchedule schedule, DateTime now) {
    final DateTime? allowedUntil = _settings.restAllowedUntil;
    if (allowedUntil != null && now.isBefore(allowedUntil)) return null;
    return schedule.activeAt(now);
  }

  void _emitAndUpdate(PlayTimeState next) {
    if (isClosed) return;
    emit(next);
    _updateTicker();
  }

  bool get _ticking => _started && _foreground && !state.inAdultArea;

  void _updateTicker() {
    if (_ticking) {
      _ticker ??= Timer.periodic(tick, (_) => _onTick());
    } else {
      _ticker?.cancel();
      _ticker = null;
    }
  }

  /// Con el descanso debido y sin tablero a medias no se suma nada: el tiempo
  /// frente a la pantalla de descanso no se come los minutos extra que dé un
  /// adulto. Aun así se mira el día y la hora, para que al día siguiente, o al
  /// acabar la noche o la siesta, se pueda jugar (HU-038 R6).
  void _onTick() {
    if (isClosed) return;
    final DateTime now = _now();
    final RestKind? scheduledRest = _restAt(state.schedule, now);
    final double windDown = state.schedule.windDownAt(now);
    if (scheduledRest != state.scheduledRest || windDown != state.windDown) {
      emit(state.copyWith(scheduledRest: () => scheduledRest, windDown: windDown));
    }
    if (state.restDue && !state.boardInProgress) {
      final DailyPlayTime today = state.today.on(now);
      if (today != state.today) emit(state.copyWith(today: today));
      return;
    }
    _unsaved += tick;
    emit(state.copyWith(
      today: state.today.add(tick, now),
      history: state.history?.add(_currentGame, tick, now),
    ));
    if (_unsaved >= saveEvery) unawaited(_save());
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _save() async {
    _unsaved = Duration.zero;
    final int? limit = state.limitMinutes;
    final DailyPlayTime today = state.today;
    final PlayDay? day = state.history?.dayAt(today.day);
    final DateTime? allowedUntil = _settings.restAllowedUntil;
    try {
      if (day != null && day.total > Duration.zero) await _repository.savePlayDay(day);
      // Solo sus dos campos: la dificultad y «Jugar sin tiempo» los guarda la
      // sección «Juegos» (HU-030) y no se deben pisar.
      _settings = await _repository.updateParentalSettings(
        (current) => current.withLimit(limit).withPlayTime(today).withRestAllowedUntil(allowedUntil),
      );
    } catch (error, stackTrace) {
      if (!isClosed) addError(error, stackTrace);
    }
  }

  @override
  Future<void> close() async {
    _ticker?.cancel();
    if (_started) await _save();
    return super.close();
  }
}
