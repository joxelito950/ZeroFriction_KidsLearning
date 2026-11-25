import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/places/place_drop.dart';
import '../../domain/shadows/shadow_drop.dart';
import '../blocs/how_to_play/how_to_play_cubit.dart';
import '../theme/app_palette.dart';

/// Una pieza de la bandeja: un vehículo en «A su sitio», un objeto en
/// «Clasificar» (HU-027). [scale] encoge el emoji (grande 1, mediano 0,7,
/// pequeño 0,45); la tarjeta de la bandeja no cambia, para que se pueda tocar.
@immutable
final class BoardPiece {
  const BoardPiece({required this.id, required this.symbol, required this.semanticLabel, this.scale = 1});

  final String id;
  final String symbol;
  final String semanticLabel;
  final double scale;
}

/// Un destino: un sitio en «A su sitio», una cesta en «Clasificar». [scale]
/// encoge la tarjeta entera (las cestas de tamaño, HU-027 P6) y [symbolScale]
/// solo su muestra.
@immutable
final class BoardTarget {
  const BoardTarget({
    required this.id,
    required this.symbol,
    required this.semanticLabel,
    this.scale = 1,
    this.symbolScale = 1,
  });

  final String id;
  final String symbol;

  /// Lo que dice el lector de pantalla, con lo que ya tiene dentro.
  final String semanticLabel;
  final double scale;
  final double symbolScale;
}

/// Lo que el tablero necesita saber de la partida. Lo prepara cada juego a
/// partir de su estado; las reglas siguen en su cubit.
@immutable
final class PlaceBoardData {
  const PlaceBoardData({
    required this.boardId,
    required this.pieces,
    required this.targets,
    required this.targetOf,
    required this.placedAt,
    required this.isPlaced,
    required this.canDrag,
    required this.coverageToSnap,
    required this.placesFirst,
    this.slots = 2,
    this.placedBadge,
    this.trayLayout,
    this.balanced = false,
  });

  /// Cambia con cada tablero: al cambiar, se olvida lo que estaba en el aire.
  final int boardId;
  final List<BoardPiece> pieces;
  final List<BoardTarget> targets;
  final String Function(String piece) targetOf;

  /// Piezas ya colocadas en un destino, en el orden de sus huecos.
  final List<String> Function(String target) placedAt;
  final bool Function(String piece) isPlaced;
  final bool Function(String piece) canDrag;
  final double coverageToSnap;
  final bool placesFirst;

  /// Huecos de cada destino: 2 en «A su sitio», 3 en «Clasificar».
  final int slots;

  /// Un adorno junto a cada pieza colocada (el regalo de Navidad de HU-052 §6).
  final String? placedBadge;

  /// Qué pieza va en cada hueco de la bandeja, en orden. Un id que no es de
  /// ninguna pieza deja el hueco vacío. Sin él, todas las piezas, cada una en
  /// su hueco fijo. Sirve para la bandeja que se repone de «Clasificar»
  /// (HU-027 4.3): los huecos no se mueven al entrar una pieza nueva.
  final List<String>? trayLayout;

  /// Reparte el espacio entre destinos y bandeja buscando las piezas más
  /// grandes, en vez de la proporción fija de «A su sitio». Lo usa
  /// «Clasificar», con piezas pequeñas que no pueden bajar de 28 dp (HU-027
  /// 3.4).
  final bool balanced;
}

/// Dónde va cada cosa en un tablero de destinos, en coordenadas del propio
/// tablero (HU-052 7.1): los destinos en tarjetas grandes, la bandeja con las
/// piezas y, dentro de cada destino, sus huecos para lo colocado.
final class PlaceBoardGeometry {
  PlaceBoardGeometry._({
    required this.targetZone,
    required this.trayZone,
    required this.targetRects,
    required this.trayRects,
    required this.pieceCell,
    required this.slots,
  });

  static const double gap = 12;
  static const double padding = 10;

  /// El emoji ocupa esta parte de su celda.
  static const double emojiFraction = 0.72;

  /// Tope del emoji en píxeles físicos: por encima, el moto g55 no lo pinta
  /// (spike de HU-007).
  static const double maxEmojiPhysicalPx = 220;

  /// Lado de cada hueco respecto a la tarjeta del destino, con 2 huecos y con 3.
  static const double slotFractionTwo = 0.4;
  static const double slotFractionThree = 0.28;

  factory PlaceBoardGeometry.compute({
    required Size size,
    required bool placesFirst,
    required List<BoardTarget> targets,
    required List<String> pieces,
    required double devicePixelRatio,
    int slots = 2,
    bool leftHanded = false,
    bool balanced = false,
  }) {
    RangeError.checkValueInInterval(slots, 1, 3, 'slots');
    final bool horizontal = size.width > size.height;
    // Con la mano izquierda y en horizontal, los destinos pasan al otro lado,
    // donde la mano no los tapa (HU-031 R1), como en Sombras.
    placesFirst = placesFirst != (horizontal && leftHanded);
    final int targetCount = math.max(targets.length, 1);
    final int pieceCount = math.max(pieces.length, 1);
    final double main = (horizontal ? size.width : size.height) - gap;
    final double maxCell = maxEmojiPhysicalPx / devicePixelRatio / emojiFraction;
    final bool first = placesFirst;

    Rect zone(double start, double length) =>
        horizontal ? Rect.fromLTWH(start, 0, length, size.height) : Rect.fromLTWH(0, start, size.width, length);
    (Rect, Rect, double, double) split(double share) {
      final double targetMain = main * share;
      final double trayMain = main - targetMain;
      final Rect targetZone = first ? zone(0, targetMain) : zone(trayMain + gap, targetMain);
      final Rect trayZone = first ? zone(targetMain + gap, trayMain) : zone(0, trayMain);
      final double targetCell = math.max(0, _bestCell(targetCount, targetZone.deflate(padding).size));
      final double pieceCell = math.max(
        0,
        // Como mucho el 80 % del destino (el 90 % en el reparto equilibrado:
        // la caja de soltar ya se limita al destino más pequeño).
        [_bestCell(pieceCount, trayZone.deflate(padding).size), maxCell, targetCell * (balanced ? 0.9 : 0.8)]
            .reduce(math.min),
      );
      return (targetZone, trayZone, targetCell, pieceCell);
    }

    // Los destinos llevan dentro sus piezas: reciben algo más de espacio.
    var (Rect targetZone, Rect trayZone, double targetCell, double pieceCell) =
        split((targetCount * 1.4) / (targetCount * 1.4 + pieceCount));
    if (balanced) {
      // La proporción con las piezas más grandes; a igualdad, destinos mayores.
      for (var share = 0.2; share <= 0.8; share += 0.02) {
        final (Rect, Rect, double, double) candidate = split(share);
        if (candidate.$4 > pieceCell + 0.01 || (candidate.$4 > pieceCell - 0.01 && candidate.$3 > targetCell)) {
          (targetZone, trayZone, targetCell, pieceCell) = candidate;
        }
      }
    }
    final Map<String, Rect> cells =
        _place([for (final target in targets) target.id], targetZone.deflate(padding), targetCell);
    return PlaceBoardGeometry._(
      targetZone: targetZone,
      trayZone: trayZone,
      // Una cesta más pequeña (HU-027 P6) se apoya en el fondo de su celda.
      targetRects: {
        for (final BoardTarget target in targets) target.id: _shrink(cells[target.id]!, target.scale),
      },
      trayRects: _place(pieces, trayZone.deflate(padding), pieceCell),
      pieceCell: pieceCell,
      slots: slots,
    );
  }

  final Rect targetZone;
  final Rect trayZone;
  final Map<String, Rect> targetRects;
  final Map<String, Rect> trayRects;

  /// Lado de la celda de una pieza (en la bandeja y al arrastrarla).
  final double pieceCell;

  /// Huecos de cada destino.
  final int slots;

  /// Hueco [index] de una pieza colocada en [target]. Si hay más piezas que
  /// huecos, las de más comparten el último.
  Rect slotRect(String target, int index) {
    final Rect card = targetRects[target]!;
    final double side = card.width * (slots <= 2 ? slotFractionTwo : slotFractionThree);
    final double spacing = (card.width - slots * side) / (slots + 1);
    final int at = math.min(index, slots - 1);
    return Rect.fromLTWH(card.left + spacing + at * (side + spacing), card.bottom - side - spacing / 2, side, side);
  }

  static Rect _shrink(Rect cell, double scale) {
    if (scale >= 1) return cell;
    final double side = cell.width * scale;
    return Rect.fromLTWH(cell.center.dx - side / 2, cell.bottom - side, side, side);
  }

  /// La celda cuadrada más grande con la que caben [count] celdas en [area].
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

  /// Reparte [items] en filas centradas dentro de [area].
  static Map<T, Rect> _place<T>(List<T> items, Rect area, double cell) {
    if (items.isEmpty || cell <= 0) return {for (final item in items) item: Rect.zero};
    final int columns = math.max(1, math.min(items.length, ((area.width + gap) / (cell + gap)).floor()));
    final int rows = (items.length / columns).ceil();
    final double top = area.top + (area.height - (rows * cell + (rows - 1) * gap)) / 2;
    final Map<T, Rect> rects = {};
    for (var row = 0; row < rows; row++) {
      final int inRow = math.min(columns, items.length - row * columns);
      final double left = area.left + (area.width - (inRow * cell + (inRow - 1) * gap)) / 2;
      for (var column = 0; column < inRow; column++) {
        rects[items[row * columns + column]] =
            Rect.fromLTWH(left + column * (cell + gap), top + row * (cell + gap), cell, cell);
      }
    }
    return rects;
  }

  static ShadowBox boxOf(Rect rect) =>
      ShadowBox(left: rect.left, top: rect.top, width: rect.width, height: rect.height);
}

/// Tablero de destinos común a «A su sitio» (HU-052 7.1) y «Clasificar»
/// (HU-027): los destinos, la bandeja y la pieza que se arrastra o se toca
/// (HU-039). Las reglas las decide quien recibe [onDrop] y [onMatch] (el
/// cubit); aquí solo se dibuja y se anima. Las zonas son físicas, también en
/// árabe: dependen de la mano, como en Sombras.
///
/// Las claves de los widgets llevan [keyPrefix] («vehicle-tray-car»…).
class PlaceBoardView extends StatefulWidget {
  const PlaceBoardView({
    super.key,
    required this.data,
    required this.keyPrefix,
    required this.onGrab,
    required this.onDrop,
    required this.onMatch,
    this.hintPiece,
    this.hintPieceKey,
    this.hintTargetKey,
  });

  final PlaceBoardData data;
  final String keyPrefix;
  final ValueChanged<String> onGrab;
  final ShadowDropOutcome Function(String piece, ShadowBox box, Map<String, ShadowBox> targets) onDrop;
  final ShadowDropOutcome Function(String piece, String target) onMatch;

  /// Pieza que señala la mano del tutorial, con sus dos claves (HU-022).
  final String? hintPiece;
  final GlobalKey? hintPieceKey;
  final GlobalKey? hintTargetKey;

  static const Duration flightDuration = Duration(milliseconds: 280);

  @override
  State<PlaceBoardView> createState() => _PlaceBoardViewState();
}

class _PlaceBoardViewState extends State<PlaceBoardView> with SingleTickerProviderStateMixin {
  late final AnimationController _flight = AnimationController(vsync: this, duration: PlaceBoardView.flightDuration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _flying = null);
    });

  PlaceBoardGeometry? _geometry;
  String? _dragged;
  Offset _dragCenter = Offset.zero;
  String? _flying;
  Rect _flightFrom = Rect.zero;
  Rect _flightTo = Rect.zero;

  /// Pieza elegida tocando (o con el lector de pantalla), a la espera de su destino.
  String? _selected;

  PlaceBoardData get _data => widget.data;
  String _key(String name) => '${widget.keyPrefix}-$name';

  BoardPiece _piece(String id) => _data.pieces.firstWhere((piece) => piece.id == id);

  @override
  void didUpdateWidget(PlaceBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.boardId != oldWidget.data.boardId) {
      _dragged = null;
      _flying = null;
      _selected = null;
      _flight.reset();
    }
  }

  @override
  void dispose() {
    _flight.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _onPanStart(String piece) {
    if (_dragged != null || _flying != null || !_data.canDrag(piece)) return;
    final Rect? slot = _geometry?.trayRects[piece];
    if (slot == null) return;
    widget.onGrab(piece);
    setState(() {
      _dragged = piece;
      _dragCenter = slot.center;
      _selected = null;
    });
  }

  void _onPanUpdate(String piece, DragUpdateDetails details) {
    if (_dragged == piece) setState(() => _dragCenter += details.delta);
  }

  Rect _draggedRect(PlaceBoardGeometry geometry) =>
      Rect.fromCenter(center: _dragCenter, width: geometry.pieceCell, height: geometry.pieceCell);

  /// Lo que cuenta al soltar: la parte visible de la pieza (una pieza pequeña
  /// es pequeña, HU-027 3.4), nunca más grande que el destino más pequeño.
  /// Así una pieza puede caer entera en una cesta pequeña. Con todas las
  /// piezas y destinos al mismo tamaño («A su sitio») es la celda de siempre.
  Rect _dropRect(PlaceBoardGeometry geometry, String piece) {
    final double smallest =
        geometry.targetRects.values.fold(double.infinity, (side, rect) => math.min(side, rect.width));
    final double side =
        math.min(geometry.pieceCell * math.max(_piece(piece).scale, minDropScale), smallest * maxDropShare);
    return Rect.fromCenter(center: _dragCenter, width: side, height: side);
  }

  /// La caja de una pieza muy pequeña no baja de esta parte de su celda.
  static const double minDropScale = 0.5;

  /// La caja de la pieza, como mucho esta parte del destino más pequeño.
  static const double maxDropShare = 0.9;

  Map<String, ShadowBox> _targetBoxes(PlaceBoardGeometry geometry) => {
        for (final entry in geometry.targetRects.entries) entry.key: PlaceBoardGeometry.boxOf(entry.value),
      };

  void _onPanEnd(String piece) {
    final PlaceBoardGeometry? geometry = _geometry;
    if (_dragged != piece || geometry == null) return;
    final Rect from = _draggedRect(geometry);
    final ShadowDropOutcome outcome =
        widget.onDrop(piece, PlaceBoardGeometry.boxOf(_dropRect(geometry, piece)), _targetBoxes(geometry));
    final Rect to = outcome == ShadowDropOutcome.snapped ? _slotOf(geometry, piece) : geometry.trayRects[piece]!;
    _fly(piece, from: from, to: to);
  }

  /// El hueco del destino donde queda [piece]: el siguiente libre. El estado
  /// con la pieza ya colocada aún no ha llegado al tablero.
  Rect _slotOf(PlaceBoardGeometry geometry, String piece) {
    final String target = _data.targetOf(piece);
    final List<String> before = _data.placedAt(target);
    final int index = before.contains(piece) ? before.indexOf(piece) : before.length;
    return geometry.slotRect(target, index);
  }

  void _fly(String piece, {required Rect from, required Rect to}) {
    setState(() {
      _dragged = null;
      if (_reduceMotion) return;
      _flying = piece;
      _flightFrom = from;
      _flightTo = to;
    });
    if (!_reduceMotion) _flight.forward(from: 0);
  }

  /// La pieza arrastrada encajaría si se soltara ahora: el borde de su destino
  /// se ilumina en ámbar (como en Sombras, HU-050 P2).
  bool _wouldSnap(PlaceBoardGeometry geometry, String target) {
    final String? dragged = _dragged;
    if (dragged == null || _data.targetOf(dragged) != target) return false;
    return PlaceDrop.overlap(
          PlaceBoardGeometry.boxOf(_dropRect(geometry, dragged)),
          PlaceBoardGeometry.boxOf(geometry.targetRects[target]!),
        ) >=
        _data.coverageToSnap;
  }

  /// Tocar la pieza la elige; tocarla otra vez la suelta; tocar otra cambia la
  /// elección (HU-039 R3).
  void _onPieceTapped(String piece) {
    if (_dragged != null || _flying != null || !_data.canDrag(piece)) return;
    if (_selected != piece) widget.onGrab(piece);
    setState(() => _selected = _selected == piece ? null : piece);
  }

  /// Con una pieza elegida, tocar un destino la lleva hasta él. Si no es el
  /// suyo, vuelve a la bandeja como al soltarla mal (HU-039 R4).
  void _onTargetActivated(String target) {
    final String? selected = _selected;
    final PlaceBoardGeometry? geometry = _geometry;
    if (selected == null) return;
    setState(() => _selected = null);
    final Rect? slotBefore = geometry == null ? null : _slotOf(geometry, selected);
    final ShadowDropOutcome outcome = widget.onMatch(selected, target);
    final Rect? tray = geometry?.trayRects[selected];
    final Rect? at = geometry?.targetRects[target];
    if (tray == null || at == null || slotBefore == null) return;
    _fly(selected,
        from: outcome == ShadowDropOutcome.snapped ? tray : at,
        to: outcome == ShadowDropOutcome.snapped ? slotBefore : tray);
  }

  @override
  Widget build(BuildContext context) {
    final PlaceBoardData data = _data;
    final String? hintPiece = widget.hintPiece;
    final String? hintTarget = hintPiece == null ? null : data.targetOf(hintPiece);
    // Arrastrar, tocar o ambas (HU-039). Con el lector de pantalla siempre se
    // puede tocar.
    final HowToPlay how = context.select<HowToPlayCubit?, HowToPlay>((cubit) => cubit?.state ?? const HowToPlay());
    final bool tapEnabled = how.moveMode.allowsTap || MediaQuery.accessibleNavigationOf(context);
    final bool dragEnabled = how.moveMode.allowsDrag;

    return LayoutBuilder(
      builder: (context, constraints) {
        final PlaceBoardGeometry geometry = PlaceBoardGeometry.compute(
          size: constraints.biggest,
          placesFirst: data.placesFirst,
          targets: data.targets,
          pieces: data.trayLayout ?? [for (final piece in data.pieces) piece.id],
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          slots: data.slots,
          leftHanded: how.leftHanded,
          balanced: data.balanced,
        );
        _geometry = geometry;
        final double pieceEmoji = geometry.pieceCell * PlaceBoardGeometry.emojiFraction;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _Zone(key: ValueKey<String>(_key('zone-places')), rect: geometry.targetZone, places: true),
            _Zone(key: ValueKey<String>(_key('zone-tray')), rect: geometry.trayZone, places: false),
            for (final BoardTarget target in data.targets)
              Positioned.fromRect(
                rect: geometry.targetRects[target.id]!,
                child: _hintWrap(
                  target.id == hintTarget,
                  widget.hintTargetKey,
                  _TargetCard(
                    key: ValueKey<String>(_key('place-${target.id}')),
                    target: target,
                    almostKey: _key('almost-${target.id}'),
                    almost: _wouldSnap(geometry, target.id),
                    onActivate: _selected == null ? null : () => _onTargetActivated(target.id),
                  ),
                ),
              ),
            for (final BoardTarget target in data.targets)
              for (final (int index, String id) in data.placedAt(target.id).indexed)
                if (_flying != id)
                  Positioned.fromRect(
                    rect: geometry.slotRect(target.id, index),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: _Emoji(
                            key: ValueKey<String>(_key('placed-$id')),
                            symbol: _piece(id).symbol,
                            // Lo colocado llena su hueco: el tamaño ya lo dice
                            // la cesta, que es más pequeña (visto en el moto g55:
                            // con la escala de la pieza, apenas se veía).
                            size: geometry.slotRect(target.id, 0).width * PlaceBoardGeometry.emojiFraction,
                          ),
                        ),
                        if (data.placedBadge case final String badge)
                          PositionedDirectional(
                            end: -geometry.slotRect(target.id, 0).width * 0.1,
                            bottom: 0,
                            child: _Emoji(
                              key: ValueKey<String>(_key('gift-$id')),
                              symbol: badge,
                              size: geometry.slotRect(target.id, 0).width * 0.35,
                            ),
                          ),
                      ],
                    ),
                  ),
            for (final BoardPiece piece in data.pieces)
              // El hueco sigue en el árbol mientras se arrastra (invisible): si se
              // quitara, su detector de gestos se perdería con el dedo encima.
              if (!data.isPlaced(piece.id) && _flying != piece.id && geometry.trayRects.containsKey(piece.id))
                Positioned.fromRect(
                  rect: geometry.trayRects[piece.id]!,
                  child: _hintWrap(
                    piece.id == hintPiece,
                    widget.hintPieceKey,
                    Semantics(
                      key: ValueKey<String>(_key('tray-${piece.id}')),
                      button: true,
                      selected: _selected == piece.id,
                      label: piece.semanticLabel,
                      onTap: data.canDrag(piece.id) ? () => setState(() => _selected = piece.id) : null,
                      excludeSemantics: true,
                      child: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onTap: tapEnabled ? () => _onPieceTapped(piece.id) : null,
                        onPanStart: dragEnabled ? (_) => _onPanStart(piece.id) : null,
                        onPanUpdate: dragEnabled ? (details) => _onPanUpdate(piece.id, details) : null,
                        onPanEnd: dragEnabled ? (_) => _onPanEnd(piece.id) : null,
                        onPanCancel: dragEnabled ? () => _onPanEnd(piece.id) : null,
                        child: Opacity(
                          opacity: _dragged == piece.id ? 0 : 1,
                          child: _PieceCard(
                              symbol: piece.symbol,
                              emojiSize: pieceEmoji * piece.scale,
                              selected: _selected == piece.id),
                        ),
                      ),
                    ),
                  ),
                ),
            if (_dragged case final String dragged)
              Positioned.fromRect(
                rect: _draggedRect(geometry),
                child: IgnorePointer(
                  child: _PieceCard(
                    key: ValueKey<String>(_key('dragged')),
                    symbol: _piece(dragged).symbol,
                    emojiSize: pieceEmoji * _piece(dragged).scale,
                    lifted: true,
                  ),
                ),
              ),
            if (_flying case final String flying)
              AnimatedBuilder(
                animation: _flight,
                builder: (context, _) {
                  final Rect rect = Rect.lerp(_flightFrom, _flightTo, Curves.easeOutCubic.transform(_flight.value))!;
                  return Positioned.fromRect(
                    rect: rect,
                    child: IgnorePointer(
                      child: _Emoji(
                        key: ValueKey<String>(_key('flying')),
                        symbol: _piece(flying).symbol,
                        size: rect.width * PlaceBoardGeometry.emojiFraction * _piece(flying).scale,
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _hintWrap(bool hinted, GlobalKey? key, Widget child) =>
      hinted && key != null ? KeyedSubtree(key: key, child: child) : child;
}

/// Fondo de una zona: la de destinos, blanca; la bandeja, teal muy suave.
class _Zone extends StatelessWidget {
  const _Zone({super.key, required this.rect, required this.places});

  final Rect rect;
  final bool places;

  @override
  Widget build(BuildContext context) => Positioned.fromRect(
        rect: rect,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: places ? AppPalette.white : AppPalette.deepTeal.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      );
}

/// La tarjeta de un destino (HU-052 7.7): crema con borde teal suave; ámbar
/// cuando la pieza arrastrada encajaría. Su emoji, arriba; las piezas
/// colocadas se pintan encima, en sus huecos.
class _TargetCard extends StatelessWidget {
  const _TargetCard({
    super.key,
    required this.target,
    required this.almostKey,
    required this.almost,
    required this.onActivate,
  });

  final BoardTarget target;
  final String almostKey;
  final bool almost;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: target.semanticLabel,
      onTap: onActivate,
      excludeSemantics: true,
      // Con una pieza elegida, el destino se toca para llevarla (HU-039 R3).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onActivate,
        child: LayoutBuilder(
          builder: (context, constraints) => DecoratedBox(
            key: almost ? ValueKey<String>(almostKey) : null,
            decoration: BoxDecoration(
              color: AppPalette.warmCream,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: almost ? AppPalette.amber : AppPalette.deepTeal.withValues(alpha: 0.35),
                width: almost ? 4 : 2,
              ),
            ),
            child: Align(
              alignment: const Alignment(0, -0.6),
              child: _Emoji(symbol: target.symbol, size: constraints.maxWidth * 0.42 * target.symbolScale),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una pieza de la bandeja: el emoji en color sobre una tarjeta blanca.
class _PieceCard extends StatelessWidget {
  const _PieceCard(
      {super.key, required this.symbol, required this.emojiSize, this.selected = false, this.lifted = false});

  final String symbol;
  final double emojiSize;
  final bool selected;
  final bool lifted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: AppPalette.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: selected ? AppPalette.amber : AppPalette.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppPalette.deepTeal.withValues(alpha: lifted ? 0.25 : 0.1),
              blurRadius: lifted ? 18 : 8,
              offset: Offset(0, lifted ? 8 : 3),
            ),
          ],
        ),
        child: Center(child: _Emoji(symbol: symbol, size: emojiSize)),
      );
}

class _Emoji extends StatelessWidget {
  const _Emoji({super.key, required this.symbol, required this.size});

  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) => Center(
        child: Text(
          symbol,
          textAlign: TextAlign.center,
          textScaler: TextScaler.noScaling,
          style: TextStyle(fontSize: size, height: 1.15),
        ),
      );
}
