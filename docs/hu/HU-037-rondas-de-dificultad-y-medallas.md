# HU-037 · Rondas de dificultad y medallas de bronce, plata y oro

| | |
|---|---|
| **Estado** | Lista (2026-11-11): el dueño decidió P1 a P10 el 2026-11-10 y P14 a P16 el 2026-11-11. Quedan P11 a P13, que no bloquean y se desarrollan con su recomendación salvo que el dueño diga otra cosa |
| **Épica** | E1 · Juegos (afecta a todos) y E2 · Zona de Padres |
| **Prioridad** | P2: cambia el progreso guardado de todos los juegos; cuanto antes, menos datos que migrar |
| **Tamaño** | L (estimación: 3–4 entregas) |
| **Depende de** | HU-001 (memoria), HU-007 (Sombras), HU-030 (dificultad), HU-002 y HU-016 (dorado y pérdida de estrellas). Cambia D-030 y D-035 |

## 1. Historia

**Como** niño o niña de 2 a 5 años,
**quiero** que cada juego empiece fácil y se vaya poniendo más difícil cuando lo domino,
**para** tener siempre un reto a mi medida y ganar medallas al superar cada etapa.

**Como** madre, padre o adulto a cargo,
**quiero** que la dificultad suba sola, y poder cambiarla si hace falta sin que mi hijo pierda lo que ya ganó,
**para** no tener que vigilar la configuración y que los logros reflejen lo que el niño de verdad ha conseguido.

## 2. Situación actual

- La dificultad (Fácil, Normal, Imposible) es un **ajuste general** de la Zona de Padres y **no cambia sola** (HU-030, D-035). Por defecto es Normal.
- Cada juego tiene **una sola escalera**: la memoria, 5 niveles; Sombras, 7 gratis y 8 con Premium. El nivel 1 no tiene tiempo; los demás, sí (en Sombras, solo con Premium).
- Al superar el último nivel se gana **una** insignia o medalla y se vuelve al nivel 1 (HU-001 R8, HU-007 R10).
- El **dorado** es la suma de las mejores estrellas de cada nivel, sin distinguir la dificultad (D-030, HU-002): la memoria llega al 100 % con 15★.
- Las estrellas se pierden poco a poco sin jugar (D-031); la insignia, nunca.

## 3. Propuesta del dueño (2026-11-10)

1. **Todos los juegos empiezan en Fácil.** Al completar la primera vuelta (todos los niveles de Fácil), el juego pasa a **Normal**; al completar Normal, a **Imposible** (el máximo reto).
2. **El nivel 1 deja de ser un nivel más:** es un **mini tutorial** sin tiempo y sencillo, al principio de cada dificultad. Al saltar a la siguiente dificultad se empieza por él.
3. **Al perder** se baja como hoy: menos cartas u objetos y el mismo límite, hasta llegar al tutorial sin tiempo.
4. **El dorado** ya no se completa al cruzar los niveles una vez, sino al completar **el juego entero en las tres dificultades**.
5. **Medallas por etapa:** **bronce** al pasar de Fácil a Normal, **plata** al pasar de Normal a Imposible y **oro** al completar Imposible.
6. La dificultad se sigue pudiendo **cambiar desde la Zona de Padres** (por juego o general, por analizar). Cambiarla **no quita logros** ya obtenidos, y los logros se siguen perdiendo con el tiempo si no se renuevan (D-031).

## 4. Comportamiento propuesto

### 4.1 Las tres rondas

Cada juego tiene **tres rondas**, una por dificultad, con la misma escalera de niveles. Ejemplo con la memoria:

| | Tutorial | 2×3 | 2×4 | 3×4 | 4×4 | Al completarla |
|---|---|---|---|---|---|---|
| **Fácil** | 2×2 sin tiempo | 270 s | 180 s | 135 s | 90 s | 🥉 Bronce y pasa a Normal |
| **Normal** | 2×2 sin tiempo | 90 s | 60 s | 45 s | 30 s | 🥈 Plata y pasa a Imposible |
| **Imposible** | 2×2 sin tiempo | 45 s | 30 s | 22 s | 15 s | 🥇 Oro y sigue en Imposible (P4) |

Sombras sigue el mismo esquema con su tabla 4.2 y sus series 4.3: el tutorial es su nivel 1 (2 objetos).

- **Ganar** un nivel sube al siguiente con su límite, como hoy.
- **Perder** baja un nivel conservando el límite; en el primer nivel con tiempo, se vuelve al tutorial (P3: ¿también se baja de dificultad?).
- **El tutorial** no tiene tiempo ni se puede perder. ¿Da estrellas? (P2).
- Las **ayudas** siguen la regla de HU-030 R10: vista previa en la memoria y animación de inicio en Sombras en Fácil y Normal; en Imposible, no.

### 4.2 Dorado

El 100 % del dorado es **todas las estrellas de todos los niveles en las tres dificultades**. Con 3★ por nivel y sin contar el tutorial (P2):

| Juego | Niveles con estrellas | Estrellas para el 100 % |
|---|---|---|
| Memoria | 4 × 3 dificultades | 36 |
| Sombras (gratis, 7 niveles) | 6 × 3 dificultades | 54 (más con Premium, P6) |

Cada dificultad aporta un tercio. La pérdida de estrellas (D-031) se aplica igual, empezando por el logro más antiguo, en cualquier dificultad.

### 4.3 Medallas

| Medalla | Se gana al | ¿Se pierde? |
|---|---|---|
| 🥉 Bronce | completar la ronda Fácil | No (P5) |
| 🥈 Plata | completar la ronda Normal | No (P5) |
| 🥇 Oro | completar la ronda Imposible | No (P5) |

En el menú, cada juego muestra la medalla más alta que tiene. La celebración de cada medalla es especial y distinta del final de un nivel normal.

### 4.4 La Zona de Padres

La dificultad deja de ser solo un ajuste: ahora es **la ronda en la que va el niño**, y sube sola. Lo que puede hacer el adulto (P1):

- **Ver en qué ronda va** cada juego y **cambiarla**: por ejemplo, devolverlo a Fácil si se frustra, o saltar a Normal si ya domina Fácil.
- Al cambiarla se empieza por el tutorial de esa ronda, **sin quitar** estrellas ni medallas ya ganadas (R5).
- «Jugar sin tiempo» sigue siendo general y de Premium (HU-030 R4).

## 5. Reglas (borrador)

| # | Regla |
|---|---|
| R1 | Un juego nuevo empieza en **Fácil**, en el tutorial. |
| R2 | Completar el último nivel de una ronda da su medalla y pasa a la ronda siguiente, empezando por su tutorial. En Imposible, ver P4. |
| R3 | El tutorial (nivel 1) no tiene tiempo ni derrota, en ninguna ronda. |
| R4 | Las estrellas se guardan **por ronda y nivel**: la mejor de cada una, con su fecha (D-030). |
| R5 | Cambiar la ronda desde la Zona de Padres no borra estrellas ni medallas; solo cambia dónde se sigue jugando. |
| R6 | La pérdida de estrellas sin jugar (D-031, HU-016) sigue igual y afecta a todas las rondas. Las medallas no se pierden (P5). |
| R7 | Las ayudas solo en Fácil y Normal (HU-030 R10). |
| R8 | El progreso que ya existe en los teléfonos se conserva al actualizar (P7). |
| R9 | **Al superar el tutorial** no hay estrellas ni celebración de nivel: una **invitación a jugar** breve (unos 1,5 s, sin botones, D-022), por ejemplo la mano de HU-022 con un gesto de «¡vamos!» y los puntos de nivel que se encienden, y empieza el primer nivel con tiempo (P2). |
| R10 | **Bajar de ronda** (P3): si el niño llega por segunda vez al tutorial de una ronda (ver P15), pasa a la ronda anterior, en el nivel de P14. No pierde medallas ni estrellas. En Fácil no hay ronda anterior: se sigue como hoy. |

## 6. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-035 (dificultad general) | **Cambia:** la dificultad pasa a ser la ronda de cada juego, que sube sola. Sustituida por una decisión nueva |
| D-030 (estrellas y dorado) | **Cambia:** las estrellas se guardan por ronda y nivel; el dorado se calcula sobre las tres rondas |
| D-031, D-037, HU-016 | Sin cambios: la pérdida sigue igual y se calcula al empezar el juego |
| HU-001 R8, HU-007 R10 (insignia y medalla únicas) | **Cambia:** tres medallas por juego |
| D-028 (gratis y Premium) | Por decidir cómo encaja Premium en las rondas (P6) |
| HU-030 (Zona de Padres, sección «Juegos») | La sección pasa a mostrar la ronda de cada juego (P1) |
| SPECIFICATION 3.4 (persistencia) | Campos nuevos en `MemoryProgressHiveModel` y `ShadowProgressHiveModel` (ronda actual, medallas, estrellas por ronda); índices nuevos, sin reutilizar los antiguos |

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | Un modelo común de rondas (`GameRound`: fácil, normal, imposible) y de escalera con tutorial, que usan la memoria y Sombras. Estrellas por (ronda, nivel). `StarDecay` sin cambios. Es el «modelo común de progreso» que HU-023 tenía pendiente |
| Persistencia | Campos nuevos en los dos modelos de progreso: 5 `currentRound`, 6 `medals`, 7 estrellas y fechas por ronda. Migración de lo guardado (P7) |
| Estado | Los dos cubits leen la ronda del progreso en vez del ajuste general; al completar una ronda, dan la medalla y pasan a la siguiente |
| Presentación | Celebración de medalla (bronce, plata, oro), indicador de ronda en la cabecera del juego, medalla más alta en el menú y la sección «Juegos» de la Zona de Padres por juego |
| Catálogo | Nombres de las rondas y de las medallas, mensajes de celebración y textos de la Zona de Padres, en 9 idiomas |
| Tests | Escaleras con tutorial, paso de ronda, medallas, dorado sobre tres rondas, cambio de ronda sin perder logros, migración de datos guardados |

## 8. Preguntas y decisiones

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿La ronda se cambia en la Zona de Padres **por juego** o con un ajuste **general**? | ✅ Decidido (2026-11-10): **por juego**, como la recomendación | — |
| P2 | ¿El tutorial (nivel 1) da estrellas y cuenta para el dorado? | ✅ Decidido (2026-11-10): **no** da estrellas ni cuenta para el dorado. **Además:** al superar el tutorial no se muestra la celebración con estrellas, sino una **invitación a jugar** (R9) | — |
| P3 | Al perder en el primer nivel con tiempo de Normal o Imposible, ¿se vuelve a la ronda anterior? | ✅ Decidido (2026-11-10), **distinto de la recomendación:** para evitar la frustración, si se llega **por segunda vez** al tutorial de la misma ronda, se **baja a la ronda anterior** (R10). Así el niño encuentra solo su nivel y el adulto no tiene que intervenir a menudo. Detalles en P14 y P15 | — |
| P4 | ¿Qué pasa al completar Imposible (tras el oro)? | ✅ Decidido (2026-11-10): se sigue en Imposible, como la recomendación | — |
| P5 | ¿Las medallas se pierden con el tiempo, como las estrellas? | ✅ Decidido (2026-11-10): las medallas no se pierden, como la recomendación | — |
| P6 | ¿Cómo encaja Premium (D-028)? Hoy Sombras gratis no tiene tiempo ni nivel 8 | ✅ Decidido (2026-11-10): **cada juego decide** qué es Premium, o si el juego entero lo es. Memoria, **100 % gratis**; Sombras, **80 % o más gratis**; el próximo juego, **alrededor del 50 % gratis**; los demás, **100 % Premium**, con **ediciones especiales** (pruebas o muestras gratis de juegos nuevos o de temporada que después pasan a Premium). Reparto de Sombras en P16; ediciones especiales en HU-042. Actualiza D-028 | — |
| P7 | ¿Qué pasa con el progreso de quien ya juega? | ✅ Decidido (2026-11-10): como la recomendación | — |
| P8 | ¿Un indicador de la ronda en la cabecera del juego? | ✅ Decidido (2026-11-10): como la recomendación | — |
| P9 | La versión sin pago de Sombras que se publica ahora (7 niveles sin tiempo), ¿cómo queda? | ✅ Decidido (2026-11-10): como la recomendación | — |
| P10 | ¿Cuándo se desarrolla? | ✅ Decidido (2026-11-10): como la recomendación | — |

## 9. Fuera de alcance

- Varios perfiles de niños (HU-033).
- Rondas distintas en cada juego más allá de las tres dificultades.
- Sonidos de las medallas (HU-005).

## 10. Avance del refinamiento (2026-11-10, sin respuestas del dueño)

### 10.1 Modelo de datos propuesto (con las recomendaciones de la sección 8)

Un modelo **común** para todos los juegos, en `domain/progress/`:

| Pieza | Qué es |
|---|---|
| `GameRound` | `easy`, `normal`, `impossible` (reutiliza `GameDifficulty`) |
| `RoundLadder` | La escalera de un juego: el tutorial y los niveles con tiempo, con su serie de tiempos por ronda (la de HU-030 para la memoria y la tabla 4.3 para Sombras) |
| `GameProgress` | Ronda actual, nivel actual, medallas ganadas (`Set<GameRound>`), récords por (ronda, nivel) con su fecha, última partida. Implementa `DecayingProgress` (la pérdida de estrellas no cambia) |

Guardado: se **añaden** campos a los modelos actuales, sin typeId nuevo y sin reutilizar índices (SPECIFICATION 3.4):

| Modelo | Campo nuevo | Contenido |
|---|---|---|
| `MemoryProgressHiveModel` (typeId 2) y `ShadowProgressHiveModel` (typeId 4) | 5 `round` | Nombre de la ronda (`null` → la de la migración, P7) |
| | 6 `medals` | Lista de rondas con medalla |
| | 7 `bestStarsByRoundLevel` | Clave `ronda*10 + nivel` → estrellas |
| | 8 `achievedAtByRoundLevel` | Misma clave → fecha |

Los campos 2 y 3 actuales (estrellas y fechas por nivel) se leen una vez para migrar y se dejan de escribir; su índice queda reservado.

### 10.2 Migración (P7, recomendada)

| Hoy | Tras la actualización |
|---|---|
| Nivel actual N, sin insignia | Ronda **Normal**, nivel N |
| Insignia de la memoria o medalla de Sombras | Medalla de **plata** (y bronce: se da por superada Fácil) |
| Estrellas por nivel | Estrellas de la ronda **Normal** en el mismo nivel; el nivel 1 (ahora tutorial) se descarta (P2) |

La migración se prueba con *fixtures* de los datos actuales (como `test/fixtures/hive_v2/`).

### 10.3 Dorado con tres rondas

| Juego | Niveles con estrellas por ronda | 100 % |
|---|---|---|
| Memoria | 4 (2×3, 2×4, 3×4, 4×4) | 36★ |
| Sombras gratis (7 niveles) | 6 | 54★ |
| Sombras con Premium (8 niveles) | 7 | 63★ |

Con la migración, quien hoy tiene la memoria al 100 % (15★, de las que 3 son del 2×2) pasa a 12/36 ≈ 33 %. **Es una bajada visible del dorado**: conviene una celebración única tras la actualización («¡Nuevos retos!») para que no se viva como una pérdida (P11).

### 10.4 Entregas propuestas

| # | Entrega | Contenido |
|---|---|---|
| 1 | Dominio común | `GameRound`, `RoundLadder`, `GameProgress`, medallas, dorado sobre tres rondas, tests |
| 2 | Guardado y migración | Campos 5–8, lectura de lo antiguo, *fixtures* |
| 3 | Juegos | Memoria y Sombras sobre el modelo común; paso de ronda con la celebración de la medalla; color de los puntos según la ronda (P8) |
| 4 | Menú y Zona de Padres | Medalla más alta en el menú; sección «Juegos» por juego (P1); «Jugar sin tiempo» sigue general; textos en 9 idiomas; moto g55 |

### 10.5 Preguntas nuevas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P11 | ¿Se avisa al niño o al adulto del cambio de dorado tras la actualización? | **Sí:** una celebración única al abrir cada juego por primera vez tras la actualización, con las medallas que ya tiene, y una línea en la Zona de Padres que explique las rondas | No |
| P12 | ¿Las ayudas de Fácil (vista previa de 1 s, animación de inicio) siguen en Normal? | **Sí**, como hoy (HU-030 R10): solo Imposible va sin ayudas | No |
| P13 | ¿HU-010 (punto de partida) se absorbe aquí? | **Sí**, si se acepta P1: cambiar de ronda cubre «saltarse lo que ya domina» (HU-010 sección 10) | No |

## 11. Decisiones del dueño (2026-11-10) y lo que cambian

### 11.1 Resumen

| # | Decisión |
|---|---|
| P1 | Ronda **por juego** en la Zona de Padres |
| P2 | El tutorial no da estrellas; al superarlo, **invitación a jugar** (R9) |
| P3 | Llegar **dos veces** al tutorial de una ronda **baja de ronda** (R10) |
| P4, P5 | Tras el oro se sigue en Imposible; las medallas no se pierden |
| P6 | **Cada juego decide su parte Premium:** Memoria 100 % gratis, Sombras ≥ 80 % gratis, el próximo juego ≈ 50 % gratis, los demás 100 % Premium con ediciones especiales gratis por un tiempo (HU-042) |
| P7 a P10 | Como las recomendaciones: migración a Normal, puntos de nivel del color de la ronda, la versión sin pago de Sombras se publica tal cual y se desarrolla antes de HU-006 |

### 11.2 Bajar de ronda (R10), con un ejemplo

Memoria en Normal: tutorial → 2×3 → 2×4 → pierde → 2×3 → pierde → **tutorial (2.ª vez)** → pasa a **Fácil**, en el nivel de P14. Al volver a completar Fácil, el niño sube otra vez a Normal (sin nueva medalla de bronce: ya la tiene).

### 11.3 Reparto gratis y Premium de cada juego (P6)

| Juego | Gratis | Premium | Parte gratis |
|---|---|---|---|
| Memoria (HU-001) | Todo | Nada | 100 % |
| Sombras (HU-007) | Las tres rondas, niveles 1 a 7, con sus estrellas y sus medallas (P16) | El nivel 8 de cada ronda y «Jugar sin tiempo» | 54 de 63 estrellas ≈ **86 %** |
| ¿Cuál es diferente? (HU-025, el próximo) | Propuesta: la ronda Fácil completa y la primera mitad de Normal | El resto de Normal e Imposible | ≈ 50 % |
| Los siguientes | Ediciones especiales gratis por un tiempo (HU-042) | El juego completo | 0 % fuera de las ediciones |

«Jugar sin tiempo» (HU-030) sigue siendo de Premium y general para todos los juegos.

### 11.4 Preguntas nuevas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P14 | Al bajar de ronda (R10), ¿en qué nivel se sigue? | ✅ Decidido (2026-11-11): en el **primer nivel con tiempo** de la ronda anterior, como la recomendación | — |
| P15 | ¿Qué cuenta como «llegar al tutorial» para R10? ¿También la entrada en la ronda, que empieza por el tutorial? | ✅ Decidido (2026-11-11): **solo las caídas** (llegar al tutorial por perder) cuentan; el contador vuelve a cero al cambiar de ronda, como la recomendación | — |
| P16 | En Sombras gratis, ¿una ronda se completa (y da su medalla) al superar el nivel 7, y el nivel 8 es el extra de Premium? | ✅ Decidido (2026-11-11): en Sombras gratis la ronda se completa (y da su medalla) al superar el nivel 7; el nivel 8 es el extra de Premium, como la recomendación | — |
| P11 a P13 | (sección 10.5) Aviso tras la actualización, ayudas en Normal, absorber HU-010 | Las recomendaciones de la sección 10.5 | No |

