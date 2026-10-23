import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/memory/memory_ladder.dart';
import '../../domain/repositories/i_persistence_repository.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/memory_game/memory_ladder_cubit.dart';
import '../blocs/memory_game/memory_ladder_state.dart';
import '../widgets/memory_board.dart';
import '../widgets/memory_level_indicator.dart';
import '../widgets/memory_round_overlay.dart';
import '../widgets/memory_time_bar.dart';
import '../widgets/protected_exit.dart';

/// Juego de memoria progresivo (HU-001): sin botones dentro del juego (R13); se
/// sale con «atrás» repetido (R19).
class MemoryGameScreen extends StatelessWidget {
  const MemoryGameScreen({super.key, this.random, this.now});

  /// Inyectables para tests: azar del reparto y reloj del guardado.
  final Random? random;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemoryLadderCubit>(
      create: (context) => MemoryLadderCubit(
        repository: context.read<IPersistenceRepository>(),
        random: random,
        now: now,
      )..start(),
      child: const _MemoryGameView(),
    );
  }
}

class _MemoryGameView extends StatefulWidget {
  const _MemoryGameView();

  @override
  State<_MemoryGameView> createState() => _MemoryGameViewState();
}

class _MemoryGameViewState extends State<_MemoryGameView> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// El cronómetro se pausa con la app en segundo plano o la pantalla apagada (R11).
  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    final cubit = context.read<MemoryLadderCubit>();
    if (lifecycle == AppLifecycleState.resumed) {
      cubit.resume();
    } else {
      cubit.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProtectedExit(
      onExit: () => Navigator.of(context).pop(),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF4D6), Color(0xFFFFE4B5), Color(0xFFFFF8E1)],
            ),
          ),
          child: SafeArea(
            child: BlocBuilder<MemoryLadderCubit, MemoryLadderState>(
              builder: (context, state) => Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _Header(level: state.level, moves: state.moves),
                        if (state.remainingFraction case final double fraction) ...[
                          const SizedBox(height: 12),
                          MemoryTimeBar(fraction: fraction),
                        ],
                        const SizedBox(height: 14),
                        Expanded(child: _Board(state: state)),
                        const SizedBox(height: 12),
                        _Footer(isProcessing: state.isProcessing),
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _overlayFor(state),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _overlayFor(MemoryLadderState state) {
    return switch (state.phase) {
      MemoryRoundPhase.celebrating => MemoryCelebration(stars: state.stars ?? 0, badgeEarned: state.badgeEarned),
      MemoryRoundPhase.timeUp => MemoryTimeUpNotice(loss: state.loss ?? MemoryLoss.fewerCards),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.state});

  final MemoryLadderState state;

  @override
  Widget build(BuildContext context) {
    if (state.cards.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    // Transición suave al repartir un tablero nuevo (R13).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: KeyedSubtree(
        key: ValueKey<int>(state.round),
        child: MemoryBoard(
          cards: state.cards,
          onCardTap: (index) => context.read<MemoryLadderCubit>().flipCard(index),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.level, required this.moves});

  final int level;
  final int moves;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 8))],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        // Los puntos de nivel van en su propia fila: junto al contador no caben
        // en teléfonos estrechos con textos largos (árabe, portugués).
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFFFC857),
                  child: Icon(Icons.child_care_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.memoryGameTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text(l10n.memoryGameInstructions,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF0EA5E9), borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    l10n.memoryGameMovesCounter(moves),
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MemoryLevelIndicator(level: level, total: MemoryLadder.maxLevel),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.isProcessing});

  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(24)),
      child: Text(
        isProcessing ? l10n.memoryGameHintProcessing : l10n.memoryGameHintPlaying,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}
