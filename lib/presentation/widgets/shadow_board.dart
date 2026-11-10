import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../domain/shadows/shadow_drop.dart';
import '../../domain/shadows/shadow_ladder.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/shadow_game/shadow_game_state.dart';
import '../theme/app_palette.dart';

/// Dónde va cada cosa en el tablero de Sombras, en coordenadas del propio
/// tablero (HU-007 4.1). Se calcula sin depender del *layout* de los hijos, así
/// la colocación por cobertura (P4) y las animaciones usan las mismas cajas que
/// se pintan.
final class ShadowBoardGeometry {
  ShadowBoardGeometry._({
    required this.shadowZone,
    required this.trayZone,
    required this.cell,
    required this.emojiSize,
    required this.shadowRects,
    required this.trayRects,
  });

  /// Separación entre celdas y entre las dos zonas.
  static const double gap = 12;

  /// Relleno interior de cada zona.
  static const double padding = 10;

  /// El emoji ocupa esta parte de su celda.
  static const double emojiFraction = 0.72;

  /// Tope del emoji en píxeles físicos: por encima, el moto g55 no lo pinta, ni
  /// en color ni como silueta (R13, spike de HU-007).
  static const double maxEmojiPhysicalPx = 220;

  factory ShadowBoardGeometry.compute({
    required Size size,
    required ShadowLayout layout,
    required List<String> shadows,
    required List<String> objects,
    required double devicePixelRatio,
  }) {
    final bool horizontal = size.width > size.height;
    final int shadowCount = math.max(shadows.length, 1);
    final int objectCount = math.max(objects.length, 1);
    // Cada zona recibe espacio según cuántas cosas tiene.
    final double share = shadowCount / (shadowCount + objectCount);
    final double main = (horizontal ? size.width : size.height) - gap;
    final double shadowMain = main * share;
    final double trayMain = main - shadowMain;
    final bool shadowsFirst = layout == ShadowLayout.shadowsFirst;

    Rect zone(double start, double length) => horizontal
        ? Rect.fromLTWH(start, 0, length, size.height)
        : Rect.fromLTWH(0, start, size.width, length);
    final Rect shadowZone = shadowsFirst ? zone(0, shadowMain) : zone(trayMain + gap, shadowMain);
    final Rect trayZone = shadowsFirst ? zone(shadowMain + gap, trayMain) : zone(0, trayMain);

    final double maxEmoji = maxEmojiPhysicalPx / devicePixelRatio;
    final double cell = math.max(
      0,
      [
        _bestCell(shadowCount, shadowZone.deflate(padding).size),
        _bestCell(objectCount, trayZone.deflate(padding).size),
        maxEmoji / emojiFraction,
      ].reduce(math.min),
    );

    return ShadowBoardGeometry._(
      shadowZone: shadowZone,
      trayZone: trayZone,
      cell: cell,
      emojiSize: cell * emojiFraction,
      shadowRects: _place(shadows, shadowZone.deflate(padding), cell),
      trayRects: _place(objects, trayZone.deflate(padding), cell),
    );
  }

  final Rect shadowZone;
  final Rect trayZone;

  /// Lado de cada celda (las sombras y los objetos miden lo mismo).
  final double cell;

  /// Tamaño de fuente del emoji.
  final double emojiSize;
  final Map<String, Rect> shadowRects;
  final Map<String, Rect> trayRects;

  /// La celda cuadrada más grande con la que caben [count] celdas en [area].
  static double _bestCell(int count, Size area) {
    var best = 0.0;
    for (var columns = 1; columns <= count; columns++) {
      final int rows = (count / columns).ceil();
      final double side = math.min(
        (area.width - gap * (columns - 1)) / columns,
        (area.height - gap * (rows - 1)) / rows,
      );
      best = math.max(best, side);
    }
    return best;
  }

  /// Reparte [items] en filas centradas dentro de [area].
  static Map<String, Rect> _place(List<String> items, Rect area, double cell) {
    if (items.isEmpty || cell <= 0) return {for (final item in items) item: Rect.zero};
    final int columns = math.max(1, math.min(items.length, ((area.width + gap) / (cell + gap)).floor()));
    final int rows = (items.length / columns).ceil();
    final double top = area.top + (area.height - (rows * cell + (rows - 1) * gap)) / 2;
    final rects = <String, Rect>{};
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

/// Tablero de Sombras (HU-007 4.1, R2–R5, R13, R16, R17, R19): las sombras, la
/// bandeja y el objeto que se arrastra. Las reglas las decide quien recibe
/// [onDrop] y [onMatch] (el cubit); aquí solo se dibuja y se anima.
class ShadowBoard extends StatefulWidget {
  const ShadowBoard({
    super.key,
    required this.state,
    required this.onGrab,
    required this.onDrop,
    required this.onMatch,
    required this.onIntroDone,
    this.hintSymbol,
    this.hintObjectKey,
    this.hintShadowKey,
  });

  final ShadowGameState state;
  final ValueChanged<String> onGrab;
  final ShadowDropOutcome Function(String symbol, ShadowBox object, Map<String, ShadowBox> shadows) onDrop;
  final ShadowDropOutcome Function(String symbol, String shadow) onMatch;
  final VoidCallback onIntroDone;

  /// Objeto que señala la mano del tutorial (R15), con sus dos claves.
  final String? hintSymbol;
  final GlobalKey? hintObjectKey;
  final GlobalKey? hintShadowKey;

  /// Animación de inicio (R19): unos 1,2 s, con los objetos escalonados.
  static const Duration introDuration = Duration(milliseconds: 1200);

  /// Vuelo del objeto al soltarlo: hasta su sombra o de vuelta a la bandeja.
  static const Duration flightDuration = Duration(milliseconds: 280);

  /// Mientras se arrastra, el objeto se ve un poco más grande (R3).
  static const double dragScale = 1.15;

  @override
  State<ShadowBoard> createState() => _ShadowBoardState();
}

class _ShadowBoardState extends State<ShadowBoard> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(vsync: this, duration: ShadowBoard.introDuration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onIntroDone();
    });
  late final AnimationController _flight = AnimationController(vsync: this, duration: ShadowBoard.flightDuration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _flying = null);
    });

  ShadowBoardGeometry? _geometry;
  int? _introRound;

  /// Objeto que sigue al dedo y su centro (un solo dedo, R17).
  String? _dragged;
  Offset _dragCenter = Offset.zero;

  /// Objeto en vuelo tras soltarlo.
  String? _flying;
  Rect _flightFrom = Rect.zero;
  Rect _flightTo = Rect.zero;
  bool _flyingToShadow = false;

  /// Objeto elegido con el lector de pantalla, a la espera de su sombra (R16).
  String? _selected;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startIntroIfNeeded();
  }

  @override
  void didUpdateWidget(ShadowBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.round != oldWidget.state.round) {
      _dragged = null;
      _flying = null;
      _selected = null;
      _flight.reset();
    }
    _startIntroIfNeeded();
  }

  @override
  void dispose() {
    _intro.dispose();
    _flight.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  /// Al llegar un tablero con animación de inicio, se reproduce una vez; con
  /// «reducir movimiento», los objetos aparecen ya en la bandeja (R19).
  void _startIntroIfNeeded() {
    final ShadowGameState state = widget.state;
    if (state.phase != ShadowRoundPhase.introducing || _introRound == state.round) return;
    _introRound = state.round;
    if (_reduceMotion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onIntroDone();
      });
    } else {
      _intro.forward(from: 0);
    }
  }

  void _onPanStart(String symbol, DragStartDetails details) {
    if (_dragged != null || _flying != null || !widget.state.canDrag(symbol)) return;
    final Rect? slot = _geometry?.trayRects[symbol];
    if (slot == null) return;
    widget.onGrab(symbol);
    setState(() {
      _dragged = symbol;
      _dragCenter = slot.center;
      _selected = null;
    });
  }

  void _onPanUpdate(String symbol, DragUpdateDetails details) {
    if (_dragged != symbol) return;
    setState(() => _dragCenter += details.delta);
  }

  void _onPanEnd(String symbol) {
    final ShadowBoardGeometry? geometry = _geometry;
    if (_dragged != symbol || geometry == null) return;
    final Rect object = Rect.fromCenter(center: _dragCenter, width: geometry.cell, height: geometry.cell);
    final ShadowDropOutcome outcome = widget.onDrop(
      symbol,
      ShadowBoardGeometry.boxOf(object),
      {for (final entry in geometry.shadowRects.entries) entry.key: ShadowBoardGeometry.boxOf(entry.value)},
    );
    final bool snapped = outcome == ShadowDropOutcome.snapped;
    _fly(symbol, from: object, to: snapped ? geometry.shadowRects[symbol]! : geometry.trayRects[symbol]!, toShadow: snapped);
  }

  /// Vuelo suave del objeto (R4, R5); sin vuelo con «reducir movimiento».
  void _fly(String symbol, {required Rect from, required Rect to, required bool toShadow}) {
    setState(() {
      _dragged = null;
      if (_reduceMotion) return;
      _flying = symbol;
      _flightFrom = from;
      _flightTo = to;
      _flyingToShadow = toShadow;
    });
    if (!_reduceMotion) _flight.forward(from: 0);
  }

  void _onShadowActivated(String shadow) {
    final String? selected = _selected;
    if (selected == null) return;
    setState(() => _selected = null);
    widget.onMatch(selected, shadow);
  }

  @override
  Widget build(BuildContext context) {
    final ShadowGameState state = widget.state;
    final l10n = AppLocalizations.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final ShadowBoardGeometry geometry = ShadowBoardGeometry.compute(
          size: constraints.biggest,
          layout: state.layout,
          shadows: state.shadows,
          objects: state.objects,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
        );
        _geometry = geometry;
        final bool introducing = state.phase == ShadowRoundPhase.introducing;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _Zone(key: const ValueKey<String>('shadow-zone-shadows'), rect: geometry.shadowZone, shadows: true),
            _Zone(key: const ValueKey<String>('shadow-zone-tray'), rect: geometry.trayZone, shadows: false),
            for (final shadow in state.shadows)
              Positioned.fromRect(
                rect: geometry.shadowRects[shadow]!,
                child: _hintWrap(
                  shadow,
                  widget.hintShadowKey,
                  _ShadowCell(
                    key: ValueKey<String>('shadow-target-$shadow'),
                    symbol: shadow,
                    emojiSize: geometry.emojiSize,
                    filled: state.placed.contains(shadow) && !(_flying == shadow && _flyingToShadow),
                    semanticLabel: state.placed.contains(shadow)
                        ? l10n.shadowsPlacedSemantics(shadow)
                        : l10n.shadowsShadowSemantics(shadow),
                    onActivate: state.placed.contains(shadow) || _selected == null
                        ? null
                        : () => _onShadowActivated(shadow),
                  ),
                ),
              ),
            for (final object in state.objects)
              // El hueco sigue en el árbol mientras se arrastra (invisible): si se
              // quitara, su detector de gestos se perdería con el dedo encima.
              if (!introducing && !state.placed.contains(object) && _flying != object)
                Positioned.fromRect(
                  rect: geometry.trayRects[object]!,
                  child: _hintWrap(
                    object,
                    widget.hintObjectKey,
                    Semantics(
                      key: ValueKey<String>('shadow-object-$object'),
                      button: true,
                      selected: _selected == object,
                      label: l10n.shadowsObjectSemantics(object),
                      onTap: state.canDrag(object) ? () => setState(() => _selected = object) : null,
                      child: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onPanStart: (details) => _onPanStart(object, details),
                        onPanUpdate: (details) => _onPanUpdate(object, details),
                        onPanEnd: (_) => _onPanEnd(object),
                        onPanCancel: () => _onPanEnd(object),
                        child: Opacity(
                          opacity: _dragged == object ? 0 : 1,
                          child: _ObjectCard(symbol: object, emojiSize: geometry.emojiSize, selected: _selected == object),
                        ),
                      ),
                    ),
                  ),
                ),
            if (introducing) ..._introObjects(geometry),
            if (_dragged case final String dragged)
              Positioned.fromRect(
                rect: Rect.fromCenter(
                  center: _dragCenter,
                  width: geometry.cell * ShadowBoard.dragScale,
                  height: geometry.cell * ShadowBoard.dragScale,
                ),
                child: IgnorePointer(
                  child: _ObjectCard(
                    key: const ValueKey<String>('shadow-dragged'),
                    symbol: dragged,
                    emojiSize: geometry.emojiSize * ShadowBoard.dragScale,
                    lifted: true,
                  ),
                ),
              ),
            if (_flying case final String flying)
              AnimatedBuilder(
                animation: _flight,
                builder: (context, _) => Positioned.fromRect(
                  rect: Rect.lerp(_flightFrom, _flightTo, Curves.easeOutCubic.transform(_flight.value))!,
                  child: IgnorePointer(
                    child: _ObjectCard(
                      key: const ValueKey<String>('shadow-flying'),
                      symbol: flying,
                      emojiSize: geometry.emojiSize,
                      bare: _flyingToShadow,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Animación de inicio (R19): cada objeto sale de su sombra, pintado como
  /// ella, y llega a la bandeja en color. Las sombras libres no sueltan nada.
  List<Widget> _introObjects(ShadowBoardGeometry geometry) {
    final List<String> objects = widget.state.objects;
    final double step = objects.length > 1 ? 0.5 / (objects.length - 1) : 0;
    return [
      for (var index = 0; index < objects.length; index++)
        AnimatedBuilder(
          key: ValueKey<String>('shadow-intro-${objects[index]}'),
          animation: _intro,
          builder: (context, _) {
            final double start = index * step;
            final double t = Curves.easeInOutCubic.transform(((_intro.value - start) / 0.5).clamp(0.0, 1.0));
            final String symbol = objects[index];
            return Positioned.fromRect(
              rect: Rect.lerp(geometry.shadowRects[symbol], geometry.trayRects[symbol], t)!,
              child: IgnorePointer(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(opacity: t, child: _ObjectCard(symbol: symbol, emojiSize: geometry.emojiSize)),
                    Opacity(opacity: 1 - t, child: _Emoji(symbol: symbol, size: geometry.emojiSize, silhouette: true)),
                  ],
                ),
              ),
            );
          },
        ),
    ];
  }

  Widget _hintWrap(String symbol, GlobalKey? key, Widget child) =>
      symbol == widget.hintSymbol && key != null ? KeyedSubtree(key: key, child: child) : child;
}

/// Fondo de una zona: la de sombras, blanca; la bandeja, teal muy suave.
class _Zone extends StatelessWidget {
  const _Zone({super.key, required this.rect, required this.shadows});

  final Rect rect;
  final bool shadows;

  @override
  Widget build(BuildContext context) {
    return Positioned.fromRect(
      rect: rect,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: shadows ? AppPalette.white : AppPalette.deepTeal.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

/// Una sombra: el emoji pintado en teal profundo (R13). Con su objeto ya
/// encajado, el objeto en color ocupa su sitio.
class _ShadowCell extends StatelessWidget {
  const _ShadowCell({
    super.key,
    required this.symbol,
    required this.emojiSize,
    required this.filled,
    required this.semanticLabel,
    required this.onActivate,
  });

  final String symbol;
  final double emojiSize;
  final bool filled;
  final String semanticLabel;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: !filled,
      label: semanticLabel,
      onTap: onActivate,
      excludeSemantics: true,
      child: Center(
        child: _Emoji(
          key: ValueKey<String>(filled ? 'shadow-placed-$symbol' : 'shadow-silhouette-$symbol'),
          symbol: symbol,
          size: emojiSize,
          silhouette: !filled,
        ),
      ),
    );
  }
}

/// Un objeto de la bandeja: el emoji en color sobre una tarjeta blanca.
class _ObjectCard extends StatelessWidget {
  const _ObjectCard({
    super.key,
    required this.symbol,
    required this.emojiSize,
    this.selected = false,
    this.lifted = false,
    this.bare = false,
  });

  final String symbol;
  final double emojiSize;
  final bool selected;

  /// Mientras se arrastra: sombra más marcada.
  final bool lifted;

  /// Sin tarjeta: el objeto ya entra en su sombra.
  final bool bare;

  @override
  Widget build(BuildContext context) {
    final Widget emoji = Center(child: _Emoji(symbol: symbol, size: emojiSize));
    if (bare) return emoji;
    return DecoratedBox(
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
      child: ExcludeSemantics(child: emoji),
    );
  }
}

/// El emoji, en color o como silueta de un solo color (`srcIn`, comprobado en
/// el spike de HU-007).
class _Emoji extends StatelessWidget {
  const _Emoji({super.key, required this.symbol, required this.size, this.silhouette = false});

  final String symbol;
  final double size;
  final bool silhouette;

  @override
  Widget build(BuildContext context) {
    final Widget text = Text(
      symbol,
      textAlign: TextAlign.center,
      textScaler: TextScaler.noScaling,
      style: TextStyle(fontSize: size, height: 1.15),
    );
    if (!silhouette) return text;
    return ColorFiltered(colorFilter: const ColorFilter.mode(AppPalette.deepTeal, BlendMode.srcIn), child: text);
  }
}
