import 'package:flutter/material.dart';

import '../../domain/shadows/shadow_drop.dart';
import '../../domain/vehicles/vehicle_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/vehicle_game/vehicle_game_state.dart';
import 'place_board_view.dart';

/// Tablero de «A su sitio» (HU-052 7.1): el tablero de destinos común
/// ([PlaceBoardView], HU-027 entrega 1) con los vehículos como piezas y los
/// sitios como destinos, dos huecos por sitio. Las reglas las decide el cubit.
class VehicleBoardView extends StatelessWidget {
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

  static const Duration flightDuration = PlaceBoardView.flightDuration;

  /// El regalo que deja cada vehículo en Navidad (HU-052 sección 6).
  static const String gift = '🎁';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final List<Place> places = state.board?.places ?? const [];
    Vehicle vehicle(String id) => Vehicle.values.byName(id);
    Place place(String id) => Place.values.byName(id);

    return PlaceBoardView(
      keyPrefix: 'vehicle',
      data: PlaceBoardData(
        boardId: state.round,
        pieces: [
          for (final Vehicle each in state.vehicles)
            BoardPiece(
              id: each.name,
              symbol: each.symbol,
              semanticLabel: l10n.vehiclesVehicleSemantics(l10n.vehiclesVehicleName(each.name)),
            ),
        ],
        targets: [
          for (final Place each in places)
            BoardTarget(id: each.name, symbol: each.symbol, semanticLabel: _placeLabel(l10n, state, each)),
        ],
        targetOf: (id) => state.board!.targetOf(vehicle(id)).name,
        placedAt: (id) => [for (final Vehicle each in state.placedAt(place(id))) each.name],
        isPlaced: (id) => state.placed.contains(vehicle(id)),
        canDrag: (id) => state.canDrag(vehicle(id)),
        coverageToSnap: state.coverageToSnap,
        placesFirst: state.placesFirst,
        placedBadge: state.christmas ? gift : null,
      ),
      onGrab: (id) => onGrab(vehicle(id)),
      onDrop: (id, box, targets) =>
          onDrop(vehicle(id), box, {for (final entry in targets.entries) place(entry.key): entry.value}),
      onMatch: (id, target) => onMatch(vehicle(id), place(target)),
      hintPiece: hintVehicle?.name,
      hintPieceKey: hintVehicleKey,
      hintTargetKey: hintPlaceKey,
    );
  }

  static String _placeLabel(AppLocalizations l10n, VehicleGameState state, Place place) {
    final String name = l10n.vehiclesPlaceName(place.name);
    final List<Vehicle> here = state.placedAt(place);
    if (here.isEmpty) return name;
    return l10n.vehiclesPlaceWithSemantics(
        name, here.map((vehicle) => l10n.vehiclesVehicleName(vehicle.name)).join(', '));
  }
}
