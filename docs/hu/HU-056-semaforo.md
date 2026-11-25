# HU-056 · Juego: Semáforo

| | |
|---|---|
| **Estado** | **Lista (2026-11-25)**: el dueño responde las preguntas el 2026-11-25 (sección 12). Es el juego B de HU-052 (sección 3), que pasa a tener su propia historia |
| **Épica** | E4 · Juegos |
| **Prioridad** | P2 |
| **Tamaño** | L (5–6 días, 3 entregas) |
| **Depende de** | HU-052 (catálogo de vehículos y sus nombres en 9 idiomas). HU-051 (ocho rondas), HU-039 (movimientos), HU-031 (mano izquierda), HU-022 (mano guía), HU-005 (sonidos), HU-041 («Nuevo»), HU-042 (acceso), HU-023 (tarjeta del menú). Una decisión de colores nueva (P2) |

## 1. Historia

**Como** niño o niña de 3 a 5 años al que le encantan los coches,
**quiero** hacer cruzar los coches cuando el semáforo se pone verde,
**para** aprender a esperar mi momento (control de impulsos) y lo que significan los colores del semáforo.

## 2. Situación actual y qué reutiliza

- Todos los juegos de hoy son de **buscar y colocar**; ninguno pide **esperar**. Es una mecánica nueva: el tiempo corre solo y el niño tiene que elegir **cuándo** tocar, no **qué**.
- **Se reutiliza:**
  - los emojis de coches y sus nombres para el lector de pantalla (`Vehicle` de HU-052, mensajes `select` ya traducidos);
  - `GameHeader` (ronda, puntos de nivel, movimientos), `RoundLadder`, la barra de tiempo, la celebración, la invitación, `GestureHint` (toque) y los sonidos suaves (HU-005);
  - el progreso común (`GameProgress`), `Discovery` (HU-041) y el acceso (`playableRound` como «A su sitio»).
- **Es nuevo:** el ciclo del semáforo con reloj inyectable, la calle animada con coches que cruzan, el semáforo dibujado y los patitos que cruzan en rojo.

## 3. Cómo se juega

### 3.1 El tablero

- **Una calle ancha** que cruza la pantalla de lado a lado (en vertical, en la franja central; en horizontal, ocupa casi todo el alto).
- **A un lado, la fila de coches** esperando; **al otro, un aparcamiento** con un hueco por coche.
- **Un semáforo grande** dibujado (no el emoji 🚦, que es pequeño y no puede encender una luz) junto a la línea de espera, al lado contrario de la mano que juega (HU-031), para que el dedo no lo tape.
- **Arriba, un paso de cebra**: en rojo, una familia de **patitos 🦆** lo cruza despacio. Dan una razón para esperar sin palabras.
- Los emojis de coche miran a la izquierda en casi todas las fuentes: los coches van **de derecha a izquierda**, con la fila a la derecha, donde la mano derecha llega. Con la mano izquierda, todo se refleja (coches reflejados con `Transform`, fila a la izquierda). En árabe no cambia: la dirección depende de la mano, no del sentido de lectura (como Sombras).

### 3.2 Gestos

- **Tocar en verde** (en cualquier coche de la fila): el **primer coche** arranca, cruza en 1,2 s con un «brum» suave y aparca. Cada toque, un coche; entre salidas, 0,6 s.
- **Tocar en rojo:** **no pasa nada malo.** El coche no se mueve, el semáforo parpadea suave dos veces y los patitos siguen. Sin sonido (HU-005: nunca ante un error).
- **Un coche que ya ha salido termina de cruzar** aunque la luz cambie: nunca hay un frenazo ni un coche a medias. Los patitos solo empiezan a cruzar con la calle vacía: **nunca** se ve un coche cerca de un patito.
- **Toques seguidos en un mismo rojo:** a partir del tercero, no cuentan (ni para estrellas ni para movimientos) y el semáforo hace un pulso lento, como una respiración. Así aporrear no hunde la partida.
- **Movimientos (HU-039):** cada toque en un coche, en verde o en rojo (salvo los del punto anterior).
- Es un juego **de tocar**: el ajuste «Arrastrar · Tocar · Ambas» no le afecta (P4).
- El tablero se supera cuando todos los coches están aparcados.

### 3.3 Mano guía (HU-022)

En el tutorial (nivel 1), la mano **espera quieta y abierta** junto a la fila mientras la luz está en rojo y **toca en cuanto se pone verde**. Lo hace dos veces. Es la única forma de enseñar «esperar» sin palabras.

### 3.4 Cómo se mantiene tranquilo

- **El rojo nunca castiga:** no hay vidas, ni pitidos, ni coches que se choquen, ni tiempo que se pierda.
- **Las luces cambian despacio** y con un fundido de 300 ms; el ámbar avisa (desde oro).
- **Anillo de espera** (bronce a rubí): alrededor de la luz roja, un anillo que se vacía muy despacio enseña cuánto falta. Esperar es más fácil si se ve el final.
- **Sonidos suaves:** «brum» al arrancar, una campanita al aparcar, la celebración. Ningún sonido de sirena ni de claxon.
- Con «reducir animaciones», los coches cruzan igual (es el juego), pero sin rebotes ni parpadeos: el semáforo cambia sin fundido.
- Con la capa cálida de la noche (HU-038), igual que los demás juegos.

## 4. Niveles y rondas

### 4.1 Niveles (el 1 es el tutorial)

| Nivel | Coches |
|---|---|
| 1 | 2 |
| 2 | 3 |
| 3 | 3 |
| 4 | 4 |
| 5 | 4 |
| 6 | 5 |
| 7 | 5 |
| 8 | 6 |

### 4.2 Rondas (HU-051): qué crece

| Ronda | Verde | Rojo | Ámbar | Anillo de espera | Distracciones | Carriles | Tiempo |
|---|---|---|---|---|---|---|---|
| **Bronce** | 5 s | 3 s, fijo | No | Sí | Patitos | 1 | No |
| **Plata** | 4 s | 4 s, fijo | No | Sí | Patitos | 1 | No |
| **Oro** | 4 s | 4–5 s | 1 s | Sí | Patitos | 1 | Sí |
| **Rubí** | 3,5 s | 4–6 s, al azar | 1 s | Sí | + un pájaro 🐦 o una mariposa 🦋 que pasan | 1 | Sí |
| **Esmeralda** | 3 s | 3–6 s | 1 s | No | + una pelota ⚽ que rueda por la acera | 1 | Sí |
| **Zafiro** | 3 s | 3–7 s | 1 s | No | Las tres | 1 | Sí |
| **Obsidiana** | 2,5 s | 3–7 s | 1 s | No | Las tres | **2**, cada uno con su semáforo, desfasados | Sí |
| **Diamante** | 2 s | 3–8 s | 1 s | No | Las tres | 2 | Sí |

- **Con 2 carriles** hay dos filas y dos semáforos: el niño tiene que mirar cuál está en verde (atención dividida). Nunca están los dos en verde a la vez durante más de 1 s.
- **El ámbar** cuenta como rojo: tocar en ámbar no mueve el coche (P3).
- **Las distracciones** nunca cambian el semáforo ni se pueden tocar: solo pasan. Tocarlas no cuenta.
- **Tiempo** desde oro, como en los demás juegos, pero **calculado con el ciclo**: el límite es el tiempo de los ciclos que hacen falta para todos los coches, por 1,5 en oro y por 1,2 en diamante. Así siempre sobra al menos un ciclo entero. «Jugar sin tiempo» (HU-030) lo quita.
- **Estrellas** (P5), contando como «prisa» cada toque en rojo o ámbar (salvo los toques seguidos que no cuentan): con N coches, 3★ con N ÷ 2 prisas o menos (redondeando hacia arriba), 2★ hasta N, 1★ con más.
- **Medalla** al superar el nivel 8 de cada ronda. Si se acaba el tiempo, se baja de nivel con el aviso amable de siempre.
- **El ciclo es determinista** con la semilla del tablero: los tests y la mano guía saben cuándo cambia la luz.

## 5. Contenido (Emoji 5.0 o anterior, sin ZWJ)

- **Coches:** 🚗 🚕 🚙 🚌 🚓 🚑 🚒 🚐 🚚 🚛 🚜 (de `Vehicle`, HU-052). **Fuera** 🚘 y 🚖 (de frente), 🏍️ 🚲 🛴 (no son coches de fila) y 🛻 🛺 (no se ven en Android 8).
- **Patitos:** 🦆 (3.0), una mamá y 2 o 3 detrás, más pequeños.
- **Distracciones:** 🐦 (0.6), 🦋 (3.0), ⚽ (0.6).
- **Aparcamiento:** huecos dibujados en la calle; sin emoji.
- **Semáforo:** dibujado (`CustomPaint`): caja teal profundo con tres luces. Ver colores (sección 7).
- Todos se comprueban en el emulador `LowEnd_API26` y en el moto g55, también **reflejados** (mano izquierda).

## 6. Accesibilidad e idiomas

- **Sin texto para el niño.**
- **Lector de pantalla:** el semáforo es una región que anuncia cada cambio («Rojo: esperar», «Verde: ya pueden pasar»); cada coche se nombra («Autobús»); al aparcar, «Autobús aparcado». Con el lector activo, los ciclos se alargan al doble, para que dé tiempo a oír el aviso y tocar.
- **Daltonismo:** la luz encendida no depende solo del color: **la posición** (rojo arriba, verde abajo, como los semáforos reales), el **brillo** (la encendida grande y luminosa, las apagadas al 20 %) y una **forma** dentro de cada luz (una mano ✋ dibujada en la roja; una flecha en la verde).
- **Nombre del juego y avisos:**

| Idioma | Nombre | «Rojo: esperar» | «Verde: ya pueden pasar» |
|---|---|---|---|
| es | El semáforo | Rojo: esperar | Verde: ya pueden pasar |
| en | Traffic light | Red: wait | Green: go |
| fr | Le feu tricolore | Rouge : on attend | Vert : on peut passer |
| it | Il semaforo | Rosso: aspetta | Verde: si passa |
| de | Die Ampel | Rot: warten | Grün: losfahren |
| pt | O semáforo | Vermelho: esperar | Verde: podem passar |
| ja | しんごう | あか：まってね | あお：すすめ |
| ko | 신호등 | 빨간불: 기다려요 | 초록불: 건너요 |
| ar | إشارة المرور | أحمر: انتظر | أخضر: يمكنك المرور |

- En japonés, el verde del semáforo se dice «あお»: se usa así a propósito.

## 7. Colores (D-032)

- **El semáforo necesita rojo y verde, que no están en la paleta** de la interfaz. Los únicos tonos cercanos son el **rubí `#8E1F3B`** y el **esmeralda `#1E7F5C`**, que hoy son **exclusivos de las medallas** (HU-051 3.4), y el **ámbar `#ECA463`**, que sí es de la paleta.
- **Decidido (P2, 2026-11-25):** el rubí y el esmeralda se usan **también en las luces del semáforo, y solo ahí** (`TrafficLightView`), con `palette_test` actualizado. No se añade ningún color: se amplía el uso de dos que ya existen.
- **Calle:** teal profundo al 15 % sobre crema; líneas y paso de cebra en blanco. **Aparcamiento:** huecos con borde ámbar al 50 %.
- **Caja del semáforo:** teal profundo; luces apagadas, del mismo tono al 20 %.

## 8. Acceso y «Nuevo»

- **Acceso (HU-042):** juego nuevo: **bronce y plata gratis**; de oro a diamante, Premium o durante una edición especial. En la prueba cerrada, todo gratis (D-040).
- Encaja como **segundo juego de la temática de vehículos**: si se quiere, puede entrar en la edición de Navidad de «A su sitio» (un trineo 🛷 en la fila y regalos en el aparcamiento), pero queda fuera de esta historia.
- **«Nuevo» (HU-041):** `GameId.trafficLight` no está en `gamesInRc5`: se destaca tras actualizar.

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio | `lib/domain/traffic/`: `LightPhase { red, amber, green }`; `TrafficCycle` (fases con duración, sorteadas con semilla; `phaseAt(Duration elapsed)` puro, sin reloj); `TrafficLadder` (niveles 4.1, `TrafficRules` por ronda con la tabla 4.2, `RoundLadder` con el límite calculado con el ciclo); `TrafficStars` (prisas) |
| Presentación | `TrafficGameCubit`/`TrafficGameState` (reloj inyectable con `Ticker`, pausa en segundo plano como el cronómetro de los demás juegos; cola de coches, salidas, aparcados, prisas y toques que no cuentan); `TrafficStreetView` (calle, fila, aparcamiento, coches con `AnimationController`, patitos y distracciones); `TrafficLightView` (`CustomPaint`, formas dentro de las luces, anillo de espera); `TrafficGameScreen` |
| Mano guía | `GestureHint` gana una espera: la mano se queda quieta hasta que el cubit avisa del verde (`HintGesture.waitThenTap`) |
| Persistencia | `GameId.trafficLight` en `GameProgressHiveModel` (typeId 5), clave `trafficLight`: sin tipos nuevos |
| Colores | Decisión nueva (P2) en SPECIFICATION y PALETA.md; `palette_test` admite rubí y esmeralda en `TrafficLightView` |
| Menú y padres | Tarjeta en `GameCatalog` con icono 3D (P7); «Su progreso» (HU-034) |
| Tests | Ciclo (duraciones por ronda, semilla, nunca dos verdes a la vez más de 1 s), estrellas (los toques seguidos no cuentan), cubit con reloj falso (toque en verde mueve, en rojo no, el coche que salió termina, pausa en segundo plano), pantalla (orientaciones, mano izquierda, lector con región viva), rendimiento en el emulador de gama baja (TD-013: animaciones continuas) |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **El ciclo y la partida** (dominio y cubit con reloj falso, tests), y la decisión de colores | Sí: no cambia nada visible |
| 2 | **El juego de bronce a rubí**: calle, fila, aparcamiento, semáforo dibujado, patitos, anillo de espera, tutorial con la mano que espera, menú, progreso, «Nuevo», 9 idiomas | Sí |
| 3 | **Esmeralda a diamante**: distracciones, dos carriles, ciclos al azar | Sí |

## 11. Tamaño estimado

**5–6 días:** 1 día el ciclo y el cubit con el reloj, 2–2,5 días la calle animada y el semáforo dibujado (lo más nuevo y lo que más hay que probar en el teléfono), 1 día los dos carriles y las distracciones, y 1 día de ajuste de tiempos con niños y en gama baja.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre del juego en el menú? | ✅ Decidido (2026-11-25): **«Semáforo»**, sin artículo, como «Memoria» y «Sombras» |
| P2 | ¿Rojo y verde fuera de la paleta? | ✅ Decidido (2026-11-25): **el rubí y el esmeralda de las medallas, solo en las luces del semáforo**, con posición, brillo y forma para el daltonismo (sección 7) |
| P3 | ¿Hay luz ámbar? | ✅ Decidido (2026-11-25): **sí, desde oro**, y cuenta como rojo |
| P4 | ¿Se puede arrastrar el coche en vez de tocar? | ✅ Decidido (2026-11-25): **no**: un toque en cualquier coche de la fila mueve el primero |
| P5 | ¿Los toques en rojo bajan las estrellas? | ✅ Decidido (2026-11-25): **sí, con suavidad** (3★ hasta N ÷ 2 prisas), y solo cuentan los dos primeros de cada rojo. Nunca se ve como error |
| P6 | ¿Tiempo desde oro, como los demás? | ✅ Decidido (2026-11-25): **sí, calculado con el ciclo** (sobra al menos un ciclo) |
| P7 | ¿Icono del juego? | ✅ Decidido (2026-11-25): **ilustración 3D** (D-036) con el prompt de la **pieza 20** de `docs/brand/PROMPTS-identidad.md`: un semáforo de plastilina con un cochecito esperando. La entrega el dueño |
| P8 | ¿Color de la tarjeta del menú? | ✅ Decidido: **crema con borde coral grueso y texto teal profundo**, como todos los juegos nuevos (HU-027 P7, confirmado para todos el 2026-11-25). El 2026-11-25 se aceptó la recomendación de teal profundo, pero la decisión común la sustituye |
| P9 | ¿Patitos en el paso de cebra? | ✅ Decidido (2026-11-25): **sí** |
| P10 | ¿Edición de Navidad como «A su sitio»? | ✅ Decidido (2026-11-25): **no en esta historia** |

## 13. Criterios de aceptación

1. Tocar en verde hace cruzar y aparcar el primer coche; tocar en rojo o ámbar no mueve nada, sin sonido, y el semáforo parpadea suave.
2. Un coche que ha salido termina de cruzar aunque cambie la luz; nunca hay un coche y un patito a la vez en el paso de cebra.
3. Los tiempos de las luces, el ámbar, el anillo, las distracciones y los carriles siguen la tabla 4.2 (test del ciclo con semilla).
4. Desde el tercer toque seguido en un mismo rojo, los toques no cuentan.
5. Ocho rondas, estrellas por prisas, medallas y tiempo calculado con el ciclo desde oro; sin tiempo en bronce y plata.
6. La luz encendida se distingue sin color (posición, brillo y forma).
7. El lector de pantalla anuncia cada cambio de luz y nombra los coches en los 9 idiomas; con él activo, los ciclos se alargan.
8. Con la mano izquierda todo se refleja; en árabe, la dirección no cambia.
9. La animación es fluida en el emulador de gama baja (Android 8, 720 × 1280).
10. Se destaca como nuevo tras actualizar; sin Premium, bronce y plata.

## 14. Fuera de alcance

- Peatones con figuras humanas y normas de tráfico más allá de esperar en rojo.
- Accidentes, sirenas o cualquier escena de peligro.
- Conducir el coche con el dedo (es HU-053, «Carreras tranquilas»).
- Edición de Navidad propia (P10).
