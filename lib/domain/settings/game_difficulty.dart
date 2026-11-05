/// Dificultad de los juegos (HU-030, D-035): un ajuste general de la Zona de
/// Padres. Cada juego define qué cambia en cada nivel; Normal es el juego tal
/// como está diseñado.
enum GameDifficulty {
  easy,
  normal,
  impossible;

  /// Las ayudas que enseñan la solución (vista previa de la memoria, animación
  /// de inicio de Sombras) solo van en Fácil y Normal (HU-030 R10).
  bool get showsHelps => this != impossible;

  /// Lee el valor guardado; uno desconocido (o ninguno) es Normal.
  static GameDifficulty fromName(String? name) =>
      values.firstWhere((value) => value.name == name, orElse: () => normal);
}
