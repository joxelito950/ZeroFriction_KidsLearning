import 'dart:async';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/parental_settings.dart';
import '../../../domain/parental/daily_play_time.dart';
import '../../../domain/repositories/i_persistence_repository.dart';

/// Estado del tiempo de juego diario (HU-009).
final class PlayTimeState {
  const PlayTimeState({
    required this.today,
    this.limitMinutes,
    this.boardInProgress = false,
    this.inAdultArea = false,
  });

  /// Lo jugado hoy y el tiempo extra dado.
  final DailyPlayTime today;

  /// Límite diario; `null` es «sin límite».
  final int? limitMinutes;

  /// Hay un tablero empezado o su celebración: no se corta (R4).
  final bool boardInProgress;

  /// Un adulto está en el desafío o en la Zona de Padres: no cuenta (R2).
  final bool inAdultArea;

  /// Ya se jugó todo lo permitido hoy.
  bool get limitReached => today.isOver(limitMinutes);

  /// Toca la pantalla de descanso: límite alcanzado, ningún tablero a medias y
  /// ningún adulto dentro (R4, R5).
  bool get mustRest => limitReached && !boardInProgress && !inAdultArea;

  PlayTimeState copyWith({
    DailyPlayTime? today,
    int? Function()? limitMinutes,
    bool? boardInProgress,
    bool? inAdultArea,
  }) {
    return PlayTimeState(
      today: today ?? this.today,
      limitMinutes: limitMinutes == null ? this.limitMinutes : limitMinutes(),
      boardInProgress: boardInProgress ?? this.boardInProgress,
      inAdultArea: inAdultArea ?? this.inAdultArea,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PlayTimeState &&
      other.today == today &&
      other.limitMinutes == limitMinutes &&
      other.boardInProgress == boardInProgress &&
      other.inAdultArea == inAdultArea;

  @override
  int get hashCode => Object.hash(today, limitMinutes, boardInProgress, inAdultArea);
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

  final IPersistenceRepository _repository;
  final DateTime Function() _now;

  ParentalSettings _settings = ParentalSettings.initial;
  Timer? _ticker;
  bool _started = false;
  bool _foreground = true;
  int _adultScreens = 0;
  Duration _unsaved = Duration.zero;

  /// Lee el límite y lo jugado hoy, y empieza a contar.
  Future<void> start() async {
    try {
      _settings = await _repository.readParentalSettings();
    } catch (error, stackTrace) {
      addError(error, stackTrace);
    }
    if (isClosed) return;
    final DateTime now = _now();
    emit(state.copyWith(
      today: _settings.playTime?.on(now) ?? DailyPlayTime.startOf(now),
      limitMinutes: () => _settings.dailyLimitMinutes,
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
      emit(state.copyWith(today: state.today.on(_now())));
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

  /// «15 minutos más» para hoy (R6). Sin límite no hace nada.
  Future<void> grantExtra() async {
    final int? limit = state.limitMinutes;
    if (limit == null) return;
    _emitAndUpdate(state.copyWith(today: state.today.grantExtra(limit, _now())));
    await _save();
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

  /// Con el límite alcanzado y sin tablero a medias no se suma nada: el tiempo
  /// frente a la pantalla de descanso no se come los minutos extra que dé un
  /// adulto. Aun así se mira el día, para que al día siguiente se pueda jugar.
  void _onTick() {
    if (isClosed) return;
    final DateTime now = _now();
    if (state.limitReached && !state.boardInProgress) {
      final DailyPlayTime today = state.today.on(now);
      if (today != state.today) emit(state.copyWith(today: today));
      return;
    }
    _unsaved += tick;
    emit(state.copyWith(today: state.today.add(tick, now)));
    if (_unsaved >= saveEvery) unawaited(_save());
  }

  /// Un fallo al guardar no interrumpe el juego; se reporta (D-010).
  Future<void> _save() async {
    _unsaved = Duration.zero;
    _settings = ParentalSettings(dailyLimitMinutes: state.limitMinutes, playTime: state.today);
    try {
      await _repository.saveParentalSettings(_settings);
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
