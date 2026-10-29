/// Idiomas de la app y regla para elegir el del primer arranque (HU-011).
///
/// Se trabaja con códigos de idioma (ISO 639-1), no de país: un solo español
/// neutro para Latinoamérica y España, y un portugués (de Brasil) para todos.
abstract final class AppLanguage {
  /// Idioma de reserva: inglés de EE. UU. (plantilla del catálogo).
  static const String fallback = 'en';

  static const List<String> supported = ['en', 'es', 'pt', 'de', 'ja', 'fr', 'it', 'ko', 'ar'];

  static bool isSupported(String? languageCode) => supported.contains(languageCode);

  /// Nombre de cada idioma en su propio idioma (HU-012 R2), para que un adulto
  /// encuentre el suyo aunque la app esté en otro. No se traducen.
  static const Map<String, String> nativeNames = {
    'en': 'English',
    'es': 'Español',
    'pt': 'Português (Brasil)',
    'de': 'Deutsch',
    'ja': '日本語',
    'fr': 'Français',
    'it': 'Italiano',
    'ko': '한국어',
    'ar': 'العربية',
  };

  /// Devuelve el primer idioma soportado de [preferredLanguageTags] (en orden de
  /// preferencia del dispositivo, p. ej. `es-CO`, `pt_PT`) o [fallback].
  static String resolve(Iterable<String> preferredLanguageTags) {
    for (final tag in preferredLanguageTags) {
      final String languageCode = _languageCodeOf(tag);
      if (isSupported(languageCode)) return languageCode;
    }
    return fallback;
  }

  /// Idioma en el que se repite el desafío de adultos debajo del de la app
  /// (HU-021 R1): el primero de [preferredLanguageTags] que esté soportado y no
  /// sea [appLanguage]; si no hay ninguno, el inglés. `null` cuando la app ya
  /// está en inglés y el teléfono no ofrece otro idioma: no hay ayuda mejor.
  static String? helperFor(String appLanguage, Iterable<String> preferredLanguageTags) {
    for (final tag in preferredLanguageTags) {
      final String languageCode = _languageCodeOf(tag);
      if (isSupported(languageCode) && languageCode != appLanguage) return languageCode;
    }
    return appLanguage == fallback ? null : fallback;
  }

  static String _languageCodeOf(String tag) => tag.trim().split(RegExp('[-_]')).first.toLowerCase();
}
