# HU-023 · Menú para varios juegos

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-10 sin las respuestas del dueño; preguntas en la sección 8) |
| **Épica** | E4 · Nuevos juegos |
| **Prioridad** | P2: hace falta antes del tercer juego (HU-025) |
| **Tamaño** | M (estimación: 2–3 días) |
| **Depende de** | HU-013 (iconos de los juegos), HU-002 (dorado) y HU-037 (rondas y medallas: decide qué muestra cada botón) |

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

## 5. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | Ninguno, salvo el modelo común de progreso que decida HU-037 (dorado y medalla por juego con una sola interfaz) |
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
| P1 | ¿Cuadrícula de tarjetas o seguir con botones anchos en lista? | **Cuadrícula** (3.1): el icono grande es lo que el niño reconoce y escala a 6 juegos sin scroll | Sí |
| P2 | ¿Orden fijo o el último jugado primero? | **Fijo** (R3) | No |
| P3 | ¿Puede haber juegos enteros de Premium, o todos tienen una parte gratis? | **Todos con una parte gratis** (como D-028): ningún juego aparece cerrado del todo para el niño. Depende de HU-037 P6 | No |
| P4 | ¿Se desarrolla antes o después de HU-037? | **Después:** HU-037 cambia qué muestra cada tarjeta (medalla más alta, dorado sobre tres rondas) y crea el modelo común de progreso | No |
