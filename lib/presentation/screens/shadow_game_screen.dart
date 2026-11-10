import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/shadows/shadow_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../blocs/shadow_game/shadow_game_cubit.dart';
import '../blocs/shadow_game/shadow_game_state.dart';
import '../theme/app_palette.dart';
import '../widgets/gesture_hint.dart';
import '../widgets/memory_level_indicator.dart';
import '../widgets/memory_round_overlay.dart';
import '../widgets/memory_time_bar.dart';
import '../widgets/protected_exit.dart';
import '../widgets/shadow_board.dart';

/// Juego Sombras (HU-007): arrastrar cada objeto hasta su sombra. Sin botones
/// dentro del juego (D-022); se sale con «atrás» repetido (D-025).
class ShadowGameScreen extends StatelessWidget {
  const ShadowGameScreen({super.key, this.random, this.now});

  /// Inyectables para tests: azar del reparto y reloj del guardado.
  final Random? random;
  final DateTime Function()? now;

  /// Un tablero ya tocado, o su celebración o su aviso de tiempo, no se corta
  /// al llegar al límite diario (HU-009 R4). Uno recién repartido, sí.
  static bool boardInProgress(ShadowGameState state) {
    return switch (state.phase) {
      ShadowRoundPhase.playing => state.placed.isNotEmpty || state.fails > 0 || state.timerStarted,
      ShadowRoundPhase.celebrating || ShadowRoundPhase.timeUp => true,
      _ => false,
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ShadowGameCubit>(
      create: (context) => ShadowGameCubit(
        repository: context.read<IPersistenceRepository>(),
        random: random,
        now: now,
      )..start(),
      child: const _ShadowGameView(),
    );
  }
}

class _ShadowGameView extends StatefulWidget {
  const _ShadowGameView();

  @override
  State<_ShadowGameView> createState() => _ShadowGameViewState();
}

class _ShadowGameViewState extends State<_ShadowGameView> with WidgetsBindingObserver {
  /// Claves por tablero para la mano del tutorial (HU-022, R15): durante la
  /// transición conviven el tablero viejo y el nuevo.
  final Map<int, (GlobalKey, GlobalKey)> _hintKeys = {};

  (GlobalKey, GlobalKey) _hintKeysFor(int round) {
    _hintKeys.removeWhere((key, _) => key < round - 1);
    return _hintKeys.putIfAbsent(round, () => (GlobalKey(), GlobalKey()));
  }

  /// Tiempo de juego diario (HU-009); no está en algunos tests.
  PlayTimeCubit? _playTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playTime = context.read<PlayTimeCubit?>();
  }

  @override
  void dispose() {
    _playTime?.setBoardInProgress(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El cronómetro se pausa con la app en segundo plano (R7).
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final cubit = context.read<ShadowGameCubit>();
    if (lifecycle == AppLifecycleState.resumed) {
      cubit.resume();
    } else {
      cubit.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      // Como en la memoria: los textos del juego crecen hasta 1,3 (TD-007).
      maxScaleFactor: 1.3,
      child: ProtectedExit(
        onExit: () => Navigator.of(context).pop(),
        child: Scaffold(
          body: ColoredBox(
            color: AppPalette.warmCream,
            child: SafeArea(
              child: BlocConsumer<ShadowGameCubit, ShadowGameState>(
                listener: (_, state) => _playTime?.setBoardInProgress(ShadowGameScreen.boardInProgress(state)),
                builder: (context, state) {
                  final (GlobalKey objectKey, GlobalKey shadowKey) = _hintKeysFor(state.round);
                  final List<String> tray = state.trayObjects;
                  final String? hintSymbol = tray.isEmpty ? null : tray.first;
                  return Stack(
                    children: [
                      // Tutorial (R15): si el niño no toca nada, una mano lleva un objeto a su sombra.
                      GestureHint(
                        boardId: state.round,
                        target: objectKey,
                        gesture: HintGesture.drag,
                        dragTo: shadowKey,
                        dragGhost: hintSymbol == null
                            ? null
                            : FittedBox(child: Text(hintSymbol, textScaler: TextScaler.noScaling)),
                        enabled: state.phase == ShadowRoundPhase.playing && hintSymbol != null,
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
                                child: _Board(
                                  state: state,
                                  hintSymbol: hintSymbol,
                                  hintObjectKey: objectKey,
                                  hintShadowKey: shadowKey,
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

  Widget _overlayFor(BuildContext context, ShadowGameState state) {
    return switch (state.phase) {
      ShadowRoundPhase.celebrating => MemoryCelebration(stars: state.stars ?? 0, badgeEarned: state.medalEarned),
      ShadowRoundPhase.timeUp => MemoryTimeUpNotice(
          loss: state.level == 1 ? MemoryLoss.restart : MemoryLoss.fewerCards,
          fewerMessage: AppLocalizations.of(context).shadowsTimeUpFewerObjects,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.state, this.hintSymbol, required this.hintObjectKey, required this.hintShadowKey});

  final ShadowGameState state;
  final String? hintSymbol;
  final GlobalKey hintObjectKey;
  final GlobalKey hintShadowKey;

  @override
  Widget build(BuildContext context) {
    if (state.phase == ShadowRoundPhase.loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final cubit = context.read<ShadowGameCubit>();
    // Las cajas del tablero son físicas (`Positioned` con left/top): en árabe
    // las sombras siguen a la izquierda, porque depende de la mano (4.1).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: ShadowBoard(
        key: ValueKey<int>(state.round),
        state: state,
        onGrab: cubit.grab,
        onDrop: (symbol, object, shadows) => cubit.drop(symbol, object: object, shadowBoxes: shadows),
        onMatch: cubit.match,
        onIntroDone: cubit.finishIntro,
        hintSymbol: hintSymbol,
        hintObjectKey: hintObjectKey,
        hintShadowKey: hintShadowKey,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final ShadowGameState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.shadowsGameTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(
                    l10n.shadowsGameInstructions,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Sin Premium, el nivel 8 se ve con un candado sutil (R11).
            MemoryLevelIndicator(
              level: state.level,
              total: ShadowLadder.maxLevel,
              lockedLevel: state.premium ? null : ShadowLadder.maxLevel,
            ),
          ],
        ),
      ),
    );
  }
}
