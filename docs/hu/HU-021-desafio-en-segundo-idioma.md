# HU-021 · El desafío de adultos también en un segundo idioma

| | |
|---|---|
| **Estado** | Hecha (desarrollada el 2026-10-28; falta la revisión en el moto g55, que no estaba conectado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2 |
| **Tamaño** | S (1–2 días) |
| **Depende de** | HU-004 (desafío), HU-011 (catálogo de 9 idiomas) y HU-012 (selector de idioma) |

## 1. Historia

**Como** madre, padre o adulto a cargo que no entiende el idioma en el que está la app,
**quiero** ver la pregunta del desafío también en un idioma que sí entiendo,
**para** poder entrar en la Zona de Padres y poner la app en mi idioma.

## 2. El problema: un adulto puede quedarse fuera

El idioma solo se cambia en la Zona de Padres (HU-012), y para entrar hay que resolver una pregunta escrita **con palabras** en el idioma de la app (HU-004, R2). Si el adulto no lee ese idioma, no entiende la pregunta, no puede entrar y no puede cambiar el idioma. Es un círculo cerrado; hoy la única salida es borrar los datos de la app, y con ellos se pierde el progreso del niño.

Cómo puede ocurrir sin que el adulto haya hecho nada:

| Caso | Ejemplo |
|---|---|
| Primer arranque en un teléfono con otro idioma (D-027) | La app se instaló en el teléfono de la abuela, configurado en alemán, y ahora lo usa una madre hispanohablante |
| Otro adulto cambió el idioma | Un familiar lo puso en inglés para practicar con el niño |
| Teléfono heredado o de segunda mano | Se pasaron los datos de la app con una herramienta del fabricante que no respeta las reglas de Android (desde TD-008, D-033, la app no tiene copia de seguridad) |
| El niño o una prueba cambiaron el idioma | Alguien entró en la Zona de Padres y eligió por error العربية o 日本語 |

## 3. Qué no cambia

- La pregunta del idioma de la app **sigue siendo la principal**. El segundo idioma es una ayuda debajo de ella.
- **No se cambia el idioma de la app** al abrir el desafío ni sin pasarlo: el guardado sigue mandando (D-027, HU-012 P2).
- **La seguridad es la misma.** El segundo idioma también escribe los números con palabras (nunca con cifras), así que un niño que no sabe leer no tiene más pistas. El teclado sigue barajado.

## 4. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | **Qué idioma de ayuda se muestra.** Es el **primer idioma del teléfono** (en el orden de preferencia de los ajustes del sistema) que esté entre los 9 de D-027 y **no sea el de la app**. Si ninguno cumple, se muestra el **inglés**. Si la app ya está en inglés y el teléfono no tiene otro idioma de los 9, **no hay ayuda**: ninguna otra opción es mejor que el inglés |
| R2 | El idioma del teléfono se lee **cada vez que se abre el desafío**, no solo al arrancar la app. Si el adulto cambia el idioma del teléfono para salir del paso, la ayuda lo refleja en el siguiente intento |
| R3 | **Dónde se ve:** justo debajo de la pregunta principal, en un tamaño menor y en teal profundo al 80 % (como el lema del menú, D-032). Es **la misma pregunta con los mismos números**, escritos con palabras en el idioma de ayuda. Siempre visible: un adulto que no lee la pantalla no puede encontrar un botón de «traducir» |
| R4 | La ayuda se dibuja con **su propia dirección de escritura**: en una app en árabe, la ayuda en inglés va de izquierda a derecha, y al revés |
| R5 | El **lector de pantalla** lee primero la pregunta principal y después la de ayuda, cada una con su pronunciación (igual que los nombres de los idiomas en HU-012) |
| R6 | La ayuda llega también a los **otros textos necesarios para entrar**: el aviso «Toca otra vez para entrar» del menú (R1 de HU-004) y el título del mensaje de respuesta incorrecta («Esa no es la respuesta»). En ambos, una segunda línea más pequeña con el mismo criterio de R1 |
| R7 | **Iconos** en los botones del camino que hoy solo tienen texto, para que se entiendan sin leer: «Aceptar» del teclado (✓), «Reintentar» (↻) y «Volver al menú» (casa, como en la Zona de Padres). Los iconos van en azul petróleo o blanco según el botón (C6) |
| R8 | **Sin textos nuevos en el catálogo:** la ayuda reutiliza las traducciones que ya existen en los 9 idiomas. Las traducciones en borrador también se usan como ayuda (igual que HU-012 P3) |

El resto del camino ya se entiende sin leer el idioma de la app: el botón «Zona de Padres» lleva un escudo; el teclado usa cifras de 0 a 9 en todos los idiomas (HU-004 P6); y dentro de la Zona de Padres, la sección «Idioma» es la **primera**, lleva el icono de traducir y cada idioma aparece con su propio nombre (HU-012 R2).

### Ejemplos

| App | Idiomas del teléfono | Pregunta principal | Ayuda |
|---|---|---|---|
| Alemán | Español (Colombia) | Wie viel ist sieben mal sechs? | ¿Cuánto es siete por seis? |
| Alemán | Alemán | Wie viel ist sieben mal sechs? | What is seven times six? |
| Español | Español, Inglés | ¿Cuánto es siete por seis? | What is seven times six? (primero que no es el de la app) |
| Árabe | Portugués (Portugal) | Pregunta en árabe, de derecha a izquierda | Quanto é sete vezes seis? (de izquierda a derecha; `pt_PT` cuenta como portugués, D-027) |
| Inglés | Inglés | What is seven times six? | Sin ayuda |
| Inglés | Ruso (no está entre los 9) | What is seven times six? | Sin ayuda |

## 5. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-027 (multiidioma) | Se mantiene: el idioma de la app no cambia. Solo se **lee** el idioma del teléfono, con la misma regla de coincidencia (código de idioma, no de país) que en el primer arranque |
| D-029 / HU-004 R2 (números en palabras) | Se mantiene en los dos idiomas; ninguna línea muestra cifras. El riesgo aceptado de HU-004 (≈ 1 % por intento) no cambia |
| HU-004 R7 (mínima exposición) | Sin cambios: la ayuda no añade tiempo ni acciones |
| HU-012 (selector) | Esta historia cierra el hueco que deja: el selector solo sirve si se puede llegar a él |
| D-032 (paleta) | La ayuda usa teal profundo al 80 %; contraste sobre el crema ≥ 4,5:1 (se añade la pareja al test de contraste) |
| TD-007 (texto ampliado) | La pantalla del desafío tiene ahora más texto; sus tests de diseño deben incluir la ayuda |

## 6. Criterios de aceptación (borrador)

1. **Dado** la app en alemán y el teléfono en español, **cuando** abro el desafío, **entonces** veo debajo de la pregunta en alemán la misma pregunta en español, con los mismos números escritos con palabras.
2. **Dado** la app y el teléfono en el mismo idioma (que no sea inglés), **cuando** abro el desafío, **entonces** la ayuda está en inglés.
3. **Dado** la app en inglés y el teléfono en inglés o en un idioma fuera de los 9, **cuando** abro el desafío, **entonces** no hay ayuda y la pantalla es igual que hoy.
4. **Dado** que cambio el idioma del teléfono con la app abierta, **cuando** vuelvo a abrir el desafío, **entonces** la ayuda está en el nuevo idioma del teléfono.
5. **Dado** la app en árabe y la ayuda en inglés (o al revés), **entonces** cada línea va en su dirección de escritura y la pantalla no se desborda.
6. **Dado** el lector de pantalla, **entonces** lee la pregunta principal y después la de ayuda, cada una en su idioma.
7. **Dado** un toque en «Zona de Padres» y un fallo en el desafío, **entonces** el aviso «Toca otra vez para entrar» y el título del mensaje de fallo también tienen su línea de ayuda.
8. **Dado** el teclado y el mensaje de fallo, **entonces** «Aceptar», «Reintentar» y «Volver al menú» tienen icono además del texto.
9. **Dado** cualquier pareja de idioma de la app e idioma de ayuda, **entonces** ninguna línea muestra cifras.
10. **Dado** los 9 idiomas de la app con su ayuda más larga y la de dirección contraria, en vertical y en horizontal, **entonces** el desafío, el aviso y el mensaje no se desbordan.
11. **Dado** que resuelvo el desafío con ayuda de la segunda línea, **cuando** entro en la Zona de Padres y elijo mi idioma, **entonces** la app cambia a él (recorrido completo de rescate).

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `AppLanguage.helperFor(appLanguage, preferredLanguageTags)` → idioma de ayuda o `null` (R1). Dart puro, con la misma normalización que `resolve` |
| Presentación | Un widget pequeño de «línea de ayuda» que recibe un `AppLocalizations` de otro idioma (`lookupAppLocalizations`), con su `Directionality` y su `locale` para el lector de pantalla. Se usa en `_QuestionPanel`, en el aviso del menú y en `ParentalGateMessage`. Los idiomas del teléfono se leen de `PlatformDispatcher.locales` al abrir el desafío, inyectables en los tests |
| Catálogo | Ninguna clave nueva (R8) |
| Persistencia | Ninguna |
| Tests | `helperFor` con todos los casos de la tabla de ejemplos; widget de la pregunta con y sin ayuda; LTR ↔ RTL mezclados; semántica con el idioma de cada línea; contraste de la ayuda; diseño de los 9 idiomas de la app × su ayuda peor (la más larga y la de dirección contraria) × teléfonos × orientaciones; recorrido completo de rescate (criterio 11) |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿El idioma de ayuda sale del teléfono (R1) o siempre es el inglés? | ✅ Decidido (2026-10-27): **el del teléfono**; si no está entre los 9 idiomas, **inglés** por defecto | — |
| P2 | ¿La ayuda se ve siempre o solo cuando el idioma de la app no coincide con el del teléfono? | ✅ Decidido (2026-10-27): **siempre**, porque el inglés es un idioma muy extendido y sirve también a un adulto que usa un teléfono ajeno. Solo falta cuando la app ya está en inglés y no hay otro idioma del teléfono que mostrar (R1) | — |
| P3 | ¿Se muestra una sola línea de ayuda o varias (todos los idiomas del teléfono)? | ✅ Asumida la recomendación: **una sola.** Varias llenarían la pantalla, sobre todo en horizontal, y la primera preferencia casi siempre basta | No |
| P4 | ¿Se identifica el idioma de la ayuda con su nombre («Español: ¿Cuánto es…?»)? | ✅ Asumida la recomendación: **no.** El adulto reconoce su idioma al leerlo; la etiqueta solo ocupa espacio. El lector de pantalla ya lo pronuncia en su idioma (R5) | No |
| P5 | ¿La ayuda llega también al aviso del menú y al mensaje de fallo (R6) y se añaden los iconos (R7)? | ✅ Asumida la recomendación: **sí.** Sin ellos el camino sigue teniendo pasos que solo se entienden en el idioma de la app; con un fallo, el adulto no sabría qué botón pulsar antes de los 5 s | No |
| P6 | ¿Se ofrece un botón en el desafío para «cambiar la app al idioma del teléfono» sin pasar el desafío? | ✅ Asumida la recomendación: **no.** Saltaría el control de adultos (D-029); con la ayuda, el adulto puede entrar y elegir el idioma en el selector, que ya existe | No |

## 9. Fuera de alcance

- Mostrar en dos idiomas la Zona de Padres o el resto de la app: dentro de la Zona de Padres, la sección «Idioma» ya se encuentra sin leer (primera, con icono y nombres propios).
- Cambiar el idioma de la app desde el desafío (P6).
- Leer la pregunta en voz alta (HU-018, descartada por D-034).
- Idiomas fuera de los 9 de D-027.

## 10. Desarrollo y verificación

- **Rama:** `feature/hu-021-gate-helper-language`.
- **Dominio:** `AppLanguage.helperFor` (R1), con la misma normalización de idiomas que el primer arranque.
- **Presentación:** `HelperLanguageText` lee los idiomas del teléfono al construirse (R2) y dibuja el texto del catálogo del idioma de ayuda con su dirección de escritura y su idioma para el lector de pantalla (R4, R5). Se usa en la pregunta del desafío, en el aviso «Toca otra vez para entrar» (`QuietHint` gana una línea de ayuda opcional) y en el título del mensaje de fallo (R6). Iconos en «Aceptar» (✓), «Reintentar» (↻) y «Volver al menú» (casa) (R7). Ningún texto nuevo en el catálogo (R8).
- **Tests:**
  - 12 de la historia: los casos de R1, la lectura al abrir (R2), las direcciones mezcladas, la semántica con su idioma, los avisos con ayuda, los iconos, ninguna cifra en las 49 preguntas × 9 idiomas, y el recorrido completo de rescate (alemán → pregunta en español → Zona de Padres → «Español»).
  - Los de diseño del desafío y del mensaje se repiten con la ayuda más larga y con la de dirección contraria (380 casos).
  - El test de la paleta comprueba el contraste de las líneas de ayuda (≥ 4,5:1).
  - 749 tests en verde; cobertura del 99,7 % y del 100 % en los archivos tocados.
