import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/pairs/pair_board.dart';
import '../theme/app_palette.dart';

/// Dónde va cada carta de un tablero de parejas, en coordenadas del propio
/// tablero (HU-036 3.1). Cartas cuadradas: el contenido es un emoji o un grupo
/// de objetos (HU-026).
final class PairBoardGeometry {
  PairBoardGeometry._({required this.side, required this.rects});

  /// Separación entre cartas.
  static const double gap = 14;

  /// Separación entre los dos lados con [PairLayout.columns]: se ve que son dos
  /// grupos.
  static const double sideGap = 32;

  /// Zona táctil mínima de cada carta (HU-036 3.2, HU-039).
  static const double minSide = 64;

  /// Las cartas no crecen más: con pocas, el tablero queda en el centro.
  static const double maxSide = 180;

  factory PairBoardGeometry.compute({required Size size, required PairBoard<Object?> board}) {
    final bool horizontal = size.width > size.height;
    if (board.layout == PairLayout.columns) {
      // Cada lado, una columna (en horizontal, una fila).
      final List<String> first = [
        for (final card in board.cards)
          if (card.side == 0) card.id
      ];
      final List<String> second = [
        for (final card in board.cards)
          if (card.side == 1) card.id
      ];
      final int longest = math.max(1, math.max(first.length, second.length));
      final double across = horizontal ? size.height : size.width;
      final double along = horizontal ? size.width : size.height;
      final double side = [
        (across - sideGap) / 2,
        (along - gap * (longest - 1)) / longest,
        maxSide,
      ].reduce(math.min);
      final double start = (across - (2 * side + sideGap)) / 2;
      final Map<String, Rect> rects = {};
      void place(List<String> ids, int lane) {
        final double offset = (along - (ids.length * side + (ids.length - 1) * gap)) / 2;
        for (var index = 0; index < ids.length; index++) {
          final double a = offset + index * (side + gap);
          final double c = start + lane * (side + sideGap);
          rects[ids[index]] = horizontal ? Rect.fromLTWH(a, c, side, side) : Rect.fromLTWH(c, a, side, side);
        }
      }

      place(first, 0);
      place(second, 1);
      return PairBoardGeometry._(side: side, rects: rects);
    }
    final List<String> ids = [for (final card in board.cards) card.id];
    final int count = math.max(1, ids.length);
    var best = 0.0;
    var columns = 1;
    for (var candidate = 1; candidate <= count; candidate++) {
      final int rows = (count / candidate).ceil();
      final double side = math.min(
        (size.width - gap * (candidate - 1)) / candidate,
        (size.height - gap * (rows - 1)) / rows,
      );
      // Con el mismo tamaño, menos columnas: filas más llenas.
      if (math.min(side, maxSide) > math.min(best, maxSide) + 0.5) {
        best = side;
        columns = candidate;
      }
    }
    final double side = math.min(best, maxSide);
    final int rows = (ids.length / columns).ceil();
    final double top = (size.height - (rows * side + (rows - 1) * gap)) / 2;
    final Map<String, Rect> rects = {};
    for (var row = 0; row < rows; row++) {
      final int inRow = math.min(columns, ids.length - row * columns);
      final double left = (size.width - (inRow * side + (inRow - 1) * gap)) / 2;
      for (var column = 0; column < inRow; column++) {
        rects[ids[row * columns + column]] =
            Rect.fromLTWH(left + column * (side + gap), top + row * (side + gap), side, side);
      }
    }
    return PairBoardGeometry._(side: side, rects: rects);
  }

  /// Lado de cada carta.
  final double side;
  final Map<String, Rect> rects;
}

/// Tablero de parejas a la vista (HU-036 3.1–3.2; lo comparte HU-026): las
/// cartas boca arriba, la elegida con halo ámbar, el vaivén de un fallo y el
/// saltito de una pareja. Las reglas las decide quien recibe [onTap] (con
/// [PairPlay.tap]); aquí solo se dibuja y se anima. Es un juego de tocar: el
/// ajuste «Arrastrar · Tocar · Ambas» no le afecta (HU-039 P5).
class PairBoardView<T> extends StatelessWidget {
  const PairBoardView({
    super.key,
    required this.keyPrefix,
    required this.board,
    required this.play,
    required this.cardBuilder,
    required this.semanticLabel,
    required this.onTap,
    this.missed,
    this.missToken = 0,
    this.joined,
    this.joinToken = 0,
    this.hintKeys = const {},
  });

  /// Prefijo de las claves de las cartas (`$keyPrefix-card-$id`).
  final String keyPrefix;
  final PairBoard<T> board;
  final PairPlay play;

  /// El contenido de una carta, en un cuadrado de lado `side`.
  final Widget Function(BuildContext context, PairCard<T> card, double side) cardBuilder;

  /// Lo que dice el lector de pantalla de una carta.
  final String Function(PairCard<T> card) semanticLabel;
  final ValueChanged<String> onTap;

  /// Las dos cartas del último fallo: hacen el vaivén. [missToken] cambia con
  /// cada fallo, para repetirlo aunque sean las mismas.
  final (String, String)? missed;
  final int missToken;

  /// Las dos cartas de la última pareja: se acercan con un saltito.
  final (String, String)? joined;
  final int joinToken;

  /// Claves de las cartas que señala la mano del tutorial (HU-022).
  final Map<String, GlobalKey> hintKeys;

  /// Vaivén de un fallo y saltito de una pareja.
  static const Duration shakeDuration = Duration(milliseconds: 450);
  static const Duration joinDuration = Duration(milliseconds: 450);

  /// Cuánto se acercan las dos cartas de una pareja (parte de la distancia) y
  /// cuánto saltan.
  static const double joinApproach = 0.3;
  static const double joinHop = 14;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = MediaQuery.disableAnimationsOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final PairBoardGeometry geometry = PairBoardGeometry.compute(size: constraints.biggest, board: board);
        Offset? joinOffset(String id) {
          final (String, String)? pair = joined;
          if (pair == null || (pair.$1 != id && pair.$2 != id)) return null;
          final Offset mid = (geometry.rects[pair.$1]!.center + geometry.rects[pair.$2]!.center) / 2;
          return mid - geometry.rects[id]!.center;
        }

        return Stack(
          children: [
            for (final PairCard<T> card in board.cards)
              Positioned.fromRect(
                rect: geometry.rects[card.id]!,
                child: _hint(
                  card.id,
                  _PairCardTile(
                    key: ValueKey<String>('$keyPrefix-card-${card.id}'),
                    label: semanticLabel(card),
                    selected: play.selected == card.id,
                    matched: play.matched.contains(card.id),
                    shake: missed != null && (missed!.$1 == card.id || missed!.$2 == card.id) ? missToken : 0,
                    join: joinOffset(card.id) == null ? 0 : joinToken,
                    joinTowards: joinOffset(card.id) ?? Offset.zero,
                    reduceMotion: reduceMotion,
                    onTap: () => onTap(card.id),
                    child: cardBuilder(context, card, geometry.side),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _hint(String id, Widget child) => hintKeys[id] == null ? child : KeyedSubtree(key: hintKeys[id], child: child);
}

/// Una carta: blanca con borde teal suave; elegida, crece con halo ámbar; ya
/// emparejada, borde dorado y el contenido atenuado (HU-036 sección 7).
class _PairCardTile extends StatelessWidget {
  const _PairCardTile({
    super.key,
    required this.label,
    required this.selected,
    required this.matched,
    required this.shake,
    required this.join,
    required this.joinTowards,
    required this.reduceMotion,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool selected;
  final bool matched;
  final int shake;
  final int join;
  final Offset joinTowards;
  final bool reduceMotion;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Duration quick = reduceMotion ? Duration.zero : const Duration(milliseconds: 150);
    final Widget card = AnimatedContainer(
      duration: quick,
      decoration: BoxDecoration(
        color: AppPalette.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected
              ? AppPalette.amber
              : matched
                  ? AppPalette.gold.withValues(alpha: 0.5)
                  : AppPalette.deepTeal.withValues(alpha: 0.35),
          width: selected ? 4 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: selected ? AppPalette.amber.withValues(alpha: 0.45) : AppPalette.deepTeal.withValues(alpha: 0.1),
            blurRadius: selected ? 16 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedOpacity(duration: quick, opacity: matched ? 0.6 : 1, child: Center(child: child)),
    );
    return Semantics(
      button: !matched,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: matched ? null : onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          // Cambia con cada fallo sobre esta carta: el vaivén se repite.
          key: ValueKey<String>('shake-$shake'),
          tween: Tween<double>(begin: shake == 0 ? 1 : 0, end: 1),
          duration: reduceMotion ? Duration.zero : PairBoardView.shakeDuration,
          builder: (context, t, child) => Transform.translate(
            offset: Offset(math.sin(t * math.pi * 4) * 10 * (1 - t), 0),
            child: child,
          ),
          child: TweenAnimationBuilder<double>(
            key: ValueKey<String>('join-$join'),
            tween: Tween<double>(begin: join == 0 ? 1 : 0, end: 1),
            duration: reduceMotion ? Duration.zero : PairBoardView.joinDuration,
            builder: (context, t, child) {
              final double bump = math.sin(t * math.pi);
              return Transform.translate(
                offset: joinTowards * PairBoardView.joinApproach * bump + Offset(0, -PairBoardView.joinHop * bump),
                child: child,
              );
            },
            child: AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: quick,
              curve: Curves.easeOutBack,
              child: card,
            ),
          ),
        ),
      ),
    );
  }
}
