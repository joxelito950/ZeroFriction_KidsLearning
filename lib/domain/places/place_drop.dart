import '../shadows/shadow_drop.dart';

/// Qué pasa al soltar una pieza sobre un tablero de destinos: los sitios de
/// «A su sitio» (HU-052 7.1) y las cestas de «Clasificar» (HU-027). Los
/// destinos son tarjetas más grandes que la pieza y reciben varias, así que se
/// mide qué parte **de la pieza** cae sobre cada destino (en Sombras, qué parte
/// de la sombra cubre el objeto). Reutiliza las cajas y los resultados de
/// Sombras.
abstract final class PlaceDrop {
  /// Parte de [piece] que cae sobre [target], de 0 a 1.
  static double overlap(ShadowBox piece, ShadowBox target) => ShadowDrop.coverage(target, piece);

  /// Resultado de soltar en [piece] una pieza cuyo destino es [target].
  /// [targets] son los destinos del tablero que aún admiten piezas.
  static ShadowDropOutcome evaluate<T>({
    required T target,
    required ShadowBox piece,
    required Map<T, ShadowBox> targets,
    required double threshold,
  }) {
    final ShadowBox? own = targets[target];
    if (own != null && overlap(piece, own) >= threshold) return ShadowDropOutcome.snapped;
    final bool wrong = targets.entries.any((entry) => entry.key != target && overlap(piece, entry.value) >= threshold);
    return wrong ? ShadowDropOutcome.wrongShadow : ShadowDropOutcome.missed;
  }
}
