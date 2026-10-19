# TD-003 · Keystore de release y firma

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-10-19; el desarrollo **no** ha empezado) |
| **Épica** | E6 · Publicación y distribución |
| **Prioridad** | P2: bloquea HU-014 (primera publicación) |
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

## 6. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Dónde se guardan el keystore y sus contraseñas? | En un gestor de contraseñas (por ejemplo Bitwarden o 1Password), con el `.jks` como adjunto, más una copia cifrada fuera del equipo | Sí |
| P2 | Sin `key.properties`, ¿el *release* firma con debug (F4) o falla? | Firma con debug y avisa, para no romper el CI. Las compilaciones para publicar se hacen siempre en tu equipo | No (hay recomendación) |
| P3 | ¿Qué nombre figura en el certificado (CN, O)? | El mismo titular que la cuenta de Google Play: persona u organización (ver HU-014, tipo de cuenta) | Sí, depende de HU-014 |
| P4 | ¿El CI debería generar AAB firmados? | Más adelante, con *GitHub Secrets*. Fuera de alcance aquí | No |

## 7. Fuera de alcance

- Firmar en el CI (P4).
- Subir a Google Play (HU-014).
- La firma específica de otras tiendas (HU-015).
