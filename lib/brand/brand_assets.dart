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

  static const List<String> all = [logo, memoryIcon, shadowsIcon];
}
