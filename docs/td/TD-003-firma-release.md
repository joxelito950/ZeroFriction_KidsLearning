# TD-003 · Keystore de release y firma

| | |
|---|---|
| **Estado** | En curso: configuración de firma lista y verificada; **falta que el dueño genere su clave** (sección 7) |
| **Épica** | E6 · Publicación y distribución |
| **Prioridad** | P1: pendientes técnicos antes de las historias; bloquea HU-014 (primera publicación) |
| **Tamaño** | S (medio día) |
| **Decisión que cierra** | D-019 («el APK release se firma con la clave de debug») |

## 1. Objetivo

Firmar las compilaciones *release* con una clave propia, para poder publicar en Google Play y en otras tiendas, **sin que ningún secreto llegue al repositorio**.

## 2. Situación actual

- `android/app/build.gradle.kts` firma el *release* con `signingConfigs.getByName("debug")`, la plantilla por defecto de Flutter. Google Play rechaza los APK/AAB firmados con la clave de debug.
- `android/.gitignore` ya excluye `key.properties`, `**/*.jks` y `**/*.keystore`.

## 3. Conceptos (para decidir con contexto)

- **Clave de subida (*upload key*):** la que guardamos nosotros y usamos para firmar el AAB que subimos a Google Play.
- **Clave de firma de la app (*app signing key*):** con **Play App Signing**, la custodia Google y es la que firma lo que reciben los usuarios. Es obligatoria para apps nuevas.
- **Ventaja:** si se pierde la clave de subida, Google permite **restablecerla** mediante soporte. Sin Play App Signing, perder la clave significaría no poder actualizar nunca más la app.
- Las otras tiendas (HU-015) gestionan la firma de forma propia. Lo habitual es firmar con nuestra clave; se revisa al refinar HU-015.

## 4. Alcance

| # | Requisito |
|---|---|
| F1 | **Tú generas** el keystore en tu equipo con `keytool` (incluido en el JDK 21 que ya tienes), **fuera del repositorio**. Ruta sugerida: `%USERPROFILE%\.android\keys\toddler_logic_upload.jks`. Algoritmo RSA de 4096 bits, validez de 25 años o más |
| F2 | `android/key.properties`, fuera de git, con la ruta del keystore, el alias y las contraseñas |
| F3 | `build.gradle.kts` lee `key.properties` y firma el *release* con esa clave |
| F4 | **Si no existe `key.properties`** (CI, otro equipo), el *release* se sigue firmando con la clave de debug y la compilación avisa. Así el CI y el desarrollo no se rompen (ver P2) |
| F5 | Procedimiento documentado: generar la clave, hacer copia de seguridad, rotarla y qué hacer si se pierde. Sin incluir nunca contraseñas |
| F6 | SPECIFICATION: D-019 cerrada; sección 7 con la configuración de firma |

**Regla de seguridad:** las contraseñas y el keystore **no pasan por esta conversación ni por ningún archivo versionado**. Yo preparo la configuración de Gradle y las instrucciones; los valores secretos los introduces tú.

## 5. Criterios de aceptación

1. **Dado** `key.properties` presente, **cuando** compilo `flutter build appbundle --release`, **entonces** el AAB está firmado con la clave de subida (`keytool -printcert -jarfile` muestra nuestro certificado y no «Android Debug»).
2. **Dado** que no hay `key.properties`, **entonces** la compilación *release* sigue funcionando, firmada con debug, y muestra un aviso claro.
3. **Dado** el repositorio, **entonces** no contiene ningún keystore, `key.properties` ni contraseña (`git ls-files` y búsqueda de patrones).
4. **Dado** el CI, **entonces** sigue en verde sin cambios.
5. **Dado** el procedimiento documentado, **entonces** otra persona podría generar una compilación firmada siguiéndolo, si tuviera el keystore.

## 6. Decisiones (2026-10-19)

| # | Pregunta | Decisión |
|---|---|---|
| P1 | ¿Dónde se guardan el keystore y sus contraseñas? | Recomendación aceptada como punto de partida: gestor de contraseñas con el `.jks` adjunto, más una copia cifrada fuera del equipo (pasos 4 y 5 de la guía) |
| P2 | Sin `key.properties`, ¿firmar con debug o fallar? | Firmar con debug y avisar (F4), para no romper el CI |
| P3 | Titular del certificado | **Cuenta personal** (no existe organización). El certificado lleva el nombre del dueño como persona |
| P4 | ¿Firmar en el CI? | Fuera de alcance |

Es la primera app del dueño: la sección 7 es una guía completa. El desarrollo de F3–F5 lo puedo hacer en paralelo, porque no necesita la clave (la configuración funciona sin `key.properties`, criterio 2).

### Implementación de la configuración (2026-10-19, rama `chore/td-003-release-signing`)

- `android/app/build.gradle.kts` lee `android/key.properties` si existe y firma el *release* con esa clave (F3). Si falta alguna de las cuatro propiedades, la compilación se detiene con un mensaje que indica cuál.
- Sin `key.properties`, firma con debug y Gradle muestra «ATENCIÓN: no existe android/key.properties…» (F4). `flutter build` solo enseña ese aviso en modo detallado (`-v`).

| Criterio | Resultado |
|---|---|
| 1 | ✅ Mecanismo verificado con una **clave de prueba desechable** (contraseña aleatoria, borrada después): el AAB quedó firmado con «CN=TD003 Throwaway Test». ⏳ Falta repetirlo con la clave real del dueño |
| 2 | ✅ Sin `key.properties`: compila, firma con «CN=Android Debug» y muestra el aviso |
| 3 | ✅ `git check-ignore` confirma que `android/key.properties` está ignorado; el repositorio no contiene claves |
| 4 | Se comprueba en el CI del PR |
| 5 | ✅ Guía de la sección 7 |

**Cómo se comprueba la firma:** el AAB usa firma JAR, así que vale `keytool -printcert -jarfile app-release.aab`. El APK, con `minSdk` 26, usa el esquema v2, que `keytool` no lee; para el APK hay que usar `apksigner verify --print-certs` (incluido en el Android SDK).

## 7. Guía paso a paso: crear y guardar la clave de subida

> **Regla de oro:** las contraseñas y el archivo `.jks` **nunca** se escriben en el chat, en el repositorio ni en capturas de pantalla. Solo tú los conoces.

### Paso 1. Elegir las contraseñas
Genera en tu gestor de contraseñas **una contraseña larga** (20 caracteres o más). El formato PKCS12 usa **la misma contraseña** para el almacén y para la clave, así que basta con una. Guárdala en una entrada nueva, por ejemplo «ToddlerLogic · upload key».

### Paso 2. Crear la carpeta fuera del repositorio
En PowerShell:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.android\keys"
```

### Paso 3. Generar la clave
En PowerShell (es un solo comando):

```powershell
& "$env:JAVA_HOME\bin\keytool.exe" -genkeypair -v `
  -keystore "$env:USERPROFILE\.android\keys\toddler_logic_upload.jks" `
  -storetype PKCS12 -keyalg RSA -keysize 4096 -validity 10000 -alias upload
```

`keytool` hará estas preguntas (en el idioma del sistema):

| Pregunta | Qué responder (cuenta personal) |
|---|---|
| Contraseña del almacén (dos veces) | La del paso 1. No se ve mientras escribes; es normal |
| Nombre y apellido (CN) | Tu nombre completo, el mismo que pondrás en la cuenta de Google Play |
| Unidad organizativa (OU) | Déjalo vacío (Enter) |
| Organización (O) | Tu nombre o déjalo vacío: no hay organización |
| Ciudad (L), Estado o provincia (ST) | Tu ciudad y tu departamento |
| Código de país (C) | `CO` |
| ¿Es correcto? | `sí` (o `yes`) |

`-validity 10000` son unos 27 años: Google Play exige que la clave sea válida al menos hasta 2033.

### Paso 4. Comprobar la clave y anotar su huella
```powershell
& "$env:JAVA_HOME\bin\keytool.exe" -list -v -keystore "$env:USERPROFILE\.android\keys\toddler_logic_upload.jks" -alias upload
```
Te pedirá la contraseña. Copia la línea **`SHA256:`** en la misma entrada del gestor de contraseñas. La huella es **pública** (no es un secreto) y sirve para verificar más adelante que Google Play reconoce tu clave.

### Paso 5. Copia de seguridad
1. **Adjunta** el archivo `toddler_logic_upload.jks` a la entrada del gestor de contraseñas.
2. Guarda **otra copia** fuera del portátil (por ejemplo, en un USB guardado en casa, o en la nube dentro de un archivo cifrado con contraseña).
3. Comprueba que puedes abrir la copia (repite el paso 4 apuntando a la copia).

Si pierdes la clave de subida, Google permite restablecerla gracias a Play App Signing, pero tarda días y hay que contactar con soporte. Con copia de seguridad, nunca hace falta.

### Paso 6. Crear `android/key.properties` (solo en tu equipo)
Crea el archivo `android/key.properties` con este contenido, sustituyendo la contraseña. Usa **barras normales** (`/`) en la ruta:

```properties
storePassword=LA_CONTRASEÑA_DEL_PASO_1
keyPassword=LA_CONTRASEÑA_DEL_PASO_1
keyAlias=upload
storeFile=C:/Users/User/.android/keys/toddler_logic_upload.jks
```

`android/.gitignore` ya lo excluye de git. Antes de cada commit, `git status` **no** debe mostrar `key.properties`.

### Paso 7. Avisarme
Con eso, compilo `flutter build appbundle --release` y verifico el criterio 1 **sin ver la contraseña**: compruebo que el AAB esté firmado con tu certificado y no con el de debug.

### Qué hará Google Play con esta clave (HU-014)
Al crear la app en Play Console, se activa **Play App Signing** (es el valor por defecto). Google genera y custodia la clave de firma de la app; tú subes el AAB firmado con tu **clave de subida**, y Play la registra en la primera subida.

### Notas de la cuenta personal (para HU-014)
- Cuota única de registro de 25 USD y verificación de identidad.
- **Prueba cerrada obligatoria:** al menos 12 testers durante 14 días seguidos antes de publicar en producción.
- No hace falta número D-U-N-S, que solo se pide a las organizaciones.

## 8. Fuera de alcance


- Firmar en el CI (P4).
- Subir a Google Play (HU-014).
- La firma específica de otras tiendas (HU-015).
