# HU-026 · Juego: ¿Cuántos hay?

| | |
|---|---|
| **Estado** | **Lista (2026-11-24)**: el dueño responde las preguntas el 2026-11-24 (sección 12) |
| **Épica** | E4 · Juegos |
| **Prioridad** | P2 |
| **Tamaño** | M (3 días solo; 2 días si HU-036 ya hizo el motor de parejas) |
| **Depende de** | HU-036 (el motor de parejas a la vista: lo construye el primero de los dos). HU-051 (ocho rondas), HU-039 (movimientos), HU-022 (mano guía), HU-005 (sonidos), HU-041 («Nuevo»), HU-042 (acceso), HU-023 (tarjeta del menú) |

## 1. Historia

**Como** niño o niña de 3 a 5 años,
**quiero** juntar los grupos que tienen la misma cantidad de cosas,
**para** reconocer cuántas hay de un vistazo, sin necesidad de saber los números escritos.

## 2. Situación actual y qué reutiliza

- Ningún juego trabaja la cantidad. Reconocer de un vistazo hasta 4 o 5 cosas (subitización) es un hito de los 3–4 años y la base para contar.
- **Misma mecánica que Opuestos (HU-036):** cartas boca arriba; se toca una y después la que tiene la misma cantidad. Se reutiliza su **motor de parejas a la vista** (`PairBoard`, `PairBoardView`, `PairGameCubit`) entero; aquí solo cambian el contenido de las cartas y el sorteo.
- **Es nuevo:** dibujar dentro de una carta un grupo de 1 a 6 emojis con una disposición legible (sección 3.4).

## 3. Cómo se juega

### 3.1 El tablero

- Una cuadrícula de cartas boca arriba. Cada carta tiene **un grupo de objetos iguales** (🍎🍎🍎). Cada cantidad aparece **exactamente en dos cartas**, que son la pareja.
- Sin números escritos, ni dedos, ni puntos de dado como ayuda: solo los objetos.

### 3.2 Gestos

- Se toca una carta (halo ámbar, HU-039 R3) y después la que tiene **la misma cantidad**. Se juntan con un saltito y el sonido de pareja (HU-005) y quedan atenuadas.
- **Fallo:** si la cantidad no coincide, vaivén suave, sin sonido de error; cuenta como fallo y como movimiento.
- **Movimientos (HU-039):** cada intento de pareja.
- Es un juego de tocar: el ajuste «Arrastrar · Tocar · Ambas» no le afecta. Zona táctil de cada carta, al menos 64 dp.
- **Al juntar una pareja**, los objetos de las dos cartas se iluminan **uno a uno** a la vez (1, 2, 3…), con un toque suave por objeto. Así el niño **ve** que hay los mismos, sin números ni voz (D-034).
- **El destello es una ayuda** (P5, 2026-11-24): solo sale en el **tutorial y en la ronda bronce**. Desde plata, la pareja se junta con su saltito y su sonido, sin destello. Con «reducir animaciones», nunca.

### 3.3 Mano guía (HU-022)

En el tutorial (nivel 1: una carta con 1 y otra con 3, cada una dos veces), la mano toca la carta de 1 y después su pareja, con el gesto `tapThenTap`.

### 3.4 Cómo se evita que contar sea imposible

| Regla | Por qué |
|---|---|
| **Un solo tipo de objeto por carta**, salvo en diamante | Mezclar 🍎🍌🍎 obliga a contar «cosas» en abstracto: demasiado para 3–4 años. En diamante sí se mezclan (P4), como último reto |
| **Como mucho 5** (6 solo en diamante) | Hasta 4 se reconoce de un vistazo; 5 y 6, con una disposición conocida |
| **Disposiciones fijas** (plantillas), no posiciones al azar | Un grupo desordenado de 5 no se reconoce sin contar uno a uno |
| **Sin solapes y con separación mínima** del 30 % del objeto | Cada objeto se ve entero |
| **Objetos de al menos 28 dp** en el compacto | Si no caben, el tablero pone menos parejas |
| **Objetos que son «uno»** | Fuera 🍒 (son dos), 🍇, 👀, 👣, 🍡, 🐾, 🎎: parecen varios |
| **Nunca dos cartas de la misma cantidad que no sean pareja** | Cada cantidad sale dos veces exactas |
| **Sin giros ni tamaños distintos** dentro de una carta | El tamaño no debe parecer cantidad |

**Disposiciones** (plantillas de 1 a 6):

- **Dado:** 1 en el centro; 2 en diagonal; 3 en diagonal; 4 en cuadrado; 5 cuadrado con centro; 6 en dos filas de 3.
- **Fila:** todos en una fila (hasta 5) o dos filas (6).
- **Sueltos:** 3 o 4 plantillas por cantidad con posiciones algo irregulares pero sin solapes, ya probadas (no se generan al azar en el teléfono).

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
| 8 | 5 | 10 |

- Las parejas nunca superan las cantidades de la ronda: en bronce (1 a 3), como mucho 3 parejas aunque el nivel pida más.
- Como mucho 10 cartas con hasta 6 objetos cada una: es el límite para que los objetos no bajen de 28 dp en el compacto. Se comprueba en el diseño de la entrega 1.

### 4.2 Rondas (HU-051): cómo crecen las cantidades

| Ronda | Cantidades | Objetos de la pareja | Disposición | Cantidades vecinas juntas | Tiempo |
|---|---|---|---|---|---|
| **Bronce** | 1 a 3 | Iguales en las dos cartas (🍎🍎 y 🍎🍎) | Dado en las dos | No: el sorteo prefiere 1 y 3 | No |
| **Plata** | 1 a 4 | Iguales | Dado | No | No |
| **Oro** | 1 a 5 | **Distintos de la misma temática** (🍎🍎🍎 y 🍐🍐🍐) | Dado | Sí | Sí |
| **Rubí** | 1 a 5 | Distintos de la misma temática | Dado | Sí | Sí |
| **Esmeralda** | 1 a 5 | **De temáticas sin relación** (🍎🍎🍎 y 🐟🐟🐟): la cantidad no depende de qué sea | Una carta en dado y su pareja en fila | Sí | Sí |
| **Zafiro** | 1 a 5 | De temáticas sin relación | Dado o fila en cada carta, al azar | Sí, 3, 4 y 5 juntos | Sí |
| **Obsidiana** | 1 a 5 | De temáticas sin relación | Sueltos | Sí | Sí |
| **Diamante** | 1 a 6 | De temáticas sin relación, y **objetos mezclados dentro de una carta** (🍎🐟🍎 y 🌸🌸🚗) | Sueltos | Sí | Sí |

- En bronce y plata, **todos los objetos del tablero son iguales** salvo la cantidad: el niño solo mira cuántos hay.
- **Oro y rubí** (P3, 2026-11-24): el tablero usa una sola temática (sección 5) y cada pareja junta dos objetos distintos de ella. Los objetos se pueden repetir entre parejas: solo importa la cantidad.
- **Desde esmeralda**, cada carta de una pareja es de una temática distinta.
- **Diamante** (P4, 2026-11-24): una carta puede mezclar objetos; su pareja tiene la misma cantidad total. Es la única ronda con mezcla.
- **Tiempo** desde oro: como en Opuestos, por pareja (oro 12 s por pareja → diamante 6 s), ajustado en el teléfono. «Jugar sin tiempo» lo quita.
- **Estrellas:** las de Opuestos (`PairStars`): con N parejas, 3★ con N ÷ 2 fallos o menos, 2★ hasta N, 1★ con más.
- **Medalla** al superar el nivel 8 de cada ronda.

## 5. Contenido (Emoji 5.0 o anterior, sin ZWJ)

- **Objetos:** 🍎 🍊 🍋 🍓 🍐 ⭐ 🎈 ⚽ 🐟 🐞 🐤 🌸 🌻 🍄 🍪 🚗 🐶 🐱 🦆 🌙. Todos Emoji 0.6–1.0 salvo 🦆 (3.0).
- **Temáticas** (P3): **comida** 🍎 🍊 🍋 🍓 🍐 🍪 · **animales** 🐟 🐞 🐤 🐶 🐱 🦆 · **naturaleza** 🌸 🌻 🍄 ⭐ 🌙 · **juguetes** 🎈 ⚽ 🚗. Cada temática necesita al menos 2 objetos; conviene ampliar juguetes al validar en el emulador.
- **Fuera:** 🍒 🍇 👀 👣 🍡 🐾 🎎 👯 (parecen varios), 🌈 y 🎂 (formas grandes que no se leen pequeñas), y los que tienen ZWJ.
- Desde esmeralda, cada tablero elige objetos **muy distintos entre sí** (nunca 🍎 y 🍓 en cartas que no son pareja), para que se vea qué carta es cuál.
- Todos se comprueban en el emulador `LowEnd_API26` **a 28 dp**: un objeto que no se reconoce a ese tamaño no entra.

## 6. Accesibilidad e idiomas

- **Sin texto para el niño.** Nada de números escritos, ni siquiera en la celebración.
- **Lector de pantalla:** cada carta dice su cantidad y el objeto («Tres manzanas»); al juntar, «Tres manzanas y tres peces». Mensajes `plural` + `select` en los 9 idiomas (el árabe tiene formas de dual y plural: hay que revisarlas).
- **Nombre del juego y ejemplo:**

| Idioma | Nombre | «Tres manzanas» |
|---|---|---|
| es | ¿Cuántos hay? | Tres manzanas |
| en | How many? | Three apples |
| fr | Combien ? | Trois pommes |
| it | Quanti sono? | Tre mele |
| de | Wie viele? | Drei Äpfel |
| pt | Quantos são? | Três maçãs |
| ja | いくつ？ | りんごが みっつ |
| ko | 몇 개일까? | 사과 세 개 |
| ar | كم عددها؟ | ثلاث تفاحات |

## 7. Colores (D-032)

- Cartas blancas con borde teal profundo al 35 %; elegida, halo ámbar; emparejadas, borde dorado al 50 % y objetos al 60 %; el destello de cada objeto al juntar, ámbar.
- **Sin colores nuevos.** La tarjeta del menú se decide con los demás juegos nuevos (P6); el icono se diseña para leerse sobre crema y sobre blanco.

## 8. Acceso y «Nuevo»

- **Acceso (HU-042):** bronce y plata gratis; de oro a diamante, Premium o durante una edición especial. Todo gratis en la prueba cerrada (D-040).
- **«Nuevo» (HU-041):** `GameId.counting` no está en `gamesInRc5`: se destaca tras actualizar.

## 9. Impacto técnico

| Área | Cambio |
|---|---|
| Dominio común | `lib/domain/pairs/` de HU-036 (`PairBoard`, `PairStars`). Si llega primero este juego, lo construye él |
| Dominio del juego | `lib/domain/counting/`: `CountingCatalog` (objetos de la sección 5), `CountPattern { dice, row, scattered }` con las plantillas de 1 a 6 como posiciones relativas (0–1) dentro de la carta, `CountingLadder` (niveles 4.1, `CountingRules` por ronda, `RoundLadder`), `CountingBoard.pick` (cada cantidad dos veces, objetos distintos por carta desde rubí) |
| Presentación | `CountCard` (pinta el grupo con su plantilla y el destello uno a uno), sobre `PairBoardView`. `CountingGameScreen` |
| Persistencia | `GameId.counting` en `GameProgressHiveModel` (typeId 5), clave `counting`: sin tipos nuevos |
| Menú y padres | Tarjeta en `GameCatalog` con icono 3D (P7, pieza 17 de `docs/brand/PROMPTS-identidad.md`, `assets/brand/counting_icon.png`); «Su progreso» (HU-034) |
| Tests | Plantillas (sin solapes, separación mínima, dentro de la carta), sorteo (cada cantidad dos veces, rangos por ronda, objetos «uno»), objeto ≥ 28 dp con 10 cartas en el compacto, lector con plurales en 9 idiomas |

## 10. Entregas

| # | Entrega | Se puede publicar sola |
|---|---|---|
| 1 | **Cartas de cantidad:** plantillas, `CountCard` y medición en el compacto (si HU-036 no está, también el motor de parejas) | Sí: no cambia nada visible |
| 2 | **El juego de bronce a oro** (mismo objeto, dado): escalera, pantalla, tutorial, menú, progreso, «Nuevo», 9 idiomas | Sí |
| 3 | **Rubí a diamante:** objetos distintos, fila, sueltos y el 6 | Sí |

## 11. Tamaño estimado

**3 días** solo (1 el motor de parejas, 1 las plantillas y la carta, 1 el juego); **2 días** después de Opuestos.

## 12. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Nombre del juego en el menú? | ✅ Decidido (2026-11-24): **«¿Cuántos hay?»**, con interrogaciones como «¿Cuál es diferente?» |
| P2 | ¿Se llega al 6? | ✅ Decidido (2026-11-24): **solo en diamante**, y en dos filas de 3 |
| P3 | ¿Objetos distintos en las dos cartas de una pareja? | ✅ Decidido (2026-11-24): **desde oro, de la misma temática** (3 manzanas y 3 peras); **desde esmeralda, de temáticas sin relación** (frutas y peces). Tabla 4.2 y temáticas en la sección 5 |
| P4 | ¿Se mezclan objetos dentro de una carta (🍎🍌🍎)? | ✅ Decidido (2026-11-24): **sí, solo en diamante** |
| P5 | ¿Destello uno a uno al juntar? | ✅ Decidido (2026-11-24): **sí, pero es una ayuda**, y las ayudas solo van en el tutorial y en la ronda base: aquí, **tutorial y bronce**. Con «reducir animaciones», nunca |
| P6 | ¿Color de la tarjeta del menú? | Se decide una vez para los juegos nuevos (HU-023). El dueño pide el prompt de identidad (pieza 17), pensado para leerse sobre la tarjeta que se elija |
| P7 | ¿Icono del juego? | ✅ Decidido (2026-11-24): **ilustración 3D** (D-036) con el prompt de la **pieza 17** de `docs/brand/PROMPTS-identidad.md`: dos cartas con tres peces y tres patitos. La entrega el dueño |
| P8 | ¿Un juego de «juntar con el número» más adelante? | ✅ Decidido (2026-11-24): **sí, pero no en esta historia.** La app no tiene edad máxima: los niños crecen y piden retos mayores. Se abre **HU-057, juegos de números y retos mayores**, todos Premium |

## 13. Criterios de aceptación

1. Todos los objetos se ven en Android 8 y se reconocen a 28 dp.
2. Cada cantidad aparece exactamente dos veces por tablero; ninguna pareja tiene otra respuesta.
3. Las cantidades, temáticas y disposiciones de cada ronda siguen la tabla 4.2; el 6 y la mezcla dentro de una carta solo salen en diamante.
4. Ningún grupo se solapa ni se sale de su carta (test de plantillas).
5. Juntar dos cartas con la misma cantidad las une con sonido (y con destello solo en el tutorial y en bronce); una cantidad distinta hace el vaivén y cuenta como fallo y movimiento.
6. Ocho rondas, estrellas, medallas y tiempo desde oro.
7. Sin números ni texto para el niño; el lector dice cantidad y objeto en los 9 idiomas.
8. El nivel 8 cabe en el compacto en vertical y horizontal; se destaca como nuevo tras actualizar; sin Premium, bronce y plata.

## 14. Fuera de alcance

- Números escritos, contar en voz alta o con dedos (los números van en HU-057).
- Sumar o quitar («si añado una…»).
- Más de 6 objetos por carta, y objetos mezclados dentro de una carta fuera de diamante.
