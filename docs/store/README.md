# Publicación en Google Play

Todo lo que se rellena en Play Console se guarda también aquí, para que no dependa de la memoria ni de una sola persona (HU-014 R7). La historia completa está en [HU-014](../hu/HU-014-primera-publicacion-google-play.md).

## Cuenta y datos fijos

| Dato | Valor |
|---|---|
| Cuenta de Play Console | Personal, del dueño (creada el 2026-11-06). El correo de la cuenta es privado |
| Correo de contacto público (ficha y política) | `toddler.logic.app@outlook.com` |
| Política de privacidad | `https://joxelito950.github.io/ZeroFriction_KidsLearning/privacy/` |
| Paquete | `com.zerofriction.toddler_logic` |

## Configurar Play Console y abrir la prueba cerrada

Orden recomendado. Lo que necesita el AAB firmado o la clave solo lo hace el dueño.

1. **Verificar la cuenta:** identidad (documento oficial) y teléfono Android con la app Play Console. Google tarda unos días; mientras tanto se puede avanzar.
2. **Nombre de desarrollador:** es público en la ficha. Mejor uno de marca (por ejemplo, «ZeroFriction») que el usuario de la cuenta.
3. **Crear la app:** nombre «ToddlerLogic: memoria», idioma por defecto español (es-419), tipo *App*, *Gratis*. Aceptar las declaraciones.
4. **Configurar la app** (menú *Política y programas › Contenido de la app*), con las respuestas de la sección 5 de [HU-014](../hu/HU-014-primera-publicacion-google-play.md):
   - Política de privacidad: la URL de arriba.
   - Acceso a la app: «Toda la funcionalidad está disponible sin restricciones», con la nota para el revisor de [ficha.md](ficha.md).
   - Anuncios: no contiene anuncios.
   - Clasificación de contenido: cuestionario IARC (sin violencia, sin compras, sin interacción entre usuarios).
   - Público objetivo: 5 años o menos y 6–8 años. Esto activa la política de **Familias**.
   - Seguridad de los datos: no recoge ni comparte datos.
   - Apps gubernamentales, financieras, de salud, noticias: no.
5. **Ficha de la tienda:** textos, icono, gráfico destacado y capturas de [ficha.md](ficha.md), en español y en inglés.
6. **Play App Signing:** aceptarlo al subir el primer AAB (TD-003).
7. **Prueba cerrada:** *Pruebas › Prueba cerrada › Crear canal*. Lista de testers (correos de Google o un Grupo de Google), países, y subir el AAB generado con los pasos de abajo. Enviar a revisión.
8. **Invitar a los testers** con el enlace de participación. Necesitan **12 o más** durante **14 días seguidos**; conviene invitar a 15.
9. A los 14 días, **solicitar el acceso a producción** (entrega 5).

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
| 2026-11-09 | `1.0.0-rc.2` | 3 | Prueba cerrada | Primera subida. Juego de memoria con dificultad y vista previa (HU-030), tiempo diario y descanso (HU-009), identidad visual (HU-013), dorado líquido y pérdida de estrellas (HU-002, HU-016), textos revisados en español e inglés (TD-011). AAB de 49,6 MB, sin permisos y firmado con la clave de subida (comprobado con los dos scripts) |
