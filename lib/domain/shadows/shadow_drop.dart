/// Qué pasa al soltar un objeto (HU-007 R4, R5, P4): se mide qué parte de cada
/// sombra libre cubre el objeto.
library;

/// Un rectángulo en pantalla, en coordenadas lógicas. El dominio no depende de
/// Flutter (D-012), por eso no usa `Rect`.
final class ShadowBox {
  const ShadowBox({required this.left, required this.top, required this.width, required this.height});

  final double left;
  final double top;
  final double width;
  final double height;

  double get right => left + width;
  double get bottom => top + height;
  double get area => width * height;
}

enum ShadowDropOutcome {
  /// Cubre su sombra lo suficiente: se coloca solo (R4).
  snapped,

  /// Cubre una sombra equivocada lo suficiente: fallo de forma (R5, R9).
  wrongShadow,

  /// No cubre ninguna sombra lo suficiente: vuelve a la bandeja sin fallo.
  missed,
}

abstract final class ShadowDrop {
  /// Parte de [shadow] cubierta por [object], de 0 a 1.
  static double coverage(ShadowBox object, ShadowBox shadow) {
    if (shadow.area <= 0) return 0;
    final double width = _overlap(object.left, object.right, shadow.left, shadow.right);
    final double height = _overlap(object.top, object.bottom, shadow.top, shadow.bottom);
    return (width * height) / shadow.area;
  }

  static double _overlap(double a1, double a2, double b1, double b2) {
    final double from = a1 > b1 ? a1 : b1;
    final double to = a2 < b2 ? a2 : b2;
    return to > from ? to - from : 0;
  }

  /// Resultado de soltar el objeto [symbol] en [object]. [shadows] son las
  /// sombras aún libres, por su emoji. Si cubre bien la suya, encaja aunque
  /// también roce otra.
  static ShadowDropOutcome evaluate({
    required String symbol,
    required ShadowBox object,
    required Map<String, ShadowBox> shadows,
    required double threshold,
  }) {
    final ShadowBox? own = shadows[symbol];
    if (own != null && coverage(object, own) >= threshold) return ShadowDropOutcome.snapped;
    final bool wrong =
        shadows.entries.any((entry) => entry.key != symbol && coverage(object, entry.value) >= threshold);
    return wrong ? ShadowDropOutcome.wrongShadow : ShadowDropOutcome.missed;
  }
}
