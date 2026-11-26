# HU-036 · Juego: Opuestos

| | |
|---|---|
| **Estado** | **Lista (2026-11-25)**: el dueño responde las preguntas el 2026-11-25 (sección 12) |
| **Épica** | E4 · Juegos |
| **Prioridad** | P2 |
| **Tamaño** | M (3 días, 3 entregas) |
| **Depende de** | HU-051 (ocho rondas), HU-039 (movimientos en la cabecera común), HU-022 (mano guía), HU-005 (sonidos), HU-041 («Nuevo»), HU-042 (acceso), HU-023 (tarjeta del menú). Comparte el motor de parejas a la vista con HU-026 («¿Cuántos hay?») |

## 1. Historia

**Como** niño o niña de 3 a 5 años,
**quiero** juntar cada dibujo con su contrario (el sol con la luna, el fuego con la nieve),
**para** aprender las palabras de los contrarios sin necesidad de leerlas.

## 2. Situación actual y qué reutiliza

- Ningún juego empareja cartas **a la vista**. Memoria empareja cartas iguales **boca abajo**; «¿Cuál es diferente?» se juega con un toque en una carta.
- **Se reutiliza:**
  - la cuadrícula de cartas de Memoria (`MemoryBoard`: reparto en filas y columnas en los 4 teléfonos y en las dos orientaciones);
  - la carta de «¿Cuál es diferente?» (`_OddCard`: carta blanca grande con un emoji) y su vaivén suave;
  - la elección con halo ámbar de HU-039 R3 (tocar para elegir, tocar otra vez para soltar);
  - `GameHeader` (ronda, puntos de nivel y movimientos), `RoundLadder`, la barra de tiempo, la celebración, el tutorial con `GestureHint` (gesto `tapThenTap`) y la invitación;
  - el progreso común (`GameProgress`).
- **Es nuevo:** un **motor de parejas a la vista** (`PairBoard` en dominio y `PairBoardView` en presentación), que también usará HU-026. Quien llegue primero lo construye.

## 3. Cómo se juega

### 3.1 El tablero

- Una cuadrícula de **cartas boca arriba**: cada carta tiene un emoji grande. Hay N parejas de contrarios mezcladas.
- En bronce y plata, las cartas van en **dos columnas** (en horizontal, dos filas): a un lado, una de cada pareja; al otro, los contrarios, desordenados. Así el niño solo busca en el otro lado. Desde oro, todas mezcladas en la cuadrícula.

### 3.2 Gestos

- Se **toca una carta** (crece con halo ámbar) y después **su contraria**. Las dos se acercan, se juntan con un saltito y un sonido suave (el de pareja de Memoria, HU-005) y quedan juntas, un poco atenuadas.
- El orden da igual (☀️ y después 🌙, o al revés). Tocar otra vez la carta elegida la suelta; tocar otra carta del mismo lado cambia la elección.
- **Fallo:** si la segunda carta no es la contraria, las dos hacen el vaivén suave y se separan, sin sonido de error. Cuenta como fallo para las estrellas.
- **Movimientos (HU-039):** cada intento de pareja (segunda carta tocada), acierte o no.
- Es un juego **de tocar**: el ajuste «Arrastrar · Tocar · Ambas» no le afecta (HU-039 P5). La zona táctil de cada carta, al menos 64 dp.
- El tablero se supera cuando todas las parejas están juntas.

### 3.3 Mano guía (HU-022)

En el tutorial (nivel 1, dos parejas de bronce), la mano toca ☀️ y después 🌙 (gesto `tapThenTap`); las cartas se juntan. Después, la invitación a jugar.

## 4. Niveles y rondas

### 4.1 Niveles (el 1 es el tutorial)

| Nivel | Parejas | Cartas |
|---|---|---|
| 1 | 2 | 4 |
| 2 | 2 | 4 |
| 3 | 3 | 6 |
| 4 | 3 | 6 |
| 5 | 4 | 8 |
| 6 | 4 | 8 |
| 7 | 5 | 10 |
| 8 | 6 | 12 |

- 12 cartas caben: Memoria ya pone 16 en el compacto (4 × 4).
- **Un tablero por nivel**, como «A su sitio».

### 4.2 Rondas (HU-051)

| Ronda | Qué contrarios (sección 5) | Disposición | Carta sin pareja | Tiempo |
|---|---|---|---|---|
| **Bronce** | Los 4 más claros: día y noche, caliente y frío, grande y pequeño, contento y triste | Dos columnas | No | No |
| **Plata** | + rápido y lento, mayor y bebé | Dos columnas | No | No |
| **Oro** | Los 6 anteriores | Mezcladas | No | Sí |
| **Rubí** | + las variantes (🍦 y ☕, 🐳 y 🐜, 🚀 y 🐌) | Mezcladas | No | Sí |
| **Esmeralda** | + abierto y cerrado, dormido y despierto | Mezcladas | **Sí, una** (P5) | Sí |
| **Zafiro** | Todos los seguros | Mezcladas | Sí, una | Sí |
| **Obsidiana** | Todos los seguros | Mezcladas | Sí, una | Sí |
| **Diamante** | Todos, también los dudosos que pasen la validación (5.2) | Mezcladas | **Hasta dos**, que nunca son contrarias entre sí (P5) | Sí |

- **Tiempo** desde oro: los tiempos de «¿Cuál es diferente?» por tablero, escalados al número de parejas. Propuesta: **12 s por pareja** en oro bajando hasta **6 s por pareja** en diamante (oro 12, rubí 11, esmeralda 10, zafiro 9, obsidiana 7, diamante 6). Se ajusta en el teléfono. «Jugar sin tiempo» (HU-030) lo quita.
- **Carta sin pareja** (P5, 2026-11-25): un dibujo cuyo contrario no está. **Desde esmeralda, una; en diamante, hasta dos.** Las dos de diamante **nunca son contrarias entre sí**: quien ha llegado hasta ahí entendiendo los contrarios sabe que esas dos no van juntas. El tablero se supera sin tocarlas; tocar una y después otra carta cuenta como fallo.
- **Estrellas**, con N parejas: 3★ con N ÷ 2 fallos o menos (redondeando hacia arriba), 2★ hasta N, 1★ con más. Es más estricto que «A su sitio» porque aquí se ve todo.
- **Medalla** al superar el nivel 8 de cada ronda.

## 5. Contenido (Emoji 5.0 o anterior, sin ZWJ)

### 5.1 Parejas candidatas

| # | Contrario | Pareja | Versión de Emoji | Valoración |
|---|---|---|---|---|
| 1 | Día · noche | ☀️ · 🌙 | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 2 | Caliente · frío | 🔥 · ❄️ | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 3 | Grande · pequeño | 🐘 · 🐁 | ≤ 1.0 · ≤ 1.0 | ✅ Clara (el ratón entero 🐁, no la cara 🐭, para comparar cuerpos) |
| 4 | Contento · triste | 😄 · 😢 | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 5 | Rápido · lento | 🐇 · 🐢 | ≤ 1.0 · ≤ 1.0 | ✅ Clara (la liebre y la tortuga) |
| 6 | Mayor · bebé | 👴 · 👶 | ≤ 1.0 · ≤ 1.0 | ✅ Clara («abuelo y bebé») |
| 7 | Caliente · frío (variante) | ☕ · 🍦 | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 8 | Grande · pequeño (variante) | 🐳 · 🐜 | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 9 | Rápido · lento (variante) | 🚀 · 🐌 | ≤ 1.0 · ≤ 1.0 | ✅ Clara |
| 10 | Abierto · cerrado | 📖 · 📕 | ≤ 1.0 · ≤ 1.0 | ⚠️ Para 4–5 años: el libro cerrado es rojo y el abierto blanco; puede verse como «dos libros distintos» |
| 11 | Dormido · despierto | 😴 · 😃 | ≤ 1.0 · ≤ 1.0 | ⚠️ Choca con contento y triste (son caras): nunca en el mismo tablero (5.2) |
| 12 | Ruido · silencio | 📢 · 🤫 | ≤ 1.0 · 5.0 | ⚠️ Dudosa: el megáfono no es un objeto conocido a los 3 años; 🤫 es Emoji 5.0 y se ve |
| 13 | Arriba · abajo | ⬆️ · ⬇️ | ≤ 1.0 · ≤ 1.0 | ⚠️ Dudosa: flechas abstractas; además son iguales giradas. Solo diamante si pasa la validación |
| 14 | Alto · bajo | 🦒 · 🦔 | 5.0 · 5.0 | ⚠️ Dudosa: se confunde con grande y pequeño |
| 15 | Pesado · ligero | 🐘 · 🎈 | ≤ 1.0 · ≤ 1.0 | ❌ Ambigua: el 🐘 ya es «grande» y el globo no se lee como «ligero» |
| 16 | Verano · invierno | 🏖️ · ⛄ | ≤ 1.0 · ≤ 1.0 | ❌ Choca con caliente y frío y con día y noche |
| 17 | Lleno · vacío | — | — | ❌ No hay pareja en Emoji 5.0 (la batería vacía 🪫 es Emoji 14.0) |
| 18 | Limpio · sucio | 🛁 · 🐷 | ≤ 1.0 · ≤ 1.0 | ❌ Necesita contexto («el cerdito en el barro») |

- **Seguras** (1 a 9, y 10 y 11 en esmeralda): entran.
- **Dudosas** (12 a 14): solo en diamante y solo si pasan la validación con niños de 4–5 años (P4). **Descartadas** (15 a 18).
- Los caretos usan el color amarillo por defecto (sin modificador de tono, sin ZWJ).

### 5.2 Reglas del sorteo (que nunca haya dos respuestas posibles)

- **Un contrario por tablero:** nunca 🐘/🐁 con 🐳/🐜 (el 🐘 también podría ir con la 🐜).
- **Conceptos que no conviven en un tablero**, porque se cruzan:
  - día y noche **con** caliente y frío (☀️ podría ir con ❄️);
  - grande y pequeño **con** alto y bajo;
  - contento y triste **con** dormido y despierto, y con ruido y silencio (todos son caras);
  - rápido y lento (🐇/🐢) **con** la variante 🚀/🐌.
- Las mismas reglas valen para las cartas sin pareja: nunca pueden ser contrarias de una carta del tablero **ni entre sí** (en diamante hay dos), ni del mismo concepto cruzado (5.2).
- Todo con test de sorteo (miles de semillas).

## 6. Accesibilidad e idiomas

- **Sin texto para el niño.** El lector de pantalla nombra cada carta («Sol», «Luna») y, al juntar, la pareja («Sol y luna: día y noche»). Las cartas ya juntas se anuncian como «emparejada».
- **Nombre del juego y anuncio de ejemplo:**

| Idioma | Nombre | «Día y noche» |
|---|---|---|
| es | Opuestos | Día y noche |
| en | Opposites | Day and night |
| fr | Contraires | Le jour et la nuit |
| it | Contrari | Giorno e notte |
| de | Gegenteile | Tag und Nacht |
| pt | Opostos | Dia e noite |
| ja | はんたいことば | ひるとよる |
| ko | 반대말 | 낮과 밤 |
| ar | الأضداد | النهار والليل |

- Unas 6 claves + dos `select` (las cartas y los conceptos) por idioma; revisar las traducciones como en HU-052.

## 7. Colores (D-032)

- **Cartas:** blancas con borde teal profundo al 35 %; la elegida, halo ámbar (HU-039 R3); las emparejadas, con el borde dorado al 50 % y el emoji al 60 %.
- **Fondo:** crema cálida. **Sin colores nuevos.**
- **Tarjeta del menú (P6):** ver la nota de P6 en la sección 12.

## 8. Acceso y «Nuevo»

- **Acceso (HU-042):** juego nuevo, del cuarto en adelante: **bronce y plata gratis**; de oro a diamante, Premium o durante una edición especial. En la prueba cerrada, todo gratis (D-040).
- **«Nuevo» (HU-041):** `GameId.opposites` no está en `gamesInRc5`: se destaca tras actualizar, sin código nuevo.

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio común | `lib/domain/pairs/`: `PairBoard` (cartas, parejas, `matches(a, b)`, carta sin pareja), `PairStars` (regla 4.2) y `PairLayout { columns, mixed }`. Lo comparte HU-026 |
| Dominio del juego | `lib/domain/opposites/`: `OppositeCatalog` (tabla 5.1 con conceptos, variantes, estado seguro o dudoso y conflictos de 5.2), `OppositeLadder` (niveles 4.1, `OppositeRules` por ronda y `RoundLadder`), `OppositeBoard.pick(random, level, rules)` |
| Presentación | `PairBoardView` (cuadrícula de Memoria con cartas a la vista, elección ámbar, animación de juntar, vaivén) y `PairGameCubit`/`PairGameState` genéricos, con el cronómetro, la pausa en segundo plano, estrellas, medalla, bajada de nivel y tutorial de los demás juegos. `OppositesGameScreen` |
| Persistencia | `GameId.opposites` en `GameProgressHiveModel` (typeId 5), clave `opposites`: sin tipos nuevos |
| Menú y padres | Tarjeta en `GameCatalog` con icono 3D (P7); «Su progreso» (HU-034) |
| Tests | Catálogo (Emoji 5.0, sin conceptos repetidos), sorteo (ningún tablero con dos respuestas, conflictos de 5.2), estrellas, pantalla (elegir, soltar, fallo, juntar, lector), 12 cartas en el compacto en vertical y horizontal en 9 idiomas |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Motor de parejas a la vista** (dominio y vista genéricos) con tests, sin juego en el menú | Sí: no cambia nada visible |
| 2 | **Opuestos de bronce a zafiro**: catálogo seguro, escalera, pantalla, tutorial, menú, progreso, «Nuevo», 9 idiomas, y la carta sin pareja desde esmeralda | Sí |
| 3 | **Obsidiana y diamante**: las dos cartas sin pareja de diamante y las parejas dudosas que pasen la validación | Sí |

## 11. Tamaño estimado

**3 días:** 1 día el motor de parejas, 1,5 días el juego con su pantalla, textos y menú, y 0,5 días la carta sin pareja y los ajustes. Si HU-026 ya construyó el motor, 2 días.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre del juego en el menú? | ✅ Decidido (2026-11-25): **«Opuestos»** |
| P2 | ¿Las cartas se juntan tocando las dos, o arrastrando una sobre la otra? | ✅ Decidido (2026-11-25): **tocando** |
| P3 | ¿Dos columnas en bronce y plata? | ✅ Decidido (2026-11-25): **sí**; desde oro, mezcladas |
| P4 | ¿Entran las parejas dudosas (12 a 14)? | ✅ Decidido (2026-11-25): **solo en diamante y tras probarlas** con 3–5 niños de 4–5 años |
| P5 | ¿Carta sin pareja? | ✅ Decidido (2026-11-25): **una desde esmeralda; en diamante, hasta dos**, que nunca son contrarias entre sí (4.2 y 5.2) |
| P6 | ¿Color de la tarjeta del menú? | ✅ Decidido (2026-11-25): **crema con borde coral grueso y texto teal profundo**, como todos los juegos nuevos (HU-027 P7) |
| P7 | ¿Icono del juego? | ✅ Decidido (2026-11-25): **ilustración 3D** (D-036) con el prompt de la **pieza 19** de `docs/brand/PROMPTS-identidad.md`: un sol y una luna de plastilina abrazados. La entrega el dueño |
| P8 | ¿Un tablero por nivel o tres, como «¿Cuál es diferente?»? | ✅ Decidido (2026-11-25): **uno** |

## 13. Criterios de aceptación

1. Todas las cartas se ven en Android 8 (emulador `LowEnd_API26`) y en el moto g55.
2. Ningún tablero tiene dos respuestas posibles (test de sorteo con los conflictos de 5.2).
3. Tocar una carta y su contraria las junta con sonido suave; una carta que no es la contraria hace el vaivén, sin sonido de error, y cuenta como fallo y como movimiento.
4. Bronce y plata en dos columnas y sin tiempo; desde oro, mezcladas y con tiempo; una carta sin pareja desde esmeralda y hasta dos en diamante, nunca contrarias entre sí.
5. Ocho rondas, estrellas y medallas como en los otros juegos.
6. El nivel 8 (12 cartas) cabe sin desplazar en el compacto en vertical y horizontal, en 9 idiomas y con el texto al máximo.
7. Sin texto para el niño; el lector nombra cartas y parejas en los 9 idiomas.
8. Se destaca como nuevo tras actualizar; sin Premium, bronce y plata.

## 14. Fuera de alcance

- Decir las palabras en voz alta (D-034).
- Contrarios de posición con escenas (dentro y fuera, encima y debajo): necesitan dibujos propios.
- Más de 6 parejas por tablero.
