import '../shadows/shadow_drop.dart';
import 'vehicle_catalog.dart';

/// Qué pasa al soltar un vehículo (HU-052 7.1). Los sitios son tarjetas más
/// grandes que el vehículo y reciben hasta 2, así que se mide qué parte **del
/// vehículo** cae sobre cada sitio (en Sombras, qué parte de la sombra cubre el
/// objeto). Reutiliza las cajas y los resultados de Sombras.
abstract final class VehicleDrop {
  /// Parte de [vehicle] que cae sobre [place], de 0 a 1.
  static double overlap(ShadowBox vehicle, ShadowBox place) => ShadowDrop.coverage(place, vehicle);

  /// Resultado de soltar un vehículo cuyo sitio es [target] en [vehicle].
  /// [places] son los sitios del tablero que aún admiten vehículos.
  static ShadowDropOutcome evaluate({
    required Place target,
    required ShadowBox vehicle,
    required Map<Place, ShadowBox> places,
    required double threshold,
  }) {
    final ShadowBox? own = places[target];
    if (own != null && overlap(vehicle, own) >= threshold) return ShadowDropOutcome.snapped;
    final bool wrong = places.entries.any((entry) => entry.key != target && overlap(vehicle, entry.value) >= threshold);
    return wrong ? ShadowDropOutcome.wrongShadow : ShadowDropOutcome.missed;
  }
}
