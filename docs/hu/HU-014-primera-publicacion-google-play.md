# HU-014 · Primera publicación en Google Play

| | |
|---|---|
| **Estado** | En curso: entregas 1 y 2 hechas (2026-11-03); falta el correo de contacto de la política y activar GitHub Pages; las 3–5 esperan a HU-013 y a los testers (TD-003 ✅) |
| **Épica** | E6 · Publicación y distribución |
| **Prioridad** | P2 |
| **Tamaño** | L: unas 3–4 semanas de calendario, de las que **14 días** son la prueba cerrada obligatoria; el trabajo técnico es de unos 4–5 días |
| **Depende de** | TD-003 (clave de subida, la genera el dueño), HU-013 (icono de 512 px y capturas con la identidad nueva) y la revisión del idioma o idiomas con los que se publique (`docs/i18n/REVISION.md`) |

## 1. Historia

**Como** dueño del producto,
**quiero** publicar ToddlerLogic en Google Play cumpliendo la política de apps para niños,
**para** que las familias puedan instalarla y para empezar a recibir opiniones reales.

## 2. Situación actual

| Punto | Estado |
|---|---|
| `applicationId` | `com.zerofriction.toddler_logic`. **No se podrá cambiar** una vez publicado |
| Nivel de API | `targetSdk` 36 (heredado de Flutter, comprobado en el APK el 2026-10-27). Cumple el requisito de Google Play para apps nuevas desde el 31 de agosto de 2026 (Android 16, API 36). `minSdk` 26 (D-026) |
| Permisos del release | **Ninguno.** `INTERNET` solo aparece en los manifiestos `debug` y `profile` (lo añade Flutter para la depuración) |
| Datos | No se recogen datos personales ni hay red, analítica, anuncios ni crash reporting (SPECIFICATION 4.3). Todo se guarda en el teléfono (Hive) |
| Firma | ✅ TD-003 hecha (2026-10-29): el release se firma con la clave de subida del dueño. Cuenta **personal** |
| Versión | `1.0.0-rc.1+2` en `pubspec.yaml` desde la entrega 1 (antes `0.0.1-beta+1`) |
| Contenido | Juego de memoria completo y **100 % gratuito** (D-028), Zona de Padres con desafío (HU-004). Sin compras (HU-006) |
| Traducciones | Los 9 idiomas están en **borrador** hasta su revisión externa |

## 3. Requisitos de Google Play (consultados el 2026-10-27)

| # | Requisito | Cómo se cumple |
|---|---|---|
| G1 | **Prueba cerrada** antes de producción en cuentas personales creadas después del 13-11-2023: al menos **12 testers** inscritos durante **14 días seguidos**. Si bajan de 12, el contador vuelve a cero. Fuentes secundarias indican que desde 2026 Google comprueba además que los testers usen la app | Reunir 12–15 testers (con margen) antes de empezar; P2 |
| G2 | Apps nuevas y actualizaciones con `targetSdk` ≥ 36 desde el 31-08-2026 | Ya cumple. Revisarlo cada año: el requisito sube con cada versión de Android |
| G3 | **Formato AAB** y Play App Signing | `flutter build appbundle` firmado con la clave de subida (TD-003) |
| G4 | **Política de privacidad**: enlace en Play Console **y** enlace o texto dentro de la app | Texto dentro de la Zona de Padres y la misma política publicada en una URL pública (P4) |
| G5 | **Política de Familias**: si el público incluye niños, el contenido debe ser apropiado, la política de privacidad debe reflejar la realidad y solo se pueden usar SDK de anuncios certificados | Sin anuncios ni SDK de terceros; público objetivo declarado (P3) |
| G6 | Formularios de **Seguridad de los datos**, **clasificación de contenido** (IARC), **público objetivo y contenido**, anuncios (no) y acceso a la app (sin inicio de sesión) | Se rellenan en Play Console; la sección 5 lleva las respuestas preparadas |
| G7 | **Ficha**: icono de 512 × 512, gráfico destacado de 1024 × 500, al menos 2 capturas de teléfono, nombre (30 caracteres), descripción breve (80) y completa (4000) | HU-013 aporta el icono; capturas y textos en esta historia |
| G8 | Declarar el público con exactitud: indicar mal el público o el contenido puede llevar a la retirada de la app | Sección 5 |

## 4. Reglas

| # | Regla |
|---|---|
| R1 | La primera versión pública es la **1.0.0** (`versionCode` que sube en cada build distribuida, SPECIFICATION 5). Las builds de la prueba cerrada son `1.0.0-rc.N`. |
| R2 | Se mantiene el comportamiento de TD-003: sin `key.properties` el release se firma con debug y avisa, para que el CI pueda compilarlo sin secretos. **Antes de subir** un AAB a Play Console se comprueba que lo firma la clave de subida (`keytool -printcert -jarfile`), con un script de `tool/` que falla si es la de debug. |
| R3 | El release no declara ningún permiso. Un test o un paso del CI lo comprueba en el manifiesto fusionado. |
| R4 | La política de privacidad dice la verdad del producto: no se recogen datos, todo se queda en el teléfono, no hay anuncios ni conexión a internet. Si algún día cambia (HU-006 añadirá Google Play Billing), la política y el formulario de Seguridad de los datos se actualizan **en el mismo PR**. |
| R5 | El texto de la política está dentro de la app, en la Zona de Padres (tras el desafío, D-029), sin enlace externo: así no hace falta abrir el navegador ni pedir permisos. |
| R6 | Solo se anuncian en la ficha los idiomas **revisados** (`docs/i18n/REVISION.md`). Los demás siguen funcionando en la app, pero sin ficha propia hasta su revisión. |
| R7 | Todo lo que se rellena en Play Console (respuestas de formularios, textos de la ficha) se guarda también en `docs/store/` para que no dependa de la memoria ni de una sola persona. |

## 5. Respuestas preparadas para Play Console (borrador)

| Formulario | Respuesta propuesta |
|---|---|
| Público objetivo | **5 años o menos y de 6 a 8 años** (P3). Sin atractivo para adultos fuera de la Zona de Padres |
| Programa «Diseñado para familias» | Sí: la app se dirige a niños |
| Anuncios | No contiene anuncios |
| Seguridad de los datos | No recoge ni comparte datos. Datos guardados solo en el dispositivo; se borran al desinstalar |
| Clasificación de contenido (IARC) | Sin violencia, sin contenido sexual, sin lenguaje ofensivo, sin compras, sin interacción entre usuarios ni ubicación. Se espera la clasificación más baja (PEGI 3 / Everyone) |
| Acceso a la app | Toda la funcionalidad está disponible sin credenciales. La Zona de Padres se abre resolviendo una multiplicación: se explica en las notas para el revisor |
| Categoría | Educación (con la etiqueta de edad que asigna el programa de Familias) |
| Precio | Gratuita (P5) |

## 6. Plan de entregas (propuesta)

| # | Entrega | Incluye |
|---|---|---|
| 1 | Preparación técnica ✅ | Versión 1.0.0, `build appbundle` en el CI, comprobación de «sin permisos» (R3) y script de comprobación de la firma antes de subir (R2) |
| 2 | Política de privacidad ✅ | Texto en `docs/privacy/` y en la Zona de Padres (idiomas de la ficha), publicación en una URL pública (P4) |
| 3 | Ficha | Textos por idioma revisado, capturas en vertical y horizontal (con la identidad de HU-013), gráfico destacado, respuestas de la sección 5 en `docs/store/` |
| 4 | Prueba cerrada | Alta en Play Console, subida del AAB firmado, 12+ testers durante 14 días, recogida de fallos |
| 5 | Producción | Solicitud de acceso a producción, revisión de Google y lanzamiento (P6) |

Las entregas 1 y 2 no dependen de TD-003 ni de HU-013 y pueden empezar ya.

### Entrega 1 · Preparación técnica (hecha, 2026-11-03)

| Pieza | Resultado |
|---|---|
| Versión (R1) | `1.0.0-rc.1+2` |
| CI | Instala JDK 21, compila `flutter build appbundle --release` (firmado con debug, porque el CI no tiene `key.properties`) y ejecuta `tool/check_release_permissions.dart`. Tiempo máximo del job: 30 min |
| Sin permisos (R3) | `tool/check_release_permissions.dart` lee el manifiesto fusionado definitivo (`build/app/intermediates/merged_manifests/release/processReleaseManifest/AndroidManifest.xml`) y falla con cualquier permiso salvo `com.zerofriction.toddler_logic.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`, el permiso interno de firma que añade AndroidX. Comprobado: pasa con el release y falla con el manifiesto de debug (`INTERNET`) |
| Firma antes de subir (R2) | `tool/check_upload_signature.dart` ejecuta `keytool -printcert -jarfile` y exige la huella SHA-256 de la clave de subida (TD-003): falla con la de debug, con cualquier otra clave o sin firma. Comprobado con el AAB `1.0.0-rc.1+2` firmado en el equipo del dueño |
| Procedimiento | [docs/store/README.md](../store/README.md): pasos para generar, comprobar y subir un AAB, y registro de versiones subidas |
| Tests | `test/tool/`: 9 tests de los dos scripts |

### Entrega 2 · Política de privacidad (hecha, 2026-11-03)

| Pieza | Resultado |
|---|---|
| Texto | [docs/privacy/es.md](../privacy/es.md) y [docs/privacy/en.md](../privacy/en.md), con una portada bilingüe ([index.md](../privacy/index.md)). Dice lo que guarda la app (nivel, estrellas, medallas, fechas, idioma, sonido y si Premium está desbloqueado), que todo se queda en el teléfono sin copia de seguridad (D-033), que no hay permisos, red, anuncios, analítica ni terceros, y qué cambiará con las compras (R4) |
| Una sola fuente | GitHub Pages publica `docs/privacy/` y la app incluye **esos mismos archivos** como assets: la web y la app no pueden diferir. `docs/_config.yml` excluye el resto de `docs/` de la web |
| En la app (R5) | Sección «Privacidad» al final de la Zona de Padres, con un resumen de una línea en los 9 idiomas; al desplegarla muestra la política en español o inglés (P7), y en inglés para el resto de idiomas. Va **dentro** de la Zona de Padres, no en otra pantalla: así desplazarse por el texto cuenta como actividad para `AdultSessionGuard` y la sesión no se cierra mientras el adulto lee. La política se carga al desplegar la sección, no antes |
| Formato | Markdown mínimo (títulos, párrafos, viñetas, negrita y cursiva) pintado por `PolicyDocument`, sin dependencias nuevas; los títulos se anuncian como encabezados al lector de pantalla |
| Tests | Lector de Markdown, sección de la Zona de Padres (resumen, español, vuelta al inglés), tests de diseño en los 9 idiomas a 1,0 y 2,0, y `test/store/privacy_policy_test.dart`: los dos idiomas existen, son assets, tienen la misma estructura y la web solo publica `privacy/` |

**Revisión en el moto g55 (2026-11-03).** El dueño recorrió la sección mientras se tomaban capturas por adb, sin tocar la pantalla desde el ordenador:

| Comprobación | Resultado |
|---|---|
| Resumen al final de la Zona de Padres y política completa en español al desplegarla | ✅ Títulos, viñetas y negritas se ven bien; al final, el marcador del correo pendiente |
| Cambiar a English con la sección abierta | ✅ El resumen y la política pasan al inglés al instante |
| Volver a español y girar a horizontal | ✅ |
| Leer sin que se cierre la sesión | ✅ La Zona de Padres siguió abierta 64 s seguidos con el adulto leyendo y desplazándose (sin actividad se cierra a los 60 s) |
| Sin tocar, vuelve al menú | ✅ 61 s después del último toque |
| Francés: resumen en francés y política en inglés | No salió en las capturas; lo cubre el test de la Zona de Padres |

**Pendiente del dueño antes de la entrega 4:**

1. **Correo de contacto.** La política lleva el marcador `[CORREO PENDIENTE]` / `[CONTACT EMAIL PENDING]` hasta que exista el correo dedicado (decidido el 2026-11-03). No se puede subir a Google Play con el marcador.
2. **Activar GitHub Pages:** *Settings › Pages › Build and deployment › Deploy from a branch*, rama `main`, carpeta `/docs`. La URL para Play Console será `https://joxelito950.github.io/ZeroFriction_KidsLearning/privacy/`. Como Pages publica desde `main`, la política se ve en la web cuando `develop` pase a `main`.

## 7. Criterios de aceptación (borrador)

1. **Dado** el CI, **entonces** genera el AAB de release y falla si el manifiesto fusionado del release declara algún permiso.
2. **Dado** un AAB firmado con la clave de debug, **cuando** se ejecuta el script de comprobación previo a la subida, **entonces** falla con un mensaje claro; con la clave de subida, pasa.
3. **Dado** la Zona de Padres, **entonces** hay una sección «Privacidad» con la política completa en el idioma de la app (para los idiomas de la ficha) y la misma política está publicada en una URL pública.
4. **Dado** `docs/store/`, **entonces** contiene los textos de la ficha, las respuestas de los formularios y la lista de capturas, por idioma.
5. **Dado** Play Console, **entonces** la prueba cerrada se completa con al menos 12 testers durante 14 días seguidos y la app pasa la revisión de producción.
6. **Dado** un teléfono con Android 8 y uno reciente, **cuando** se instala desde Google Play, **entonces** la app funciona sin conexión y conserva el progreso al actualizar.

## 8. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Android | Revisar que el manifiesto fusionado del release no tenga permisos (R3). La firma no cambia (TD-003) |
| Herramientas | Script en `tool/` que comprueba la firma del AAB antes de subirlo (R2) |
| CI | Paso `flutter build appbundle --release` (sin firma o con una clave de prueba) y comprobación del manifiesto |
| Presentación | Sección «Privacidad» en la Zona de Padres, con su texto en el catálogo |
| Catálogo | Textos de la política (largos) en los idiomas de la ficha. Ver P7 |
| Documentación | `docs/store/` (textos, respuestas y capturas) y la política en una URL pública |
| Versión | `1.0.0-rc.1` para la prueba cerrada y `1.0.0` para producción |

## 9. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Cuenta personal u organización? | ✅ Decidido en TD-003: **personal** (exige la prueba cerrada de G1; la de organización pediría número D-U-N-S) | — |
| P2 | ¿Quiénes son los 12 testers? | ⏭️ Tarea del dueño antes de la entrega 4: reunir **15** (familia, amigos y familias con niños pequeños) para tener margen. Necesitan una cuenta de Google y un teléfono Android | Solo la entrega 4 |
| P3 | ¿Qué franja de edad se declara? | ✅ Decidido (2026-10-27): **«5 años o menos» y «6–8 años»**, para ampliar el alcance en la tienda. Ambas franjas están en la política de Familias; el contenido es apto para las dos. La ficha y las capturas deben seguir mostrando con claridad que el juego está pensado para los más pequeños | — |
| P4 | ¿Dónde se publica la política de privacidad? | ✅ Decidido (2026-10-27): **GitHub Pages** del propio repositorio (público, comprobado el 2026-10-27), versionada con el código | — |
| P5 | ¿Se publica gratis antes de tener Premium (HU-006)? | ✅ Asumida la recomendación: **sí.** El juego de memoria es 100 % gratuito (D-028); las compras se añaden después con una actualización, sin cambiar el precio de la app | — |
| P6 | ¿En qué países? | ✅ Asumida la recomendación: **todos** los disponibles: la app no recoge datos ni usa red, lo que simplifica las leyes de protección de menores (COPPA, RGPD, Children's Code del Reino Unido) | — |
| P7 | ¿Con qué idiomas se publica la ficha? | ✅ Decidido (2026-10-27): **español e inglés** al principio: el español lo puede revisar el dueño; el inglés necesita una revisión rápida. El resto se añade según `REVISION.md` | — |
| P8 | ¿Se revisa la política con un abogado? | ✅ Asumida la recomendación: recomendable pero no bloqueante: al no recoger datos, la política es corta. Basta una plantilla para apps infantiles sin datos, adaptada | — |

## 10. Fuera de alcance

- Compras y restauración (HU-006).
- Otras tiendas (HU-015) e iOS (TD-005).
- Anuncios, analítica o crash reporting remoto (prohibidos sin decisión explícita, SPECIFICATION 4.3).
- El programa «Teacher Approved» de Google Play (se puede solicitar más adelante).
- Generar la clave de subida (TD-003, la genera el dueño).
