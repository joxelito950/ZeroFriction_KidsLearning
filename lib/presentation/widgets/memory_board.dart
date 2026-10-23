import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../blocs/memory_game/memory_card_model.dart';
import 'memory_card_widget.dart';

/// Tablero de cartas que siempre cabe en pantalla, sin scroll (D-011): elige el
/// número de columnas que da las cartas más grandes, solo con filas completas.
class MemoryBoard extends StatelessWidget {
  const MemoryBoard({super.key, required this.cards, required this.onCardTap});

  final List<MemoryCard> cards;
  final ValueChanged<int> onCardTap;

  static const double _spacing = 14;
  static const double _preferredAspectRatio = 0.84;
  static const int _fallbackCrossAxisCount = 2;

  static Size _cellSize(BoxConstraints constraints, int crossAxisCount, int itemCount) {
    final int rowCount = (itemCount / crossAxisCount).ceil();
    return Size(
      (constraints.maxWidth - _spacing * (crossAxisCount - 1)) / crossAxisCount,
      (constraints.maxHeight - _spacing * (rowCount - 1)) / rowCount,
    );
  }

  static int _bestCrossAxisCount(BoxConstraints constraints, int itemCount) {
    if (!constraints.hasBoundedHeight) return _fallbackCrossAxisCount;

    int bestCount = _fallbackCrossAxisCount;
    double bestCardWidth = 0;
    for (var columns = 1; columns <= itemCount; columns++) {
      if (itemCount % columns != 0) continue;
      final Size cell = _cellSize(constraints, columns, itemCount);
      final double cardWidth = math.min(cell.width, cell.height * _preferredAspectRatio);
      if (cardWidth > bestCardWidth) {
        bestCount = columns;
        bestCardWidth = cardWidth;
      }
    }
    return bestCount;
  }

  static double _fittingAspectRatio(BoxConstraints constraints, int crossAxisCount, int itemCount) {
    if (!constraints.hasBoundedHeight) return _preferredAspectRatio;
    final Size cell = _cellSize(constraints, crossAxisCount, itemCount);
    if (cell.width <= 0 || cell.height <= 0) return _preferredAspectRatio;
    return math.max(cell.width / cell.height, _preferredAspectRatio);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int crossAxisCount = _bestCrossAxisCount(constraints, cards.length);
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            childAspectRatio: _fittingAspectRatio(constraints, crossAxisCount, cards.length),
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => MemoryCardWidget(
            key: ValueKey<String>('memory-card-$index'),
            card: cards[index],
            onTap: () => onCardTap(index),
          ),
        );
      },
    );
  }
}
