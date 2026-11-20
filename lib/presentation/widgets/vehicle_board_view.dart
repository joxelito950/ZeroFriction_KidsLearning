import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/shadows/shadow_drop.dart';
import '../../domain/vehicles/vehicle_catalog.dart';
import '../../domain/vehicles/vehicle_drop.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/how_to_play/how_to_play_cubit.dart';
import '../blocs/vehicle_game/vehicle_game_state.dart';
import '../theme/app_palette.dart';

/// Dónde va cada cosa en el tablero de «A su sitio», en coordenadas del propio
/// tablero (HU-052 7.1): los sitios en tarjetas grandes, la bandeja con los
/// vehículos y, dentro de cada sitio, dos huecos para los vehículos colocados.
final class VehicleBoardGeometry {
  VehicleBoardGeometry._({
    required this.placeZone,
    required this.trayZone,
    required this.placeRects,
    required this.trayRects,
    required this.vehicleCell,
  });

  static const double gap = 12;
  static const double padding = 10;

  /// El emoji ocupa esta parte de su celda.
  static const double emojiFraction = 0.72;

  /// Tope del emoji en píxeles físicos: por encima, el moto g55 no lo pinta
  /// (spike de HU-007).
  static const double maxEmojiPhysicalPx = 220;

  /// Lado de cada hueco de vehículo colocado, respecto a la tarjeta del sitio.
  static const double slotFraction = 0.4;

  factory VehicleBoardGeometry.compute({
    required Size size,
    required bool placesFirst,
    required List<Place> places,
    required List<Vehicle> vehicles,
    required double devicePixelRatio,
    bool leftHanded = false,
  }) {
    final bool horizontal = size.width > size.height;
    // Con la mano izquierda y en horizontal, los sitios pasan al otro lado,
    // donde la mano no los tapa (HU-031 R1), como en Sombras.
    placesFirst = placesFirst != (horizontal && leftHanded);
    final int placeCount = math.max(places.length, 1);
    final int vehicleCount = math.max(vehicles.length, 1);
    // Los sitios llevan dentro sus vehículos: reciben algo más de espacio.
    final double share = (placeCount * 1.4) / (placeCount * 1.4 + vehicleCount);
    final double main = (horizontal ? size.width : size.height) - gap;
    final double placeMain = main * share;
    final double trayMain = main - placeMain;

    Rect zone(double start, double length) =>
        horizontal ? Rect.fromLTWH(start, 0, length, size.height) : Rect.fromLTWH(0, start, size.width, length);
    final Rect placeZone = placesFirst ? zone(0, placeMain) : zone(trayMain + gap, placeMain);
    final Rect trayZone = placesFirst ? zone(placeMain + gap, trayMain) : zone(0, trayMain);

    final double maxCell = maxEmojiPhysicalPx / devicePixelRatio / emojiFraction;
    final double placeCell = math.max(0, _bestCell(placeCount, placeZone.deflate(padding).size));
    final double vehicleCell = math.max(
      0,
      [_bestCell(vehicleCount, trayZone.deflate(padding).size), maxCell, placeCell * 0.8].reduce(math.min),
    );
    return VehicleBoardGeometry._(
      placeZone: placeZone,
      trayZone: trayZone,
      placeRects: _place(places, placeZone.deflate(padding), placeCell),
      trayRects: _place(vehicles, trayZone.deflate(padding), vehicleCell),
      vehicleCell: vehicleCell,
    );
  }

  final Rect placeZone;
  final Rect trayZone;
  final Map<Place, Rect> placeRects;
  final Map<Vehicle, Rect> trayRects;

  /// Lado de la celda de un vehículo (en la bandeja y al arrastrarlo).
  final double vehicleCell;

  /// Hueco [index] (0 o 1) de un vehículo colocado en [place].
  Rect slotRect(Place place, int index) {
    final Rect card = placeRects[place]!;
    final double side = card.width * slotFraction;
    final double spacing = (card.width - 2 * side) / 3;
    return Rect.fromLTWH(card.left + spacing + index * (side + spacing), card.bottom - side - spacing / 2, side, side);
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

/// Tablero de «A su sitio» (HU-052 7.1): los sitios, la bandeja y el vehículo
/// que se arrastra. Las reglas las decide quien recibe [onDrop] y [onMatch] (el
/// cubit); aquí solo se dibuja y se anima. Las zonas son físicas, también en
/// árabe: dependen de la mano, como en Sombras.
class VehicleBoardView extends StatefulWidget {
  const VehicleBoardView({
    super.key,
    required this.state,
    required this.onGrab,
    required this.onDrop,
    required this.onMatch,
    this.hintVehicle,
    this.hintVehicleKey,
    this.hintPlaceKey,
  });

  final VehicleGameState state;
  final ValueChanged<Vehicle> onGrab;
  final ShadowDropOutcome Function(Vehicle vehicle, ShadowBox box, Map<Place, ShadowBox> places) onDrop;
  final ShadowDropOutcome Function(Vehicle vehicle, Place place) onMatch;

  /// Vehículo que señala la mano del tutorial, con sus dos claves (HU-022).
  final Vehicle? hintVehicle;
  final GlobalKey? hintVehicleKey;
  final GlobalKey? hintPlaceKey;

  static const Duration flightDuration = Duration(milliseconds: 280);

  /// El regalo que deja cada vehículo en Navidad (HU-052 sección 6).
  static const String gift = '🎁';

  @override
  State<VehicleBoardView> createState() => _VehicleBoardViewState();
}

class _VehicleBoardViewState extends State<VehicleBoardView> with SingleTickerProviderStateMixin {
  late final AnimationController _flight = AnimationController(vsync: this, duration: VehicleBoardView.flightDuration)
    ..addStatusListener((status) {
      if (status == AnimationStatus.completed) setState(() => _flying = null);
    });

  VehicleBoardGeometry? _geometry;
  Vehicle? _dragged;
  Offset _dragCenter = Offset.zero;
  Vehicle? _flying;
  Rect _flightFrom = Rect.zero;
  Rect _flightTo = Rect.zero;

  /// Vehículo elegido con el lector de pantalla, a la espera de su sitio.
  Vehicle? _selected;

  @override
  void didUpdateWidget(VehicleBoardView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state.round != oldWidget.state.round) {
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

  void _onPanStart(Vehicle vehicle) {
    if (_dragged != null || _flying != null || !widget.state.canDrag(vehicle)) return;
    final Rect? slot = _geometry?.trayRects[vehicle];
    if (slot == null) return;
    widget.onGrab(vehicle);
    setState(() {
      _dragged = vehicle;
      _dragCenter = slot.center;
      _selected = null;
    });
  }

  void _onPanUpdate(Vehicle vehicle, DragUpdateDetails details) {
    if (_dragged == vehicle) setState(() => _dragCenter += details.delta);
  }

  Rect _draggedRect(VehicleBoardGeometry geometry) =>
      Rect.fromCenter(center: _dragCenter, width: geometry.vehicleCell, height: geometry.vehicleCell);

  Map<Place, ShadowBox> _placeBoxes(VehicleBoardGeometry geometry) => {
        for (final entry in geometry.placeRects.entries) entry.key: VehicleBoardGeometry.boxOf(entry.value),
      };

  void _onPanEnd(Vehicle vehicle) {
    final VehicleBoardGeometry? geometry = _geometry;
    if (_dragged != vehicle || geometry == null) return;
    final Rect from = _draggedRect(geometry);
    final ShadowDropOutcome outcome = widget.onDrop(vehicle, VehicleBoardGeometry.boxOf(from), _placeBoxes(geometry));
    final Rect to = outcome == ShadowDropOutcome.snapped ? _slotOf(geometry, vehicle) : geometry.trayRects[vehicle]!;
    _fly(vehicle, from: from, to: to);
  }

  /// El hueco del sitio donde queda [vehicle]: el siguiente libre. El estado
  /// con el vehículo ya colocado aún no ha llegado al tablero.
  Rect _slotOf(VehicleBoardGeometry geometry, Vehicle vehicle) {
    final Place place = widget.state.board!.targetOf(vehicle);
    final List<Vehicle> before = widget.state.placedAt(place);
    final int index = before.contains(vehicle) ? before.indexOf(vehicle) : before.length;
    return geometry.slotRect(place, math.min(index, 1));
  }

  void _fly(Vehicle vehicle, {required Rect from, required Rect to}) {
    setState(() {
      _dragged = null;
      if (_reduceMotion) return;
      _flying = vehicle;
      _flightFrom = from;
      _flightTo = to;
    });
    if (!_reduceMotion) _flight.forward(from: 0);
  }

  /// El vehículo arrastrado encajaría si se soltara ahora: el borde de su sitio
  /// se ilumina en ámbar (como en Sombras, HU-050 P2).
  bool _wouldSnap(VehicleBoardGeometry geometry, Place place) {
    final Vehicle? dragged = _dragged;
    if (dragged == null || widget.state.board!.targetOf(dragged) != place) return false;
    return VehicleDrop.overlap(
          VehicleBoardGeometry.boxOf(_draggedRect(geometry)),
          VehicleBoardGeometry.boxOf(geometry.placeRects[place]!),
        ) >=
        widget.state.coverageToSnap;
  }

  /// Tocar el vehículo lo elige; tocarlo otra vez lo suelta; tocar otro
  /// cambia la elección (HU-039 R3).
  void _onVehicleTapped(Vehicle vehicle) {
    if (_dragged != null || _flying != null || !widget.state.canDrag(vehicle)) return;
    if (_selected != vehicle) widget.onGrab(vehicle);
    setState(() => _selected = _selected == vehicle ? null : vehicle);
  }

  /// Con un vehículo elegido, tocar un sitio lo lleva hasta él. Si no es el
  /// suyo, vuelve a la bandeja como al soltarlo mal (HU-039 R4).
  void _onPlaceActivated(Place place) {
    final Vehicle? selected = _selected;
    final VehicleBoardGeometry? geometry = _geometry;
    if (selected == null) return;
    setState(() => _selected = null);
    final Rect? slotBefore = geometry == null ? null : _slotOf(geometry, selected);
    final ShadowDropOutcome outcome = widget.onMatch(selected, place);
    final Rect? tray = geometry?.trayRects[selected];
    final Rect? at = geometry?.placeRects[place];
    if (tray == null || at == null || slotBefore == null) return;
    _fly(selected,
        from: outcome == ShadowDropOutcome.snapped ? tray : at,
        to: outcome == ShadowDropOutcome.snapped ? slotBefore : tray);
  }

  @override
  Widget build(BuildContext context) {
    final VehicleGameState state = widget.state;
    final l10n = AppLocalizations.of(context);
    final List<Place> places = state.board?.places ?? const [];
    final Vehicle? hintVehicle = widget.hintVehicle;
    final Place? hintPlace = hintVehicle == null ? null : state.board?.targetOf(hintVehicle);
    // Arrastrar, tocar o ambas (HU-039). Con el lector de pantalla siempre se
    // puede tocar.
    final HowToPlay how = context.select<HowToPlayCubit?, HowToPlay>((cubit) => cubit?.state ?? const HowToPlay());
    final bool tapEnabled = how.moveMode.allowsTap || MediaQuery.accessibleNavigationOf(context);
    final bool dragEnabled = how.moveMode.allowsDrag;

    return LayoutBuilder(
      builder: (context, constraints) {
        final VehicleBoardGeometry geometry = VehicleBoardGeometry.compute(
          size: constraints.biggest,
          placesFirst: state.placesFirst,
          places: places,
          vehicles: state.vehicles,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          leftHanded: how.leftHanded,
        );
        _geometry = geometry;
        final double vehicleEmoji = geometry.vehicleCell * VehicleBoardGeometry.emojiFraction;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            _Zone(key: const ValueKey<String>('vehicle-zone-places'), rect: geometry.placeZone, places: true),
            _Zone(key: const ValueKey<String>('vehicle-zone-tray'), rect: geometry.trayZone, places: false),
            for (final Place place in places)
              Positioned.fromRect(
                rect: geometry.placeRects[place]!,
                child: _hintWrap(
                  place == hintPlace,
                  widget.hintPlaceKey,
                  _PlaceCard(
                    key: ValueKey<String>('vehicle-place-${place.name}'),
                    place: place,
                    almost: _wouldSnap(geometry, place),
                    semanticLabel: _placeLabel(l10n, state, place),
                    onActivate: _selected == null ? null : () => _onPlaceActivated(place),
                  ),
                ),
              ),
            for (final Place place in places)
              for (final (int index, Vehicle vehicle) in state.placedAt(place).indexed)
                if (_flying != vehicle)
                  Positioned.fromRect(
                    rect: geometry.slotRect(place, math.min(index, 1)),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: _Emoji(
                            key: ValueKey<String>('vehicle-placed-${vehicle.name}'),
                            symbol: vehicle.symbol,
                            size: geometry.slotRect(place, 0).width * VehicleBoardGeometry.emojiFraction,
                          ),
                        ),
                        // En Navidad, cada vehículo que llega deja un regalo (HU-052 §6).
                        if (state.christmas)
                          PositionedDirectional(
                            end: -geometry.slotRect(place, 0).width * 0.1,
                            bottom: 0,
                            child: _Emoji(
                              key: ValueKey<String>('vehicle-gift-${vehicle.name}'),
                              symbol: VehicleBoardView.gift,
                              size: geometry.slotRect(place, 0).width * 0.35,
                            ),
                          ),
                      ],
                    ),
                  ),
            for (final Vehicle vehicle in state.vehicles)
              // El hueco sigue en el árbol mientras se arrastra (invisible): si se
              // quitara, su detector de gestos se perdería con el dedo encima.
              if (!state.placed.contains(vehicle) && _flying != vehicle)
                Positioned.fromRect(
                  rect: geometry.trayRects[vehicle]!,
                  child: _hintWrap(
                    vehicle == hintVehicle,
                    widget.hintVehicleKey,
                    Semantics(
                      key: ValueKey<String>('vehicle-tray-${vehicle.name}'),
                      button: true,
                      selected: _selected == vehicle,
                      label: l10n.vehiclesVehicleSemantics(l10n.vehiclesVehicleName(vehicle.name)),
                      onTap: state.canDrag(vehicle) ? () => setState(() => _selected = vehicle) : null,
                      excludeSemantics: true,
                      child: GestureDetector(
                        dragStartBehavior: DragStartBehavior.down,
                        onTap: tapEnabled ? () => _onVehicleTapped(vehicle) : null,
                        onPanStart: dragEnabled ? (_) => _onPanStart(vehicle) : null,
                        onPanUpdate: dragEnabled ? (details) => _onPanUpdate(vehicle, details) : null,
                        onPanEnd: dragEnabled ? (_) => _onPanEnd(vehicle) : null,
                        onPanCancel: dragEnabled ? () => _onPanEnd(vehicle) : null,
                        child: Opacity(
                          opacity: _dragged == vehicle ? 0 : 1,
                          child: _VehicleCard(
                              symbol: vehicle.symbol, emojiSize: vehicleEmoji, selected: _selected == vehicle),
                        ),
                      ),
                    ),
                  ),
                ),
            if (_dragged case final Vehicle dragged)
              Positioned.fromRect(
                rect: _draggedRect(geometry),
                child: IgnorePointer(
                  child: _VehicleCard(
                    key: const ValueKey<String>('vehicle-dragged'),
                    symbol: dragged.symbol,
                    emojiSize: vehicleEmoji,
                    lifted: true,
                  ),
                ),
              ),
            if (_flying case final Vehicle flying)
              AnimatedBuilder(
                animation: _flight,
                builder: (context, _) {
                  final Rect rect = Rect.lerp(_flightFrom, _flightTo, Curves.easeOutCubic.transform(_flight.value))!;
                  return Positioned.fromRect(
                    rect: rect,
                    child: IgnorePointer(
                      child: _Emoji(
                        key: const ValueKey<String>('vehicle-flying'),
                        symbol: flying.symbol,
                        size: rect.width * VehicleBoardGeometry.emojiFraction,
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

  static String _placeLabel(AppLocalizations l10n, VehicleGameState state, Place place) {
    final String name = l10n.vehiclesPlaceName(place.name);
    final List<Vehicle> here = state.placedAt(place);
    if (here.isEmpty) return name;
    return l10n.vehiclesPlaceWithSemantics(
        name, here.map((vehicle) => l10n.vehiclesVehicleName(vehicle.name)).join(', '));
  }

  Widget _hintWrap(bool hinted, GlobalKey? key, Widget child) =>
      hinted && key != null ? KeyedSubtree(key: key, child: child) : child;
}

/// Fondo de una zona: la de sitios, blanca; la bandeja, teal muy suave.
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

/// La tarjeta de un sitio (HU-052 7.7): blanca con borde teal suave; ámbar
/// cuando el vehículo arrastrado encajaría. El emoji del sitio, arriba; los
/// vehículos colocados se pintan encima, en sus huecos.
class _PlaceCard extends StatelessWidget {
  const _PlaceCard({
    super.key,
    required this.place,
    required this.almost,
    required this.semanticLabel,
    required this.onActivate,
  });

  final Place place;
  final bool almost;
  final String semanticLabel;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      onTap: onActivate,
      excludeSemantics: true,
      // Con un vehículo elegido, el sitio se toca para llevarlo (HU-039 R3).
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onActivate,
        child: LayoutBuilder(
          builder: (context, constraints) => DecoratedBox(
            key: almost ? ValueKey<String>('vehicle-almost-${place.name}') : null,
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
              child: _Emoji(symbol: place.symbol, size: constraints.maxWidth * 0.42),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un vehículo de la bandeja: el emoji en color sobre una tarjeta blanca.
class _VehicleCard extends StatelessWidget {
  const _VehicleCard(
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
