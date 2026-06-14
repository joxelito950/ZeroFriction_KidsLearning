import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../blocs/memory_game/memory_card_model.dart';

class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({
    super.key,
    required this.card,
    required this.onTap,
  });

  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isRevealed = card.isFaceUp || card.isMatched;
    final String semanticLabel = isRevealed ? 'Carta abierta con ${card.assetPath}' : 'Carta cerrada';

    return Semantics(
      button: true,
      selected: isRevealed,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('memory-card-button-${card.id}'),
          borderRadius: BorderRadius.circular(28),
          onTap: card.isMatched ? null : onTap,
          child: AspectRatio(
            aspectRatio: 0.82,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: isRevealed ? 1 : 0),
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                final double angle = value * math.pi;
                final bool showFront = value > 0.45;

                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.0018)
                    ..rotateY(angle),
                  child: showFront
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _FrontFace(symbol: card.assetPath),
                        )
                      : _BackFace(id: card.id),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.symbol});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<String>('memory-card-front-$symbol'),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFF7D6), Color(0xFFFFE0B2)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFFFC86E), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          key: ValueKey<String>('memory-card-symbol-$symbol'),
          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<int>(id),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7DD3FC), Color(0xFF38BDF8)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 12,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.question_mark_rounded,
          size: 44,
          color: Colors.white,
        ),
      ),
    );
  }
}
