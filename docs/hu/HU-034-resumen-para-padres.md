# HU-034 · Resumen del progreso para padres

| | |
|---|---|
| **Estado** | **Lista** (2026-11-13): P1 a P9 decididas. La entrega 2 es HU-046, que sigue en refinamiento |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | **P1: es lo próximo que se desarrolla** (P6, 2026-11-12) |
| **Tamaño** | L (4 entregas, unos 5 días; la entrega 2 es HU-046) |
| **Depende de** | HU-037 (rondas, medallas y récords por nivel en `GameProgress`). HU-009 (tiempo de hoy). **HU-046** (Zona de Padres por filas, P1), que se hace como entrega 2. Necesita un **historial diario** de tiempo que hoy no existe |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** ver de un vistazo a qué ha jugado mi hijo y lo que ha ido consiguiendo,
**para** acompañarlo, celebrar con él y elegir bien la dificultad, **sin que nada me preocupe ni lo compare con otros niños**.

## 2. Premisa

**Nunca generar preocupación, ni al niño ni a los padres.** Y, por encima de todo, **que el niño disfrute y practique sin frustrarse** (P4). De ahí salen todas las decisiones de esta historia:

| Se muestra | No se muestra nunca |
|---|---|
| Logros: medallas, estrellas, niveles alcanzados | Fallos, tiempos agotados, veces que bajó de nivel o de ronda |
| Lo que está explorando ahora («Está jugando la ronda Normal») | Porcentajes de acierto o «nivel esperado para su edad» |
| Cuánto ha jugado, como información neutra | Comparaciones con otros niños, medias, rankings |
| Su juego favorito de estos días | Rachas («lleva 3 días sin jugar») ni estrellas perdidas (D-037) |
| Una **sugerencia amable** de bajar la dificultad cuando un nivel le cuesta (§4.5) | Colores de alarma (rojo, ámbar como aviso) |
| Las estrellas por nivel, **solo si el adulto las pide** (§4.4) | Botones para borrar el progreso (P5) |

Las palabras siguen la misma idea: «ha conseguido», «está explorando», «le gusta», «puede brillar más». Nunca «le falta», «solo», «todavía no», «suspendido».

## 3. ¿Dónde y en qué formato?

| Opción | Valoración |
|---|---|
| **PDF** | ❌ Descartado. Exige generar y compartir un archivo, invita a enviarlo y compararlo, y un informe impreso se lee como una evaluación |
| **Pantalla «Su progreso» dentro de la Zona de Padres** | ✅ **Decidido.** Es la **primera fila** de la Zona de Padres reorganizada (HU-046, P1): muestra un resumen en una línea y, al tocarla, abre la pantalla. Un solo nivel de profundidad |
| Submenú con gráficos y porcentajes | ⚠️ Los gráficos, sí, pocos y amables; los **porcentajes, no**: «33 %» se lee como una nota |

La fila dice, por ejemplo: **«Su progreso · Le gusta Sombras · 1 h 10 min estos días»**.

## 4. Qué mide y cómo lo presenta

La pantalla «Su progreso» tiene, de arriba abajo, una frase, la sugerencia si la hay, una tarjeta por juego y el gráfico del tiempo.

### 4.1 Una frase de resumen

Una sola frase, generada a partir de los datos y siempre positiva:

- «Estos días ha jugado sobre todo a **Sombras** y ha conseguido **la medalla de bronce**».
- Si no ha jugado: «Estos días no ha jugado. ¡Cuando quiera, aquí estaremos!»

### 4.2 Una tarjeta por juego

Con el icono del juego (como en el menú) y:

- **Medallas conseguidas**: bronce, plata y oro con sus colores (`AppPalette.medalBronze`, `medalSilver`, `gold`). Las que aún no tiene **no aparecen**.
- **Qué está explorando**: «Ronda Normal · nivel 4», **también si bajó de ronda** (P4), sin decir que bajó.
- **Estrellas reunidas**: el total con una estrella («★ 23 de 36»), que es lo mismo que el dorado del menú, en número. **Se toca** para ver el detalle por nivel (§4.4).
- Un juego que nunca ha abierto se muestra como «Aún por descubrir», con su icono en color, como una invitación.

### 4.3 Tiempo de juego: 6 días y un hueco (P2)

Un gráfico **semanal fijo**, con los 7 días en su sitio (lunes a domingo, o domingo a sábado según el idioma del teléfono), que funciona como un **barrido**:

```
 L    M    X    J    V    S    D
 ▇    ▅    ▆    ·    ▃    ▆    ▂
 ── esta semana ──  hueco  ─ semana pasada ─
            (hoy = X)
```

- Se ven **6 días con datos: hoy y los 5 anteriores**. El día siguiente a hoy queda **vacío**: es la **separación entre lo nuevo y lo viejo**.
- Así, el lunes el gráfico **no aparece vacío**: muestra el lunes (hoy) y, después del hueco del martes, los últimos días de la semana pasada.
- Las barras de **esta semana** van en teal profundo; las de la **semana pasada**, en teal profundo con transparencia (C2 de la paleta). **Hoy** lleva su nombre en negrita. El hueco tiene una línea fina punteada, sin barra.
- Encima de cada barra, los minutos. Sin línea del límite diario ni barras de otro color al pasarlo: el límite ya lo aplica la app.
- Debajo, en texto: **«Total de estos 6 días: 1 h 10 min»**.

### 4.4 Detalle de estrellas por nivel (P3)

Al tocar el total de estrellas de una tarjeta se abre un **cuadro de diálogo** (no una pantalla nueva, para no añadir otro nivel de menú). Está pensado para el adulto **perfeccionista** que quiere ver el dorado completo del menú y saber dónde puede ganar más:

- Título: «Estrellas de Sombras». Debajo: «Cada nivel da hasta 3 estrellas. Con todas, el botón del juego queda dorado del todo».
- Una fila por ronda (Fácil, Normal, Reto máximo, con su color de medalla) y en ella los niveles con tiempo (el tutorial no da estrellas, HU-037 P2): «4 ★★☆».
- Las estrellas conseguidas en dorado; las que puede ganar, **en contorno** con teal profundo transparente, nunca en rojo ni gris de «apagado».
- Los niveles que aún no ha jugado, con el texto «por descubrir», no como tres estrellas vacías.
- Se cierra con «Cerrar» o «atrás». Solo lectura.

### 4.5 Sugerencia: «Este nivel le está costando» (P4)

Si el niño **llega una y otra vez al mismo nivel y no consigue superarlo**, la pantalla muestra una tarjeta amable encima de las de los juegos (y un punto en la fila «Su progreso»):

> **Sombras le está costando un poco.** Para que siga disfrutando y practicando, puede probar la ronda Fácil. Lo que ya ha ganado no se pierde.
> [ Pasar a Fácil ]  [ Ahora no ]

- **Cuándo** (P7): en un juego, el niño **llega 3 veces al mismo nivel y las 3 veces vuelve a bajar sin superarlo**. Cuenta cada juego por separado, aunque las 3 llegadas sean en días distintos. La cuenta vuelve a cero al **superar ese nivel**, al cambiar de ronda o con «Ahora no». La bajada automática de ronda de HU-037 (R10) ya cubre las caídas al tutorial; esta sugerencia cubre al niño que **va y viene entre niveles medios** sin llegar a caer.
- **Qué propone:**
  - En Normal o Reto máximo: **bajar a la ronda anterior**. El botón la cambia ahí mismo, con una confirmación («¿Pasar Sombras a la ronda Fácil? Empezará por el tutorial. Conserva sus estrellas y medallas»), sin ir a otra pantalla. Es lo mismo que cambiar la ronda en «Juegos» (HU-037 R5).
  - En Fácil: no hay ronda más baja. Se propone **«Jugar sin tiempo»** (HU-030) si está disponible (hoy lo está para todos, D-040); si no, no se muestra nada.
- **Cuándo desaparece:** al superar el nivel, al cambiar la ronda o con «Ahora no». Tras «Ahora no» no vuelve hasta que se cumpla otra vez la condición desde cero (otras 3 llegadas sin superarlo).
- **Dónde se avisa** (P8): solo con un **punto** en la fila «Su progreso» de la Zona de Padres. Nunca en el menú ni al niño, y sin notificaciones.
- **Nunca** se dice cuántos tableros ha perdido ni se muestra al niño.

## 5. Reglas

- **R1.** Solo lectura, salvo el botón de la sugerencia (§4.5), que hace lo mismo que el selector de ronda de HU-037.
- **R2.** Todo sale de lo que ya se guarda en el teléfono, más el historial diario nuevo (R3). No se envía nada; la política de privacidad no cambia.
- **R3.** Se guarda el **tiempo jugado por día y por juego** de **hoy y los 5 días anteriores** (P2). Los días más antiguos se borran solos.
- **R4.** Para la sugerencia, cada juego guarda **el nivel más alto al que ha llegado sin superarlo y cuántas veces ha llegado a él y ha vuelto a bajar**. Se ponen a cero al superar ese nivel, al cambiar de ronda o con «Ahora no».
- **R5.** El lector de pantalla lee cada barra («miércoles, hoy, 12 minutos»; «viernes de la semana pasada, 8 minutos»; el hueco no se lee) y cada tarjeta como una frase.
- **R6.** Los textos están en los 9 idiomas, y el gráfico se invierte en árabe. El primer día de la semana sale del idioma (`MaterialLocalizations.firstDayOfWeekIndex`).
- **R7.** **No se puede borrar el progreso** desde la Zona de Padres ni se ofrece la opción (P5). Solo se borra borrando los datos de la app en Android.

## 6. Criterios de aceptación

1. La primera fila de la Zona de Padres es «Su progreso», con su resumen; al tocarla se abre la pantalla y se vuelve con «atrás».
2. Con un niño que nunca ha jugado, la pantalla muestra los juegos «por descubrir» y un gráfico sin barras, sin mensajes de alarma.
3. Con progreso de varias rondas, cada tarjeta muestra solo las medallas conseguidas, la ronda y el nivel actuales (también tras bajar de ronda) y el total de estrellas.
4. Al tocar el total se abre el detalle por ronda y nivel, con las conseguidas en dorado y las posibles en contorno; los niveles no jugados dicen «por descubrir».
5. Un miércoles, el gráfico muestra lunes a miércoles de esta semana, el jueves vacío y viernes a domingo de la semana pasada en transparente. Un lunes, muestra el lunes y, tras el hueco del martes, miércoles a domingo de la semana pasada. El total suma los 6 días.
6. En Normal, si el niño llega 3 veces al nivel 4 y las 3 veces baja sin superarlo, aparece la sugerencia y un punto en la fila «Su progreso»; con 2 veces, no. «Pasar a Fácil» cambia la ronda sin quitar logros; «Ahora no» la oculta; superar el nivel la quita.
7. En Fácil, la sugerencia propone «Jugar sin tiempo» solo si está disponible.
8. En ningún texto aparecen porcentajes, fallos, comparaciones ni botones de borrar (prueba sobre las cadenas de los 9 idiomas).
9. Contraste AA con la paleta, sin colores fuera de ella (`palette_test`).

## 7. Impacto técnico

| Capa | Cambio |
|---|---|
| Dominio | `PlayHistory` (minutos por día y por `GameId`, ventana de 6 días) con la disposición del barrido (posición de cada día en la semana, semana actual o pasada, hueco). `ProgressSummary`, que reúne `GameProgress` de cada juego y el historial y elige la frase. `StuckDetector` (regla de §4.5) |
| Datos | **typeId 6** (`PlayDayHiveModel`), caja nueva `play_history` con clave por fecha. El tiempo lo suma `PlayTimeCubit`, que ya cuenta los segundos de hoy; se le añade el juego en curso. Campos nuevos en los modelos de progreso de cada juego: el nivel al que llega sin superarlo y las veces que ha bajado desde él (siguientes índices libres, sin typeId nuevo) |
| Presentación | `ParentsProgressScreen` con las tarjetas, el diálogo de estrellas y el gráfico de barras dibujado con `CustomPaint` (sin dependencia nueva) |

**Entregas:**

1. **Historial diario** y su guardado, y los contadores de avance de R4 (empieza a acumular cuanto antes; no se ve).
2. **HU-046:** la Zona de Padres por filas, con «Su progreso» como primera fila.
3. **La pantalla:** frase, tarjetas, diálogo de estrellas y gráfico.
4. **La sugerencia** (§4.5).

## 8. Preguntas

| # | Pregunta | Respuesta |
|---|---|---|
| P1 | ¿Pantalla propia o sección dentro de la Zona de Padres? | ✅ Decidido (2026-11-12): la Zona de Padres pasa a **filas que resumen la opción elegida**; al tocar una fila se abre su configuración, se guarda y se vuelve. Como máximo un nivel de profundidad. Se desarrolla como **HU-046**; «Su progreso» es una de esas filas |
| P2 | ¿Cuántos días de historia? | ✅ Decidido (2026-11-12), distinto de la recomendación: **gráfico semanal con 6 días y un hueco** que separa lo nuevo de lo viejo; al empezar la semana se ven los últimos días de la anterior (§4.3) |
| P3 | ¿Se muestran las estrellas por nivel? | ✅ Decidido (2026-11-12): el **total** en la tarjeta; al tocarlo, un **diálogo con el detalle por nivel**, para quien quiera completar el dorado (§4.4) |
| P4 | ¿Se muestra la ronda en la que está aunque haya bajado? | ✅ Decidido (2026-11-12): **sí**, como «está explorando». **Además**, una **sugerencia de bajar la dificultad** si el niño está atascado, para que disfrute y no se frustre (§4.5) |
| P5 | ¿Se puede borrar el progreso desde aquí? | ✅ Decidido (2026-11-12): **no**, ni se presentan opciones para borrarlo (R7) |
| P6 | ¿Se desarrolla pronto? | ✅ Decidido (2026-11-12): **es el próximo desarrollo** (P1 en el backlog), empezando por el historial |
| P7 | ¿Qué cuenta como «atascado»? | ✅ Decidido (2026-11-13), distinto de la recomendación: en cada juego, **llegar 3 veces al mismo nivel y volver a bajar las 3 veces sin superarlo** (§4.5). El número se puede ajustar tras la prueba cerrada |
| P8 | ¿La sugerencia avisa también fuera de la pantalla «Su progreso»? | ✅ Decidido (2026-11-13), como la recomendación: solo un **punto** en la fila «Su progreso» de la Zona de Padres. Nunca en el menú ni al niño, y sin notificaciones |
| P9 | En el detalle de estrellas, ¿se muestran las rondas Premium que el niño no tiene (la ronda Reto máximo de ¿Cuál es diferente?, el nivel 8 de Sombras)? | ✅ Decidido (2026-11-13), como la recomendación: mientras todo sea gratis (D-040) no hay diferencia; con HU-006, esas filas se muestran con el candado sutil de HU-023 y sin texto de compra |

## 9. Fuera de alcance

- Exportar, compartir o imprimir (PDF, imagen, correo).
- Sincronizar entre teléfonos o con una cuenta.
- Cambiar la dificultad sin que el adulto lo confirme: la sugerencia **propone**, no decide.
- Borrar el progreso desde la app (R7).
