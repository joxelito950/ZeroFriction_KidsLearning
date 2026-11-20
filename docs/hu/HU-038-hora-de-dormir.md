# HU-038 · Hora de dormir

| | |
|---|---|
| **Estado** | **Desarrollada** (2026-11-19, rama `feature/hu-038-bedtime`): las tres entregas (sección 8). Falta verla en el teléfono. R13 (música tranquila) llega con HU-045 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | M (3 entregas, unos 3 días) |
| **Depende de** | HU-009 (límite diario, pantalla de descanso, «15 minutos más», `ParentalSettings`). HU-046 (la Zona de Padres por filas: el ajuste va en la pantalla «Tiempo de juego»). La salida directa de la pantalla de descanso (corrección del 2026-11-12). La ilustración del niño durmiendo (PROMPTS-identidad §11), que no bloquea. HU-045 (música), solo para R13 |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** fijar una hora a partir de la cual la app invita a dormir,
**para** que el juego no alargue la noche, que ayude a preparar el sueño y que el niño lo viva como algo tranquilo, no como un castigo.

## 2. Situación actual

- HU-009 limita los **minutos al día**. Al llegar al límite, se termina el tablero y aparece la pantalla de descanso («¡Hagamos una pausa! Mañana podremos jugar de nuevo»), con acceso a la Zona de Padres y, desde el 2026-11-12, el botón «Salir».
- La sección «Tiempo de juego» de la Zona de Padres **recomienda primero los controles del sistema** («Bienestar digital y controles parentales» y Google Family Link) y después ofrece el límite propio como refuerzo.
- No hay nada que dependa de la hora del día.

## 3. Comportamiento propuesto

### 3.1 Ajuste en la Zona de Padres

En la pantalla **«Tiempo de juego»** (HU-046), debajo del límite diario, una parte nueva **«Hora de dormir»**. Es un **apoyo** a los controles del sistema, **no los sustituye** (P2):

1. **Primero, la recomendación del sistema**, con el mismo tono que el límite diario: «Android tiene un **modo Hora de dormir** (Bienestar digital) que apaga los colores y silencia el teléfono, y Family Link permite fijar un **tiempo de inactividad** para todo el dispositivo. Son la forma más completa». Sin enlaces que abran ajustes del sistema (P4).
2. **Después, la recomendación de sueño** (P1), como la leyenda de la OMS del límite diario:
   > «La OMS recomienda (2019): de 1 a 2 años, de 11 a 14 horas de sueño al día, contando las siestas; de 3 a 4 años, de 10 a 13 horas. Con horarios regulares para dormir y despertar».
3. **Después, el ajuste propio**, como refuerzo dentro de la app:

| Ajuste | Opciones | Por defecto |
|---|---|---|
| **Hora de dormir** | Interruptor | **Desactivado** |
| Desde | Selector de hora del sistema (`showTimePicker`) | 19:30 |
| Hasta | Selector de hora del sistema | 07:00 |
| **Siestas** (P6) | Interruptor y «Añadir otra siesta» (como máximo **2**) | **Desactivadas** |
| Desde · Hasta de cada siesta | Selector de hora del sistema. Cada siesta dura **de 30 min a 2 h** seguidas | 1.ª: 13:00 · 15:00. 2.ª: la primera hora libre que cumpla R7 |

Una frase resume lo elegido: «De 7:30 p. m. a 7:00 a. m., la app invita a dormir». En la fila de la Zona de Padres: «1 h al día · Dormir de 19:30 a 7:00».

**Formato de la hora (P1):** el que tenga el teléfono, **24 horas o a. m./p. m.** (`MediaQuery.alwaysUse24HourFormatOf` y `MaterialLocalizations.formatTimeOfDay`). El selector del sistema ya lo respeta.

### 3.2 Preparación para dormir: los 30 minutos antes (P5)

Media hora antes de que empiece la hora de dormir (y la siesta, si está activa), la app **ayuda a bajar el ritmo sin avisar al niño**:

- **R10.** **Se silencian los sonidos de celebración**: completar un tablero, encontrar una pareja y subir de nivel o de ronda (HU-005). Los sonidos suaves de tocar y voltear siguen, para que el juego no parezca roto.
- **R11.** **Una capa cálida** cubre la app: un velo **ámbar transparente** (variante permitida por la regla C2 de la paleta) que aparece poco a poco durante esos 30 minutos, hasta una transparencia máxima que se fija midiendo el contraste (P7). Reduce la luz fría de la pantalla, como la «Luz nocturna» de Android.
- **R12.** **Sin avisos ni cuenta atrás**: nada de «quedan 10 minutos», que generaría ansiedad. El cambio es gradual y silencioso.
- **R13.** **Con música (HU-045):** en esos 30 minutos y si la música está activa, solo suenan las piezas marcadas como **tranquilas**: tempo lento, volumen estable, sin pasajes fuertes ni sorpresas (se excluyen, por ejemplo, la «Sorpresa» de Haydn o el *presto* del «Verano» de Vivaldi). Esa lista se define en HU-045.
- La capa y el silencio se quitan al llegar la hora «Hasta», o si se desactiva la hora de dormir.

### 3.3 Qué ve el niño

- **R1.** Si se abre la app dentro del horario, aparece directamente la **pantalla de descanso en su versión de noche**.
- **R2.** Si el horario empieza mientras juega, **se termina el tablero en curso** (como HU-009 R4) y después aparece la pantalla de noche. Nunca se corta un tablero a medias.
- **R3.** La versión de noche usa la misma pantalla de descanso con otra ilustración y otro texto: **el niño dormido bajo una luna** (PROMPTS §11), fondo en teal profundo y textos en crema, «¡A dormir!» y «Mañana seguimos jugando». En la siesta: «¡A descansar!» y «Luego seguimos jugando». Sin cuenta atrás, sin rojo, sin sonido.
- **R4.** Tiene los mismos botones que la de descanso: Zona de Padres (doble toque y desafío) y «Salir».
- **R5.** Desde la Zona de Padres, el adulto puede dar **15 minutos más**, como en HU-009 (el botón aparece arriba de la Zona de Padres, HU-046). Si se llega también al límite diario, manda el que llegue primero.
- **R6.** A la hora «Hasta», la app vuelve a ser normal. Si estaba abierta en la pantalla de noche, cambia sola al menú.

### 3.4 Reglas

- **R7.** El horario de la noche puede cruzar la medianoche (19:30–07:00). Si «Desde» y «Hasta» son iguales, no se puede guardar.
- **R7a.** Las siestas (P6), como máximo **dos al día**, duran cada una **entre 30 minutos y 2 horas seguidas**, no cruzan la medianoche y **no se solapan** entre sí ni con la noche. Entre una siesta y la otra, y entre una siesta y la noche, quedan **al menos 2 horas** libres. Si no se cumple, «Guardar» no se activa y una frase amable dice qué ajustar («Deja al menos 2 horas entre la siesta y la noche»).
- **R8.** Se usa el **reloj del teléfono**, en su zona horaria. Si el adulto cambia la hora del teléfono, la app la sigue (P3).
- **R9.** El horario es **el mismo todos los días** (P2). Todo ocurre en el teléfono. No se envía nada.

## 4. Criterios de aceptación

1. Con la hora de dormir desactivada, nada cambia.
2. Con el horario 19:30–07:00, abrir la app a las 22:00 muestra la pantalla de noche; a las 07:00 se vuelve al menú.
3. Si el horario empieza a mitad de un tablero, ese tablero se termina antes de mostrar la pantalla de noche.
4. A las 19:00 se silencian los sonidos de celebración (no los de tocar) y empieza la capa cálida, que llega a su máximo a las 19:30. Nada lo anuncia.
5. Con el teléfono en formato a. m./p. m., las horas se muestran así; con 24 horas, en 24 horas.
6. Cada siesta, activada, funciona igual con su texto propio. Se pueden configurar hasta 2; no se puede guardar una siesta de menos de 30 min o de más de 2 h, ni dos siestas (o una siesta y la noche) a menos de 2 h.
7. Los «15 minutos más» funcionan igual que en el límite diario.
8. La pantalla «Tiempo de juego» muestra primero la recomendación del sistema, después la de la OMS y después el ajuste, en los 9 idiomas, también en árabe.
9. La pantalla de noche y el juego con la capa cálida al máximo cumplen el contraste AA con la paleta.

## 5. Impacto técnico

| Capa | Cambio |
|---|---|
| Dominio | `Bedtime` (desde y hasta en minutos desde la medianoche; `contains(DateTime)` con el cruce de medianoche; `windDownProgress(DateTime)` de 0 a 1 en los 30 minutos antes). Un `RestSchedule` con la noche y hasta 2 siestas, que valida la duración (30 min a 2 h), el solape y la separación de 2 h (R7a) |
| Datos | Campos nuevos en `ParentalSettingsHiveModel`: inicio y fin de la noche y de cada una de las 2 siestas (`null` = desactivada) y el permiso en curso (la hora a la que acaban los 15 minutos), con los siguientes índices libres |
| Presentación | `PlayTimeCubit` decide «descanso» por límite **o** por horario, y expone cuál, para elegir la versión de la pantalla, y el avance de la preparación. Un temporizador hasta el próximo cambio (no un sondeo cada minuto). `RestScreen` gana las variantes de noche y siesta. `WarmVeil` sobre el `MaterialApp` (ámbar con transparencia). El servicio de sonidos de HU-005 consulta si está en preparación antes de sonar una celebración |
| Zona de Padres | Parte nueva en la pantalla «Tiempo de juego» (HU-046) |
| Catálogo | La leyenda de sueño de la OMS, siesta, textos de las pantallas y el resumen, en 9 idiomas |

**Entregas:** (1) dominio, guardado, ajuste en la Zona de Padres y pantalla de noche con el icono `bedtime`; (2) la preparación de 30 minutos (sonidos y capa cálida); (3) la ilustración del niño durmiendo cuando exista. R13 llega con HU-045.

## 6. Preguntas

| # | Pregunta | Respuesta |
|---|---|---|
| P1 | ¿Horas por defecto y formato? | ✅ Decidido (2026-11-12): **19:30 a 7:00**; la hora en el **formato del teléfono** (24 h o a. m./p. m.) y una **recomendación de sueño** en el ajuste (§3.1). **Sobre la siesta:** la OMS **no fija una hora** para la siesta; sus pautas de 2019 dan las horas totales de sueño (contando las siestas) y piden horarios regulares. La costumbre que recomiendan los pediatras es una siesta temprano por la tarde, después de comer, y no a última hora de la tarde para no retrasar la noche; de ahí el 13:00–15:00 por defecto. Ese consejo no se atribuye a la OMS en la app |
| P2 | ¿Horarios distintos el fin de semana? | ✅ Decidido (2026-11-12): **no**. El ajuste es general y **no pretende reemplazar** los controles del sistema, solo apoyarlos |
| P3 | ¿Se protege contra cambiar la hora del teléfono? | ✅ Decidido (2026-11-12): **no**, como la recomendación |
| P4 | ¿Un botón que abra los ajustes de Bienestar digital? | ✅ Decidido (2026-11-12): **no**, como la recomendación |
| P5 | ¿Cambia algo antes de la hora? | ✅ Decidido (2026-11-12), distinto de la recomendación: **sí, una preparación de 30 minutos** sin avisos: sin sonidos de celebración, capa cálida gradual y, con HU-045, solo música tranquila (§3.2) |
| P6 | ¿Un segundo horario para la siesta? | ✅ Decidido (2026-11-18): **sí**, como la recomendación (opcional y desactivado, 13:00–15:00 por defecto), y además **hasta 2 siestas al día**, de **30 min a 2 h** seguidas cada una, que no se solapen y con **al menos 2 h** entre ellas y con la noche (R7a) |
| P7 | ¿Cuánta capa cálida? | ✅ Decidido (2026-11-19): **ámbar con una transparencia de hasta un 15 %**, ajustada midiendo que el texto y los botones sigan cumpliendo AA, y vista en el moto g55. **Medido:** queda en un **14 %** (sección 8.2) |

## 7. Fuera de alcance

- Bloquear otras apps o el teléfono.
- Horarios por día de la semana.
- Avisos o notificaciones.
- Cambiar la luz o los colores del sistema: la capa cálida solo cubre la app.

## 8. Desarrollo

| # | Entrega | Estado |
|---|---|---|
| 1 | Dominio, guardado, ajuste en la Zona de Padres y pantalla de noche | ✅ 2026-11-19, rama `feature/hu-038-bedtime` |
| 2 | Preparación de 30 minutos: sin sonidos de celebración y capa cálida ámbar al 14 % (P7) | ✅ 2026-11-19, misma rama (sección 8.2) |
| 3 | La ilustración del niño durmiendo | ✅ 2026-11-19: ya estaba en `assets/brand/child_sleeping.png` y entró con la entrega 1 |

### 8.1 Entrega 1 (2026-11-19)

- **Dominio** (`domain/parental/rest_schedule.dart`):
  - `RestWindow`: desde y hasta en minutos desde la medianoche, con el cruce de medianoche (R7);
  - `RestSchedule`: la noche y hasta 2 siestas. `problem` dice por qué no se puede guardar: horas iguales, siesta de menos de 30 min o más de 2 h, siesta que cruza la medianoche, o descansos a menos de 2 h (R7a). `suggestedNap` propone 13:00–15:00 si cabe; si no, la primera hora libre.
- **Guardado:** campos 8 a 11 de `ParentalSettingsHiveModel` (SPECIFICATION 3.4). Un horario dañado se lee como apagado, para que la app nunca se quede en la pantalla de noche.
- **Tiempo de juego** (`PlayTimeCubit`):
  - decide el descanso por el límite **o** por el horario (`restDue`), y dice cuál (`scheduledRest`: noche o siesta);
  - se mira la hora en cada segundo que ya contaba HU-009, así que no hace falta otro temporizador;
  - el tablero en curso se termina antes (R2), y el tiempo frente a la pantalla de noche no cuenta como jugado.
- **«15 minutos más»** (R5): en la noche o la siesta dejan jugar 15 minutos, también tras cerrar la app (campo 11). Con el límite diario alcanzado a la vez, el mismo botón da tiempo para los dos.
- **Pantalla de noche** (R3): `RestScreen(kind:)` con el niño durmiendo bajo la luna, fondo teal profundo y textos en crema; «¡A dormir!» y «¡A descansar!». Si el motivo cambia con la pantalla abierta (del límite a la noche), cambia sola; a la hora «Hasta» vuelve el menú (R6).
- **Zona de Padres:**
  - en «Tiempo de juego», debajo del límite: la recomendación del sistema, la de sueño de la OMS y el ajuste, con el selector de hora del sistema en el formato del teléfono (P1);
  - siestas con «Añadir otra siesta» y «Quitar esta siesta»;
  - si algo no cumple las reglas, una frase amable sin rojo, y «Guardar» no guarda;
  - la fila dice «60 min al día · Dormir de 19:30 a 7:00».
- **Textos** en los 9 idiomas: 20 claves nuevas.
- **Tests:** horario y reglas, guardado y datos dañados, cubit (abrir de noche, tablero en curso, fin de la noche, 15 minutos, límite y noche a la vez), pantalla de noche y de siesta, la app real pasando de la noche al menú, y el ajuste con el selector de hora. Cobertura del 100 % en los archivos de la historia.

### 8.2 Entrega 2 (2026-11-19)

- **Dominio:** `RestSchedule.windDownAt` dice cuánto ha avanzado la preparación: 0 fuera de ella; sube poco a poco en los 30 minutos antes de la noche o de una siesta; vale 1 durante el descanso, hasta la hora «Hasta».
- **Tiempo de juego:** `PlayTimeState.windDown` se actualiza cada segundo, con el mismo reloj que ya contaba el tiempo. Sin avisos ni cuenta atrás: el niño sigue jugando hasta la hora (R12).
- **Sonidos** (R10): `SoundCubit.setCelebrationsMuted` calla las celebraciones (pareja, tablero, insignia o medalla). El sonido de voltear y tocar sigue, y el interruptor de sonido de los padres no cambia.
- **Capa cálida** (R11, `WarmVeil`):
  - un velo ámbar sobre toda la app, también encima de los diálogos;
  - no recibe toques y el lector de pantalla no lo lee;
  - se quita sola a la hora «Hasta».
- **Transparencia máxima (P7):** con un 15 %, el azul petróleo sobre el crema baja a 4,47:1, por debajo de AA. Con un **14 %** queda en 4,54:1, y todos los pares medidos cumplen: texto, botones, la Zona de Padres y la pantalla de noche. Lo vigila el test de la paleta.
- **Tests:** la preparación a las 19:00, 19:15 y 19:29 y durante el descanso; antes de una siesta; el estado del cubit; el sonido; la app real con la capa al 50 %, sin tapar los toques, y sin capa a las 7:00; el contraste con la capa al máximo.

### 8.3 Prueba en el moto g55 (2026-11-19)

Con la versión instalada conservando los datos y la hora de dormir puesta a las 15:45:

- **Se vio bien:** la parte «Hora de dormir» en su orden, el interruptor con 19:30–7:00, el selector de hora y la **capa cálida**. El crema del menú pasó de (255, 242, 226) a (253, 235, 215) a las 15:33, justo lo que toca con un 14 % de ámbar al 60 % de la preparación. El horario se conservó al reinstalar.
- **Tres fallos, corregidos:**
  1. La fila «Tiempo de juego» no se actualizaba al guardar la hora de dormir: solo se repintaba al cambiar el límite.
  2. **La Zona de Padres se cerraba sola mientras se elegía la hora.** El selector es otra ruta, y sus toques no contaban como actividad (HU-004 R7, un minuto). Ahora los cuenta (`AdultSessionGuard.registerActivity`).
  3. **Formato de la hora:** en español Flutter escribe las horas en 24 h aunque el teléfono esté en a. m./p. m. En el modo teclado, el selector validaba con el formato del teléfono y no dejaba escribir las 15:00. Ahora la pantalla y el selector usan el mismo formato (`use24HourTimes`): 24 h si el teléfono lo pide o si el idioma escribe así las horas (español, francés, alemán…); a. m./p. m. en inglés con el teléfono en 12 h. **Cambia P1:** «el formato del teléfono» pasa a ser «el del teléfono o el del idioma», porque el selector de Flutter no ofrece a. m./p. m. en español.
- **Pendiente en el teléfono:** ver la pantalla de noche a la hora y los «15 minutos más». Después hay que quitar la hora de prueba, porque el teléfono quedó con 15:45–7:00.
