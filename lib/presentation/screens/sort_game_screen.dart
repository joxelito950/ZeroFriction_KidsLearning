import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/progress/game_progress.dart';
import '../../domain/progress/helps.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/sorting/sort_board.dart';
import '../../domain/sorting/sort_ladder.dart';
import '../../domain/sound/game_sound.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../blocs/sort_game/sort_game_cubit.dart';
import '../blocs/sort_game/sort_game_state.dart';
import '../blocs/sound/game_sound_events.dart';
import '../blocs/sound/sound_cubit.dart';
import '../theme/app_palette.dart';
import '../widgets/game_header.dart';
import '../widgets/game_icon.dart';
import '../widgets/gesture_hint.dart';
import '../widgets/memory_level_indicator.dart';
import '../widgets/memory_round_overlay.dart';
import '../widgets/memory_time_bar.dart';
import '../widgets/protected_exit.dart';
import '../widgets/round_style.dart';
import '../widgets/sort_board_view.dart';

/// «Clasificar» (HU-027): llevar cada objeto a la cesta de su color. Sin
/// botones dentro del juego (D-022); se sale con «atrás» repetido (D-025).
class SortGameScreen extends StatelessWidget {
  const SortGameScreen({super.key, this.random, this.now});

  /// Inyectables para tests: azar del reparto y reloj.
  final Random? random;
  final DateTime Function()? now;

  /// Un tablero ya tocado, o su celebración o su aviso, no se corta al llegar
  /// al límite diario (HU-009 R4). Uno recién repartido, sí.
  static bool boardInProgress(SortGameState state) => switch (state.phase) {
        SortPhase.playing => state.placed.isNotEmpty || state.fails > 0 || state.timerStarted,
        SortPhase.celebrating || SortPhase.timeUp || SortPhase.inviting => true,
        SortPhase.loading => false,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SortGameCubit>(
      create: (context) =>
          SortGameCubit(repository: context.read<IPersistenceRepository>(), random: random, now: now)..start(),
      child: const _SortGameView(),
    );
  }
}

class _SortGameView extends StatefulWidget {
  const _SortGameView();

  @override
  State<_SortGameView> createState() => _SortGameViewState();
}

class _SortGameViewState extends State<_SortGameView> with WidgetsBindingObserver {
  /// Claves por tablero para la mano del tutorial (HU-022): durante la
  /// transición conviven el tablero viejo y el nuevo.
  final Map<int, (GlobalKey, GlobalKey)> _hintKeys = {};

  (GlobalKey, GlobalKey) _hintKeysFor(int round) {
    _hintKeys.removeWhere((key, _) => key < round - 1);
    return _hintKeys.putIfAbsent(round, () => (GlobalKey(), GlobalKey()));
  }

  PlayTimeCubit? _playTime;
  SoundCubit? _sound;
  SortGameState _previous = const SortGameState();

  void _onState(SortGameState state) {
    _playTime?.setBoardInProgress(SortGameScreen.boardInProgress(state));
    final GameSound? sound = GameSoundEvents.sorting(_previous, state);
    _previous = state;
    if (sound != null) _sound?.play(sound);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playTime = context.read<PlayTimeCubit?>();
    // El tiempo de esta pantalla cuenta para este juego (HU-034 R3).
    _playTime?.setCurrentGame(GameId.sorting);
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
    final SortGameCubit cubit = context.read<SortGameCubit>();
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
              child: BlocConsumer<SortGameCubit, SortGameState>(
                listener: (_, state) => _onState(state),
                builder: (context, state) {
                  final (GlobalKey pieceKey, GlobalKey basketKey) = _hintKeysFor(state.round);
                  final List<SortPiece> tray = state.trayPieces;
                  final SortPiece? hint = tray.isEmpty ? null : tray.first;
                  return Stack(
                    children: [
                      // Tutorial (HU-022): si el niño no toca nada, una mano lleva
                      // un objeto a su cesta, solo en el tutorial y en bronce ([Helps]).
                      GestureHint(
                        boardId: state.round,
                        target: pieceKey,
                        gesture: HintGesture.drag,
                        dragTo: basketKey,
                        dragGhost: hint == null
                            ? null
                            : FittedBox(child: Text(hint.object.symbol, textScaler: TextScaler.noScaling)),
                        enabled: Helps.allowedAt(state.gameRound, state.level) &&
                            state.phase == SortPhase.playing &&
                            hint != null,
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
                                child: state.phase == SortPhase.loading
                                    ? const Center(child: CircularProgressIndicator.adaptive())
                                    : AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        child: SortBoardView(
                                          key: ValueKey<int>(state.round),
                                          state: state,
                                          onGrab: context.read<SortGameCubit>().grab,
                                          onDrop: (id, box, baskets) =>
                                              context.read<SortGameCubit>().drop(id, box: box, basketBoxes: baskets),
                                          onMatch: context.read<SortGameCubit>().match,
                                          hintPiece: hint?.id,
                                          hintPieceKey: pieceKey,
                                          hintBasketKey: basketKey,
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

  Widget _overlayFor(BuildContext context, SortGameState state) => switch (state.phase) {
        SortPhase.celebrating => MemoryCelebration(
            stars: state.stars ?? 0,
            badgeEarned: state.medal != null,
            medal: state.medal,
            message: AppLocalizations.of(context).sortingVictoryMessage,
          ),
        SortPhase.inviting => PlayInvitation(round: state.gameRound),
        SortPhase.timeUp => MemoryTimeUpNotice(
            loss: switch (state.lossKind) {
              SortLoss.restart => MemoryLoss.restart,
              SortLoss.easierRound => MemoryLoss.easierRound,
              _ => MemoryLoss.fewerCards,
            },
            fewerMessage: AppLocalizations.of(context).sortingTimeUpFewerObjects,
          ),
        _ => const SizedBox.shrink(),
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final SortGameState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GameHeader(
      icon: const GameIcon.sorting(key: ValueKey<String>('sorting-game-icon'), size: 44),
      title: l10n.sortingGameTitle,
      instructions: l10n.sortingGameInstructions,
      instructionsMaxLines: 2,
      moves: state.moves,
      levelIndicator: MemoryLevelIndicator(
        level: state.level,
        total: SortLadder.maxLevel,
        color: RoundStyle.colorOf(state.gameRound),
        rim: RoundStyle.rimOf(state.gameRound),
        round: state.gameRound,
      ),
    );
  }
}
