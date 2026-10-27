# HU-016 · Activar o desactivar la pérdida de logros

| | |
|---|---|
| **Estado** | Lista (refinamiento cerrado el 2026-10-27; se desarrolla junto con HU-002) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | S (1 día) |
| **Depende de** | HU-002 (pérdida gradual de logros, D-031; **no desarrollada todavía**) y HU-004 (hecha) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** poder desactivar la pérdida gradual de estrellas,
**para** que mi hijo no pierda su dorado tras unas vacaciones o una enfermedad si así lo prefiero.

## 2. Situación actual

- D-031 (HU-002 R7–R12): tras **7 días** sin jugar a un juego, sus estrellas se pierden **una cada 3 días**, empezando por la más antigua. La insignia no se pierde. Está **activada por defecto**.
- HU-002 está `Lista` pero no desarrollada; espera al icono de HU-013. Por eso esta historia se desarrolla **con HU-002 o después**.
- Riesgo aceptado en D-031: se parece a las «rachas»; esta historia es la opción D3 de HU-002 para mitigarlo.

## 3. Comportamiento propuesto

| # | Regla |
|---|---|
| R1 | La Zona de Padres tiene un interruptor **«Mantener las estrellas»** (desactivado por defecto: la pérdida de D-031 está activa). |
| R2 | **Al activarlo**, las estrellas dejan de perderse: se conserva lo que haya en ese momento. Las ya perdidas no vuelven solas (se recuperan ganando, como siempre). |
| R3 | **Al desactivarlo**, el periodo de gracia de 7 días **empieza de nuevo desde ese momento**, para que no se pierdan de golpe estrellas acumuladas mientras estuvo activado (nota del backlog). |
| R4 | Es un ajuste **general** de la app (P1): aplica a todos los juegos que tengan estrellas. |
| R5 | El texto explica en una línea qué hace, sin tono negativo («Las estrellas se conservan aunque pasen días sin jugar»). |

## 4. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | El cálculo del dorado efectivo de HU-002 recibe «pérdida activada» y la fecha desde la que cuenta la gracia (la mayor entre la última partida y la última reactivación) |
| Persistencia | Dos campos: `keepStars` (bool) y `starDecayResumedAt` (fecha). Encajan en `ParentalSettings` si HU-009 la crea antes (typeId 3); si no, se crea aquí |
| Presentación | Interruptor en la Zona de Padres |
| Catálogo | 2 claves en los 9 idiomas |
| Tests | Dominio con reloj inyectado: activar, desactivar y reiniciar la gracia; widget y layout |

## 5. Criterios de aceptación (borrador)

1. **Dado** «Mantener las estrellas» activado, **cuando** pasan 30 días sin jugar, **entonces** no se pierde ninguna estrella.
2. **Dado** que lo desactivo tras 30 días sin jugar, **entonces** no se pierde nada durante los 7 días siguientes, y después la pérdida sigue la regla de D-031.
3. **Dado** que nunca se tocó el ajuste, **entonces** la pérdida funciona como en D-031.
4. **Dado** los 9 idiomas, **entonces** el interruptor y su explicación no se desbordan.

## 6. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-031 | Se mantiene como comportamiento por defecto; esta historia añade la forma de pausarlo |
| HU-002 | Su cálculo debe aceptar el ajuste: conviene diseñarlo así desde el principio |
| HU-009 | Comparte la entidad de ajustes de padres (`ParentalSettings`) |

## 7. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Ajuste por juego o general? | ✅ Decidido (2026-10-27): **general** (R4) | — |
| P2 | ¿Por defecto la pérdida activada? | ✅ Asumida la recomendación: **sí**, como dice D-031 | — |
| P3 | ¿Se desarrolla junto con HU-002? | ✅ Asumida la recomendación: **sí, en el mismo bloque**: así el cálculo de HU-002 nace con el ajuste y no hay que tocarlo dos veces | — |

## 8. Fuera de alcance

- Cambiar los plazos de D-031 (7 días de gracia, 1 estrella cada 3 días).
- Recuperar estrellas perdidas sin jugar.
