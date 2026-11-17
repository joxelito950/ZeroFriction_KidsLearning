# HU-048 · Medallas que se distinguen de un vistazo

| | |
|---|---|
| **Estado** | **Lista** (2026-11-17): recomendaciones aceptadas. Se diseña ya para las **8 medallas** de HU-051 |
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
