# HU-004 · Gatekeeper de la Zona de Padres

| | |
|---|---|
| **Estado** | En curso (entrega 1 de 3 hecha el 2026-10-26; plan en la sección 10) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2 |
| **Tamaño** | M (3–4 días) |
| **Desbloquea** | HU-005 (ajustes), HU-006 (compras), HU-009 (tiempo diario y «Fijar pantalla»), HU-010 (inicio del juego de memoria), HU-012 (idioma) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** que los ajustes y las compras de la app estén detrás de un desafío que solo pueda resolver un adulto,
**para** que mi hijo no cambie la configuración ni compre nada por accidente.

## 2. Situación actual

- El menú tiene un botón «Zona de Padres» que solo muestra el aviso «Próximamente».
- README, módulo 4: «Un desafío de lógica textual/matemática simple para adultos que bloquea el acceso a la tienda y configuraciones, evitando compras accidentales del niño».
- Especificación 4.2: las acciones de adulto (compras, ajustes) DEBEN quedar tras el Gatekeeper.

## 3. Qué piden las tiendas

| Tienda | Requisito | Fuente |
|---|---|---|
| Apple (App Store, categoría Kids) | Una «parental gate» (tarea de nivel adulto) antes de comprar, abrir enlaces externos o pedir permisos. Apple pone como ejemplo válido **una tarea matemática** | Apple Developer · Kids apps |
| Google Play | Las compras de apps del apartado infantil ya exigen la autenticación de Google Play. Los enlaces externos o las compras sin un control propio pueden chocar con la política de Familias | Google Play · guía parental |

Conclusión: un **desafío matemático propio** cumple con Apple (para el futuro iOS) y añade una capa de protección sobre la de Google Play.

## 4. Diseño del desafío

### Requisitos que debe cumplir

1. **Fácil para un adulto** (menos de 10 s) e **imposible por azar** para un niño de 3 años, que no sabe leer ni multiplicar y toca la pantalla al azar.
2. **Funciona en los 9 idiomas** (HU-011) sin depender de la cultura local.
3. **Sin sonidos ni mensajes negativos** (principios del README), aunque lo intente el niño.

### Opciones evaluadas

| Opción | Probabilidad de acertar por azar | Valoración |
|---|---|---|
| **A. Multiplicación con números escritos en palabras** («¿Cuánto es siete por tres?») y respuesta con un **teclado numérico propio** | ~1 % por intento (respuestas de 2 cifras) | ✅ **Recomendada.** Exige leer y calcular; es el ejemplo de Apple |
| B. La misma pregunta con 4 respuestas para elegir | 25 % por intento | ❌ Demasiado fácil de acertar tocando al azar |
| C. Mantener pulsado o un gesto | Alta | ❌ No exige razonar; un niño lo hace por accidente |
| D. Pedir el año de nacimiento | Alta, y Apple no acepta las comprobaciones de edad como gate | ❌ |

### Reglas (opción A, elegida el 2026-10-21)

| # | Regla |
|---|---|
| R1 | **Doble toque para entrar:** el primer toque en «Zona de Padres» muestra un **aviso pequeño** («Toca otra vez para entrar»), sin botones ni pantalla completa, como la salida protegida (D-025). Solo un **segundo toque dentro de 2 segundos** abre el desafío; si no, el aviso desaparece y no pasa nada. Superar el desafío abre la Zona de Padres |
| R2 | La pregunta es una multiplicación de dos factores al azar **entre 3 y 9** (resultados de 9 a 81), escritos **con palabras** en el idioma de la app («siete», «seven», «sieben», «七», «سبعة»…). Así un niño no puede «copiar» las cifras en el teclado |
| R3 | La respuesta se escribe con un **teclado numérico propio** (0–9, borrar, aceptar), no con el del sistema. **Las cifras aparecen en orden aleatorio**, distinto en cada desafío, para que no se pueda memorizar la posición de las teclas ni pulsarlas de memoria |
| R4 | **Respuesta incorrecta:** aparece un **mensaje** para el adulto o el niño que indica cuántos intentos quedan, con tres opciones: **«Reintentar»**, una **«X»** para cerrar y un botón **«Volver al menú»**. La «X» y «Volver al menú» llevan al menú principal |
| R5 | El mensaje tiene un **temporizador de 5 segundos**: si nadie elige, vuelve solo al menú principal. Así, si quien juega es un niño, regresa a sus juegos sin hacer nada; solo un adulto que lee el mensaje pulsa «Reintentar». **Sin penalización** por fallar varios desafíos: no hay esperas ni bloqueos, y siempre se puede volver a entrar |
| R6 | El desafío tiene un botón **«Volver»** al menú. Fuera de los juegos sí se permiten botones (D-022), y uno pulsado por error solo devuelve al menú |
| R7 | **Mínima exposición:** la Zona de Padres se cierra y vuelve al **menú principal** al salir de ella, al **apagar la pantalla**, al pasar la app a **segundo plano** o tras **1 minuto sin ninguna acción** dentro de ella. Cada nueva entrada exige un desafío nuevo |
| R8 | La lógica del desafío (generar la pregunta, barajar el teclado, validar la respuesta, contar los intentos) es **lógica pura de dominio**, con el azar y el reloj inyectados para poder probarla |
| R9 | **Regla general para el futuro:** toda compra (HU-006), enlace externo (por ejemplo, la política de privacidad de HU-014) o petición de permiso pasa por el mismo desafío |

### Contenido de la Zona de Padres en esta historia (P4: lo básico)

- La **estructura**: título, una lista de secciones y el botón «Volver al menú».
- **«Fijar pantalla»:** instrucciones breves para activarlo en el teléfono (parte informativa de HU-009, sin código nativo).
- Las secciones de HU-005, HU-010 y HU-012 se añaden con sus historias. Mientras no existan, no se muestran: nada de botones de «Próximamente».

## 5. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| D-022 (sin botones en los juegos) | No aplica: el desafío y la Zona de Padres no son juegos. Se permiten botones (R6) |
| D-025 (salida protegida) | Ver P5: ¿la Zona de Padres, usada por adultos, también pide repetir el «atrás»? |
| D-027 (multiidioma) | Los números en palabras van al catálogo, del 3 al 9, en los 9 idiomas |
| D-028 (juego de memoria gratuito) | La Zona de Padres no muestra compras hasta HU-006 |
| HU-001, R21 | El menú tendrá «Zona de Padres» y «Salir» juntos. Conviene que HU-004 y la entrega 5 de HU-001 coordinen el diseño de esa zona del menú |

## 6. Criterios de aceptación (borrador)

1. **Dado** el menú, **cuando** toco una vez «Zona de Padres», **entonces** veo el aviso pequeño «Toca otra vez para entrar», sin botones, y sigo en el menú; **cuando** vuelvo a tocar antes de 2 segundos, **entonces** veo una multiplicación escrita en palabras en el idioma de la app y un teclado numérico; **cuando** no vuelvo a tocar, **entonces** el aviso desaparece.
2. **Dado** el desafío, **cuando** escribo el resultado correcto y acepto, **entonces** entro en la Zona de Padres.
3. **Dado** el desafío, **cuando** escribo un resultado incorrecto, **entonces** veo un mensaje con los intentos que me quedan y las opciones «Reintentar», «X» y «Volver al menú», sin sonido ni color rojo.
4. **Dado** el mensaje de respuesta incorrecta, **cuando** pasan 5 segundos sin elegir nada, **entonces** vuelvo al menú principal; **cuando** pulso «Reintentar», **entonces** veo una pregunta nueva con el teclado barajado de nuevo; **cuando** pulso «X» o «Volver al menú», **entonces** vuelvo al menú principal.
5. **Dado** el desafío, **cuando** toco «Volver», **entonces** regreso al menú.
6. **Dado** que estoy en la Zona de Padres, **cuando** salgo de ella, apago la pantalla, paso la app a segundo plano o estoy 1 minuto sin hacer nada, **entonces** estoy en el menú principal y la próxima entrada pide un desafío nuevo.
7. **Dado** 10 000 respuestas al azar de 1 o 2 cifras en un test, **entonces** se aciertan aproximadamente el 1 % o menos (comprobación estadística del generador).
8. **Dado** cada idioma, **entonces** la pregunta se lee con naturalidad (los números del 3 al 9 están en el catálogo, con revisión externa) y la pantalla no se desborda en vertical ni en horizontal.
9. **Dado** el lector de pantalla, **entonces** la pregunta y las teclas tienen etiquetas en el idioma de la app.
10. **Dado** dos desafíos seguidos, **entonces** el orden de las cifras del teclado cambia.
11. **Dado** que fallo todos los intentos de una entrada, **entonces** vuelvo al menú sin esperas ni bloqueos y puedo volver a intentarlo enseguida.

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `ParentalGate`: genera preguntas (factores 3–9) y el orden aleatorio del teclado con `Random` inyectado, valida respuestas y cuenta los intentos. Dart puro |
| Presentación | `ParentalGateScreen` (pregunta y teclado propio), `ParentsZoneScreen` (estructura e instrucciones de «Fijar pantalla»), control de inactividad y de segundo plano; el botón del menú navega al desafío |
| Catálogo | Unas 15 claves nuevas en los 9 idiomas: los números del 3 al 9, la pregunta, los mensajes y los textos de la Zona de Padres |
| Persistencia | Ninguna: no hay bloqueos ni esperas que guardar |
| Tests | Lógica del desafío (incluido el test estadístico del criterio 7), widgets del desafío y de la zona, inactividad con `fake_async`, layout en los 9 idiomas |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Qué tipo de desafío? | ✅ Decidido: opción A, multiplicación escrita en palabras, con un teclado numérico propio cuyas cifras aparecen **en orden aleatorio** | — |
| P2 | ¿Qué pasa al fallar? | ✅ Decidido: mensaje con los intentos que quedan, «Reintentar», «X» y «Volver al menú», y vuelta automática al menú a los 5 s. Sin esperas ni bloqueos (R4, R5) | — |
| P3 | ¿Cuánto dura el acceso? | ✅ Decidido: mínima exposición. Se cierra al salir, al apagar la pantalla, al pasar a segundo plano o tras 1 minuto sin acciones (R7) | — |
| P4 | ¿Qué contiene la Zona de Padres en esta historia? | ✅ Decidido: lo básico. La estructura y las instrucciones de «Fijar pantalla»; cada sección nueva llega con su historia (HU-012, HU-010, HU-005…) | — |
| P5 | ¿El «atrás» del sistema dentro de la Zona de Padres también pide repetir el gesto (D-025)? | ✅ Asumida la recomendación: no; es una zona de adultos y el «atrás» vuelve al menú directamente | — |
| P6 | ¿El teclado usa cifras occidentales (0–9) también en árabe? | ✅ Asumida la recomendación: sí; la respuesta se compara como número | — |

### Riesgo aceptado (2026-10-21): sin penalización, un niño puede insistir

Sin esperas ni bloqueos, un niño que toca al azar puede repetir el desafío sin límite. Cada intento acierta por azar en torno al **1 %**; con 3 intentos por entrada, en torno al **3 % de las entradas**, es decir, unas **30 entradas de media** para entrar por casualidad. Se acepta porque:

- Para llegar a «Reintentar», el niño debe tocar justo ese botón **antes de 5 segundos**; si no, vuelve solo a sus juegos. Y cada entrada nueva exige tocar **dos veces seguidas** «Zona de Padres» (R1).
- El teclado barajado impide repetir de memoria una secuencia de toques.
- En esta historia, la Zona de Padres no contiene nada dañino (estructura e instrucciones). Las compras (HU-006) tendrán además la autenticación de Google Play.
- Si en la prueba cerrada (HU-014) se viera que algún niño entra, se puede añadir una espera breve solo tras muchas entradas fallidas seguidas.

### Supuestos sobre P2, P3 y R1 (confirmados el 2026-10-21)

| # | Supuesto | Valor aplicado |
|---|---|---|
| S1 | ¿Cuántos intentos hay en cada entrada? | **3**. Tras el tercer fallo, el mensaje ya no ofrece «Reintentar» y vuelve al menú |
| S2 | ¿«Reintentar» muestra la misma pregunta o una nueva? | Una nueva, con el teclado barajado de nuevo: evita probar respuestas una a una |
| S3 | ¿Cómo se ve el temporizador de 5 s del mensaje? | Una barra que se vacía, sin números, como la del juego (D-021) |
| S4 | ¿El minuto de inactividad cuenta también en la pantalla del desafío? | Sí: si nadie toca nada durante 1 minuto, vuelve al menú |
| S5 | ¿Cuánto tiempo hay para el segundo toque en «Zona de Padres»? | **2 segundos**, igual que la salida protegida (D-025), para que toda la app se comporte igual |

## 9. Fuera de alcance

- Las secciones de ajustes: idioma (HU-012), inicio del juego de memoria (HU-010), sonido y dificultad (HU-005), tiempo diario (HU-009, salvo las instrucciones de «Fijar pantalla»).
- Compras y restauración (HU-006).
- Un PIN o contraseña configurables por los padres (se podría valorar más adelante si el desafío resulta incómodo).

## 10. Plan de entregas (un PR cada una)

| # | Entrega | Incluye | Criterios cubiertos |
|---|---|---|---|
| 1 | Reglas del desafío | `ParentalGate` en `lib/domain/parental/`: preguntas con factores del 3 al 9, teclado barajado, validación e intentos, con el azar inyectado (R8). Tests unitarios, incluido el estadístico | 7, 10 y base de 2–4 y 11 |
| 2 | Desafío en pantalla | Doble toque en «Zona de Padres» (R1), `ParentalGateScreen` con la pregunta en palabras y el teclado propio, mensaje de fallo con temporizador de 5 s (R4, R5), botón «Volver» (R6), números del 3 al 9 y textos en los 9 idiomas, tests de widget y de layout | 1–5, 8, 9 y 11 |
| 3 | Zona de Padres | `ParentsZoneScreen` con su estructura e instrucciones de «Fijar pantalla», cierre por salida, pantalla apagada, segundo plano e inactividad de 1 minuto (R7, S4), tests con `fake_async` y de layout | 6 |

### Avance

| # | Entrega | Estado | Rama | Notas |
|---|---|---|---|---|
| 1 | Reglas del desafío | ✅ Hecha (2026-10-26) | `feature/hu-004-1-gate-domain` | `ParentalGate` y `ParentalGateChallenge` (Dart puro): `start` da 3 intentos; `check` devuelve aprobado, fallo con intentos o entrada agotada; `retry` da otra pregunta y otro orden del teclado (nunca los mismos que el desafío fallido) con un intento menos. 14 tests, entre ellos los 49 pares posibles de factores, el teclado con las 10 cifras sin repetir, el sorteo repetido con un `Random` programado y 10 000 respuestas al azar (menos del 2 % aciertan). Cobertura del 100 % |
