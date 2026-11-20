# HU-031 · Disposición según la mano dominante

| | |
|---|---|
| **Estado** | **Desarrollada** (2026-11-20, con HU-039, rama `feature/hu-039-031-how-to-play`): sección 9. Falta verla en el teléfono |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | S (1 entrega, 1 día) |
| **Depende de** | HU-009 (`ParentalSettings`). HU-007 P13–P14 (disposición de Sombras). HU-022 y la mano infantil de la identidad (`assets/brand/hand_guide.png`, integrada el 2026-11-12). Se presenta en la misma sección que HU-039 |

## 1. Historia

**Como** madre, padre o adulto a cargo de un niño zurdo,
**quiero** indicar que juega con la mano izquierda,
**para** que su mano no le tape el sitio al que lleva las piezas y la mano guía se parezca a la suya.

## 2. Situación actual

- En Sombras, las sombras van **arriba** en vertical y a la **izquierda** en horizontal (HU-007 P13), pensando en un niño diestro: la mano tapa lo que queda debajo y a la derecha del dedo. Es la izquierda **física**, también en árabe.
- En «Imposible» la disposición cambia al azar en cada tablero (P14). Ahí la mano dominante no importa.
- La mano guía es una **mano derecha** que apunta arriba a la izquierda.

## 3. Viabilidad (estudio del 2026-11-12)

| Pieza | ¿Se puede? | Cómo | Coste |
|---|---|---|---|
| Reflejar la disposición de Sombras en horizontal | **Sí** | `ShadowBoard` coloca las cajas con `left`/`top` físicos; basta con elegir el lado según el ajuste. En vertical no cambia nada: arriba es bueno para las dos manos | Bajo |
| Reflejar la mano guía | **Sí** | `Transform.flip(flipX: true)` sobre la imagen. La yema del índice pasa de estar al 8 % del ancho a estar al 92 %; `GestureHint.fingertipAnchor` se refleja igual. El dibujo es simétrico de luz y no tiene texto, así que reflejado se ve como una mano izquierda natural | Muy bajo |
| **Girar** la mano | Sí, pero **no hace falta** | `Transform.rotate` funciona, pero un giro cambia el sentido del dedo, no la mano: una mano derecha girada sigue siendo derecha. Para un zurdo lo correcto es reflejar. Girar solo tendría sentido para apuntar hacia abajo (objetivos en el borde superior), y hoy no hay ninguno | — |
| Memoria y ¿Cuál es diferente? | No aplica | Se juega tocando en el sitio; no hay destino que tapar. Solo se refleja la mano guía | — |
| Juegos de arrastrar futuros (laberinto) | Sí | Cada juego declara qué refleja; el ajuste es común | Según juego |

**Conclusión:** viable y barato. Lo único nuevo de verdad es el lado de las sombras en horizontal; el resto es reflejar una imagen.

## 4. Comportamiento propuesto

En la sección **«Cómo juega»** (compartida con HU-039):

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Mano con la que juega** | **Derecha** · **Izquierda** | **Derecha** |

- **R1.** Con «Izquierda», en Sombras **en horizontal** las sombras van a la **derecha** y la bandeja a la izquierda. En vertical, sin cambios.
- **R2.** En «Imposible» la disposición sigue al azar (HU-007 P14).
- **R3.** Con «Izquierda», la mano guía se ve **reflejada** (mano izquierda) en todos los juegos, y su yema sigue cayendo exactamente sobre el objetivo.
- **R4.** El idioma no cambia nada: en árabe un diestro sigue viendo una mano derecha y las sombras a la izquierda.

## 5. Criterios de aceptación (borrador)

1. Con «Izquierda» y el teléfono en horizontal, las sombras salen a la derecha en Fácil y Normal.
2. Con «Izquierda», la mano guía es una mano izquierda en los tres juegos y su yema toca el centro del objetivo (con la misma tolerancia que hoy en las pruebas de `GestureHint`).
3. En árabe y diestro, todo sigue como hoy.
4. El ajuste se conserva al cerrar la app.

## 6. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `enum Handedness { right, left }`; `ParentalSettings.handedness` |
| Datos | Campo nuevo en `ParentalSettingsHiveModel` (`null` = derecha), con el siguiente índice libre |
| Presentación | `GestureHint` recibe `mirrored`; `_Hand` se envuelve en `Transform.flip`, y el ancla de la yema se refleja. `ShadowBoard` elige el lado de las sombras en horizontal |

## 7. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Se refleja también la disposición en vertical (sombras abajo para el zurdo)? | ✅ Decidido (2026-11-19), como la recomendación: **no.** Arriba no lo tapa ninguna de las dos manos y cambiarlo despistaría |
| P2 | ¿Se dibuja una mano izquierda propia o se refleja la derecha? | ✅ Decidido (2026-11-19), como la recomendación: **se refleja.** La de ahora es simétrica de luz; un dibujo aparte duplica el trabajo de identidad |
| P3 | ¿Un ajuste por niño? | ✅ Decidido (2026-11-19), como la recomendación: **no**, la app no tiene perfiles (fuera de alcance) |
| P4 | ¿Se desarrolla junto con HU-039, en la misma sección y la misma entrega de datos? | ✅ Decidido (2026-11-19), como la recomendación: **sí:** comparten sección, modelo y pruebas de la Zona de Padres |

## 8. Fuera de alcance

- Detectar la mano automáticamente.
- Perfiles de varios niños.

## 9. Desarrollo (2026-11-20)

- **Ajuste:** `PlayingHand { right, left }` en el campo 13 de `ParentalSettingsHiveModel`; si falta, la derecha. Se elige en «Cómo juega» (HU-039).
- **Sombras y «A su sitio»** (R1): con la mano izquierda y el teléfono en horizontal, las sombras y los sitios pasan a la derecha. En vertical no cambia nada (P1). En las rondas con la disposición al azar, el lado sigue siendo al azar (R2).
- **Mano guía** (R3): se dibuja reflejada (`Transform.flip`) y su yema sigue cayendo en el objetivo (`GestureHint.leftFingertipAnchor`). Además llega desde abajo a la izquierda, del lado de la mano.
- **El idioma no cambia nada** (R4): todo usa la izquierda y la derecha físicas.
