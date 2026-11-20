/// Cómo se mueven las piezas en los juegos donde se lleva una pieza a su sitio
/// (HU-039): hoy, Sombras y «A su sitio». Un ajuste único para todos (P5).
enum MoveMode {
  /// Solo arrastrar.
  drag,

  /// Solo tocar la pieza y después su sitio.
  tap,

  /// Las dos formas (P1, por defecto).
  both;

  bool get allowsDrag => this != tap;

  bool get allowsTap => this != drag;

  /// Un nombre guardado desconocido o ausente es «Ambas».
  static MoveMode fromName(String? name) =>
      MoveMode.values.firstWhere((mode) => mode.name == name, orElse: () => MoveMode.both);
}

/// La mano con la que juega el niño (HU-031). Con la izquierda, las sombras van
/// a la derecha en horizontal y la mano guía se ve reflejada.
enum PlayingHand {
  right,
  left;

  /// Un nombre guardado desconocido o ausente es la derecha.
  static PlayingHand fromName(String? name) =>
      PlayingHand.values.firstWhere((hand) => hand.name == name, orElse: () => PlayingHand.right);
}
