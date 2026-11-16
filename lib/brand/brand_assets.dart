/// Imágenes de la identidad visual (HU-013). Salen de `docs/brand/fuentes/` con
/// `tool/brand/prepare_brand_images.py`; el icono del launcher no está aquí
/// porque lo genera `flutter_launcher_icons` en los recursos de Android.
abstract final class BrandAssets {
  /// El niño, personaje de identidad, con el puzle: encima del título del menú.
  static const String logo = 'assets/brand/logo.png';

  /// Icono del juego de memoria: botón del menú y cabecera del juego. Su silueta
  /// es la que se llenará de dorado (HU-002).
  static const String memoryIcon = 'assets/brand/memory_icon.png';

  /// Icono del juego Sombras (HU-007): el elefante y su sombra.
  static const String shadowsIcon = 'assets/brand/shadows_icon.png';

  /// Icono de «¿Cuál es diferente?» (HU-025): tres manzanas y una pera.
  static const String oddOneOutIcon = 'assets/brand/odd_one_out_icon.png';

  /// Mano infantil de la ayuda (HU-022): sustituye al icono de Material.
  static const String handGuide = 'assets/brand/hand_guide.png';

  /// El niño descansando con su osito (PROMPTS §11): pantalla de descanso (HU-009).
  static const String childResting = 'assets/brand/child_resting.png';

  /// El niño durmiendo bajo la luna (PROMPTS §12): versión de noche de la
  /// pantalla de descanso (HU-038), sobre teal profundo.
  static const String childSleeping = 'assets/brand/child_sleeping.png';

  /// El niño celebrando entre confeti (PROMPTS §13), con un hueco en el pecho
  /// para la medalla que pinta la app (HU-037).
  static const String childCelebrating = 'assets/brand/child_celebrating.png';

  /// El niño señalando a su izquierda (PROMPTS §14): «Aún por descubrir» y
  /// estados vacíos (HU-034, HU-041).
  static const String childInviting = 'assets/brand/child_inviting.png';

  static const List<String> all = [
    logo,
    memoryIcon,
    shadowsIcon,
    oddOneOutIcon,
    handGuide,
    childResting,
    childSleeping,
    childCelebrating,
    childInviting,
  ];
}
