# HU-048 · Medallas que se distinguen de un vistazo

| | |
|---|---|
| **Estado** | **Desarrollada para 3 medallas** (2026-11-17, rama `feature/hu-048-049-medals-and-child`); las 5 gemas llegan con HU-051. Falta verla en el moto g55 |
| **Épica** | E1 · Juegos (progresión y recompensas) |
| **Prioridad** | **P1** (corrección visible en la prueba cerrada) |
| **Tamaño** | S (1 día) |
| **Depende de** | HU-037 (rondas y medallas). Es la base visual de HU-051 (más medallas) |

## 1. Historia

**Como** niño o niña que juega, y como adulto que lo acompaña,
**quiero** reconocer enseguida si una medalla es de bronce, de plata o de oro,
**para** sentir que cada ronda es un logro distinto y saber cuál le falta.

## 2. Problema (visto en el moto g55)

Las medallas de **bronce y oro son prácticamente idénticas**. Causa en el código:

- Todas son el **mismo icono del sistema** (`Icons.military_tech_rounded`), solo teñido: en el menú, en la celebración y en los chips de la Zona de Padres.
- El bronce (`#B0603C`) y el dorado (`#A86B12`) son **dos marrones de luminosidad muy parecida**; la única diferencia es el matiz, y a 30 dp no se aprecia (y una persona con daltonismo no la ve nunca).

## 3. Propuesta

Una **medalla propia** (`MedalBadge`), dibujada por la app, que se distingue por **tres señales a la vez**, no solo por el color:

| Señal | Bronce | Plata | Oro |
|---|---|---|---|
| **Relleno** | Bronce `#B0603C` | Plata `#748A8E` | **Ámbar `#ECA463`** (claro, de la paleta) |
| **Borde** | Bronce oscurecido con transparencia sobre teal | Plata | **Dorado `#A86B12`** |
| **Estrellas grabadas** | ★ | ★★ | ★★★ |
| **Brillo** | — | — | Un destello suave al aparecer (no en bucle, D-022) |

- El oro pasa a ser **claro y luminoso** (ámbar con borde dorado) y el bronce **oscuro y rojizo**: la diferencia de luminosidad hace que se distingan incluso en gris.
- El número de estrellas es la señal que no depende del color (accesibilidad) y prepara HU-051.
- La misma `MedalBadge` en el menú, la celebración (sobre el pecho del niño, HU-049), los chips de la Zona de Padres y «Su progreso» (HU-034).
- Solo colores de la paleta y sus transparencias (C2): no hace falta un color nuevo para bronce, plata y oro.
- **Con HU-051 (8 medallas):** `MedalBadge` recibe la medalla (no la ronda de 3) y admite las 8: bronce, plata y oro como metales con 1, 2 y 3 estrellas; rubí, esmeralda, zafiro, obsidiana y diamante como **gemas facetadas** (forma distinta del disco), cada una con su color (sección 3.4 de HU-051). Se desarrolla junto con HU-051, o antes con las 3 medallas y el parámetro ya preparado.

## 4. Criterios de aceptación

1. En el menú, la celebración y la Zona de Padres, las tres medallas usan `MedalBadge`; no queda `military_tech` para medallas.
2. Convertidas a escala de grises, la de bronce y la de oro tienen una diferencia de luminosidad clara (test que compara la luminancia relativa del relleno: oro ≥ 1,8 veces la del bronce).
3. Cada medalla lleva 1, 2 o 3 estrellas grabadas y el lector de pantalla dice «Medalla de bronce/plata/oro».
4. Visto en el moto g55 junto a un adulto que no conoce la app: distingue las tres sin explicación.
5. `palette_test` sin colores nuevos.

## 5. Impacto técnico

| Capa | Cambio |
|---|---|
| Presentación | `MedalBadge` (`CustomPaint`: disco, borde, cinta y estrellas) y `RoundStyle.medalStyleOf(round)` con relleno, borde y estrellas. Sustituye el icono en `main_menu_screen`, `memory_round_overlay` y `parents_games_section` |
| Tests | Golden o test de pintura de las tres medallas, luminancias y semántica |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Medalla dibujada por la app o ilustración PNG como el resto de la identidad? | ✅ Decidido (2026-11-17): **dibujada por la app**: escala a cualquier tamaño, admite las medallas futuras (HU-051) sin pedir una ilustración por cada una y pesa nada |
| P2 | ¿Estrellas grabadas (1, 2, 3) o letras (B, P, O)? | ✅ Decidido (2026-11-17): **estrellas**: sin texto (los niños no leen y no hay que traducir) |
| P3 | ¿Se cambia también el color de la ronda en los puntos de nivel? | ✅ Decidido (2026-11-17): **sí**, el oro de los puntos pasa al ámbar con borde dorado, para que ronda y medalla coincidan |

## 7. Desarrollo (2026-11-17)

- `MedalBadge` y `MedalStyle` (`widgets/medal_badge.dart`): cinta en coral y teal, disco con borde y 1, 2 o 3 estrellas. Bronce y plata con borde de teal profundo al 45 % y estrellas crema; **oro en ámbar con borde y estrellas doradas**. Sin colores nuevos ni literales (C1, C2).
- `RoundStyle.medalStyleOf`, `colorOf` (relleno de la medalla) y `rimOf` (su borde). Los puntos de nivel alcanzados llevan el borde de la medalla de la ronda (P3); los de la ronda de oro, en ámbar con borde dorado.
- Sustituye el icono del sistema en el menú, en la celebración (HU-049) y en los chips de la Zona de Padres.
- Tests: luminancia del oro ≥ 1,8 veces la del bronce (es unas 2,5), estrellas, estilos por ronda, semántica, sin iconos del sistema y bordes de los puntos.


## 8. Medallas redondas y cinta al cuello (2026-11-18, decisión del dueño)

Al verlas en el moto g55, la cinta dentro del cuadrado dejaba el disco en un tercio del círculo blanco del menú. Decidido el diseño **mixto**:

- **`MedalBadge` sin cinta:** el disco llena todo el cuadrado (centro 0,5 y radio 0,5). En el menú, la medalla ocupa 36 de los 40 px del círculo blanco; en la Zona de Padres, igual de grande que el chip.
- **Gemas engastadas (HU-051):** cada gema va sobre un disco claro de su color (18 % sobre blanco) con borde de su color; el diamante, con el borde teal. Así todas las medallas son redondas y tapan igual el pecho del niño.
- **La cinta solo en la celebración (HU-049):** `MedalRibbonPainter` dibuja dos tiras en V desde los lados del cuello del niño hasta el disco, que tapa sus extremos, como si colgara de sus hombros. Coral y coral con teal, como antes.

## 9. Sin cinta en la celebración (2026-11-19, prueba cerrada)

Los testers vieron que la cinta en V no se veía natural: el niño de la ilustración no está del todo de frente, y las dos tiras dibujadas encima sobresalían como dos rayas independientes del niño. Decisión del dueño: **todas las medallas sin cinta**, también en la celebración. `MedalRibbonPainter` se retira. Si se quiere recuperar la cinta, tiene que venir dibujada en la ilustración: es la variante 13b de `PROMPTS-identidad.md`, opcional.
