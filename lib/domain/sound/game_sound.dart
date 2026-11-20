/// Sonidos de los juegos (HU-005 R1). Ninguno es de error (R2): dos cartas
/// distintas, el tiempo agotado o soltar una figura en otra sombra no suenan.
enum GameSound {
  /// Voltear una carta.
  flip,

  /// Encontrar una pareja o encajar un objeto en su sombra.
  match,

  /// Completar un tablero.
  complete,

  /// Conseguir la insignia o la medalla.
  badge;

  /// Sonidos de celebración: se callan en la preparación para dormir. El de
  /// voltear o tocar sigue, para que el juego no parezca roto (HU-038 R10).
  bool get isCelebration => this != flip;
}

/// Reproduce los sonidos. Se implementa con el plugin de audio en `data/`.
abstract interface class ISoundEffects {
  /// Reproduce [sound]. Nunca lanza: si falla, no suena y el juego sigue (R7).
  Future<void> play(GameSound sound);
}
