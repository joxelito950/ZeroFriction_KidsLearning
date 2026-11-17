# HU-050 · Sombras: ver la sombra mientras se arrastra el objeto

| | |
|---|---|
| **Estado** | **Lista** (2026-11-17): P1 a P3 decididas por el dueño |
| **Épica** | E4 · Juegos (HU-007 Sombras) |
| **Prioridad** | **P1** |
| **Tamaño** | S (medio día) |
| **Depende de** | HU-007. Toca la regla del solape de HU-007 P4 solo si se decide P2 |

## 1. Historia

**Como** niño, niña o adulto que juega a Sombras en el Reto máximo,
**quiero** ver la sombra mientras llevo el objeto encima,
**para** poder encajarlo con precisión.

## 2. Problema (visto en el moto g55)

En el Reto máximo (el objeto debe cubrir el 90 % de su sombra, HU-007 P4) **es casi imposible incluso para un adulto**. Causa en el código (`shadow_board.dart`):

1. Mientras se arrastra, el objeto se dibuja **sobre una tarjeta blanca opaca** (`_ObjectCard`): al llegar encima, **la tarjeta tapa la sombra** y no se ve dónde está.
2. Además se dibuja **un 15 % más grande** (`dragScale = 1,15`), pero el solape **se mide con el tamaño normal**: lo que se ve no es lo que cuenta, y el centro aparente engaña.

## 3. Propuesta

- **En la bandeja, la tarjeta («sticker») es un poco más pequeña** que la sombra (P1, por ejemplo un 85 %).
- **Al seleccionarlo o arrastrarlo, crece a su tamaño real**, que es **el mismo de la sombra** y el mismo con el que se mide el solape: se conserva el efecto de «levantar» el objeto y lo que se ve es lo que cuenta.
- **Sin tarjeta mientras se arrastra**: el objeto en color, **sin fondo blanco**, con una sombra suave para que «flote». Así la silueta de debajo se ve alrededor del dibujo.
- **Aviso de «casi»** (P2), **en todas las rondas**: al estar muy cerca de su sombra, el contorno de la sombra se ilumina en ámbar para avisar de que va a encajar (sin sonido ni texto). Da consistencia al juego aunque en Fácil y Normal sea menos necesario.

## 4. Criterios de aceptación

1. En la bandeja, la tarjeta es más pequeña que la sombra; al seleccionarla o arrastrarla, crece al tamaño de la sombra (test de tamaños).
2. Mientras se arrastra, el objeto no tiene tarjeta blanca, la sombra de destino se ve a su alrededor y se dibuja del mismo tamaño que el rectángulo con el que se mide el solape (test).
3. Cerca de su sombra, en cualquier ronda, el contorno de la sombra se ilumina en ámbar; lejos, no.
4. En el Reto máximo, en el moto g55, el dueño encaja los 8 objetos de un tablero sin fallar por precisión.
5. Fácil y Normal no cambian su regla (40 % y 60 %).

## 5. Impacto técnico

| Capa | Cambio |
|---|---|
| Presentación | `shadow_board.dart`: el objeto arrastrado usa `_ObjectCard(bare: true)` con sombra propia y `dragScale` 1,0 (o se mide con el mismo rectángulo que se dibuja) |
| Tests | Sin tarjeta y a tamaño medido mientras se arrastra; el resto de los tests de arrastre sin cambios |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Tamaño real al arrastrar, o se mantiene más grande y se mide igual de grande? | ✅ Decidido (2026-11-17), con un ajuste: en la bandeja la tarjeta es **un poco más pequeña** que la sombra y, al seleccionarla, **crece a su tamaño real**, el de la sombra, para no perder el efecto de crecer |
| P2 | ¿Aviso de «casi» (contorno ámbar) al acercarse? | ✅ Decidido (2026-11-17), distinto de la recomendación: **sí, en todas las rondas**, por consistencia |
| P3 | ¿Se baja el 90 % del Reto máximo? | ✅ Decidido (2026-11-17): **se mantiene en 90 %** y se revisa en la prueba cerrada. Con HU-051, el 90 % pasa a ser el del diamante y las rondas intermedias tienen solapes intermedios. Recomendación original: primero se prueba con la sombra visible; si sigue siendo muy difícil, bajar a 80 % tras la prueba cerrada |
