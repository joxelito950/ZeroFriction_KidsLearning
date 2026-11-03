// Comprueba que el manifiesto fusionado del release no declara ningún permiso
// (HU-014 R3; README: «cero permisos»).
//
// Uso:
//   flutter build appbundle --release
//   dart run tool/check_release_permissions.dart [ruta/AndroidManifest.xml]
import 'dart:io';

const String _defaultManifest =
    'build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml';

/// Permisos que el manifiesto pide o define.
List<String> declaredPermissions(String manifest) {
  return RegExp(r'<(?:uses-permission(?:-sdk-23)?|permission)\b[^>]*android:name="([^"]+)"')
      .allMatches(manifest)
      .map((match) => match.group(1)!)
      .toList();
}

/// Los permisos que no están permitidos. Solo se admite el permiso interno que
/// añade AndroidX (`<paquete>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`): es de
/// firma, lo define la propia app y el usuario no lo ve ni lo concede.
List<String> forbiddenPermissions(String manifest) {
  final String? package = RegExp(r'<manifest\b[^>]*\bpackage="([^"]+)"').firstMatch(manifest)?.group(1);
  final String allowed = '$package.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION';
  return declaredPermissions(manifest).where((permission) => permission != allowed).toSet().toList();
}

void main(List<String> args) {
  final String path = args.isEmpty ? _defaultManifest : args.first;
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln('No existe $path. Compila primero: flutter build appbundle --release');
    exit(2);
  }

  final List<String> forbidden = forbiddenPermissions(file.readAsStringSync());
  if (forbidden.isEmpty) {
    stdout.writeln('OK: el release no declara permisos.');
    return;
  }
  stderr.writeln('ERROR: el release declara permisos (HU-014 R3):');
  for (final permission in forbidden) {
    stderr.writeln('  - $permission');
  }
  exit(1);
}
