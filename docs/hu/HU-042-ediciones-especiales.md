# HU-042 · Ediciones especiales y muestras gratis

| | |
|---|---|
| **Estado** | En refinamiento (ficha creada el 2026-11-18; preguntas en la sección 7) |
| **Épica** | E3 · Monetización |
| **Prioridad** | P2: la **edición de Navidad** de «Cada vehículo a su casa» (HU-052) va en el próximo release a la prueba cerrada |
| **Tamaño** | S para la primera edición (fechas fijas y su aspecto); M con el candado de después (HU-006) |
| **Depende de** | HU-023 (cómo se ve en el menú), HU-052 (el primer juego con edición), HU-006 (el candado cuando la edición termina) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** que algunos juegos nuevos o de temporada lleguen gratis durante un tiempo,
**para** que el niño los pruebe antes de decidir si compro Premium.

**Como** niño o niña,
**quiero** que en Navidad mi juego tenga trineos y regalos,
**para** sentir que la app también celebra conmigo.

## 2. Origen

Propuesta del dueño del 2026-11-10 (HU-037 P6): a partir del cuarto juego, los juegos son **100 % Premium** (D-039), pero algunos llegan como **edición especial**, gratis durante un tiempo, y después pasan a Premium. El 2026-11-18 se decide que el primero sea **«Cada vehículo a su casa» con edición de Navidad** (HU-052 sección 6).

## 3. Propuesta

- **Una edición es un juego y unas fechas** fijas dentro de la versión (sin red, D-033). La app la reconoce comparando la fecha del teléfono con esas fechas.
- **Durante la edición:**
  - el juego está abierto entero, sin candado;
  - lleva su **toque de temporada**: en Navidad, el trineo 🛷, los regalos 🎁 y el árbol 🎄 (HU-052 sección 6);
  - su tarjeta del menú lleva un adorno de temporada en una esquina, sin texto ni precio.
- **Al terminar:**
  - desaparece el toque de temporada;
  - el juego pasa a Premium con el candado sutil (HU-023 3.3), salvo lo que se quede como **muestra gratis** (P2);
  - lo ganado se conserva (P3).
- **Durante la prueba cerrada todo es gratis** (D-040): la edición se nota solo por el toque de temporada.

## 4. Reglas (borrador)

| # | Regla |
|---|---|
| R1 | Cada edición tiene un juego, un tema y unas fechas de inicio y fin fijas en la versión. No necesita red. |
| R2 | Durante la edición, el juego entero se puede jugar sin Premium. |
| R3 | El tema de temporada solo cambia los dibujos y la celebración del juego, y un adorno en su tarjeta del menú: nunca reglas, niveles ni estrellas. |
| R4 | Nada de la edición invita al niño a comprar: ni precios, ni cuentas atrás, ni «últimos días» (D-029, política de Familias). |
| R5 | Al terminar, las medallas, las estrellas y el dorado ganados se conservan. |
| R6 | Cambiar la fecha del teléfono puede abrir o cerrar la edición: se acepta, porque el riesgo es bajo y no hay red para comprobarlo. |

## 5. Criterios de aceptación (borrador)

1. Con la fecha dentro de la edición, el juego muestra su toque de temporada y su tarjeta, el adorno.
2. Con la fecha fuera, el juego es el normal, sin adornos.
3. Lo ganado durante la edición sigue ahí al terminar (test con un reloj inyectado).
4. Ningún texto de la edición menciona precios ni compras.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `SpecialEdition(game, theme, from, until)` y `isActive(now)`, con el reloj inyectado, como en HU-034 |
| Presentación | El adorno en la tarjeta (HU-023) y el tema del juego (HU-052). Colores de la paleta (D-032): los adornos son emojis; sin colores nuevos |
| Acceso | `AccessPolicy` abre el juego mientras la edición está activa (cuando exista HU-006) |
| Tests | Fechas límite (primer y último día, cambio de año) y que no se pierde el progreso |

## 7. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Cuánto dura la edición de Navidad? | **Del 1 de diciembre al 6 de enero**, incluido el día de Reyes. Para las siguientes ediciones, de 4 a 6 semanas |
| P2 | Al terminar, ¿queda algo gratis como **muestra**? | **Sí, la ronda de bronce**: el niño puede seguir jugando a lo básico y el adulto ve qué incluye Premium |
| P3 | ¿Se conserva lo ganado durante la edición? | **Sí, todo**: las medallas, las estrellas y el dorado. Quitarle al niño una medalla ganada es justo lo que la app evita |
| P4 | ¿El tema navideño se ve también fuera del juego, por ejemplo en el menú o en la pantalla de inicio? | **Solo en el juego y en su tarjeta.** Así el alcance es pequeño y no hace falta otra versión en enero para quitarlo |
| P5 | ¿El toque de Navidad vuelve cada año con las mismas fechas? | **Sí**: las fechas se guardan como día y mes, sin el año |
