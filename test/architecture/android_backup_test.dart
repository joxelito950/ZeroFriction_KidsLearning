import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// La app no tiene copia de seguridad ni transferencia entre teléfonos (D-033,
/// TD-008): el progreso se queda solo en el dispositivo, como dicen la política
/// de privacidad y el formulario de Seguridad de los datos (HU-014).
///
/// `allowBackup="false"` la desactiva en Android 8 a 11; en Android 12 y
/// posteriores manda `dataExtractionRules`, que debe excluir todos los dominios
/// tanto de la nube como de la transferencia entre dispositivos.
void main() {
  const domains = [
    'root', 'file', 'database', 'sharedpref', 'external',
    'device_root', 'device_file', 'device_database', 'device_sharedpref',
  ];

  final String manifest = File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
  final String rules = File('android/app/src/main/res/xml/data_extraction_rules.xml').readAsStringSync();

  test('el manifiesto desactiva la copia de seguridad', () {
    expect(manifest, contains('android:allowBackup="false"'));
    expect(manifest, contains('android:dataExtractionRules="@xml/data_extraction_rules"'));
  });

  for (final section in ['cloud-backup', 'device-transfer']) {
    test('$section excluye todos los dominios y no incluye ninguno', () {
      final Match? match = RegExp('<$section[^>]*>(.*?)</$section>', dotAll: true).firstMatch(rules);
      expect(match, isNotNull, reason: 'Falta la sección <$section> en data_extraction_rules.xml');

      final String body = match!.group(1)!;
      expect(body, isNot(contains('<include')));
      for (final domain in domains) {
        expect(body, contains('<exclude domain="$domain" path="." />'), reason: '$section no excluye $domain');
      }
    });
  }
}
