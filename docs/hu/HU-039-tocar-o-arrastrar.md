# HU-039 · Tocar, arrastrar o ambos (accesibilidad motora)

| | |
|---|---|
| **Estado** | **Desarrollada** (2026-11-20, rama `feature/hu-039-031-how-to-play`, con HU-031): las tres entregas (sección 9). Falta verla en el teléfono |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | M (3 entregas, unos 3 días) |
| **Depende de** | HU-009 (`ParentalSettings`, typeId 3, donde se guarda el ajuste). HU-007 R16: Sombras ya tiene el modo «tocar el objeto y luego su sombra» para el lector de pantalla, y esta historia lo abre a todos. HU-022: la mano guía enseña el gesto que corresponda |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** elegir si mi hijo juega arrastrando, tocando o de las dos formas,
**para** que un niño muy pequeño o con dificultades motoras finas pueda jugar sin frustrarse.

## 2. Situación actual

- **Memoria** y **¿Cuál es diferente?** ya se juegan solo tocando. El ajuste no les afecta.
- **Sombras** se juega arrastrando el objeto hasta su sombra. Si el lector de pantalla está activo, se juega tocando: primero el objeto y después la sombra (HU-007 R16). Ese modo ya está hecho y probado, pero un adulto no puede elegirlo.
- **«A su sitio»** (HU-052) se juega arrastrando el vehículo a su sitio, y ya acepta tocar el vehículo y después el sitio.
- Los juegos de arrastrar que vengan (el laberinto, HU-043/044) tendrán la misma necesidad.
- Solo **Memoria** muestra los movimientos («Movimientos: N»). Los demás juegos cuentan los fallos para las estrellas, pero no los enseñan.

## 3. Comportamiento propuesto

### 3.1 Ajuste en la Zona de Padres

Una sección nueva, **«Cómo juega»**, debajo de «Juegos» (HU-030). Comparte la sección con la mano dominante (HU-031):

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Forma de mover las piezas** | **Arrastrar** · **Tocar** · **Ambas** | **Ambas** (P1) |

Debajo, una frase explica para qué sirve: «En los juegos donde se lleva una pieza a su sitio (hoy, Sombras y A su sitio). Tocar: se toca la pieza y después su sitio; ayuda a los más pequeños o a quien aún no controla bien el dedo».

El ajuste vale para **todos los juegos de arrastrar**, los de ahora y los que vengan (R1). Los juegos de tocar lo ignoran.

### 3.2 Qué hace cada opción en Sombras y en «A su sitio»

| Opción | El niño puede… | La mano guía (HU-022) enseña… |
|---|---|---|
| Arrastrar | solo arrastrar, como hoy | el arrastre |
| Tocar | tocar el objeto (se levanta y brilla) y después tocar una sombra o un sitio; el objeto vuela hasta él | dos toques: el objeto y su sombra |
| Ambas | las dos cosas, en cualquier momento | el arrastre (es el gesto que se quiere aprender); P3 |

### 3.3 Reglas

- **R1.** El ajuste vive en `ParentalSettings` y lo leen todos los juegos de arrastrar a través de un tipo de dominio común (`MoveMode { drag, tap, both }`). Ningún juego lo reinterpreta por su cuenta.
- **R2.** Con el lector de pantalla activo, el modo es siempre **Tocar**, elija lo que elija el adulto (HU-007 R16 se mantiene).
- **R3.** En «Tocar», el objeto elegido se marca con un halo ámbar y un pequeño salto; tocarlo otra vez lo suelta. Tocar otro objeto cambia la elección. No hay límite de tiempo para el segundo toque.
- **R4.** Una sombra equivocada se trata igual que soltar el objeto en una sombra equivocada: el objeto vuelve a la bandeja con el mismo vaivén y cuenta como fallo para las estrellas. Así el modo no regala estrellas (P2).
- **R5.** En «Tocar» las zonas táctiles de los objetos y las sombras crecen hasta un mínimo de 64 dp, sin cambiar la disposición del tablero.
- **R6.** Las estrellas, el dorado, las medallas y las rondas (HU-002, HU-037) no cambian con el modo.

## 4. Criterios de aceptación (borrador)

1. Con «Arrastrar», Sombras y «A su sitio» se juegan como hoy, y tocar un objeto no lo selecciona.
2. Con «Tocar», arrastrar no mueve nada. Tocar el objeto y después su sombra lo coloca, con el mismo sonido y la misma animación.
3. Con «Ambas» funcionan los dos gestos en el mismo tablero.
4. Con el lector de pantalla activo se juega tocando, sea cual sea el ajuste.
5. Un toque en la sombra equivocada cuenta como fallo y devuelve el objeto.
6. El ajuste se conserva al cerrar la app y se ve en los 9 idiomas.
7. Cambiar de «Ambas» a «Arrastrar» (o a cualquier otra opción) cambia a la vez Sombras y «A su sitio».
8. Los cuatro juegos muestran «Movimientos: N» con la regla de la sección 8, y las estrellas no cambian.

## 5. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `MoveMode` en `lib/domain/settings/`. `ParentalSettings.moveMode` |
| Datos | Campo nuevo en `ParentalSettingsHiveModel`, con `null` = «Ambas». Se asigna el siguiente índice libre (12 desde HU-038) cuando se desarrolle, en el orden en que lleguen HU-039 y HU-031 |
| Presentación | `ShadowBoard` ya tiene el camino de toques (R16): se activa con `moveMode != drag` o con el lector de pantalla. `VehicleBoardView` ya acepta tocar el vehículo y el sitio: se condiciona igual. El arrastre se desactiva con `moveMode == tap`. `GestureHint` gana el gesto `HintGesture.tapThenTap`. El contador de movimientos sale de la cabecera de Memoria a un widget común |
| Zona de Padres | Sección `ParentsHowToPlaySection` con un `SegmentedButton` de 3 opciones (como la dificultad) |

**Entregas:** (1) dominio, guardado y sección de padres; (2) Sombras y «A su sitio» con el ajuste y la mano de dos toques; (3) el contador de movimientos en los cuatro juegos (sección 8).

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Qué opción viene por defecto? | ✅ Decidido (2026-11-19), como la recomendación: **Ambas.** Ningún niño se queda bloqueado si no sabe arrastrar, y quien sabe arrastrar no nota nada. Si el adulto quiere que practique el arrastre, elige «Arrastrar» |
| P2 | ¿Un toque en la sombra equivocada cuenta como fallo? | ✅ Decidido (2026-11-19), como la recomendación, y con un añadido del dueño: **los movimientos se ven y se cuentan en todos los juegos**, no solo en Memoria (sección 8). **Sí, como al soltar mal.** Si no contara, en «Tocar» se podría probar sombra por sombra sin coste y las estrellas dejarían de significar lo mismo |
| P3 | En «Ambas», ¿qué gesto enseña la mano? | ✅ Decidido (2026-11-19), como la recomendación: **el arrastre**, alternando con los dos toques solo si el niño sigue sin tocar nada tras dos demostraciones |
| P4 | ¿Se agrandan las zonas táctiles también en «Ambas»? | ✅ Decidido (2026-11-19), como la recomendación: **sí**, el mínimo de 64 dp no estorba al arrastre |
| P5 | ¿El ajuste es único para todos los juegos o uno por juego? | ✅ Decidido (2026-11-19): **único y transversal**. Vale para todos los juegos donde se lleva una pieza a su sitio: hoy Sombras y «A su sitio». Cambiarlo, por ejemplo de «Ambas» a «Arrastrar», cambia los dos a la vez. Memoria y «¿Cuál es diferente?» se juegan solo tocando y no les afecta |

## 7. Fuera de alcance

- Cambiar los juegos de tocar.
- Control por interruptor o con mando (accesibilidad de conmutadores).
- Ajustar la velocidad de las animaciones.

## 8. Movimientos en todos los juegos (decidido el 2026-11-19, P2)

Hoy solo Memoria enseña «Movimientos: N». El dueño pide que **todos los juegos los muestren y los cuenten**, con la misma cabecera.

| Juego | Qué cuenta como un movimiento |
|---|---|
| Memoria | Cada pareja de cartas volteada, acierte o no (como hoy) |
| Sombras | Cada vez que se suelta un objeto sobre una sombra, o se toca una sombra con un objeto elegido, acierte o no |
| «A su sitio» | Lo mismo, con los vehículos y los sitios |
| «¿Cuál es diferente?» | Cada toque en una de las opciones, acierte o no |

- **R7.** Soltar fuera de cualquier sombra o sitio, o tocar un objeto para elegirlo, **no** cuenta: el niño no ha intentado nada.
- **R8.** Las estrellas siguen sus reglas de siempre: Memoria por movimientos, y los demás por fallos (R4, R6). Así ninguna partida guardada cambia de estrellas.
- **R9.** El contador va en la cabecera de cada juego, junto a la ronda y los puntos de nivel (HU-034, sección 10), y el lector de pantalla lo lee como en Memoria.

## 9. Desarrollo (2026-11-20)

- **Hallazgo al empezar:** hasta ahora, en Sombras y en «A su sitio» solo se podía tocar la pieza y después su sitio **con el lector de pantalla**. Un niño solo podía arrastrar. Esta historia añade el toque a la vista.
- **Ajuste** (`domain/settings/how_to_play.dart`): `MoveMode { drag, tap, both }`, guardado en el campo 12 de `ParentalSettingsHiveModel`; si falta, es «Ambas». Lo leen los tableros a través de `HowToPlayCubit`, que vive en toda la app. Cambiarlo en la Zona de Padres cambia los dos juegos a la vez (P5).
- **Tableros** (`ShadowBoard`, `VehicleBoardView`):
  - con «Tocar» o «Ambas», tocar una pieza la elige (crece, como al levantarla); tocarla otra vez la suelta, y tocar otra cambia la elección (R3);
  - con una pieza elegida, tocar su sitio la lleva volando hasta él. Si no es el suyo, vuelve a la bandeja y **cuenta como fallo** (R4, P2);
  - con «Arrastrar», tocar no elige nada; con «Tocar», arrastrar no mueve nada;
  - con el lector de pantalla siempre se puede tocar (R2).
- **Mano guía:** en «Ambas» enseña el arrastre (P3). Con «Tocar», un juego de arrastrar enseña los dos toques (`HintGesture.tapThenTap`): toca la pieza, levanta el dedo y toca su sitio.
- **Zona de Padres:** fila **«Cómo juega»** debajo de «Juegos», con su pantalla: «Forma de mover las piezas» (Arrastrar · Tocar · Ambas) y «Mano con la que juega» (HU-031), con «Guardar». La fila resume «Ambas · Mano derecha».
- **Movimientos** (sección 8, hecho por un agente en paralelo y fusionado):
  - los cuatro juegos comparten la cabecera `GameHeader`, con «Movimientos: N» junto a la ronda y los puntos de nivel;
  - en Sombras y «A su sitio» cuenta cada vez que se suelta o se toca una pieza sobre un sitio, acierte o no; en «¿Cuál es diferente?», cada toque en una opción;
  - las estrellas no cambian;
  - en «¿Cuál es diferente?» el contador sigue durante los 3 tableros de un nivel y vuelve a 0 en el siguiente, como los fallos y el tiempo de ese juego;
  - en Sombras, «A su sitio» y «¿Cuál es diferente?» los puntos de nivel bajan a una segunda fila de la cabecera, que queda un poco más alta.
- **R5 (64 dp): pendiente.** No se agrandaron las zonas táctiles. Falta medir si las piezas de los tableros más llenos llegan a 64 dp en un teléfono pequeño y, si no, agrandar solo la zona que se toca.
- **Tests:** `test/presentation/how_to_play_test.dart`, además de los del contador en los cuatro juegos. Suite completa: 2139 tests.
