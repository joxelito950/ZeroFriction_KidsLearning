# Publicación en Google Play

Todo lo que se rellena en Play Console se guarda también aquí, para que no dependa de la memoria ni de una sola persona (HU-014 R7). La historia completa está en [HU-014](../hu/HU-014-primera-publicacion-google-play.md).

## Ficha de la tienda

Textos, imágenes y notas para el revisor: [ficha.md](ficha.md).

## Generar un AAB para subir

Requisitos: la clave de subida y `android/key.properties` en tu equipo ([TD-003](../td/TD-003-firma-release.md), sección 7).

1. **Comprueba la política de privacidad:** `docs/privacy/` no tiene marcadores pendientes (`[CORREO PENDIENTE]`) y está publicada en GitHub Pages con el mismo texto que la app.
2. **Sube la versión** en `pubspec.yaml`. El número tras `+` es el `versionCode`: tiene que ser mayor que el de cualquier AAB subido antes, aunque sea a una prueba. La prueba cerrada usa `1.0.0-rc.N` y producción `1.0.0` (HU-014 R1).
3. **Pasa la checklist** de la sección 5 de la especificación (`flutter analyze`, `flutter test --coverage`, `dart run tool/coverage_check.dart`).
4. **Compila:**
   ```powershell
   flutter build appbundle --release
   ```
5. **Comprueba que no hay permisos** (R3). El CI también lo hace en cada PR:
   ```powershell
   dart run tool/check_release_permissions.dart
   ```
6. **Comprueba la firma** (R2). Falla si el AAB está firmado con la clave de debug o con otra que no sea la de subida:
   ```powershell
   dart run tool/check_upload_signature.dart
   ```
7. Sube `build/app/outputs/bundle/release/app-release.aab` a Play Console.

## Versiones subidas

| Fecha | Versión | `versionCode` | Pista | Notas |
|---|---|---|---|---|
| — | — | — | — | Aún no se ha subido ninguna |
