# HU-042 · Ediciones especiales y muestras gratis

| | |
|---|---|
| **Estado** | **Lista** (2026-11-18): P1 a P6 decididas por el dueño, con la protección contra el cambio de fecha (R7 a R9) aceptada |
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
  - el juego pasa a Premium con el candado sutil (HU-023 3.3), salvo la **muestra gratis**: las rondas de bronce y plata (P2), menos que la parte gratis de ¿Cuál es diferente?;
  - lo ganado se conserva como logro, pero se va perdiendo con el tiempo, como siempre (D-031), si el niño no lo repasa; y para repasar las rondas de oro en adelante hace falta Premium (P3).
- **Primero solo en «Cada vehículo a su casa»**; en futuras versiones, cualquier juego puede tener su edición especial (P4).
- **Durante la prueba cerrada todo es gratis** (D-040): la edición se nota solo por el toque de temporada.

## 4. Reglas (D-043)

| # | Regla |
|---|---|
| R1 | Cada edición tiene un juego, un tema y unas fechas de inicio y fin fijas en la versión. No necesita red. |
| R2 | Durante la edición, el juego entero se puede jugar sin Premium. |
| R3 | El tema de temporada solo cambia los dibujos y la celebración del juego, y un adorno en su tarjeta del menú: nunca reglas, niveles ni estrellas. |
| R4 | Nada de la edición invita al niño a comprar: ni precios, ni cuentas atrás, ni «últimos días» (D-029, política de Familias). |
| R5 | Al terminar, las medallas, las estrellas y el dorado ganados se conservan como logros. Las estrellas se van perdiendo como siempre tras 7 días sin jugar ese nivel (D-031); sin Premium, solo se pueden repasar las rondas de bronce y plata (P3). |
| R6 | Las fechas se guardan como día y mes y se repiten cada año (P5). La primera edición de Navidad va del **20 de noviembre al 6 de enero** (P1). |
| R7 | **La fecha del teléfono no sirve para abrir ediciones** (P5). La app guarda la fecha más alta que ha visto. Una edición solo está abierta cuando se cumplen las tres condiciones: <br>• la fecha de hoy está dentro de su ventana; <br>• hoy no es anterior a esa fecha más alta, salvo un margen de 2 días por cambios de hora o de zona; <br>• hoy no es posterior al fin del soporte de la versión instalada, es decir, su fecha de compilación más 13 meses. |
| R8 | Atrasar el reloj nunca reabre una edición terminada. Adelantarlo para abrir la del año siguiente obliga a dejar el teléfono con la fecha mal. Si luego se vuelve a la fecha real, la edición se cierra, y lo ganado queda como logro y se pierde con el tiempo (R5). |
| R9 | Las rondas gratis de siempre (la muestra de P2) no dependen de la fecha: un reloj mal puesto nunca le quita al niño lo que es gratis. |

## 5. Criterios de aceptación (borrador)

1. Con la fecha dentro de la edición (del 20 de noviembre al 6 de enero), el juego muestra su toque de temporada y su tarjeta, el adorno.
2. Con la fecha fuera, el juego es el normal, sin adornos.
3. Lo ganado durante la edición sigue ahí al terminar (test con un reloj inyectado).
4. Ningún texto de la edición menciona precios ni compras.
5. **Reloj atrasado:** tras ver el 7 de enero, poner el teléfono en diciembre no reabre la edición (test).
6. **Reloj adelantado:** saltar de marzo al diciembre siguiente abre la edición solo si esa fecha está dentro del soporte de la versión (R7). Al volver a marzo, se cierra (test).
7. Con la edición cerrada, el bronce y la plata siguen abiertos; el oro en adelante, con candado cuando exista HU-006.

## 6. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `SpecialEdition(game, theme, from, until)` con día y mes, y `EditionClock(highestSeen, buildDate)` que decide si una edición está abierta (R7, R8), con el reloj inyectado, como en HU-034. La parte gratis por juego: bronce y plata (P2) |
| Persistencia | La fecha más alta vista, en el perfil (`UserProfile`, campo 5 de Hive). La fecha de compilación, constante generada en la versión |
| Presentación | El adorno en la tarjeta (HU-023) y el tema del juego (HU-052). Colores de la paleta (D-032): los adornos son emojis; sin colores nuevos |
| Acceso | `AccessPolicy` abre el juego mientras la edición está activa (cuando exista HU-006) |
| Tests | Fechas límite (primer y último día, cambio de año) y que no se pierde el progreso |

## 7. Preguntas y decisiones

| # | Pregunta | Decisión |
|---|---|---|
| P1 | ¿Cuánto dura la edición de Navidad? | ✅ Decidido (2026-11-18): **del 20 de noviembre al 6 de enero**. La versión llegará a la prueba cerrada ya empezada la ventana; estará abierta desde que se instale hasta el 6 de enero |
| P2 | Al terminar, ¿queda algo gratis como muestra? | ✅ Decidido (2026-11-18): **sí, hasta la ronda de plata** (bronce y plata, 2 de 8 rondas), menos que la parte gratis de ¿Cuál es diferente? |
| P3 | ¿Se conserva lo ganado durante la edición? | ✅ Decidido (2026-11-18): **sí, como logros**. Se van perdiendo con el tiempo si el niño no compra Premium y no los repasa (D-031) |
| P4 | ¿El tema navideño se ve también fuera del juego? | ✅ Decidido (2026-11-18): **solo en el juego** y en su tarjeta. En futuras versiones, las ediciones especiales podrán ser de cualquier juego |
| P5 | ¿Vuelve cada año con las mismas fechas? | ✅ Decidido (2026-11-18): **sí**, con cuidado de que no se pueda jugar con la fecha del teléfono para ir abriendo los juegos que estuvieron gratis en otras fechas: R7 a R9 |
| P6 | El interruptor gratuito «Mantener las estrellas» (HU-016) detiene la pérdida de estrellas. ¿Se aplica también a lo ganado en la edición, o se ignora para esas rondas? | ✅ Decidido (2026-11-18): **se aplica.** Es una decisión del adulto, ya es gratis (2026-11-05), y hacer una excepción sería difícil de explicar. Lo ganado no da acceso a jugar: para repasar el oro en adelante sigue haciendo falta Premium. No bloquea |
