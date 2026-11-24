# HU-027 · Juego: Clasificar (por color y por tamaño)

| | |
|---|---|
| **Estado** | **En refinamiento (2026-11-24).** Une HU-027 (clasificar por color) y HU-008 (por tamaño: grande, mediano y pequeño), que queda absorbida aquí |
| **Épica** | E4 · Juegos |
| **Prioridad** | P2 |
| **Tamaño** | M–L (3–4 días, 3 entregas) |
| **Depende de** | HU-052 (el motor de «A su sitio»: bandeja, tarjetas con huecos, arrastre, imán y camino de toques). HU-051 (ocho rondas), HU-039 (arrastrar, tocar o ambas; movimientos), HU-031 (mano izquierda), HU-022 (mano guía), HU-041 («Nuevo»), HU-042 (acceso), HU-023 (quinta tarjeta del menú) |

## 1. Historia

**Como** niño o niña de 2 a 5 años,
**quiero** llevar cada cosa a la cesta que le toca, primero por su color y después por su tamaño,
**para** aprender a agrupar las cosas por lo que tienen en común, que es la base de la lógica.

## 2. Situación actual y qué reutiliza

- **HU-027** (por color) y **HU-008** (por tamaño) eran dos ideas con la misma mecánica: llevar objetos a cestas. Se unen en **un solo juego**: el color en las primeras rondas y el tamaño en las siguientes. HU-008 pasa a «Descartada» (absorbida).
- **«A su sitio» (HU-052) ya tiene casi todo:** sitios arriba (o a un lado) y bandeja abajo, arrastre con el imán de Sombras (`ShadowDrop`), camino de toques de HU-039, mano guía, cronómetro, estrellas por fallos, celebración y progreso común. Una cesta es un **sitio**; un objeto es un **vehículo**.
- **Lo que no sirve tal cual** (visto en el código):
  - `VehicleBoardView` (556 líneas) y `VehicleGameCubit` trabajan con los enums `Vehicle` y `Place`, no con piezas genéricas;
  - cada tarjeta de sitio tiene **2 huecos** (`slotRect` usa `min(index, 1)`), y una cesta necesita **hasta 3**;
  - los emojis de la bandeja se pintan todos del mismo tamaño; aquí el tamaño **es** el dato.
- **Decisión técnica (P3):** generalizar el tablero de «A su sitio» a piezas y destinos genéricos, para que lo usen los dos juegos (y los que vengan, como HU-024). Los tests de «A su sitio» protegen el cambio.

## 3. Cómo se juega

### 3.1 El tablero

- **Arriba (o a la izquierda en horizontal), las cestas:** tarjetas blancas con borde teal y, arriba, un **objeto de muestra** grande. La muestra dice qué va dentro: una 🍓 para lo rojo; un 🐻 grande, mediano o pequeño para cada tamaño. Abajo, **3 huecos** para lo que llega.
- **Abajo (o a la derecha), la bandeja** con los objetos, como en «A su sitio».
- Con la mano izquierda y en horizontal, las cestas pasan al otro lado (HU-031), como en Sombras y «A su sitio».
- El tablero se supera cuando la bandeja queda vacía.

### 3.2 Gestos (HU-039)

- **Arrastrar:** se lleva el objeto a su cesta; encaja con el imán de la ronda.
- **Tocar:** se toca el objeto (crece con halo ámbar) y después su cesta; el objeto vuela hasta ella.
- **Ambas** (por defecto): los dos gestos. Con el lector de pantalla, siempre tocar.
- **Fallo:** el objeto vuelve despacio a la bandeja con el vaivén de Sombras, sin sonido de error, y cuenta como fallo para las estrellas.
- **Movimientos:** cada vez que se suelta o se toca un objeto sobre una cesta, acierte o no (HU-039 sección 8), en la cabecera común `GameHeader`.

### 3.3 Mano guía (HU-022)

En el tutorial (nivel 1), la mano lleva el primer objeto a su cesta: arrastrando en «Ambas» y «Arrastrar», con dos toques en «Tocar». Después, la invitación a jugar (HU-049).

### 3.4 Qué es «tamaño» aquí

- El tamaño se muestra **escalando el mismo emoji** dentro de su celda: **grande 100 %, mediano 70 %, pequeño 45 %**. Cada paso es 1,5 veces el anterior, que se nota a simple vista.
- **Se compara dentro del tablero**, nunca con el mundo real: por eso los tableros de tamaño usan objetos sin un tamaño real marcado (fruta, estrellas, pelotas). **Nunca** un 🐘 pequeño ni un 🐭 grande.
- En cada tablero de tamaño, **cada emoji sale en todos los tamaños de la ronda** (🍎 grande y 🍎 pequeño; ⭐ grande y ⭐ pequeño): así el niño compara la misma cosa y aprende que importa el tamaño, no qué es.
- El pequeño nunca baja de **28 dp** en el teléfono compacto: si no cabe, el tablero pone menos objetos.

## 4. Niveles y rondas

### 4.1 Niveles (el 1 es el tutorial)

| Nivel | Objetos | Cestas con objetos (color) | Cestas (tamaño) | Cesta libre (color, desde esmeralda) |
|---|---|---|---|---|
| 1 | 2 | 2 | 2 | — |
| 2 | 4 | 2 | 2 | — |
| 3 | 5 | 3 | 3 * | — |
| 4 | 6 | 3 | 3 * | +1 |
| 5 | 6 | 4 | 3 * | +1 |
| 6 | 7 | 4 | 3 * | +1 |
| 7 | 8 | 4 | 3 * | +1 |
| 8 | 8 | 4 | 3 * | +1 |

\* En la ronda de oro, el tamaño solo tiene **grande y pequeño** (2 cestas).

- Como mucho **3 objetos por cesta** (los 3 huecos de la tarjeta).
- **Cesta libre:** una cesta de un color que no tiene ningún objeto. Distrae, como el sitio libre de «A su sitio». En tamaño no hay cesta libre: una cesta «mediana» vacía confundiría.

### 4.2 Rondas (HU-051): color primero, tamaño después

| Ronda | Qué se clasifica | Colores / tamaños | Cesta libre | Imán | Disposición | Tiempo |
|---|---|---|---|---|---|---|
| **Bronce** | Color | Rojo, amarillo, verde y azul. En los niveles 1 y 2, la muestra es igual que los objetos (🍓 en la cesta, 🍓 en la bandeja) | No | 40 % | Fija | No |
| **Plata** | Color | Los 4; la muestra **nunca** está en la bandeja (🍓 en la cesta; 🍎 🍒 🍅 en la bandeja) | No | 45 % | Fija | No |
| **Oro** | Tamaño | Grande y pequeño | — | 50 % | Fija | Sí (tabla de Sombras) |
| **Rubí** | Tamaño | Grande, mediano y pequeño | — | 60 % | Fija | Sí |
| **Esmeralda** | Color | Los 4 + naranja y morado (P4). Objetos de la misma clase en colores distintos (🍎 rojo y 🍏 verde) | Sí | 65 % | Fija | Sí |
| **Zafiro** | Tamaño | Tres tamaños, con dos emojis distintos en el tablero | — | 70 % | Fija | Sí |
| **Obsidiana** | Color **o** tamaño, al azar en cada tablero (las cestas dicen cuál) | Todos | Sí, en color | 80 % | Al azar | Sí |
| **Diamante** | Niveles 2–4, como obsidiana. Niveles 5–8, **color y tamaño a la vez**: 4 cestas (2 colores × grande y pequeño) (P5) | 2 colores × 2 tamaños | No | 90 % | Al azar | Sí |

- **Tiempo:** desde oro, con la tabla de tiempos de Sombras, como «A su sitio» (`ShadowLadder.timeLimitsFor`). Bronce y plata, sin tiempo: la muestra gratis es para los más pequeños. «Jugar sin tiempo» (HU-030) lo quita en todas.
- **Estrellas:** como «A su sitio» (`VehicleStars`): con N objetos, 3★ con N fallos o menos, 2★ hasta 2N, 1★ con más.
- **Medalla** al superar el nivel 8 de cada ronda. Si se acaba el tiempo, se baja de nivel con el aviso amable de siempre.
- **Por qué este orden:** el color se ve de un vistazo y lo dominan antes los más pequeños; el tamaño relativo (sobre todo «mediano») llega hacia los 3–4 años. Las rondas mezcladas son para los de 5.

## 5. Contenido (solo Emoji 5.0 o anterior, sin ZWJ, D-024 y D-026)

### 5.1 Por color

| Color | Objetos | Muestra de la cesta |
|---|---|---|
| Rojo | 🍎 🍓 🍒 🍅 🌹 🐞 🎈 🚒 🦀 | 🍓 |
| Amarillo | 🍌 🌽 🍋 🐤 🌻 🧀 ⭐ 🚕 | 🍌 |
| Verde | 🍏 🥦 🥒 🐸 🐢 🌲 🍀 🌵 🥑 🦎 | 🍀 |
| Azul | 💧 🐳 🐬 🐋 👖 🌊 🐟 | 💧 |
| Naranja (desde esmeralda, P4) | 🍊 🥕 🎃 🦊 🏀 | 🍊 |
| Morado (desde esmeralda, P4) | 🍇 🍆 🔮 | 🍇 |

- Versiones: 🥦 es Emoji 5.0; 🥒 🥑 🦎 🦊 🥕 son 3.0; el resto, 0.6–1.0. Ninguno lleva ZWJ.
- **Fuera por color dudoso o variable entre fuentes:** 🍉 (verde y rojo), 🍑, 🐝, 🌈, 🦋, 🐦, 🚙, 💎, 🧢 (azul en unas fuentes, otro color en otras), ☂️ (morado solo en algunas), 🍍. Los corazones (❤️ 💛 💚 💙 💜) son símbolos: no entran como objetos.
- **El azul es el color más corto.** Si al verlos en el emulador con Android 8 alguno cambia de color, se quita; el mínimo para jugar con 4 cestas es de 4 objetos por color.
- **Comprobación obligatoria** (como HU-025): todos en el emulador `LowEnd_API26` y en el moto g55, mirando el color, no solo que se pinten.
- 🎈 y 🚒 también salen en otros juegos: no importa, aquí se miran por su color.

### 5.2 Por tamaño

- **Objetos:** 🍎 🍊 🍋 ⭐ ⚽ 🏀 🎈 🍓 🌻 🍪 🍩 🌸. Formas compactas que se reconocen pequeñas; ninguno tiene un tamaño real que choque.
- **Muestra de las cestas: tres osos 🐻** (grande, mediano y pequeño, como en Ricitos de Oro), y la tarjeta de cada cesta también es grande, mediana o pequeña (P6).
- **Diamante (color y tamaño):** solo parejas de la **misma forma en dos colores**, para que no se mezcle qué es cada cosa: hoy, solo 🍎 y 🍏. Muestras: 🍎 grande, 🍎 pequeña, 🍏 grande y 🍏 pequeña; en la bandeja, las dos manzanas en los dos tamaños. Con una sola pareja la ronda se repite: si se quiere más variedad, se busca otra pareja de la misma forma al validar los emojis (P5).

## 6. Accesibilidad e idiomas

- **Sin texto para el niño** (D-034). La muestra de la cesta lo explica todo.
- **Lector de pantalla** (9 idiomas): cada objeto se nombra con su nombre y, en los tableros de tamaño, su tamaño («Manzana grande»). Cada cesta dice su color o su tamaño y lo que ya tiene («Cesta roja: fresa, tomate»). Al soltar, el resultado («Fresa en la cesta roja»). Los nombres van en mensajes `select`, como en «A su sitio».
- **Nombres del juego y textos clave:**

| Idioma | Nombre del juego | «Cesta roja» | «Grande» · «Mediano» · «Pequeño» |
|---|---|---|---|
| es | Clasificar | Cesta roja | Grande · Mediano · Pequeño |
| en | Sorting | Red basket | Big · Medium · Small |
| fr | Trier | Panier rouge | Grand · Moyen · Petit |
| it | Smistare | Cesto rosso | Grande · Medio · Piccolo |
| de | Sortieren | Roter Korb | Groß · Mittel · Klein |
| pt | Classificar | Cesto vermelho | Grande · Médio · Pequeno |
| ja | なかまわけ | あかいかご | おおきい · ちゅうくらい · ちいさい |
| ko | 분류하기 | 빨간 바구니 | 큰 · 중간 · 작은 |
| ar | التصنيف | سلة حمراء | كبير · متوسط · صغير |

- Las traducciones distintas del español y el inglés se revisan, como en HU-052.
- **Daltonismo:** la cesta no depende solo del color de la muestra: el lector la nombra, y el objeto de muestra es reconocible por su forma. El rojo y el verde nunca son las dos únicas cestas de un tablero (con el lector de pantalla desactivado, un niño daltónico tendría que adivinar): en bronce, el nivel 1 usa rojo y azul, o amarillo y verde.

## 7. Colores (D-032)

- **Cestas:** blanco con borde teal profundo al 35 %; al recibir un objeto, borde ámbar (como los sitios de «A su sitio»).
- **Bandeja:** crema cálida.
- Los colores de las cestas son los **de los emojis de muestra**; **ningún color nuevo** en la interfaz.
- **Tarjeta del menú (P7):** los cuatro juegos ya usan azul petróleo, teal profundo, blanco y ámbar. El coral no sirve para fondo con texto (C4) y el dorado es del progreso.

## 8. Acceso y «Nuevo»

- **Acceso (HU-042):** es el quinto juego. **Bronce y plata gratis** (las rondas de color); de oro a diamante, Premium o durante una edición especial. Mientras dure la prueba cerrada, todo gratis (D-040).
- Sin Premium y fuera de edición, del oro en adelante se juega la plata, conservando lo ganado (como `VehicleLadder.playableRound`).
- **«Nuevo» (HU-041):** `GameId.sorting` no está en `Discovery.gamesInRc5`, así que se destaca solo tras actualizar, hasta abrirlo 3 veces o ganar la plata. Sin código nuevo.

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio | `lib/domain/sorting/`: `SortCatalog` (tablas 5.1 y 5.2, con test de Emoji 5.0 y de que cada objeto tiene **un solo** color), `SortLadder` (tabla 4.1, `SortRules` por ronda con el criterio, el imán de `ShadowRules`, `timed`, `randomLayout` y la cesta libre; `RoundLadder` con los tiempos de Sombras), `SortBoard` (sorteo con semilla y `accepts(basket, piece)`). Reutiliza `VehicleStars` (o se mueve a un `DropStars` común) |
| Motor común | Generalizar `VehicleBoardView` a un `PlaceBoardView` con `BoardPiece { id, symbol, scale }` y `BoardTarget { id, symbol, scale, slots }`: huecos configurables (2 en «A su sitio», 3 aquí) y escala por pieza. `VehicleDrop` pasa a ser el cálculo común de encaje. «A su sitio» se adapta sin cambiar su comportamiento |
| Presentación | `SortGameScreen` y `SortGameCubit`/`SortGameState`, copiando la estructura de `VehicleGameCubit` (cronómetro, pausa en segundo plano, estrellas, medalla, bajada de nivel, tutorial e invitación). `GameHeader` con movimientos |
| Persistencia | `GameId.sorting`, en el progreso común `GameProgressHiveModel` (typeId 5) con la clave `sorting`: sin tipos de Hive nuevos |
| Menú | Tarjeta en `GameCatalog` (quinta: sigue sin scroll, HU-023 R2) con el icono 3D (P8) |
| Zona de Padres | El juego aparece en «Su progreso» (HU-034) con su ronda; sin Premium, solo bronce y plata |
| Textos | Unas 8 claves + dos `select` (objetos y cestas) en los 9 idiomas |
| Tests | Catálogo (Emoji 5.0, un color por objeto, sin objetos dudosos), sorteo con miles de semillas (como mucho 3 por cesta, cesta libre solo donde toca, nunca rojo y verde solos), escalera, pantalla (arrastre, toque, fallo, tamaño mínimo de 28 dp, lector), nivel 8 en el compacto en vertical y horizontal en 9 idiomas, regresión completa de «A su sitio» |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Motor común:** `PlaceBoardView` genérico con huecos y escala; «A su sitio» pasa a usarlo sin cambios visibles (sus tests en verde) | Sí: no cambia nada para el niño |
| 2 | **Clasificar por color** (bronce, plata, esmeralda): dominio, pantalla, menú, progreso, «Nuevo», 9 idiomas. Las rondas de tamaño todavía juegan color | Sí: es la parte gratis |
| 3 | **Tamaño y mezcla** (oro, rubí, zafiro, obsidiana, diamante) | Sí |

## 11. Tamaño estimado

**3–4 días:** 1 día el motor común (el mayor riesgo: tocar un juego que ya funciona), 1,5 días el color con su pantalla, menú y textos, y 1 día el tamaño y la mezcla. Si se copia en vez de generalizar (P3), 0,5 días menos ahora y más deuda después.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre del juego en el menú? | **«Clasificar»**: corto, el adulto entiende qué practica y encaja con «Memoria» y «Sombras». Alternativa: «Colores y tamaños» |
| P2 | ¿Un solo juego para color y tamaño, o dos? | **Uno**, con el color en bronce y plata y el tamaño desde oro (tabla 4.2). Dos juegos casi iguales llenarían el menú y repartirían las medallas |
| P3 | ¿Generalizar el tablero de «A su sitio» o copiarlo? | **Generalizar** (entrega 1): la misma mecánica servirá para HU-024 y otros. Los tests de «A su sitio» cubren la regresión |
| P4 | ¿Entran naranja y morado? | **Sí, desde esmeralda**: con solo 4 colores la ronda se repite. No antes: naranja y rojo se confunden a los 2–3 años |
| P5 | ¿Color y tamaño a la vez en diamante (4 cestas: manzana roja grande, roja pequeña, verde grande, verde pequeña)? | **Sí, solo en diamante y en los niveles 5–8**, y validarlo con niños de 5 años. Si frustra, diamante alterna color y tamaño como obsidiana |
| P6 | ¿Qué muestra en las cestas de tamaño? | **Tres osos 🐻 de tres tamaños, en tarjetas de tres tamaños** (Ricitos de Oro): el tamaño se ve en la muestra y en la propia cesta |
| P7 | ¿Color de la tarjeta del menú? Los cuatro colores con texto ya están usados | **Crema con borde coral grueso y texto teal profundo**: se distingue del fondo por el borde y no añade colores. Se confirma en el teléfono |
| P8 | ¿Icono del juego? | **Ilustración 3D** como los demás (D-036), con un prompt nuevo en `docs/brand/PROMPTS-identidad.md` (tres cestas con frutas de colores). La entrega el dueño; es necesaria para la tarjeta del menú, no para el resto |
| P9 | ¿Tamaños fijos (100 %, 70 %, 45 %)? | **Sí**, y comprobar en el compacto que el pequeño no baja de 28 dp |

## 13. Criterios de aceptación

1. Todos los objetos y muestras se ven en Android 8 y tienen el color de su cesta en el emulador y en el moto g55.
2. Cada objeto tiene **una sola** cesta correcta en cada tablero (test con miles de sorteos).
3. Bronce y plata son de color; oro, rubí y zafiro, de tamaño; obsidiana y diamante, mezclados (tabla 4.2).
4. En los tableros de tamaño, el mismo emoji sale en todos los tamaños de la ronda, y el pequeño mide al menos 28 dp en el teléfono compacto.
5. Arrastrar, tocar y ambas funcionan según el ajuste de HU-039; el lector de pantalla juega tocando.
6. Un objeto en una cesta equivocada vuelve a la bandeja, sin sonido de error, y cuenta como fallo y como movimiento.
7. Ocho rondas, estrellas, medallas y tiempo desde oro, como en «A su sitio»; sin tiempo en bronce y plata.
8. Sin texto para el niño; el lector nombra objetos, tamaños y cestas en los 9 idiomas.
9. «A su sitio» se juega igual que antes (todos sus tests en verde).
10. La tarjeta se destaca como nueva tras actualizar (HU-041), y sin Premium se juegan bronce y plata.

## 14. Fuera de alcance

- Clasificar por forma, por clase (animales y frutas) o por dónde vive: lo cubren «¿Cuál es diferente?» y «A su sitio».
- Dibujos propios de cestas (🧺 es Emoji 11.0 y no se ve en Android 8).
- Clasificar con más de 4 cestas o más de 8 objetos.
- Una edición especial propia.
