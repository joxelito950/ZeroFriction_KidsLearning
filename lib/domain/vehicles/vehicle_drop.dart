import '../places/place_drop.dart';
import '../shadows/shadow_drop.dart';
import 'vehicle_catalog.dart';

/// Qué pasa al soltar un vehículo (HU-052 7.1): el cálculo común de los
/// tableros de destinos ([PlaceDrop]) con los sitios de «A su sitio».
abstract final class VehicleDrop {
  /// Parte de [vehicle] que cae sobre [place], de 0 a 1.
  static double overlap(ShadowBox vehicle, ShadowBox place) => PlaceDrop.overlap(vehicle, place);

  /// Resultado de soltar un vehículo cuyo sitio es [target] en [vehicle].
  /// [places] son los sitios del tablero que aún admiten vehículos.
  static ShadowDropOutcome evaluate({
    required Place target,
    required ShadowBox vehicle,
    required Map<Place, ShadowBox> places,
    required double threshold,
  }) =>
      PlaceDrop.evaluate<Place>(target: target, piece: vehicle, targets: places, threshold: threshold);
}
