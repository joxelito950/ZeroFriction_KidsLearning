import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Cuántas columnas y de qué lado son las tarjetas del menú (HU-023 3.1).
@immutable
final class GridFit {
  const GridFit({required this.columns, required this.side});

  final int columns;
  final double side;

  /// Separación entre tarjetas.
  static const double spacing = 16;

  /// Más grande no ayuda a reconocer el juego y deja el menú vacío.
  static const double maxSide = 200;

  /// Por debajo de este lado, la tarjeta ya no se entiende: la cuadrícula se
  /// desplaza en lugar de encoger más (R2, red de seguridad).
  static const double minSide = 96;

  /// La forma de repartir [count] tarjetas cuadradas en [width] × [height] que
  /// las deja más grandes. En vertical, al menos [minColumns] columnas.
  static GridFit best({required int count, required double width, required double height, int minColumns = 1}) {
    RangeError.checkValueInInterval(count, 1, 1000, 'count');
    var columnsOfBest = 0;
    var bestSide = double.negativeInfinity;
    for (var columns = math.min(minColumns, count); columns <= count; columns++) {
      final int rows = (count / columns).ceil();
      final double side = math.min(
        (width - (columns - 1) * spacing) / columns,
        (height - (rows - 1) * spacing) / rows,
      );
      // Con el mismo tamaño, menos columnas: filas más llenas y centradas.
      if (math.min(side, maxSide) > math.min(bestSide, maxSide) + 0.5) {
        columnsOfBest = columns;
        bestSide = side;
      }
    }
    return GridFit(columns: columnsOfBest, side: math.min(bestSide, maxSide));
  }

  bool get fits => side >= minSide;
}

/// Las tarjetas de los juegos en cuadrícula, centradas y en orden fijo; en
/// árabe, de derecha a izquierda. Si no caben a un tamaño legible, la
/// cuadrícula se desplaza en vertical.
class GameGrid extends StatelessWidget {
  const GameGrid({super.key, required this.count, required this.cardBuilder, this.minColumns = 1});

  final int count;
  final int minColumns;
  final Widget Function(BuildContext context, int index, double side) cardBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final GridFit fit = GridFit.best(
          count: count,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          minColumns: minColumns,
        );
        // Si no caben a un tamaño legible, se desplazan: tantas columnas como
        // quepan a lo ancho, con el tamaño mínimo.
        final GridFit used = fit.fits
            ? fit
            : GridFit(
                columns: math.max(1, ((constraints.maxWidth + GridFit.spacing) / (GridFit.minSide + GridFit.spacing)).floor()),
                side: math.min(GridFit.minSide, constraints.maxWidth),
              );
        final double side = used.side;
        final int perRow = math.min(used.columns, count);
        // Medio píxel de holgura: el redondeo no debe bajar una tarjeta de fila.
        final double width = perRow * side + (perRow - 1) * GridFit.spacing + 0.5;
        final Widget grid = SizedBox(
          key: const ValueKey<String>('menu-game-grid'),
          width: width,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: GridFit.spacing,
            runSpacing: GridFit.spacing,
            children: [
              for (var index = 0; index < count; index++)
                SizedBox.square(dimension: side, child: cardBuilder(context, index, side)),
            ],
          ),
        );
        // Sin ocupar más alto del necesario, para centrarse con el resto del menú.
        return Center(heightFactor: 1, child: fit.fits ? grid : SingleChildScrollView(child: grid));
      },
    );
  }
}
