import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/odd_one_out/odd_one_out.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../domain/sound/game_sound.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/odd_one_out/odd_one_out_cubit.dart';
import '../blocs/odd_one_out/odd_one_out_state.dart';
import '../blocs/play_time/play_time_cubit.dart';
import '../blocs/sound/game_sound_events.dart';
import '../blocs/sound/sound_cubit.dart';
import '../theme/app_palette.dart';
import '../widgets/game_icon.dart';
import '../widgets/gesture_hint.dart';
import '../widgets/memory_level_indicator.dart';
import '../widgets/memory_round_overlay.dart';
import '../widgets/memory_time_bar.dart';
import '../widgets/protected_exit.dart';
import '../widgets/round_style.dart';

/// «¿Cuál es diferente?» (HU-025): tocar el objeto que no es como los demás. Sin
/// botones dentro del juego (D-022); se sale con «atrás» repetido (D-025).
class OddOneOutScreen extends StatelessWidget {
  const OddOneOutScreen({super.key, this.random, this.now});

  final math.Random? random;
  final DateTime Function()? now;

  /// Un tablero ya tocado, o su celebración o su aviso, no se corta al llegar
  /// al límite diario (HU-009 R4).
  static bool boardInProgress(OddOneOutState state) => switch (state.phase) {
        OddPhase.playing => state.timerStarted || state.fails > 0 || state.board > 0,
        OddPhase.solved || OddPhase.celebrating || OddPhase.inviting || OddPhase.timeUp => true,
        OddPhase.loading => false,
      };

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OddOneOutCubit>(
      create: (context) =>
          OddOneOutCubit(repository: context.read<IPersistenceRepository>(), random: random, now: now)..start(),
      child: const _OddOneOutView(),
    );
  }
}

class _OddOneOutView extends StatefulWidget {
  const _OddOneOutView();

  @override
  State<_OddOneOutView> createState() => _OddOneOutViewState();
}

class _OddOneOutViewState extends State<_OddOneOutView> with WidgetsBindingObserver {
  final Map<int, GlobalKey> _hintKeys = {};
  PlayTimeCubit? _playTime;
  SoundCubit? _sound;
  OddOneOutState _previous = const OddOneOutState();

  GlobalKey _hintKeyFor(int round) {
    _hintKeys.removeWhere((key, _) => key < round - 1);
    return _hintKeys.putIfAbsent(round, GlobalKey.new);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _playTime = context.read<PlayTimeCubit?>();
    _sound = context.read<SoundCubit?>();
  }

  @override
  void dispose() {
    _playTime?.setBoardInProgress(false);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final cubit = context.read<OddOneOutCubit>();
    if (lifecycle == AppLifecycleState.resumed) {
      cubit.resume();
    } else {
      cubit.pause();
    }
  }

  void _onState(OddOneOutState state) {
    _playTime?.setBoardInProgress(OddOneOutScreen.boardInProgress(state));
    final GameSound? sound = GameSoundEvents.oddOneOut(_previous, state);
    _previous = state;
    if (sound != null) _sound?.play(sound);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: ProtectedExit(
        onExit: () => Navigator.of(context).pop(),
        child: Scaffold(
          body: ColoredBox(
            color: AppPalette.warmCream,
            child: SafeArea(
              child: BlocConsumer<OddOneOutCubit, OddOneOutState>(
                listener: (_, state) => _onState(state),
                builder: (context, state) {
                  final GlobalKey hintKey = _hintKeyFor(state.round);
                  return Stack(
                    children: [
                      // Tutorial (HU-022): si el niño no toca nada, la mano toca el diferente.
                      GestureHint(
                        boardId: state.round,
                        target: hintKey,
                        enabled: state.phase == OddPhase.playing && state.objects.isNotEmpty,
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
                              Expanded(child: _Board(state: state, hintKey: hintKey)),
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

  Widget _overlayFor(BuildContext context, OddOneOutState state) => switch (state.phase) {
        OddPhase.celebrating =>
          MemoryCelebration(stars: state.stars ?? 0, badgeEarned: state.medal != null, medal: state.medal),
        OddPhase.inviting => PlayInvitation(round: state.gameRound),
        OddPhase.timeUp => MemoryTimeUpNotice(
            loss: switch (state.loss) {
              OddLoss.restart => MemoryLoss.restart,
              OddLoss.easierRound => MemoryLoss.easierRound,
              _ => MemoryLoss.fewerCards,
            },
            fewerMessage: AppLocalizations.of(context).shadowsTimeUpFewerObjects,
          ),
        _ => const SizedBox.shrink(),
      };
}

class _Header extends StatelessWidget {
  const _Header({required this.state});

  final OddOneOutState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.1), blurRadius: 16, offset: const Offset(0, 8))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const GameIcon.oddOneOut(key: ValueKey<String>('odd-one-out-game-icon'), size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.oddOneOutTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(
                    l10n.oddOneOutInstructions,
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
              total: OddOneOut.maxLevel,
              color: RoundStyle.colorOf(state.gameRound),
            ),
          ],
        ),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.state, required this.hintKey});

  final OddOneOutState state;
  final GlobalKey hintKey;

  /// Tope del emoji en píxeles físicos, como en Sombras (HU-007 R13).
  static const double maxEmojiPhysicalPx = 220;
  static const double gap = 14;

  /// La celda cuadrada más grande con la que caben [count] tarjetas en [area].
  static double _bestCell(int count, Size area) {
    var best = 0.0;
    for (var columns = 1; columns <= count; columns++) {
      final int rows = (count / columns).ceil();
      best = math.max(
        best,
        math.min((area.width - gap * (columns - 1)) / columns, (area.height - gap * (rows - 1)) / rows),
      );
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    if (state.phase == OddPhase.loading || state.objects.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    final cubit = context.read<OddOneOutCubit>();
    final double dpr = MediaQuery.devicePixelRatioOf(context);
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final int count = state.objects.length;
        final double cell = math.max(0, math.min(_bestCell(count, constraints.biggest), 260));
        final double emoji = math.min(cell * 0.6, maxEmojiPhysicalPx / dpr);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Center(
            key: ValueKey<int>(state.round),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var index = 0; index < count; index++)
                  SizedBox(
                    width: cell,
                    height: cell,
                    child: _maybeHint(
                      index,
                      _OddCard(
                        key: ValueKey<String>('odd-object-$index'),
                        symbol: state.objects[index],
                        emojiSize: emoji,
                        label: l10n.oddOneOutObjectSemantics(state.objects[index]),
                        solved: state.phase == OddPhase.solved && index == state.oddIndex,
                        shake: index == state.wrongIndex ? state.wrongCount : 0,
                        // La ayuda del saltito solo en el tutorial de cada ronda (P8, decidido el
                        // 2026-11-12) y nunca en Reto máximo (HU-030 R10).
                        hop: index == state.oddIndex &&
                            state.level == 1 &&
                            state.gameRound.showsHelps &&
                            !reduceMotion,
                        reduceMotion: reduceMotion,
                        onTap: () => cubit.tap(index),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _maybeHint(int index, Widget child) =>
      index == state.oddIndex ? KeyedSubtree(key: hintKey, child: child) : child;
}

/// Un objeto: el diferente salta al acertar (R3); otro hace un «no» al tocarlo,
/// sin rojo ni sonido. Con [hop], un saltito al aparecer enseña cuál es.
class _OddCard extends StatelessWidget {
  const _OddCard({
    super.key,
    required this.symbol,
    required this.emojiSize,
    required this.label,
    required this.solved,
    required this.shake,
    required this.hop,
    required this.reduceMotion,
    required this.onTap,
  });

  final String symbol;
  final double emojiSize;
  final String label;
  final bool solved;
  final int shake;
  final bool hop;
  final bool reduceMotion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget card = DecoratedBox(
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: solved ? AppPalette.amber : AppPalette.white, width: 3),
        boxShadow: [
          BoxShadow(color: AppPalette.deepTeal.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 3))
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: emojiSize, height: 1.15),
        ),
      ),
    );
    final Duration duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 450);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          // Cambia con cada fallo sobre esta tarjeta: el «no» se repite.
          key: ValueKey<int>(shake),
          tween: Tween<double>(begin: shake == 0 ? 1 : 0, end: 1),
          duration: duration,
          builder: (context, t, child) => Transform.translate(
            offset: Offset(math.sin(t * math.pi * 4) * 10 * (1 - t), 0),
            child: child,
          ),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: hop ? 0 : 1, end: 1),
            duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 600),
            builder: (context, h, child) => Transform.translate(
              offset: Offset(0, -math.sin(h * math.pi) * 18),
              child: child,
            ),
            child: AnimatedScale(
              scale: solved ? 1.15 : 1,
              duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: card,
            ),
          ),
        ),
      ),
    );
  }
}
