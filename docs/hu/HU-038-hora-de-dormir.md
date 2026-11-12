# HU-038 · Hora de dormir

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-11-12). Faltan las respuestas del dueño a P1–P5 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | S–M (2 entregas, unos 2 días) |
| **Depende de** | HU-009 (límite diario, pantalla de descanso, «15 minutos más», `ParentalSettings`). La salida directa de la pantalla de descanso (corrección del 2026-11-12). La ilustración del niño durmiendo (PROMPTS-identidad §11), que no bloquea |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** fijar una hora a partir de la cual la app invita a dormir,
**para** que el juego no alargue la noche y el niño lo viva como algo tranquilo, no como un castigo.

## 2. Situación actual

- HU-009 limita los **minutos al día**. Al llegar al límite, se termina el tablero y aparece la pantalla de descanso («¡Hagamos una pausa! Mañana podremos jugar de nuevo»), con acceso a la Zona de Padres y, desde el 2026-11-12, el botón «Salir».
- La sección «Tiempo de juego» de la Zona de Padres **recomienda primero los controles del sistema** («Bienestar digital y controles parentales» y Google Family Link) y después ofrece el límite propio como refuerzo.
- No hay nada que dependa de la hora del día.

## 3. Comportamiento propuesto

### 3.1 Ajuste en la Zona de Padres

Dentro de la sección **«Tiempo de juego»**, debajo del límite diario (como pide el dueño), una parte nueva **«Hora de dormir»**:

1. **Primero, la recomendación del sistema**, con el mismo tono que el límite diario: «Android tiene un **modo Hora de dormir** (Bienestar digital) que apaga los colores y silencia el teléfono, y Family Link permite fijar un **tiempo de inactividad** para todo el dispositivo. Son la forma más completa». Sin enlaces que abran ajustes del sistema (P4).
2. **Después, el ajuste propio**, como refuerzo dentro de la app:

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Hora de dormir** | Interruptor | **Desactivado** |
| Desde | Selector de hora del sistema (`showTimePicker`) | 19:30 |
| Hasta | Selector de hora del sistema | 07:00 |

Una frase resume lo elegido: «De 19:30 a 7:00, la app invita a dormir».

### 3.2 Qué ve el niño

- **R1.** Si se abre la app dentro del horario, aparece directamente la **pantalla de descanso en su versión de noche**.
- **R2.** Si el horario empieza mientras juega, **se termina el tablero en curso** (como HU-009 R4) y después aparece la pantalla de noche. Nunca se corta un tablero a medias.
- **R3.** La versión de noche usa la misma pantalla de descanso con otra ilustración y otro texto: **el niño dormido bajo una luna** (PROMPTS §11), fondo en teal profundo y textos en crema, «¡A dormir!» y «Mañana seguimos jugando». Sin cuenta atrás, sin rojo, sin sonido.
- **R4.** Tiene los mismos botones que la de descanso: Zona de Padres (doble toque y desafío) y «Salir».
- **R5.** Desde la Zona de Padres, el adulto puede dar **15 minutos más** esta noche, como en HU-009. Si se llega también al límite diario, manda el que llegue primero.
- **R6.** A la hora «Hasta», la app vuelve a ser normal. Si estaba abierta en la pantalla de noche, cambia sola al menú.

### 3.3 Reglas

- **R7.** El horario puede cruzar la medianoche (19:30–07:00) o no (13:00–15:00, una siesta). Si «Desde» y «Hasta» son iguales, el ajuste no se puede guardar.
- **R8.** Se usa el **reloj del teléfono**, en su zona horaria. Si el adulto cambia la hora del teléfono, la app la sigue: no hay forma fiable ni necesaria de evitarlo (P3).
- **R9.** Todo ocurre en el teléfono. No se envía nada.

## 4. Criterios de aceptación (borrador)

1. Con la hora de dormir desactivada, nada cambia.
2. Con el horario 19:30–07:00, abrir la app a las 22:00 muestra la pantalla de noche; a las 07:00 se vuelve al menú.
3. Si el horario empieza a mitad de un tablero, ese tablero se termina antes de mostrar la pantalla de noche.
4. Los «15 minutos más» funcionan igual que en el límite diario.
5. La sección muestra primero la recomendación del sistema y después el ajuste, en los 9 idiomas, también en árabe.
6. La pantalla de noche cumple el contraste AA con la paleta (crema sobre teal profundo).

## 5. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `Bedtime` (desde y hasta en minutos desde la medianoche; `contains(DateTime)` con el cruce de medianoche) |
| Datos | Campos nuevos en `ParentalSettingsHiveModel`: inicio y fin (`null` = desactivada) y el permiso de esta noche (la hora a la que acaban los 15 minutos), con los siguientes índices libres |
| Presentación | `PlayTimeCubit` decide «descanso» por límite **o** por horario, y expone cuál de los dos, para elegir la versión de la pantalla. Un temporizador hasta el próximo cambio de horario (no un sondeo cada minuto). `RestScreen` gana la variante de noche |
| Zona de Padres | Parte nueva en `ParentsPlayTimeSection` |

**Entregas:** (1) dominio, guardado, ajuste en la Zona de Padres y pantalla de noche con el icono `bedtime`; (2) la ilustración del niño durmiendo cuando exista.

## 6. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Horas por defecto? | **19:30 a 7:00**, habituales de 2 a 5 años. El adulto las cambia |
| P2 | ¿Horarios distintos el fin de semana? | **No** en esta historia: añade pantalla y casi nadie lo usa. Para eso están los controles del sistema |
| P3 | ¿Se protege contra cambiar la hora del teléfono? | **No.** Quien cambia la hora es un adulto; la app no es un control parental del sistema y lo dice |
| P4 | ¿Un botón que abra los ajustes de Bienestar digital? | **No.** El intent cambia según el fabricante y puede fallar; basta con nombrarlo, como hoy en el límite diario |
| P5 | ¿Se oscurece también el menú poco antes de la hora? | **No** por ahora: un aviso previo («quedan 10 minutos») genera ansiedad en el niño. Se reconsidera tras la prueba cerrada |

## 7. Fuera de alcance

- Bloquear otras apps o el teléfono.
- Horarios por día de la semana.
- Avisos o notificaciones.
