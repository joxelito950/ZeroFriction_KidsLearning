import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../blocs/memory_game/memory_card_model.dart';
import '../theme/app_palette.dart';

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
    final l10n = AppLocalizations.of(context);
    final String semanticLabel = isRevealed
        ? l10n.memoryCardOpenSemantics(card.assetPath)
        : l10n.memoryCardClosedSemantics;

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
              tween: Tween<double>(end: card.isFaceUp ? 1 : 0),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOutCubic,
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
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppPalette.amber, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppPalette.deepTeal.withValues(alpha: 0.13),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      // El símbolo es un dibujo, no un texto: no sigue el texto ampliado del
      // sistema y se encoge con la carta para no salirse de ella (TD-007 A4).
      child: LayoutBuilder(
        builder: (context, constraints) => Center(
          child: Text(
            symbol,
            key: ValueKey<String>('memory-card-symbol-$symbol'),
            style: TextStyle(fontSize: _symbolSize(constraints.biggest), fontWeight: FontWeight.w700),
            textScaler: TextScaler.noScaling,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  static const double _maxSymbolSize = 42;

  /// Tamaño del símbolo para una carta de [card]: el de siempre, salvo que la
  /// carta sea tan pequeña que no quepa.
  static double _symbolSize(Size card) => math.min(_maxSymbolSize, card.shortestSide * 0.5);
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.id});

  final int id;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey<int>(id),
      decoration: BoxDecoration(
        color: AppPalette.petrolBlue,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppPalette.white.withValues(alpha: 0.8), width: 3),
        boxShadow: [
          BoxShadow(
            color: AppPalette.deepTeal.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.question_mark_rounded,
          size: 44,
          color: AppPalette.warmCream,
        ),
      ),
    );
  }
}
