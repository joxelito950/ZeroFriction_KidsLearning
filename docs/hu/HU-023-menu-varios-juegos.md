# HU-023 · Menú para varios juegos

| | |
|---|---|
| **Estado** | **Desarrollada** (2026-11-18, rama `feature/hu-023-menu-grid`). Falta verla en el moto g55. Primera pieza del próximo release a la prueba cerrada |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: **condición para empezar el cuarto juego** (decidido el 2026-11-11). El tercero (HU-025) cabe aún en la lista de botones anchos |
| **Tamaño** | M (estimación: 2–3 días) |
| **Depende de** | HU-013 (iconos de los juegos), HU-002 (dorado) y HU-037 (rondas y medallas: decide qué muestra cada botón), las tres hechas |

## 1. Historia

**Como** niño o niña de 2 a 5 años,
**quiero** ver todos los juegos de un vistazo y reconocer cada uno por su dibujo,
**para** elegir a qué jugar sin saber leer.

**Como** madre, padre o adulto a cargo,
**quiero** que el menú siga siendo sencillo aunque haya muchos juegos,
**para** que el niño no se pierda ni se frustre con lo que todavía no puede abrir.

## 2. Situación actual (2026-11-10)

- El menú tiene **dos botones anchos**, uno debajo del otro: «Memoria» (azul petróleo) y «Sombras» (teal profundo, HU-007), cada uno con su icono 3D, su dorado líquido y su medalla. Debajo, «Zona de padres» y «Salir».
- En vertical, el logo va arriba y los botones debajo; en horizontal, lado a lado. Con dos juegos todo cabe sin scroll en los 4 teléfonos de los tests, en 9 idiomas y con el texto ampliado.
- Con un tercer juego (HU-025), en el teléfono compacto en horizontal los botones anchos ya no caben sin scroll: el alto útil ronda 330 dp.
- No hay nada bloqueado en el menú: Premium no existe todavía (HU-006).

### 2.1 Actualización (2026-11-18)

- Hoy hay **tres botones anchos**: Memoria, Sombras y ¿Cuál es diferente? En horizontal, el logo va a la izquierda y los tres botones llenan el alto a la derecha: **un cuarto no cabe** sin scroll.
- HU-037 y HU-051 ya están hechas: los juegos comparten `GameId` y `GameProgress`, y cada botón muestra la medalla más alta de las ocho rondas (bronce a diamante), redonda y llenando su círculo blanco (HU-048 sección 8).
- HU-041 dejó las bases para destacar un juego nuevo (`Discovery`): la etiqueta «Nuevo» irá en la tarjeta (R7).

## 3. Propuesta

### 3.1 Cuadrícula de tarjetas grandes

- Cada juego es una **tarjeta cuadrada** con su icono grande (el dibujo es lo que el niño reconoce), el nombre debajo en letra pequeña para el adulto y el dorado llenando la tarjeta de abajo arriba (HU-002 R16).
- **Columnas según el ancho:** 2 en vertical en un teléfono; 3 o 4 en horizontal y en tablets (TD-010). Con 2 juegos, la cuadrícula se ve igual que dos botones grandes lado a lado.
- **Sin scroll hasta 6 juegos** en los teléfonos de referencia; con más, la cuadrícula se desplaza en vertical (el niño ya sabe hacerlo en otras apps) y el logo se encoge.
- La **medalla** (o la más alta de HU-037) va en una esquina de la tarjeta, sobre un círculo blanco.
- «Zona de padres» y «Salir» se quedan fuera de la cuadrícula, pequeños, como hoy.

### 3.2 Orden de los juegos

Fijo, en el orden en que llegaron (Memoria, Sombras, ¿Cuál es diferente?…). Un orden que cambia (por ejemplo, el último jugado primero) confunde a un niño que busca su juego por la posición (P2).

### 3.3 Premium en el menú (cuando exista, HU-006)

Lo que todavía no se puede abrir **no se esconde ni se tacha**: la tarjeta se ve igual y lleva un **candado sutil** en la esquina. Al tocarla, el juego se abre en lo gratuito (como Sombras hoy). Nada invita al niño a comprar ni abre la tienda (D-029, política de Familias). Si un juego entero fuera Premium (P3), su tarjeta mostraría el candado y, al tocarla, una animación suave de «cerrado», sin texto.

## 4. Reglas (borrador)

| # | Regla |
|---|---|
| R1 | Cada juego es una tarjeta con su icono, su nombre, su dorado y su medalla. Toda la tarjeta se puede tocar. |
| R2 | Hasta 6 juegos caben sin scroll en los 4 teléfonos de los tests, en 9 idiomas y con el texto ampliado (TD-007). |
| R3 | El orden de los juegos es fijo. |
| R4 | El lector de pantalla lee el nombre del juego y su dorado («Memoria, 40 % dorado»), como hoy. |
| R5 | La entrada a la Zona de padres sigue fuera de la cuadrícula, con su doble toque (HU-004 R1). |
| R6 | Añadir un juego nuevo es añadir una entrada a una lista (nombre, subtítulo, icono, pantalla y progreso): el menú no se reescribe con cada juego. |
| R7 | Un juego nuevo lleva la etiqueta «Nuevo» en su tarjeta hasta abrirlo por tercera vez o superar la ronda plata (HU-041 R4). |
| R8 | Un juego en edición especial lleva su adorno de temporada en una esquina de la tarjeta, sin texto ni precio (HU-042 R3, R4). |
| R9 | Colores (D-032): cada tarjeta conserva el color de su botón actual (azul petróleo, teal profundo, blanco) con su onda de arena y su dorado; la medalla, sobre el círculo blanco; la etiqueta «Nuevo», en ámbar con texto teal profundo. Sin colores nuevos. |

## 5. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | Ninguno: el modelo común de progreso ya existe (`GameId`, `GameProgress`, HU-037) y `Discovery` (HU-041) dice qué es nuevo |
| Presentación | `GameCatalog`: la lista de juegos (R6). `GameCard` reutiliza `GameIcon` y `LiquidGold`. `MainMenuScreen` pasa a una cuadrícula adaptable |
| Tests | Diseño con 2, 3 y 6 juegos en los 4 teléfonos, 9 idiomas y dos escalas de texto; orden fijo; lector de pantalla |

## 6. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| HU-001 R1 (un botón por juego) | Se mantiene la idea: una tarjeta por juego |
| HU-002 R16 (dorado en todo el botón) | El dorado llena la tarjeta |
| HU-007 P8 / HU-037 | El modelo común de progreso simplifica R6 |
| D-028, D-029 | Candado sutil, sin invitar a comprar (3.3) |
| TD-010 | Las columnas crecen en tablets |

## 7. Ejemplo

Teléfono en vertical, 3 juegos: dos tarjetas en la primera fila (Memoria y Sombras) y una centrada debajo (¿Cuál es diferente?). En horizontal: el logo a la izquierda y las tres tarjetas en una fila a la derecha.

## 8. Preguntas y decisiones

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Cuadrícula de tarjetas o seguir con botones anchos en lista? | ✅ Decidido (2026-11-18): **cuadrícula** (3.1): el icono grande es lo que el niño reconoce y escala a 6 juegos sin scroll | — |
| P2 | ¿Orden fijo o el último jugado primero? | ✅ Decidido (2026-11-18): **fijo** (R3), en el orden en que llegaron los juegos | — |
| P3 | ¿Puede haber juegos enteros de Premium, o todos tienen una parte gratis? | ✅ Respondida por HU-037 P6 (2026-11-10): **sí habrá juegos enteros de Premium** (a partir del cuarto). Su tarjeta se ve igual, con el candado sutil; si hay una edición especial gratis (HU-042), sin candado mientras dure. Al tocar un juego cerrado: una animación suave de «cerrado», sin texto ni tienda (3.3) | — |
| P4 | ¿Se desarrolla antes o después de HU-037? | ✅ Cerrada (2026-11-18): **ya no aplica**. HU-037 está hecha (y HU-051 amplió las rondas a ocho): se desarrolla después, sobre su modelo común de progreso, como se recomendaba. No se absorbió: HU-037 no tocó la forma del menú | — |

## 9. Desarrollo (2026-11-18)

- **`GameCatalog`** (`widgets/game_catalog.dart`, R6): la lista de juegos en orden fijo (R3). Cada entrada lleva el título, el icono, la escalera de rondas (dorado y estrellas), los colores y la pantalla que abre. Añadir un juego es añadir una entrada.
- **`GameGrid` y `GridFit`** (`widgets/game_grid.dart`): eligen las columnas que dejan las tarjetas más grandes en el espacio que queda.
  - Tamaño: de 96 a 200 dp por tarjeta.
  - En vertical, al menos 2 columnas.
  - Con 3 juegos: dos arriba y uno centrado debajo.
  - Si las tarjetas tuvieran que bajar de 96 dp, la cuadrícula se desplaza (red de seguridad de R2).
  - En árabe, de derecha a izquierda.
- **Tarjeta (R1):**
  - icono grande;
  - nombre debajo, en letra de hasta 1,6 veces con el texto del sistema al máximo;
  - dorado de abajo arriba;
  - medalla más alta en la esquina, sobre el círculo blanco;
  - se puede tocar entera;
  - el lector de pantalla anuncia el nombre y el dorado (R4).
- **Menú sin subtítulos:** se quitan las 3 claves de subtítulo de los 9 idiomas. La flecha también desaparece, porque toda la tarjeta se toca.
- **Icono de «A su sitio»** preparado (`assets/brand/vehicles_icon.png`, prompt 16), para cuando llegue el juego.
- **Tests:**
  - el menú cabe sin desplazarse en los 4 teléfonos, los 9 idiomas y las dos escalas de texto, con tarjetas de 96 dp o más;
  - el orden se invierte en árabe;
  - `GridFit` con 3 y 6 juegos;
  - la red de seguridad del desplazamiento;
  - el catálogo.
- **Queda para el resto del release:** la etiqueta «Nuevo» (R7, con HU-041) y el adorno de edición (R8, con HU-042), cuando llegue el cuarto juego.
