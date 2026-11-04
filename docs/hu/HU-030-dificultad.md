# HU-030 · Dificultad de los juegos y «Jugar sin tiempo»

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-11-04; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2: Sombras (HU-007) nace con sus tres niveles |
| **Tamaño** | M (3 entregas, unos 3 días) |
| **Depende de** | HU-009, que crea `ParentalSettings` (typeId 3), donde se guardan estos dos ajustes. HU-004 (Zona de Padres, hecha) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** elegir lo difíciles que son los juegos y si tienen tiempo,
**para** que el reto se ajuste a mi hijo: que no se frustre ni se aburra.

## 2. Situación actual

- El único juego, la memoria (HU-001), tiene una escalera fija: el 2×2 sin tiempo y después la serie **90 → 60 → 45 → 30 s**. No se puede cambiar.
- Al refinar HU-005 se retiró la «dificultad» del backlog porque la cubrían la escalera de HU-001 y el punto de partida de HU-010. Esta historia la recupera como **ajuste propio**, con su decisión en la sección 8 de la especificación (D-035, sección 5).
- Sombras (HU-007) ya tiene decididas sus tres series de tiempo (tabla 4.3) y su reto en «Imposible» (disposición al azar, P14).
- El 2026-11-04 el dueño decide que **«sin tiempo» es una opción de todos los juegos**, no solo de Sombras.

## 3. Comportamiento propuesto

### 3.1 Ajustes en la Zona de Padres

Una sección nueva, **«Juegos»**, con dos ajustes que valen para **todos los juegos** (P1):

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Dificultad** | Fácil · Normal · Imposible, cada una con una frase que explica qué cambia | **Normal** (el comportamiento actual) |
| **Jugar sin tiempo** | Interruptor | **Desactivado** (hay tiempo) |

### 3.2 Qué cambia en cada juego

Cada juego define qué significa cada nivel de dificultad. Lo común: **Normal** es el juego tal como está diseñado, con sus ayudas; **Fácil** da más margen; **Imposible** es un reto para quien ya domina el juego y **no tiene ayudas** (R10).

**Memoria (HU-001).** Cambian los límites de tiempo, nivel por nivel, y la **vista previa** de las cartas (sección 3.4):

| Dificultad | 2×2 | 2×3 | 2×4 | 3×4 | 4×4 |
|---|---|---|---|---|---|
| Fácil (×3) | Sin tiempo | 270 s | 180 s | 135 s | 90 s |
| **Normal** | Sin tiempo | 90 s | 60 s | 45 s | 30 s |
| Imposible (la mitad, decidido el 2026-11-03) | Sin tiempo | 45 s | 30 s | 22 s | 15 s |

La lógica de la escalera no cambia (HU-001 R4–R6): al ganar se sube y el límite pasa al siguiente de la serie elegida; al perder se baja conservando el límite. Imposible redondea 22,5 s hacia abajo, a 22 s.

**Vista previa** (sección 3.4): en Fácil y Normal, sí; en Imposible, no.

**Sombras (HU-007).**

| | Fácil | Normal | Imposible |
|---|---|---|---|
| Tiempo con Premium (tabla 4.3) | 90 → 30 s | 60 → 25 s | 50 → 20 s |
| Sombras libres (distractores) | **Ninguna**: tantas sombras como objetos (P3) | Las de la tabla 4.2 | Las de la tabla 4.2 |
| Zona magnética | **1,5 veces** la de Normal (P3) | Media sombra (HU-007 P4) | Media sombra |
| Disposición | Fija | Fija | **Al azar en cada tablero** (HU-007 P14) |
| Animación de inicio (HU-007 R19) | Sí | Sí | **No** |

**Juegos futuros:** cada uno, al refinarse, rellena su columna en esta tabla. Un juego nuevo no se da por «Lista» sin sus tres niveles.

### 3.3 Reglas

| # | Regla |
|---|---|
| R1 | La sección «Juegos» está en la Zona de Padres, tras el control para adultos (D-029): el niño no puede cambiar estos ajustes. |
| R2 | **Dificultad:** tres opciones (Fácil, Normal, Imposible) que se eligen con un toque. Cada una lleva una frase corta y **general** que explica qué cambia (P6). Normal es el valor por defecto. |
| R3 | **Jugar sin tiempo:** con el interruptor activado, ningún juego muestra barra de tiempo ni hace perder por tiempo. La escalera solo sube: al ganar se pasa al siguiente nivel y nunca se baja. |
| R4 | **Sin tiempo se puede conseguir todo** (P2): quitar el tiempo no penaliza los logros del niño. Las estrellas, el dorado y la insignia o medalla de cada juego se ganan igual que con tiempo. En la memoria, las estrellas ya dependen de los movimientos, no del tiempo (D-030), así que no cambian. **En Sombras, el tiempo y su ajuste son Premium:** sin Premium no hay tiempo, así que poner o quitar el tiempo de Sombras solo es posible con Premium; lo Premium sigue exigiendo Premium (HU-007 R18). En la memoria, que es 100 % gratuita (D-028), el ajuste es gratuito. |
| R5 | **La dificultad no cambia los premios** (P4): las estrellas, el dorado y la insignia valen lo mismo en Fácil, Normal o Imposible. No hay comparación entre niños; el adulto ajusta el reto a su hijo. |
| R6 | **Cambiar un ajuste** se aplica en el **siguiente tablero**, nunca en el que está en curso (como HU-007 R12). El progreso se conserva: el niño sigue en su nivel y el límite pasa al de ese nivel en la serie nueva (el límite de llegada, como al abrir el juego, HU-001 R12). |
| R7 | Con «Jugar sin tiempo» activado, la dificultad **sigue aplicando** a lo que no es tiempo (en Sombras: sombras libres, zona magnética y disposición). En la memoria, como solo cambia el tiempo, la frase de la dificultad lo indica (P6). |
| R8 | El tutorial visual (HU-022) no cambia con la dificultad. |
| R9 | Los ajustes se guardan en el teléfono con el resto de ajustes de padres (`ParentalSettings`, HU-009) y no se envían a ningún sitio. |
| R10 | **Las ayudas solo van en Fácil y Normal** (decidido el 2026-11-04): las animaciones que enseñan la solución (la vista previa de la memoria, sección 3.4, y la animación de inicio de Sombras, HU-007 R19) no se muestran en Imposible. El tutorial de la mano (HU-022) no es una de ellas: enseña el gesto, no la solución, y sigue en todas (R8). |

### 3.4 Vista previa de la memoria (propuesta por el dueño el 2026-11-04)

Al empezar cada tablero, en Fácil y Normal, **todas las cartas se ven boca arriba durante 1 segundo** y después **se voltean todas a la vez**. Es una ayuda: el niño se lleva una primera idea de dónde está cada pareja.

| # | Regla |
|---|---|
| V1 | Pasa en **todos los tableros** (el 2×2 incluido) y también en el que llega tras perder por tiempo. |
| V2 | Las cartas se reparten ya boca arriba; tras **1 s** (P8), se voltean todas juntas con la animación de volteo actual. |
| V3 | Mientras dura la vista previa, tocar una carta no hace nada. El cronómetro sigue arrancando con el primer toque (HU-001 R10), así que la vista previa no quita tiempo. |
| V4 | La mano de HU-022 cuenta sus 4 s desde que las cartas se han volteado. |
| V5 | Con «reducir movimiento» del sistema, las cartas se ven igual 1 s (es información, no adorno) y se ocultan sin animación de volteo. |
| V6 | No cambia los movimientos ni las estrellas (P4): la vista previa no cuenta como movimiento. |
| V7 | En Imposible no hay vista previa: las cartas se reparten boca abajo, como hasta ahora. |

### 3.5 Encaje con HU-010

HU-010 (punto de partida de la memoria) elige **en qué tablero y con qué tiempo** empieza el niño. Con esta historia, el tiempo de partida se toma de la serie de la dificultad elegida. Si HU-010 se desarrolla antes, su selector de tiempo se adapta al desarrollar esta.

## 4. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| HU-001 (D-020, D-021) | La escalera y la barra de tiempo no cambian; solo la serie de límites. Normal es la serie actual. **Cambio en Normal:** la vista previa de 1 s (3.4) es nueva también en Normal, que hasta ahora repartía boca abajo (decidido por el dueño el 2026-11-04) |
| D-030 (estrellas) | Sin cambios: se cuentan por movimientos (memoria) o por fallos de forma (Sombras, HU-007 R9) |
| D-028 (modelo de acceso) | «Jugar sin tiempo» y la dificultad son gratuitos. En Sombras, el tiempo sigue siendo Premium: sin Premium nunca hay tiempo, así que «Jugar sin tiempo» no cambia nada |
| D-029 | Los ajustes quedan tras el control para adultos |
| HU-005 P1 | Revierte la retirada de la «dificultad»: nueva decisión **D-035** (sección 5) |
| HU-007 P7, P14, P15, R18 | Esta historia las resuelve para todos los juegos |

## 5. Decisión para la sección 8 de la especificación (borrador)

| ID | Decisión | Motivo |
|---|---|---|
| D-035 | **Dificultad y «Jugar sin tiempo»:** dos ajustes generales de la Zona de Padres, para todos los juegos. La dificultad tiene tres niveles (Fácil, Normal por defecto, Imposible) y cada juego define qué cambia en cada uno; la memoria multiplica sus límites por 3 en Fácil y los divide entre 2 en Imposible. Las ayudas que enseñan la solución (vista previa de la memoria, animación de inicio de Sombras) solo van en Fácil y Normal. «Jugar sin tiempo» quita la barra y la derrota por tiempo en todos los juegos, sin quitar ningún premio; en los juegos con tiempo Premium (Sombras), el ajuste solo actúa con Premium. Los premios valen igual en las tres dificultades. Los cambios se aplican en el siguiente tablero | Un mismo juego tiene que servir a niños de 2 a 5 años; el adulto ajusta el reto. Recupera la «dificultad» retirada en HU-005 P1 |

## 6. Criterios de aceptación (borrador)

1. **Dado** la Zona de Padres, **entonces** veo la sección «Juegos» con la dificultad en Normal y «Jugar sin tiempo» desactivado.
2. **Dado** la dificultad Fácil, **cuando** juego a la memoria, **entonces** el 2×3 tiene 270 s y el 4×4 llega con 90 s.
3. **Dado** la dificultad Imposible, **cuando** juego a la memoria, **entonces** el 2×3 tiene 45 s y el 4×4 llega con 15 s.
4. **Dado** «Jugar sin tiempo», **cuando** juego a la memoria, **entonces** no hay barra de tiempo en ningún nivel, nunca bajo de nivel y, al completar el 4×4, consigo la insignia.
5. **Dado** un tablero en curso, **cuando** un adulto cambia la dificultad o «Jugar sin tiempo», **entonces** el tablero en curso sigue igual y el cambio se ve en el siguiente, en el mismo nivel.
6. **Dado** que gano un nivel con los mismos movimientos en Fácil y en Imposible, **entonces** consigo las mismas estrellas.
7. **Dado** que cierro y vuelvo a abrir la app, **entonces** los dos ajustes se conservan.
8. **Dado** datos guardados por una versión anterior (sin estos ajustes), **entonces** la app arranca en Normal y con tiempo.
9. **Dado** los 9 idiomas, en vertical y en horizontal, con el texto ampliado hasta 2,0, **entonces** la sección «Juegos» no se desborda.
10. **Dado** el código, **entonces** solo usa colores de la paleta (`palette_test.dart`).
11. **Dado** la dificultad Fácil o Normal, **cuando** empieza un tablero de la memoria, **entonces** veo todas las cartas boca arriba 1 s y después se voltean todas; mientras tanto, tocar una carta no hace nada ni arranca el tiempo.
12. **Dado** la dificultad Imposible, **cuando** empieza un tablero de la memoria, **entonces** las cartas salen boca abajo, sin vista previa.
13. **Dado** «reducir movimiento», **cuando** empieza un tablero en Fácil o Normal, **entonces** las cartas se ven 1 s y se ocultan sin animación.

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `GameDifficulty` (enum: easy, normal, impossible) en `domain/settings/`. `MemoryLadder` recibe la serie de límites según la dificultad (hoy es una constante) y un modo sin tiempo en el que perder no existe |
| Persistencia | Dos campos nuevos en `ParentalSettings` (typeId 3, creada en HU-009): `difficulty` y `timerDisabled`, con valores por defecto (Normal y `false`) para los datos ya guardados. Test de compatibilidad, como en HU-001 |
| Estado | `MemoryLadderCubit` lee los ajustes al empezar cada tablero (R6). Nueva fase `previewing` en `MemoryLadderState`: reparte boca arriba, ignora los toques y, tras 1 s, voltea todas y pasa a `playing` |
| Presentación | Sección «Juegos» en `ParentsZoneScreen` (tarjeta como la de idioma): `SegmentedButton` con las tres dificultades y su frase, y un `SwitchListTile` para «Jugar sin tiempo». Colores de la paleta (ninguno nuevo) |
| Catálogo | Unas 8 claves en los 9 idiomas: título de la sección, las tres dificultades, sus frases y el interruptor con su explicación |
| Tests | Dominio (las tres series, sin tiempo, R6), cubit (cambio entre tableros), widget de la sección, layout en los 9 idiomas y las dos escalas de texto |

### Entregas

| # | Entrega | Contenido |
|---|---|---|
| 1 | Dominio y guardado | `GameDifficulty`, series de la memoria, modo sin tiempo de `MemoryLadder`, campos de `ParentalSettings` |
| 2 | Zona de Padres | Sección «Juegos» y catálogo en los 9 idiomas |
| 3 | Memoria | El cubit aplica los ajustes en el siguiente tablero y la vista previa (3.4); verificación en el moto g55 |

Sombras aplica su columna de la tabla 3.2 cuando se desarrolle HU-007.

## 8. Preguntas y decisiones

| # | Pregunta | Decisión o recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿«Sin tiempo» es solo de Sombras o de todos los juegos? | ✅ Decidido (2026-11-04): **de todos los juegos**, como ajuste general | — |
| P2 | Sin tiempo, ¿se pueden ganar la insignia de la memoria y todos los premios? | ✅ Decidido (2026-11-04): **sí**, quitar el tiempo no penaliza los logros del niño. En Sombras, el tiempo y el ajuste para ponerlo o quitarlo son exclusivos de Premium (R4) | — |
| P3 | En Sombras, ¿qué más cambia en Fácil? | ✅ Decidido (2026-11-04): **sin sombras libres** y **zona magnética 1,5 veces** mayor | — |
| P4 | ¿La dificultad cambia los premios (estrellas, dorado, insignia)? | ✅ Decidido (2026-11-04): **no**, valen igual en las tres | — |
| P5 | ¿Un ajuste general o uno por juego? | ✅ Asumida la recomendación: **general** en esta historia. Si un juego necesitara el suyo, se añade al refinarlo | — |
| P6 | ¿Cómo se explica cada dificultad? | ✅ Asumida la recomendación, ajustada a R10: una frase general por opción, sin números: «Fácil: más tiempo y ayudas», «Normal: el juego tal como es, con ayudas», «Imposible: menos tiempo y sin ayudas». Los textos finales pasan por TD-011 | — |
| P7 | En Imposible, ¿Sombras añade también una sombra libre más? | ✅ Decidido (2026-11-04): **no**; la disposición al azar, el tiempo más corto y la falta de ayudas ya ponen el reto | — |
| P8 | ¿Cuánto dura la vista previa de la memoria? | ✅ Decidido por el dueño (2026-11-04): **1 segundo**, igual en Fácil y Normal y en todos los tableros. Si en el 4×4 se quedara corto, se revisa jugando | — |

## 9. Fuera de alcance

- Una dificultad distinta para cada juego (P5).
- Cambiar el tamaño de los tableros de la memoria según la dificultad: la escalera de HU-001 se queda como está.
- El punto de partida de la memoria (HU-010).
