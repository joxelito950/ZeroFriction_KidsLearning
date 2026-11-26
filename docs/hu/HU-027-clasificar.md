# HU-027 · Juego: Clasificar (por color y por tamaño)

| | |
|---|---|
| **Estado** | **En curso**: preguntas respondidas el 2026-11-24 (sección 12); **las tres entregas en `develop`** (sección 10) con los arreglos de la revisión en el moto g55 (mensaje de victoria propio, objetos que cambian de color con la fuente, objetos que llenan su hueco). Falta: los colores de los emojis en el emulador de Android 8 y en el moto g55, y el nivel 8 de diamante. Une HU-027 (clasificar por color) y HU-008 (por tamaño: grande, mediano y pequeño), que queda absorbida aquí |
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

- **Arriba (o a la izquierda en horizontal), las cestas:** **cestas dibujadas** (asa, borde y pared de mimbre) y, en la pared, una **etiqueta redonda con el objeto de muestra**. La muestra dice qué va dentro: una 🍓 para lo rojo; para cada tamaño, un objeto de la temática del tablero en ese tamaño (sección 5.2). Lo que llega se coloca **dentro**, en 3 huecos sobre el borde: cada objeto queda un tercio por detrás de la pared delantera, como si hubiera caído en la cesta, y se pinta casi del ancho de su hueco para que se vean varios a la vez.
  - **Cambio del 2026-11-26** (decidido por el dueño): un tester no entendía qué era la cesta. Antes era una tarjeta crema con la muestra grande arriba, igual que una pieza de la bandeja, y con los huecos sin dibujar. Visto en el emulador `Medium_Phone_API_37.0`: la cesta se reconoce y lo colocado se ve dentro. «A su sitio» sigue con sus tarjetas.
  - **Ilustración (2026-11-26):** la cesta dibujada con código «se notaba forzada» y no encajaba con la identidad; la sustituye una **cesta de mimbre de plastilina** con rejilla (pieza 21 de `docs/brand/PROMPTS-identidad.md`). La app la pinta entera detrás de los objetos y, recortada desde el borde delantero y con los huecos transparentes, delante de ellos: los objetos asoman casi dos tercios por encima del borde y el resto se ve por los huecos. La muestra va en la placa crema de la ilustración. Cuando el objeto arrastrado encajaría, un halo ámbar detrás de la cesta. Vista en el emulador con 2 y 3 cestas. En el moto g55, un emoji plano como 🐟 quedaba tapado por la cuerda delantera: los objetos ahora se hunden solo una quinta parte de su hueco y asoman cuatro quintos.
- **La muestra no es una pista** (P6, 2026-11-24): fuera del tutorial y de los niveles 1 y 2 de bronce, la muestra **nunca** es uno de los objetos de la bandeja. Las ayudas solo van en el tutorial y en la ronda base (la misma regla de HU-026 P5).
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
| **Obsidiana** | **Color y tamaño a la vez** (P5): 4 cestas, 2 colores × grande y pequeño | 2 colores × 2 tamaños | No | 80 % | Al azar | Sí |
| **Diamante** | Color y tamaño a la vez, **alternando la pareja de tamaños** por nivel: grande y pequeño (niveles 2, 5), grande y mediano (3, 6), mediano y pequeño (4, 7). Nivel 8: se analiza (4.3) | 2 colores × 2 tamaños | No | 90 % | Al azar | Sí |

- **Tiempo:** desde oro, con la tabla de tiempos de Sombras, como «A su sitio» (`ShadowLadder.timeLimitsFor`). Bronce y plata, sin tiempo: la muestra gratis es para los más pequeños. «Jugar sin tiempo» (HU-030) lo quita en todas.
- **Estrellas:** como «A su sitio» (`VehicleStars`): con N objetos, 3★ con N fallos o menos, 2★ hasta 2N, 1★ con más.
- **Medalla** al superar el nivel 8 de cada ronda. Si se acaba el tiempo, se baja de nivel con el aviso amable de siempre.
- **Por qué este orden:** el color se ve de un vistazo y lo dominan antes los más pequeños; el tamaño relativo (sobre todo «mediano») llega hacia los 3–4 años. Las rondas mezcladas son para los de 5.
- **Diamante con «mediano»** es lo más difícil del juego: grande y mediano (o mediano y pequeño) se distinguen por un solo paso de 1,5 veces. Se valida con niños de 5 años; si frustra, el mediano vuelve a salir solo en grande y pequeño.

### 4.3 Nivel 8 de diamante: los 3 tamaños y todos los colores (a analizar)

Propuesta del dueño (P5, 2026-11-24): el último nivel con **los 3 tamaños y todos los colores**, y los objetos **van apareciendo** en la bandeja a medida que el niño clasifica otro.

Análisis:
- **Todas las combinaciones no caben:** 6 colores × 3 tamaños son 18 cestas, y en el teléfono compacto caben como mucho 6 tarjetas legibles (2 filas de 3) con el pequeño a 28 dp.
- **Propuesta viable:** **6 cestas** (2 colores × 3 tamaños) y una **bandeja que se repone**: hay 3 o 4 objetos a la vista y, al clasificar uno, entra otro, hasta 12. Los **2 colores cambian en cada partida**, así que a lo largo de la ronda salen todos.
- **Alternativa más ambiciosa:** 3 cestas de tamaño y 6 de color en dos pasos (cada objeto primero a su tamaño y después a su color). Es otra mecánica: no entra en esta historia.
- **Qué hay que medir** (entrega 3): que 6 tarjetas con su muestra y 3 huecos quepan en el compacto en vertical y en horizontal; que la bandeja que se repone no confunda (el objeto nuevo entra despacio, con el mismo vuelo de vuelta a la bandeja); y el tiempo, que se cuenta por objeto.
- **Decisión:** se construye la propuesta viable detrás de la regla del nivel 8; si no cabe o frustra, el nivel 8 es como el 5.

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

- **Cada tablero de tamaño tiene una temática**, y la muestra de las cestas es de esa temática (P6, 2026-11-24). La muestra sale en sus tres tamaños, en tarjetas también de tres tamaños, y **no está entre los objetos de la bandeja**:

| Temática | Objetos de la bandeja | Muestra de las cestas |
|---|---|---|
| Animales | 🐶 🐱 🐰 🐤 🐟 🐞 🐢 🐸 | 🐻 (los tres osos, como en Ricitos de Oro) |
| Frutas | 🍊 🍋 🍓 🍐 🍌 🍑 | 🍎 |
| Vehículos | 🚕 🚒 🚌 🚜 🚲 🚀 | 🚗 |
| Variados (al azar) | ⭐ ⚽ 🏀 🎈 🌻 🍪 🍩 🌸 | Un objeto igual en los tres tamaños que no esté en la bandeja (por ejemplo, 🔵 o 🌙) |

- Se compara dentro del tablero: el mismo emoji sale en todos los tamaños de la ronda, así que un 🐶 pequeño y un 🐶 grande no chocan con el mundo real. Se mantiene la regla de no poner animales de tamaño real muy marcado (🐘, 🐭, 🐳).
- Los objetos nuevos (🐰 🐢 🚌 🚜 🚲 🚀 🍑 🔵) se comprueban en el emulador con Android 8, como el resto.
- **Obsidiana y diamante (color y tamaño):** la muestra de cada cesta es un objeto de **ese color** en **ese tamaño**, que no está en la bandeja (🍓 grande para «rojo grande»). En la bandeja, objetos de los dos colores, cada uno en los dos tamaños del nivel (🍎 grande y 🍎 pequeño, 🍌 grande y 🍌 pequeño). Así ya no hace falta la pareja 🍎/🍏 de la misma forma, y hay variedad para todos los colores.

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

- **Cestas:** la ilustración de mimbre (pieza 21), con placa crema y borde teal para la muestra. Cuando el objeto arrastrado encajaría, un **halo ámbar** detrás (el borde ámbar de «A su sitio» no se vería sobre el mimbre). La interfaz no gana colores nuevos (2026-11-26).
- **Bandeja:** crema cálida.
- Los colores de las cestas son los **de los emojis de muestra**; **ningún color nuevo** en la interfaz.
- **Tarjeta del menú (P7, decidido el 2026-11-24):** **crema con borde coral grueso y texto teal profundo.** Los cuatro juegos ya usan azul petróleo, teal profundo, blanco y ámbar; el coral no sirve para fondo con texto (C4) y el dorado es del progreso. Es el color de los juegos nuevos (HU-026, HU-036, HU-056), con el icono como diferencia. Se confirma en el teléfono.

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
| Menú | Tarjeta en `GameCatalog` (quinta: sigue sin scroll, HU-023 R2) con el icono 3D (P8, pieza 18 de `docs/brand/PROMPTS-identidad.md`, `assets/brand/sorting_icon.png`) |
| Zona de Padres | El juego aparece en «Su progreso» (HU-034) con su ronda; sin Premium, solo bronce y plata |
| Textos | Unas 8 claves + dos `select` (objetos y cestas) en los 9 idiomas |
| Tests | Catálogo (Emoji 5.0, un color por objeto, sin objetos dudosos), sorteo con miles de semillas (como mucho 3 por cesta, cesta libre solo donde toca, nunca rojo y verde solos), escalera, pantalla (arrastre, toque, fallo, tamaño mínimo de 28 dp, lector), nivel 8 en el compacto en vertical y horizontal en 9 idiomas, regresión completa de «A su sitio» |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Motor común:** `PlaceBoardView` genérico con huecos y escala; «A su sitio» pasa a usarlo sin cambios visibles (sus tests en verde). **Hecha el 2026-11-24:** `PlaceBoardView`/`PlaceBoardGeometry` (de 1 a 3 huecos, escala por pieza y por cesta), `PlaceDrop` común, `VehicleBoardView` como adaptador con las mismas claves; la regla de ayudas `Helps` (la mano solo en el tutorial y en bronce, en los cuatro juegos); los iconos de «Clasificar» y «¿Cuántos hay?» preparados. 2279 tests en verde y prueba rápida en los emuladores de Android 8.0 y API 37 | Sí: para el niño solo cambia que la mano no sale desde plata |
| 2 | **Clasificar por color** (bronce, plata, esmeralda): dominio, pantalla, menú, progreso, «Nuevo», 9 idiomas. Las rondas de tamaño todavía juegan color. **Hecha el 2026-11-25** en `feature/hu-027-2-color`: 42 objetos en 6 colores, la muestra igual solo en los niveles 1 y 2 de bronce, la tarjeta crema con borde coral, 2342 tests en verde y prueba rápida en los emuladores de Android 8.0 y API 37. **Falta mirar los colores de los emojis** en el emulador de Android 8 y en el moto g55 (criterio 1) | Sí: es la parte gratis |
| 3 | **Tamaño y mezcla** (oro, rubí, zafiro, obsidiana, diamante), con las muestras por temática. El nivel 8 de diamante (4.3), detrás de su regla: si no cabe, como el 5. **Hecha el 2026-11-25** en `feature/hu-027-3-size`: temáticas con su muestra fuera de la bandeja, cestas de tres tamaños, color y tamaño desde obsidiana, la pareja de tamaños de diamante y el nivel 8 con 6 cestas y una bandeja de 4 que se repone hasta 12 (tiempo × 1,5). El tablero común reparte el espacio para que el objeto pequeño no baje de 28 dp y mide el encaje con el tamaño visible del objeto. Medido en tests: los tableros más grandes caben en el compacto en vertical y horizontal en los 9 idiomas, con el pequeño a 28 dp o más. 2418 tests en verde | Sí |

## 11. Tamaño estimado

**3–4 días:** 1 día el motor común (el mayor riesgo: tocar un juego que ya funciona), 1,5 días el color con su pantalla, menú y textos, y 1 día el tamaño y la mezcla. Si se copia en vez de generalizar (P3), 0,5 días menos ahora y más deuda después.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre del juego en el menú? | ✅ Decidido (2026-11-24): **«Clasificar»** |
| P2 | ¿Un solo juego para color y tamaño, o dos? | ✅ Decidido (2026-11-24): **uno**, con el color en bronce y plata y el tamaño desde oro (tabla 4.2) |
| P3 | ¿Generalizar el tablero de «A su sitio» o copiarlo? | ✅ Decidido (2026-11-24): **generalizar** (entrega 1) |
| P4 | ¿Entran naranja y morado? | ✅ Decidido (2026-11-24): **sí, desde esmeralda** |
| P5 | ¿Color y tamaño a la vez? | ✅ Decidido (2026-11-24): **desde obsidiana.** En diamante se alterna la pareja de tamaños (grande y pequeño, grande y mediano, mediano y pequeño). El nivel 8 con los 3 tamaños, todos los colores y una bandeja que se repone **se analiza** (4.3) |
| P6 | ¿Qué muestra en las cestas de tamaño? | ✅ Decidido (2026-11-24): **un objeto de la temática del tablero**: osos 🐻 para animales, 🍎 para frutas, 🚗 para vehículos y un objeto igual para los variados. **Nunca uno de la bandeja**, para que no sea una ayuda fuera del tutorial y de bronce (5.2) |
| P7 | ¿Color de la tarjeta del menú? | ✅ Decidido (2026-11-24): **crema con borde coral grueso y texto teal profundo**, para todos los juegos nuevos. Se confirma en el teléfono |
| P8 | ¿Icono del juego? | **Ilustración 3D** (D-036) con el prompt de la **pieza 18** de `docs/brand/PROMPTS-identidad.md`: tres cestas de tres tamaños y colores con sus pelotas. **Recibido el 2026-11-24** (`docs/brand/fuentes/icono-clasificar.png` → `assets/brand/sorting_icon.png`) |
| P9 | ¿Tamaños fijos (100 %, 70 %, 45 %)? | ✅ Decidido (2026-11-24): **sí**, y comprobar en el compacto que el pequeño no baja de 28 dp |

## 13. Criterios de aceptación

1. Todos los objetos y muestras se ven en Android 8 y tienen el color de su cesta en el emulador y en el moto g55.
2. Cada objeto tiene **una sola** cesta correcta en cada tablero (test con miles de sorteos).
3. Bronce y plata son de color; oro, rubí y zafiro, de tamaño; obsidiana y diamante, color y tamaño a la vez, con la pareja de tamaños alternando en diamante (tabla 4.2).
3b. Fuera del tutorial y de los niveles 1 y 2 de bronce, la muestra de una cesta nunca está en la bandeja; las de tamaño son de la temática del tablero.
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
