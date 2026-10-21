/// Idiomas de la app y regla para elegir el del primer arranque (HU-011).
///
/// Se trabaja con códigos de idioma (ISO 639-1), no de país: un solo español
/// neutro para Latinoamérica y España, y un portugués (de Brasil) para todos.
abstract final class AppLanguage {
  /// Idioma de reserva: inglés de EE. UU. (plantilla del catálogo).
  static const String fallback = 'en';

  static const List<String> supported = ['en', 'es', 'pt', 'de', 'ja', 'fr', 'it', 'ko', 'ar'];

  static bool isSupported(String? languageCode) => supported.contains(languageCode);

  /// Devuelve el primer idioma soportado de [preferredLanguageTags] (en orden de
  /// preferencia del dispositivo, p. ej. `es-CO`, `pt_PT`) o [fallback].
  static String resolve(Iterable<String> preferredLanguageTags) {
    for (final tag in preferredLanguageTags) {
      final String languageCode = tag.trim().split(RegExp('[-_]')).first.toLowerCase();
      if (isSupported(languageCode)) return languageCode;
    }
    return fallback;
  }
}
