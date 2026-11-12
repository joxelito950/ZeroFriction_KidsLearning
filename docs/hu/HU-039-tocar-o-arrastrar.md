# HU-039 · Tocar, arrastrar o ambos (accesibilidad motora)

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-11-12). Faltan las respuestas del dueño a P1–P5 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | S–M (2 entregas, unos 2 días) |
| **Depende de** | HU-009 (`ParentalSettings`, typeId 3, donde se guarda el ajuste). HU-007 R16: Sombras ya tiene el modo «tocar el objeto y luego su sombra» para el lector de pantalla, y esta historia lo abre a todos. HU-022: la mano guía enseña el gesto que corresponda |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** elegir si mi hijo juega arrastrando, tocando o de las dos formas,
**para** que un niño muy pequeño o con dificultades motoras finas pueda jugar sin frustrarse.

## 2. Situación actual

- **Memoria** y **¿Cuál es diferente?** ya se juegan solo tocando. El ajuste no les afecta.
- **Sombras** se juega arrastrando el objeto hasta su sombra. Si el lector de pantalla está activo, se juega tocando: primero el objeto y después la sombra (HU-007 R16). Ese modo ya está hecho y probado, pero un adulto no puede elegirlo.
- Los juegos de arrastrar que vengan (el laberinto, HU-043/044) tendrán la misma necesidad.

## 3. Comportamiento propuesto

### 3.1 Ajuste en la Zona de Padres

Una sección nueva, **«Cómo juega»**, debajo de «Juegos» (HU-030). Comparte la sección con la mano dominante (HU-031):

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Forma de mover las piezas** | **Arrastrar** · **Tocar** · **Ambas** | **Ambas** (P1) |

Debajo, una frase explica para qué sirve: «En los juegos donde se lleva una pieza a su sitio (hoy, Sombras). Tocar: se toca la pieza y después su sitio; ayuda a los más pequeños o a quien aún no controla bien el dedo».

El ajuste vale para **todos los juegos de arrastrar**, los de ahora y los que vengan (R1). Los juegos de tocar lo ignoran.

### 3.2 Qué hace cada opción en Sombras

| Opción | El niño puede… | La mano guía (HU-022) enseña… |
|---|---|---|
| Arrastrar | solo arrastrar, como hoy | el arrastre |
| Tocar | tocar el objeto (se levanta y brilla) y después tocar una sombra; el objeto vuela hasta ella | dos toques: el objeto y su sombra |
| Ambas | las dos cosas, en cualquier momento | el arrastre (es el gesto que se quiere aprender); P3 |

### 3.3 Reglas

- **R1.** El ajuste vive en `ParentalSettings` y lo leen todos los juegos de arrastrar a través de un tipo de dominio común (`MoveMode { drag, tap, both }`). Ningún juego lo reinterpreta por su cuenta.
- **R2.** Con el lector de pantalla activo, el modo es siempre **Tocar**, elija lo que elija el adulto (HU-007 R16 se mantiene).
- **R3.** En «Tocar», el objeto elegido se marca con un halo ámbar y un pequeño salto; tocarlo otra vez lo suelta. Tocar otro objeto cambia la elección. No hay límite de tiempo para el segundo toque.
- **R4.** Una sombra equivocada se trata igual que soltar el objeto en una sombra equivocada: el objeto vuelve a la bandeja con el mismo vaivén y cuenta como fallo para las estrellas. Así el modo no regala estrellas (P2).
- **R5.** En «Tocar» las zonas táctiles de los objetos y las sombras crecen hasta un mínimo de 64 dp, sin cambiar la disposición del tablero.
- **R6.** Las estrellas, el dorado, las medallas y las rondas (HU-002, HU-037) no cambian con el modo.

## 4. Criterios de aceptación (borrador)

1. Con «Arrastrar», Sombras se juega como hoy, y tocar un objeto no lo selecciona.
2. Con «Tocar», arrastrar no mueve nada. Tocar el objeto y después su sombra lo coloca, con el mismo sonido y la misma animación.
3. Con «Ambas» funcionan los dos gestos en el mismo tablero.
4. Con el lector de pantalla activo se juega tocando, sea cual sea el ajuste.
5. Un toque en la sombra equivocada cuenta como fallo y devuelve el objeto.
6. El ajuste se conserva al cerrar la app y se ve en los 9 idiomas.

## 5. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `MoveMode` en `lib/domain/settings/`. `ParentalSettings.moveMode` |
| Datos | Campo nuevo en `ParentalSettingsHiveModel`, con `null` = «Ambas». Se asigna el siguiente índice libre (hoy 8) cuando se desarrolle, en el orden en que lleguen HU-039, HU-031 y HU-038 |
| Presentación | `ShadowBoard` ya tiene el camino de toques (R16): se activa con `moveMode != drag` o con el lector de pantalla. El arrastre se desactiva con `moveMode == tap`. `GestureHint` gana el gesto `HintGesture.tapThenTap` |
| Zona de Padres | Sección `ParentsHowToPlaySection` con un `SegmentedButton` de 3 opciones (como la dificultad) |

**Entregas:** (1) dominio, guardado y sección de padres; (2) Sombras y la mano de dos toques.

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Qué opción viene por defecto? | **Ambas.** Ningún niño se queda bloqueado si no sabe arrastrar, y quien sabe arrastrar no nota nada. Si el adulto quiere que practique el arrastre, elige «Arrastrar» |
| P2 | ¿Un toque en la sombra equivocada cuenta como fallo? | **Sí, como al soltar mal.** Si no contara, en «Tocar» se podría probar sombra por sombra sin coste y las estrellas dejarían de significar lo mismo |
| P3 | En «Ambas», ¿qué gesto enseña la mano? | **El arrastre**, alternando con los dos toques solo si el niño sigue sin tocar nada tras dos demostraciones |
| P4 | ¿Se agrandan las zonas táctiles también en «Ambas»? | **Sí**, el mínimo de 64 dp no estorba al arrastre |
| P5 | ¿El ajuste es único para todos los juegos o uno por juego? | **Único**, como pide el dueño: es una característica del niño, no del juego |

## 7. Fuera de alcance

- Cambiar los juegos de tocar.
- Control por interruptor o con mando (accesibilidad de conmutadores).
- Ajustar la velocidad de las animaciones.
