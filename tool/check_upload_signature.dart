// Comprueba, antes de subir un AAB a Google Play, que lo firma la clave de
// subida y no la de debug (HU-014 R2, TD-003).
//
// Uso:
//   flutter build appbundle --release
//   dart run tool/check_upload_signature.dart [ruta/app-release.aab]
import 'dart:io';

/// Huella SHA-256 de la clave de subida. Es pública (TD-003, sección 6): sirve
/// para comprobar la firma, no para firmar.
const String uploadKeySha256 =
    '38:1B:3B:88:04:B1:CB:47:4F:F5:7F:97:CF:D4:BA:91:D1:76:1C:00:6B:8F:4A:B1:87:79:5C:98:46:2F:13:49';

const String _defaultAab = 'build/app/outputs/bundle/release/app-release.aab';

enum SignatureVerdict {
  /// Firmado con la clave de subida: se puede subir.
  upload,

  /// Firmado con la clave de debug: falta `android/key.properties`.
  debug,

  /// Firmado con otra clave.
  otherKey,

  /// Sin firma, o `keytool` no pudo leerla.
  unsigned,
}

/// Clasifica la salida de `keytool -printcert -jarfile`.
SignatureVerdict classifySignature(String keytoolOutput) {
  final List<String> fingerprints = RegExp(r'SHA256:\s*([0-9A-Fa-f:]{95})')
      .allMatches(keytoolOutput)
      .map((match) => match.group(1)!.toUpperCase())
      .toList();
  if (fingerprints.isEmpty) return SignatureVerdict.unsigned;
  if (keytoolOutput.contains('CN=Android Debug')) return SignatureVerdict.debug;
  if (fingerprints.every((fingerprint) => fingerprint == uploadKeySha256)) return SignatureVerdict.upload;
  return SignatureVerdict.otherKey;
}

String _message(SignatureVerdict verdict, String aab) {
  return switch (verdict) {
    SignatureVerdict.upload => 'OK: $aab está firmado con la clave de subida. Se puede subir a Google Play.',
    SignatureVerdict.debug => 'ERROR: $aab está firmado con la clave de DEBUG. Google Play lo rechazará.\n'
        'Crea android/key.properties (docs/td/TD-003-firma-release.md, sección 7) y vuelve a compilar.',
    SignatureVerdict.otherKey => 'ERROR: $aab está firmado con una clave que no es la de subida.\n'
        'Comprueba storeFile y keyAlias en android/key.properties.',
    SignatureVerdict.unsigned => 'ERROR: $aab no está firmado o keytool no pudo leerlo.',
  };
}

/// `keytool` del JDK de `JAVA_HOME` o, si no está definido, el del PATH.
String _keytool() {
  final String? javaHome = Platform.environment['JAVA_HOME'];
  if (javaHome == null || javaHome.isEmpty) return 'keytool';
  final String executable = Platform.isWindows ? 'keytool.exe' : 'keytool';
  return '$javaHome${Platform.pathSeparator}bin${Platform.pathSeparator}$executable';
}

Future<void> main(List<String> args) async {
  final String aab = args.isEmpty ? _defaultAab : args.first;
  if (!File(aab).existsSync()) {
    stderr.writeln('No existe $aab. Compila primero: flutter build appbundle --release');
    exit(2);
  }

  final ProcessResult result = await Process.run(_keytool(), ['-printcert', '-jarfile', aab]);
  final SignatureVerdict verdict = classifySignature('${result.stdout}\n${result.stderr}');
  final String message = _message(verdict, aab);
  if (verdict == SignatureVerdict.upload) {
    stdout.writeln(message);
  } else {
    stderr.writeln(message);
    exit(1);
  }
}
