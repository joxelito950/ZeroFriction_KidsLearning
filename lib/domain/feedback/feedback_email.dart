/// Datos técnicos que acompañan a los comentarios (HU-032 P2). Ninguno
/// identifica a nadie y ninguno es del niño (R4).
final class DeviceReport {
  const DeviceReport({
    required this.appVersion,
    required this.androidVersion,
    required this.model,
    required this.language,
  });

  /// Por ejemplo, `1.0.0-rc.2+3`.
  final String appVersion;

  /// Por ejemplo, `14 (SDK 34)`.
  final String androidVersion;

  /// Fabricante y modelo, por ejemplo, `motorola moto g55 5G`.
  final String model;

  /// Código del idioma de la app, por ejemplo, `es`.
  final String language;
}

/// Los textos traducidos del correo (R5).
final class FeedbackEmailTexts {
  const FeedbackEmailTexts({required this.subject, required this.whatHappened, required this.whatExpected});

  /// Asunto, ya con la versión.
  final String subject;

  /// Primera línea guía: «¿Qué pasó?».
  final String whatHappened;

  /// Segunda línea guía: «¿Qué esperabas?».
  final String whatExpected;
}

/// El correo de comentarios ya preparado, sin enviar (HU-032 R2, R3): lo abre la
/// app de correo y el adulto decide qué manda. La app no envía nada.
abstract final class FeedbackEmail {
  /// La dirección de contacto de la ficha y de la política de privacidad.
  static const String address = 'toddler.logic.app@outlook.com';

  /// El cuerpo: las dos líneas guía con espacio para escribir y, al final, los
  /// datos técnicos, siempre con el mismo formato (R5).
  static String body(FeedbackEmailTexts texts, DeviceReport report) => [
        texts.whatHappened,
        '',
        '',
        texts.whatExpected,
        '',
        '',
        '---',
        'App: ${report.appVersion}',
        'Android: ${report.androidVersion}',
        'Device: ${report.model}',
        'Language: ${report.language}',
      ].join('\n');

  /// Enlace `mailto:`. Se codifica a mano: con `queryParameters`, los espacios
  /// saldrían como «+» en muchas apps de correo.
  static Uri uri(FeedbackEmailTexts texts, DeviceReport report) => Uri.parse(
        'mailto:$address'
        '?subject=${Uri.encodeComponent(texts.subject)}'
        '&body=${Uri.encodeComponent(body(texts, report))}',
      );
}

/// Lo que la app necesita del teléfono para los comentarios: leer sus datos
/// técnicos y abrir la app de correo. Se implementa con los plugins en `data/`.
abstract interface class IFeedbackChannel {
  /// Datos técnicos del teléfono, con [language] como idioma de la app.
  Future<DeviceReport> readReport({required String language});

  /// Abre la app de correo con [email]. `false` si no hay ninguna (R6).
  Future<bool> openEmail(Uri email);
}
