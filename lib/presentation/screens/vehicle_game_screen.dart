import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/sound/game_sound.dart';
import '../../domain/vehicles/vehicle_catalog.dart';
import '../../domain/vehicles/vehicle_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../blocs/sound/game_sound_events.dart';
import '../blocs/sound/sound_cubit.dart';
import '../blocs/vehicle_game/vehicle_game_cubit.dart';
import '../blocs/vehicle_game/vehicle_game_state.dart';
import '../theme/app_palette.dart';
import '../widgets/game_icon.dart';
import '../widgets/gesture_hint.dart';
import '../widgets/memory_level_indicator.dart';
import '../widgets/memory_round_overlay.dart';
import '../widgets/memory_time_bar.dart';
import '../widgets/protected_exit.dart';
import '../widgets/round_style.dart';
import '../widgets/vehicle_board_view.dart';

/// «A su sitio» (HU-052): llevar cada vehículo a su sitio. Sin botones dentro
/// del juego (D-022); se sale con «atrás» repetido (D-025).
class VehicleGameScreen extends StatelessWidget {
  const VehicleGameScreen({super.key, this.random, this.now, this.christmas});

  /// Inyectables para tests: azar del reparto, reloj y edición de Navidad.
  final Random? random;
  final DateTime Function()? now;
  final bool Function(DateTime now)? christmas;

  /// Un tablero ya tocado, o su celebración o su aviso, no se corta al llegar
  /// al límite diario (HU-009 R4). Uno recién repartido, sí.
  static bool boardInProgress(VehicleGameState state) => switch (state.phase) {
        VehiclePhase.playing => state.placed.isNotEmpty || state.fails > 0 || state.timerStarted,
        VehiclePhase.celebrating || VehiclePhase.timeUp || VehiclePhase.inviting => true,
        VehiclePhase.loading => false,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VehicleGameCubit>(
      create: (context) => VehicleGameCubit(
        repository: context.read<IPersistenceRepository>(),
        random: random,
        now: now,
        christmas: christmas,
      )..start(),
      child: const _VehicleGameView(),
    );
  }
}

class _VehicleGameView extends StatefulWidget {
  const _VehicleGameView();

  @override
  State<_VehicleGameView> createState() => _VehicleGameViewState();
}

class _VehicleGameViewState extends State<_VehicleGameView> with WidgetsBindingObserver {
  /// Claves por tablero para la mano del tutorial (HU-022): durante la
  /// transición conviven el tablero viejo y el nuevo.
  final Map<int, (GlobalKey, GlobalKey)> _hintKeys = {};

  (GlobalKey, GlobalKey) _hintKeysFor(int round) {
    _hintKeys.removeWhere((key, _) => key < round - 1);
    return _hintKeys.putIfAbsent(round, () => (GlobalKey(), GlobalKey()));
  }

  PlayTimeCubit? _playTime;
  SoundCubit? _sound;
  VehicleGameState _previous = const VehicleGameState();

  void _onState(VehicleGameState state) {
    _playTime?.setBoardInProgress(VehicleGameScreen.boardInProgress(state));
    final GameSound? sound = GameSoundEvents.vehicles(_previous, state);
    _previous = state;
    if (sound != null) _sound?.play(sound);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playTime = context.read<PlayTimeCubit?>();
    // El tiempo de esta pantalla cuenta para este juego (HU-034 R3).
    _playTime?.setCurrentGame(GameId.vehicles);
    _sound = context.read<SoundCubit?>();
  }

  @override
  void dispose() {
    _playTime?.setBoardInProgress(false);
    _playTime?.setCurrentGame(null);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El cronómetro se pausa con la app en segundo plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final VehicleGameCubit cubit = context.read<VehicleGameCubit>();
    if (lifecycle == AppLifecycleState.resumed) {
      cubit.resume();
    } else {
      cubit.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      // Como en los otros juegos: los textos crecen hasta 1,3 (TD-007).
      maxScaleFactor: 1.3,
      child: ProtectedExit(
        onExit: () => Navigator.of(context).pop(),
        child: Scaffold(
          body: ColoredBox(
            color: AppPalette.warmCream,
            child: SafeArea(
              child: BlocConsumer<VehicleGameCubit, VehicleGameState>(
                listener: (_, state) => _onState(state),
                builder: (context, state) {
                  final (GlobalKey vehicleKey, GlobalKey placeKey) = _hintKeysFor(state.round);
                  final List<Vehicle> tray = state.trayVehicles;
                  final Vehicle? hint = tray.isEmpty ? null : tray.first;
                  return Stack(
                    children: [
                      // Tutorial (HU-022): si el niño no toca nada, una mano lleva
                      // un vehículo a su sitio.
                      GestureHint(
                        boardId: state.round,
                        target: vehicleKey,
                        gesture: HintGesture.drag,
                        dragTo: placeKey,
                        dragGhost: hint == null ? null : FittedBox(child: Text(hint.symbol, textScaler: TextScaler.noScaling)),
                        enabled: state.phase == VehiclePhase.playing && hint != null,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(state: state),
                              if (state.remainingFraction case final double fraction) ...[
                                const SizedBox(height: 10),
                                MemoryTimeBar(fraction: fraction),
                              ],
                              const SizedBox(height: 12),
                              Expanded(
                                child: state.phase == VehiclePhase.loading
                                    ? const Center(child: CircularProgressIndicator.adaptive())
                                    : AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        child: VehicleBoardView(
                                          key: ValueKey<int>(state.round),
                                          state: state,
                                          onGrab: context.read<VehicleGameCubit>().grab,
                                          onDrop: (vehicle, box, places) =>
                                              context.read<VehicleGameCubit>().drop(vehicle, box: box, placeBoxes: places),
                                          onMatch: context.read<VehicleGameCubit>().match,
                                          hintVehicle: hint,
                                          hintVehicleKey: vehicleKey,
                                          hintPlaceKey: placeKey,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _overlayFor(context, state),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlayFor(BuildContext context, VehicleGameState state) => switch (state.phase) {
        VehiclePhase.celebrating =>
          MemoryCelebration(stars: state.stars ?? 0, badgeEarned: state.medal != null, medal: state.medal),
        VehiclePhase.inviting => PlayInvitation(round: state.gameRound),
        VehiclePhase.timeUp => MemoryTimeUpNotice(
            loss: switch (state.lossKind) {
              VehicleLoss.restart => MemoryLoss.restart,
              VehicleLoss.easierRound => MemoryLoss.easierRound,
              _ => MemoryLoss.fewerCards,
            },
            fewerMessage: AppLocalizations.of(context).vehiclesTimeUpFewerVehicles,
          ),
        _ => const SizedBox.shrink(),
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final VehicleGameState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Icono del juego, sin dorado: el dorado se ve en el menú (HU-002 R16).
            const GameIcon.vehicles(key: ValueKey<String>('vehicles-game-icon'), size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.vehiclesGameTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(
                    l10n.vehiclesGameInstructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            MemoryLevelIndicator(
              level: state.level,
              total: VehicleLadder.maxLevel,
              color: RoundStyle.colorOf(state.gameRound),
              rim: RoundStyle.rimOf(state.gameRound),
            ),
          ],
        ),
      ),
    );
  }
}
