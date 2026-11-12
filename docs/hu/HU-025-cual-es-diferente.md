# HU-025 · Juego: ¿Cuál es diferente?

| | |
|---|---|
| **Estado** | En curso (desarrollada el 2026-11-11 en `feature/hu-025-odd-one-out`, las 3 entregas; falta el moto g55). Refinamiento cerrado el 2026-11-11 |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: candidato a tercer juego, el más barato de hacer después de Sombras |
| **Tamaño** | M (estimación: 3–4 días) |
| **Depende de** | HU-023 (menú para varios juegos), que hace falta antes del tercer juego. Reutiliza la escalera, las estrellas, el dorado, la dificultad, el tutorial y la celebración de la memoria |

## 1. Historia

**Como** niño de 2 a 5 años,
**quiero** encontrar el objeto que no pertenece al grupo,
**para** aprender a agrupar las cosas por lo que tienen en común.

## 2. Por qué este juego ahora

- **Un solo toque**, como la memoria: se entiende mirando (D-034) y la mano de HU-022 lo enseña sin cambios.
- **Solo emojis** de las temáticas que ya existen (D-024, D-026): no necesita ilustraciones.
- Desarrolla la **categorización**, una habilidad distinta de la memoria (HU-001) y de la forma (HU-007).
- Reutiliza casi todo: escalera con tiempo opcional (HU-001, HU-030), estrellas por fallos (como HU-007 R9), dorado (HU-002), pérdida de logros (D-031), celebración, salida protegida y tiempo diario (HU-009).

## 3. Cómo se juega

- En pantalla, **4 a 6 objetos grandes**: todos de un grupo menos uno.
- El niño **toca el diferente**. Si acierta, el objeto da un saltito de alegría y llega el siguiente tablero. Si falla, el objeto tocado se mueve un poco «no» (sin rojo ni sonido de error) y puede seguir intentándolo.
- Al completar unos tableros (P3), el nivel se supera con la celebración de siempre.

## 4. Escalera propuesta (P2)

| Nivel | Objetos | Qué los hace diferentes | Ejemplo |
|---|---|---|---|
| 1 | 3 | Grupos muy distintos | 🐶 🐱 🚗 |
| 2 | 4 | Grupos muy distintos | 🍎 🍌 🍐 ⚽ |
| 3 | 4 | Grupos cercanos | 🐶 🐮 🐷 🦁 (granja frente a salvaje) |
| 4 | 5 | Grupos cercanos | 🚗 🚌 🚲 🚂 ✈️ (tierra frente a aire) |
| 5 | 6 | Por una característica | 🍓 🍎 🍒 🌶️ 🍅 🍋 (rojos frente a uno amarillo) |

El tiempo, como en la memoria: el nivel 1 sin tiempo y después una serie por dificultad (HU-030). Las ayudas (por ejemplo, que el diferente brille un instante al empezar) solo en Fácil y Normal (HU-030 R10).

## 5. Reglas propuestas

| # | Regla |
|---|---|
| R1 | Botón «¿Cuál es diferente?» en el menú (HU-023), con su icono (HU-013, guía de estilo). |
| R2 | Cada tablero tiene exactamente un objeto diferente, en una posición al azar. |
| R3 | **Acierto:** el objeto salta y se pasa al siguiente tablero. **Fallo:** el objeto tocado hace un pequeño «no», cuenta como fallo y se puede seguir. Sin rojo, sin vibración, sin sonido de error. |
| R4 | Estrellas por nivel según los fallos (como HU-007 R9); el mejor resultado se guarda con su fecha (D-030). |
| R5 | Progreso propio con el formato de la memoria (typeId nuevo), o el modelo común si HU-023 lo decide (HU-007 P8). |
| R6 | Lector de pantalla: cada objeto se anuncia con su nombre; se elige con doble toque. |
| R7 | Sin pantallas ni textos nuevos para el niño: todo se entiende mirando. |

## 6. Encaje

| Decisión | Impacto |
|---|---|
| D-022, D-025 | Sin botones dentro del juego; salida protegida |
| D-024, D-026 | Solo emojis de Emoji 5.0 o anterior; los grupos se validan con un test como las temáticas de la memoria |
| D-028 | Modelo de acceso por decidir (P1) |
| D-030, D-031, D-037 | Estrellas, dorado y pérdida de logros iguales que en la memoria |
| HU-030 | Tiempo por dificultad y ayudas solo en Fácil y Normal |

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `domain/odd_one_out/`: catálogo de grupos (con la categoría de cada emoji), escalera, generador de tableros, estrellas |
| Estado | `OddOneOutCubit` (como `MemoryLadderCubit`) |
| Presentación | Pantalla del juego y su icono; reutiliza encabezado, barra de tiempo, celebración y `GestureHint` |
| Persistencia | Progreso del juego (typeId nuevo o modelo común, P5) |
| Tests | Catálogo (un diferente por tablero, Emoji 5.0), escalera, cubit, widgets, diseño en 9 idiomas |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Modelo de acceso? | ✅ Ver sección 11 (decidido el 2026-11-11) | — |
| P2 | ¿Cuántos niveles y objetos? | ✅ Ver sección 11 (decidido el 2026-11-11) | — |
| P3 | ¿Cuántos tableros por nivel? | **3 tableros por nivel**: uno solo es muy corto para un nivel | No |
| P4 | ¿Las categorías se basan en significado (granja/salvaje) o en rasgos visibles (color, forma)? | **Las dos**, pero los rasgos visibles solo en niveles altos: a los 3 años, el significado se aprende antes | No |
| P5 | ¿Progreso propio o modelo común? | ✅ Cerrada por HU-037 (2026-11-10): **modelo común de progreso**, sin typeId propio | — |

## 9. Fuera de alcance

- Narración que diga el nombre de los objetos (D-034).
- Grupos con imágenes propias (solo emojis).

## 10. Avance del refinamiento (2026-11-10, sin respuestas del dueño)

### 10.1 Encaje con HU-037 y HU-023

- **HU-037** (rondas de dificultad y medallas) cambia P1 y P5: si se acepta, este juego tiene las tres rondas, su tutorial (el nivel 1 de la tabla 4) y el **modelo común de progreso**, sin typeId propio. P1 pasaría a ser la misma regla de Premium que decida HU-037 P6.
- **HU-023** (menú para varios juegos) va antes: con tres juegos, los botones anchos ya no caben en el teléfono compacto en horizontal.

### 10.2 Catálogo de grupos propuesto

Solo emojis de Emoji 5.0 o anterior y sin ZWJ (D-024, D-026); un test lo comprueba como en la memoria y Sombras.

| Grupo | Emojis | Para niveles |
|---|---|---|
| Animales de granja | 🐮 🐷 🐔 🐑 🐴 🐰 | 3 (frente a salvajes) |
| Animales salvajes | 🦁 🐯 🐘 🦒 🐻 🐵 | 3 |
| Animales del agua | 🐟 🐳 🐙 🐢 🦀 | 1, 2 (frente a vehículos o comida) |
| Frutas | 🍎 🍌 🍐 🍇 🍓 🍉 🍒 | 1, 2 |
| Vehículos de tierra | 🚗 🚌 🚲 🚂 🚜 🚒 | 4 (frente a aire) |
| Vehículos de aire | ✈️ 🚁 🚀 🎈 | 4 |
| Ropa | 👕 👖 👗 👟 🎩 👒 | 1, 2 |
| Juguetes y pelotas | ⚽ 🏀 🎈 🎁 | 1, 2 |
| Rojos (rasgo visible) | 🍓 🍎 🍒 🍅 🌶️ 🚒 | 5 (frente a uno amarillo: 🍋 🍌 🌽) |

Notas: se descartaron 🧸 (Emoji 11.0) y 🧦 (Emoji 10.0) por D-026. 🎈 está en dos grupos: el generador nunca los junta en el mismo tablero. La lista final se valida viendo los emojis en el moto g55.

### 10.3 Tableros por nivel (P3)

Con 3 tableros por nivel, un nivel dura unos 30–60 s a los 3 años: lo mismo que un tablero 2×4 de la memoria.

### 10.4 Preguntas que quedan

P1 (modelo de acceso, ahora ligado a HU-037 P6) y P2 (escalera) siguen abiertas y bloquean. P5 se cierra con HU-037.

## 11. El juego con las rondas de HU-037 (avance del 2026-11-11)

### 11.1 Escalera de cada ronda (propuesta para P2)

Cada ronda (Fácil, Normal, Imposible) tiene la misma escalera: un **tutorial** y **4 niveles** con tiempo. Cada nivel son **3 tableros** seguidos (P3); el tiempo es para los tres.

| Nivel | Objetos | Qué los hace diferentes | Fácil | Normal | Imposible |
|---|---|---|---|---|---|
| Tutorial | 3 | Grupos muy distintos (🐶 🐱 🚗) | Sin tiempo | Sin tiempo | Sin tiempo |
| 2 | 4 | Grupos muy distintos | 60 s | 40 s | 25 s |
| 3 | 4 | Grupos cercanos (granja frente a salvaje) | 50 s | 35 s | 20 s |
| 4 | 5 | Grupos cercanos (tierra frente a aire) | 45 s | 30 s | 18 s |
| 5 | 6 | Un rasgo visible (rojos frente a un amarillo) | 40 s | 25 s | 15 s |

Para un adulto, un tablero cuesta 2–3 s: el nivel 5 en Imposible se hace en unos 9 s. Se ajustan jugando, como las de Sombras.

### 11.2 Estrellas, ayudas y Premium

- **Estrellas por nivel** (como HU-007 R9, sobre los 3 tableros): 3★ con como mucho 1 fallo, 2★ con como mucho 3, 1★ con como mucho 6. El tutorial no da estrellas (HU-037 P2).
- **Ayuda** (solo en Fácil y Normal, HU-030 R10): al empezar cada tablero, el objeto diferente da un **saltito** muy breve. En Imposible, no.
- ~~Reparto ≈ 50 % gratis: Fácil completa y media Normal.~~ **Sustituido el 2026-11-11 (P1):** gratis las rondas **Fácil y Normal completas**, con su bronce y su plata; Premium, la ronda **Imposible** con su oro. En estrellas: 24 de 36 ≈ **67 %**. El dueño pide que el reparto sea «un poco más del 50 %» si hace falta, porque lo importante es que el niño **no sienta cortes**: el límite de lo gratis cae siempre al final de una ronda, nunca a mitad.
- **Sin Premium:** al completar Normal, el niño gana la plata y **sigue en Normal** desde su tutorial, igual que tras el oro se sigue en Imposible (HU-037 P4). Para él es el final natural de una ronda, no un corte; nada se ve bloqueado ni invita a comprar. Con Premium, pasa a Imposible. Ver P6.

### 11.3 Icono del juego

Texto para generarlo en la sección 9 de [PROMPTS-identidad.md](../brand/PROMPTS-identidad.md): tres frutas iguales y un objeto distinto, con una silueta compacta para el dorado.

### 11.4 Preguntas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | Reparto gratis y Premium (≈ 50 %) | ✅ Decidido (2026-11-11): **sin cortes antes que un 50 % exacto.** Gratis las rondas Fácil y Normal completas (≈ 67 %); Premium, la ronda Imposible (sección 11.2) | — |
| P2 | Escalera y tiempos | ✅ Decidido (2026-11-11): la escalera y los tiempos de la tabla 11.1, ajustables jugando | — |
| P6 | Mientras no exista el pago, ¿qué pasa al superar la parte gratis de Normal? | ✅ Decidido (2026-11-11): sin Premium, al completar Normal se sigue en Normal desde su tutorial, como tras el oro (sección 11.2) | — |
| P7 | ¿Nombre del juego? | «¿Cuál es diferente?» en español y «Odd one out» en inglés; los otros 7 idiomas con TD-011 | No |
| P8 | ¿Ayuda del saltito también en Normal? | ✅ Decidido (2026-11-12), **distinto de la recomendación:** el saltito de ayuda solo en el **tutorial** (nivel 1) de cada ronda, no en todos los niveles; en Reto máximo, nunca (HU-030 R10) | — |

## 12. Desarrollo

| # | Entrega | Estado | Contenido |
|---|---|---|---|
| 1 | Dominio | ✅ 2026-11-11 | `domain/odd_one_out/odd_one_out.dart`: 10 grupos de emojis (Emoji 5.0, test), generador de tableros con un solo diferente en una posición al azar (R2), escalera por rondas con la tabla 11.1, 3 tableros por nivel (P3), estrellas por fallos (11.2) y la ronda Imposible solo con Premium (P1, P6). Icono del dueño (`docs/brand/fuentes/icono-cual-es-diferente.png`) |
| 2 | Guardado y estado | ✅ 2026-11-11 | **Modelo común de progreso** para los juegos que nacen con las rondas: `GameProgressHiveModel` (typeId 5) en la caja `game_progress`, una clave por juego (P5); la memoria y Sombras siguen en sus modelos por los datos que ya existen. `OddOneOutCubit`: tableros, fallos, el tiempo del nivel para los 3 tableros (no corre mientras el diferente salta), rondas, medallas, bajada de ronda y, sin Premium, se sigue en Normal tras la plata |
| 3 | Pantalla, menú y Zona de Padres | ✅ 2026-11-11 | Tarjetas grandes con el emoji (tope de 220 px físicos); el diferente **salta** al acertar y los demás hacen un **«no»** al fallar, sin rojo ni sonido (R3); **ayuda del saltito** al aparecer cada tablero en Fácil y Normal (P8); mano del tutorial; lector de pantalla con el dibujo (R6); sonidos de HU-005; tercer botón en el menú (blanco con texto teal) con su dorado y su medalla; ronda en la Zona de Padres, con Imposible visible solo con Premium. Textos en 9 idiomas. Diseño del nivel 5 comprobado en 9 idiomas, 4 teléfonos y dos escalas de texto |

## 13. Qué compara cada ronda (análisis del 2026-11-12)

### 13.1 Lo que pide el dueño

Las comparaciones más obvias en **Fácil**, una dificultad un poco mayor en **Normal** y las que piden pensar en **Reto máximo**. El juego tiene que entenderse sin explicaciones (D-034): el niño ve que «uno no es como los otros» y lo toca.

### 13.2 Cómo se percibe la diferencia a cada edad

| Tipo de diferencia | Qué tiene que hacer el niño | Edad a la que suele salir | Ronda |
|---|---|---|---|
| **Idénticos y uno distinto** (🍎🍎🍎🐶) | Ver que tres son la misma figura | Desde los 2 años: es percepción pura | Fácil |
| **Mismo color y uno de otro color** (🍎🍓🍒🍌) | Fijarse en el color, aunque las formas cambien | 2,5–3 años | Fácil |
| **Muy relacionados y uno de otro mundo** (🐮🐷🐔🚗) | Saber que tres son animales y uno un vehículo | 3–4 años | Normal |
| **Misma familia, otra categoría** (🦁🐯🐊🐮: tres de la selva y uno de granja) | Conocer dónde vive cada animal o por dónde va cada vehículo | 4–5 años | Reto máximo |

### 13.3 La escalera resultante

El número de objetos sube con el nivel (3, 4, 4, 5, 6); el **tipo** de comparación lo pone la ronda:

| Nivel | Fácil | Normal | Reto máximo |
|---|---|---|---|
| 1 (tutorial, 3) | Idénticos | Muy distintos | Selva o granja |
| 2 (4) | Idénticos | Muy distintos | Selva o granja |
| 3 (4) | Color | Muy distintos | Tierra o aire |
| 4 (5) | Color | Muy distintos | Selva o granja |
| 5 (6) | Color | Muy distintos | Tierra o aire |

Grupos de color (solo Fácil): rojos 🍎🍓🍒🍅🌶️, amarillos 🍌🍋🍍🌽 y verdes 🍏🥝🍐🥑🥒. En «idénticos», la figura repetida sale de cualquier grupo y la distinta, de otra familia (nunca dos animales). Selva: 🦁🐯🐘🦒🐵🐊 (se cambia el oso 🐻, que no es de selva, por el cocodrilo 🐊).

### 13.4 Preguntas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P9 | ¿Normal solo con «muy distintos», o también mezcla algún «color» en su nivel 5? | **Solo «muy distintos»**: así cada ronda enseña una sola idea y el niño la entiende jugando | No |
| P10 | En Reto máximo, ¿«tierra o aire» es tan claro para un niño como «selva o granja»? | **Probarlo con niños:** si «tierra o aire» confunde (por ejemplo, el cohete 🚀), cambiarlo por «agua o tierra» (🐟🐳🐙 frente a 🐮) | No |
| P11 | ¿Se avisa al adulto, en la Zona de Padres, de qué compara cada ronda? | **Sí, una línea por ronda** en la ayuda de la ronda («Fácil: formas y colores», «Normal: grupos», «Reto máximo: categorías») | No |

### 13.5 Más variedad en Reto máximo y sin repeticiones (decidido el 2026-11-12)

El dueño, jugando tras borrar los datos, vio **el helicóptero tres veces seguidas**. Causas: en Reto máximo solo había dos comparaciones, y el grupo «aire» tenía 3 objetos; nada impedía repetir el diferente del tablero anterior.

| Cambio | Qué hace |
|---|---|
| **Cuatro comparaciones en Reto máximo** | Selva o granja; tierra o aire; **tierra o agua** (coches frente a un barco ⛵🚤🚢, o animales de tierra frente a uno del mar 🐟🐳🐙🐢🦀, en los dos sentidos); **ruedas o alas** (coches frente a 🦋🐦🐝🦆🦅✈️). Cada tablero elige una al azar, **nunca la del tablero anterior** |
| **Sin repeticiones** en todas las rondas | El juego recuerda los **6 últimos objetos** diferentes (y la figura repetida de «idénticos») y no los vuelve a sacar mientras haya otra opción; si no la hay, al menos evita los dos últimos |

Un test genera 90 tableros seguidos en cada ronda y comprueba que el diferente nunca repite el de los dos tableros anteriores, y que Reto máximo nunca repite la comparación seguida y usa las cuatro.

