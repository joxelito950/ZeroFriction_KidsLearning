# HU-012 · Selector de idioma en la Zona de Padres

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-26; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2 |
| **Tamaño** | S (1 día) |
| **Depende de** | HU-004 (Zona de Padres) y HU-011 (catálogo de 9 idiomas) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** elegir en la Zona de Padres el idioma en el que la app le habla a mi hijo,
**para** que juegue en el idioma que estamos enseñando en casa, aunque el teléfono esté configurado en otro.

## 2. Situación actual

- HU-011 (D-027): en el primer arranque se toma el idioma del teléfono y se guarda en `UserProfile.languageCode`; después **manda el guardado**, aunque el teléfono cambie de idioma.
- Hoy no hay ninguna forma de cambiar ese idioma guardado, salvo borrar los datos de la app.
- El idioma se resuelve **una sola vez al arrancar** (`resolveStartupLocale`) y se pasa fijo a `MaterialApp` (`lib/main.dart`). Cambiarlo en caliente requiere que el idioma pase a ser estado de la app.
- La Zona de Padres (HU-004) todavía no existe; esta historia añade su sección «Idioma».

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | La Zona de Padres tiene una sección **«Idioma»** con la lista de los 9 idiomas de D-027 y el actual marcado. |
| R2 | Cada idioma se muestra **con su propio nombre** (endónimo): English, Español, Português (Brasil), Deutsch, 日本語, Français, Italiano, 한국어, العربية. Así un adulto encuentra el suyo aunque la app esté en un idioma que no entiende. **Sin banderas**: una bandera es un país, no un idioma. |
| R3 | Al elegir un idioma, la app cambia **al instante**, sin reiniciar, y se **guarda** en `UserProfile.languageCode`. La Zona de Padres sigue abierta, ya en el nuevo idioma. |
| R4 | Al pasar a árabe (o salir de él), la dirección de la pantalla cambia a derecha-a-izquierda (o al revés) en el mismo momento. |
| R5 | Elegir un idioma cuenta como acción para el minuto de inactividad de la Zona de Padres (HU-004, R7). |
| R6 | Si no se puede guardar, el cambio se aplica en esta sesión igualmente; en el siguiente arranque vuelve el idioma guardado antes. Sin mensajes de error para el niño. |
| R7 | El cambio de idioma **no afecta al progreso** (nivel, estrellas, insignia). |

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-027 (multiidioma) | Se mantiene: el guardado sigue mandando sobre el idioma del teléfono. Esta historia solo añade la forma de cambiarlo; no hay opción «Idioma del teléfono» (P2) |
| D-029 (control para adultos) | El selector está dentro de la Zona de Padres, así que ya queda tras el desafío |
| HU-004, P4 | Cada sección llega con su historia: esta añade la primera sección de ajustes |
| Traducciones en borrador (`docs/i18n/REVISION.md`) | El selector ofrece los 9 idiomas aunque sus textos no estén revisados (P3) |

## 5. Criterios de aceptación (borrador)

1. **Dado** la Zona de Padres, **cuando** abro «Idioma», **entonces** veo los 9 idiomas, cada uno escrito en su propio idioma, con el actual marcado.
2. **Dado** la lista, **cuando** elijo otro idioma, **entonces** toda la app cambia a ese idioma sin reiniciar y sigo en la Zona de Padres.
3. **Dado** que elijo árabe, **entonces** la pantalla pasa a derecha-a-izquierda al instante; **cuando** vuelvo a otro idioma, **entonces** vuelve a izquierda-a-derecha.
4. **Dado** que elegí un idioma, **cuando** cierro y vuelvo a abrir la app, **entonces** arranca en el idioma elegido, aunque el teléfono esté en otro.
5. **Dado** que cambio de idioma, **entonces** el nivel, las estrellas y la insignia del juego de memoria siguen igual.
6. **Dado** un fallo al guardar, **entonces** el idioma cambia en esta sesión y la app no muestra errores.
7. **Dado** cada uno de los 9 idiomas, **entonces** la sección «Idioma» no se desborda en vertical ni en horizontal, y el lector de pantalla lee el nombre de cada idioma con su pronunciación correcta.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `AppLanguage` gana el nombre propio de cada idioma (constantes, no van al catálogo porque no se traducen) |
| Presentación | Un cubit de idioma por encima de `MaterialApp` que arranca con el idioma de `resolveStartupLocale`, cambia el `locale` en caliente y guarda en el repositorio. Sección «Idioma» en `ParentsZoneScreen` |
| Catálogo | 2–3 claves nuevas en los 9 idiomas (título de la sección, etiqueta del idioma actual para el lector de pantalla) |
| Persistencia | Ninguna nueva: reutiliza `UserProfile.languageCode` (typeId existente) |
| Android | Ninguno (P1 aplazada) |
| Tests | Cubit (cambio, guardado, fallo al guardar), widget de la sección, cambio LTR ↔ RTL en caliente, layout en los 9 idiomas × orientaciones |

## 7. Android 13: idioma por app

Desde Android 13 el sistema permite elegir el idioma de cada app en *Ajustes › Sistema › Idiomas › Idiomas de las apps*. Para que ToddlerLogic aparezca ahí hay que declarar `android:localeConfig` con la lista de idiomas.

- **Conflicto con D-027:** si un adulto elige el idioma en los ajustes del sistema, Flutter lo recibe como idioma del teléfono, pero la app seguiría usando el guardado y parecería que el ajuste no funciona.
- Para evitarlo, el selector de la app y el del sistema tendrían que ser **la misma fuente**: la app leería y escribiría el idioma con `LocaleManager` (código nativo, Android 13+) y en versiones anteriores seguiría con el guardado.
- Hoy no se declara `localeConfig`, así que la app **no** aparece en ese menú del sistema y el conflicto no existe.

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Se integra el idioma por app de Android 13 (sección 7)? | ✅ Decidido (2026-10-26): **se aplaza.** No se declara `localeConfig`, así que no hay conflicto con D-027, y la historia queda en Dart puro, sin código nativo. Se puede retomar con HU-014 si la revisión de la tienda lo pide | — |
| P2 | ¿Se ofrece una opción «Idioma del teléfono» que siga al sistema? | ✅ Decidido (2026-10-26): **no.** Rompería la regla de D-027 de que el idioma del niño no cambie por sorpresa; elegir uno de los 9 cubre el caso | — |
| P3 | ¿Se muestran los 9 idiomas aunque sus traducciones sigan en borrador? | ✅ Asumida la recomendación: **sí.** Ya se usan hoy si el teléfono está en ese idioma; ocultarlos no los mejora. La revisión externa se exige antes de anunciar cada idioma en la tienda (HU-014) | — |
| P4 | ¿El idioma actual va primero o en su orden de la lista? | ✅ Asumida la recomendación: orden fijo de D-027 (inglés primero) con el actual marcado; la lista no se reordena al elegir | — |

## 9. Fuera de alcance

- Idiomas nuevos más allá de los 9 de D-027.
- Voz o audio por idioma (HU-005).
- Idioma distinto para la Zona de Padres y para los juegos.
- Fichas de la tienda por idioma (HU-014).
