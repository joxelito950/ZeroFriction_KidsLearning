import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/i_persistence_repository.dart';
import '../blocs/memory_game/memory_game_cubit.dart';
import '../blocs/memory_game/memory_game_state.dart';
import '../widgets/memory_card_widget.dart';
import '../widgets/memory_victory_dialog.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({
    super.key,
    required this.persistenceRepository,
    required this.levelId,
    this.imageAssets = const ['🐶', '🐱', '🐰'],
    this.cubit,
  });

  final IPersistenceRepository persistenceRepository;
  final String levelId;
  final List<String> imageAssets;
  final MemoryGameCubit? cubit;

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  late final MemoryGameCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? MemoryGameCubit(
      persistenceRepository: widget.persistenceRepository,
      levelId: widget.levelId,
    );

    _cubit.startGame(widget.imageAssets);
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      _cubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MemoryGameCubit, MemoryGameState>(
      bloc: _cubit,
      listenWhen: (previous, current) => !previous.isCompleted && current.isCompleted,
      listener: (context, state) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (_) => MemoryVictoryDialog(moves: state.moves),
          );
        });
      },
      builder: (context, state) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF4D6), Color(0xFFFFE4B5), Color(0xFFFFF8E1)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(moves: state.moves),
                    const SizedBox(height: 18),
                    Expanded(
                      child: state.cards.isEmpty
                          ? const Center(
                              child: CircularProgressIndicator.adaptive(),
                            )
                          : LayoutBuilder(
                              builder: (context, constraints) {
                                final int crossAxisCount = constraints.maxWidth < 420 ? 2 : 3;

                                return GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 14,
                                    mainAxisSpacing: 14,
                                    childAspectRatio: 0.84,
                                  ),
                                  itemCount: state.cards.length,
                                  itemBuilder: (context, index) {
                                    return MemoryCardWidget(
                                      key: ValueKey<String>('memory-card-$index'),
                                      card: state.cards[index],
                                      onTap: () => _cubit.flipCard(index),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 12),
                    _Footer(
                      isProcessing: state.isProcessing,
                      isCompleted: state.isCompleted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.moves});

  final int moves;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: Color(0xFFFFC857),
              child: Icon(Icons.child_care_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Memory Game',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Toca las cartas y encuentra las parejas',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0EA5E9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Movs. $moves',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.isProcessing,
    required this.isCompleted,
  });

  final bool isProcessing;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final String message = isCompleted
        ? '¡Excelente! Encontraste todas las parejas.'
        : isProcessing
            ? 'Observa bien... la carta se está volteando.'
            : 'Busquemos la pareja correcta.';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    );
  }
}
