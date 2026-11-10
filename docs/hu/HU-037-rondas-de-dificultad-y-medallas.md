# HU-037 · Rondas de dificultad y medallas de bronce, plata y oro

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-10; avanzado el mismo día sin respuestas del dueño, sección 10) |
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
| P1 | ¿La ronda se cambia en la Zona de Padres **por juego** o con un ajuste **general**? | **Por juego.** Como ahora sube sola en cada juego, cada uno puede ir en una ronda distinta (un niño puede dominar la memoria y estar empezando Sombras). Un ajuste general obligaría a mover todos los juegos a la vez. La sección «Juegos» mostraría, por juego, «Fácil · Normal · Imposible» con la ronda actual marcada | Sí |
| P2 | ¿El tutorial (nivel 1) da estrellas y cuenta para el dorado? | **No.** Es una ayuda sin tiempo ni reto: el dorado mide lo que cuesta. Así cada ronda vale lo mismo (4 niveles en la memoria) | Sí |
| P3 | Al perder en el primer nivel con tiempo de Normal o Imposible, ¿se vuelve a la ronda anterior? | **No.** Se vuelve al tutorial de la misma ronda, sin tiempo. Bajar de ronda solo lo decide el adulto (P1): perder no quita la ronda ganada | Sí |
| P4 | ¿Qué pasa al completar Imposible (tras el oro)? | **Se sigue en Imposible**, desde su tutorial, para mejorar estrellas y mantener el dorado. No se vuelve a Fácil | No |
| P5 | ¿Las medallas se pierden con el tiempo, como las estrellas? | **No.** Son el recuerdo de la etapa superada (como la insignia de hoy, HU-002 R10). Lo que se pierde es el dorado | No |
| P6 | ¿Cómo encaja Premium (D-028)? Hoy Sombras gratis no tiene tiempo ni nivel 8 | **Por decidir con HU-006.** Dos opciones: (a) gratis = la ronda Fácil completa y su bronce; Premium = Normal, Imposible, plata y oro; (b) gratis = las tres rondas sin tiempo; Premium = el tiempo, el último nivel y las 3★. Recomiendo **(a)**: es fácil de entender para los padres («Premium desbloquea los retos difíciles») y el niño gratis tiene un juego completo con su medalla | Sí, para Sombras |
| P7 | ¿Qué pasa con el progreso de quien ya juega? | **Se conserva en Normal** (la dificultad por defecto de hoy): sus estrellas pasan a la ronda Normal y su insignia, a plata. El niño sigue en Normal. Nadie pierde nada | Sí |
| P8 | ¿Un indicador de la ronda en la cabecera del juego? | **Sí, discreto:** el color de los puntos de nivel (bronce, plata, oro) dice en qué ronda va, sin texto | No |
| P9 | La versión sin pago de Sombras que se publica ahora (7 niveles sin tiempo), ¿cómo queda? | Se publica tal cual. Al desarrollar esta historia, con P6 (a), el juego gratis sería la ronda Fácil completa (tutorial y niveles con el tiempo de Fácil) y su bronce | No |
| P10 | ¿Cuándo se desarrolla? | **Después de la preview de Sombras y antes de HU-006 (pago):** el pago depende de P6, y cambiar el progreso guardado es más barato con pocos jugadores | No |

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
