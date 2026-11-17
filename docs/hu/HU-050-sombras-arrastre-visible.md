# HU-050 · Sombras: ver la sombra mientras se arrastra el objeto

| | |
|---|---|
| **Estado** | En refinamiento (2026-11-17). Corrección reportada por el dueño en el moto g55 |
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

- **Sin tarjeta mientras se arrastra**: el objeto en color, **sin fondo blanco**, con una sombra suave para que «flote». Así la silueta de debajo se ve alrededor del dibujo.
- **A su tamaño real** mientras se arrastra (sin el 15 % extra), o el mismo tamaño que se mide: lo que se ve es lo que cuenta.
- En la bandeja, los objetos siguen sobre su tarjeta blanca (son botones que se tocan).
- Opcional (P2): al estar **muy cerca** de su sombra, el contorno de la sombra se ilumina en ámbar para avisar de que va a encajar (sin sonido ni texto).

## 4. Criterios de aceptación

1. Mientras se arrastra, el objeto no tiene tarjeta blanca y la sombra de destino se ve a su alrededor.
2. El objeto arrastrado se dibuja del mismo tamaño que el rectángulo con el que se mide el solape (test).
3. En el Reto máximo, en el moto g55, el dueño encaja los 8 objetos de un tablero sin fallar por precisión.
4. Fácil y Normal no cambian su regla (40 % y 60 %).

## 5. Impacto técnico

| Capa | Cambio |
|---|---|
| Presentación | `shadow_board.dart`: el objeto arrastrado usa `_ObjectCard(bare: true)` con sombra propia y `dragScale` 1,0 (o se mide con el mismo rectángulo que se dibuja) |
| Tests | Sin tarjeta y a tamaño medido mientras se arrastra; el resto de los tests de arrastre sin cambios |

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Tamaño real al arrastrar, o se mantiene más grande y se mide igual de grande? | **Tamaño real**: coincide con la sombra, que es lo que se quiere encajar |
| P2 | ¿Aviso de «casi» (contorno ámbar) al acercarse? | **Sí, solo en el Reto máximo**, donde la precisión importa; en Fácil y Normal no hace falta |
| P3 | ¿Se baja el 90 % del Reto máximo? | **No por ahora**: primero se prueba con la sombra visible; si sigue siendo muy difícil, bajar a 80 % tras la prueba cerrada |
