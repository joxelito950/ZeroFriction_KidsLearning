/// Política de privacidad por idioma (HU-014 R5). El texto vive en
/// `docs/privacy/`, que también publica GitHub Pages: la app y la web leen los
/// mismos archivos. Solo existen los idiomas de la ficha de la tienda (P7); el
/// resto muestra la versión en inglés.
const Map<String, String> _privacyPolicyAssets = {
  'en': 'docs/privacy/en.md',
  'es': 'docs/privacy/es.md',
};

const String _fallbackLanguage = 'en';

/// Idiomas con política propia.
Iterable<String> get privacyPolicyLanguages => _privacyPolicyAssets.keys;

/// Asset de la política para [languageCode], o el inglés si no tiene.
String privacyPolicyAsset(String languageCode) =>
    _privacyPolicyAssets[languageCode] ?? _privacyPolicyAssets[_fallbackLanguage]!;
