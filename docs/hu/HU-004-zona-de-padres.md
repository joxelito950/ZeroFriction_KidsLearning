# HU-004 · Gatekeeper de la Zona de Padres

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-10-20; el desarrollo **no** ha empezado) |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2 |
| **Tamaño** | M (3–4 días), por confirmar con las preguntas de la sección 8 |
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

## 4. Diseño del desafío (propuesta)

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

### Reglas propuestas (opción A)

| # | Regla |
|---|---|
| R1 | El botón «Zona de Padres» del menú abre el desafío. Superarlo abre la Zona de Padres |
| R2 | La pregunta es una multiplicación de dos factores al azar **entre 3 y 9** (resultados de 9 a 81), escritos **con palabras** en el idioma de la app («siete», «seven», «sieben», «七», «سبعة»…). Así un niño no puede «copiar» las cifras en el teclado |
| R3 | La respuesta se escribe con un **teclado numérico propio** (0–9, borrar, aceptar), no con el del sistema, para que se vea igual en todos los teléfonos y no aparezcan sugerencias ni emojis |
| R4 | **Respuesta incorrecta:** el campo se vacía, aparece una pregunta nueva y un mensaje neutro («Prueba con esta otra»), sin sonido ni color rojo |
| R5 | **Tres fallos seguidos:** el desafío se bloquea **30 segundos**, con una cuenta atrás visible y neutra; después, pregunta nueva |
| R6 | El desafío tiene un botón **«Volver»** al menú. Fuera de los juegos sí se permiten botones (D-022), y uno pulsado por error solo devuelve al menú |
| R7 | **Duración del acceso:** la Zona de Padres queda abierta mientras el adulto está dentro. Al volver al menú, al enviar la app a segundo plano o tras **2 minutos sin actividad**, se cierra y la próxima vez se pide un desafío nuevo |
| R8 | La lógica del desafío (generar la pregunta, validar la respuesta, bloqueo por fallos) es **lógica pura de dominio**, con el azar y el reloj inyectados para poder probarla |
| R9 | **Regla general para el futuro:** toda compra (HU-006), enlace externo (por ejemplo, la política de privacidad de HU-014) o petición de permiso pasa por el mismo desafío |

### Contenido de la Zona de Padres en esta historia (propuesta, ver P4)

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

1. **Dado** el menú, **cuando** toco «Zona de Padres», **entonces** veo una multiplicación escrita en palabras en el idioma de la app y un teclado numérico.
2. **Dado** el desafío, **cuando** escribo el resultado correcto y acepto, **entonces** entro en la Zona de Padres.
3. **Dado** el desafío, **cuando** escribo un resultado incorrecto, **entonces** el campo se vacía, aparece otra pregunta y un mensaje neutro, sin sonido ni rojo.
4. **Dado** que fallo 3 veces seguidas, **entonces** el desafío se bloquea 30 s con una cuenta atrás y después muestra una pregunta nueva.
5. **Dado** el desafío, **cuando** toco «Volver», **entonces** regreso al menú.
6. **Dado** que estoy en la Zona de Padres, **cuando** vuelvo al menú, envío la app a segundo plano o pasan 2 minutos sin tocar la pantalla, **entonces** la próxima entrada pide un desafío nuevo.
7. **Dado** 10 000 respuestas al azar de 1 o 2 cifras en un test, **entonces** se aciertan aproximadamente el 1 % o menos (comprobación estadística del generador).
8. **Dado** cada idioma, **entonces** la pregunta se lee con naturalidad (los números del 3 al 9 están en el catálogo, con revisión externa) y la pantalla no se desborda en vertical ni en horizontal.
9. **Dado** el lector de pantalla, **entonces** la pregunta y las teclas tienen etiquetas en el idioma de la app.

## 7. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | `ParentalGate`: genera preguntas (factores 3–9, `Random` inyectado), valida respuestas y lleva el bloqueo por fallos (reloj inyectado). Dart puro |
| Presentación | `ParentalGateScreen` (pregunta y teclado propio), `ParentsZoneScreen` (estructura e instrucciones de «Fijar pantalla»), control de inactividad y de segundo plano; el botón del menú navega al desafío |
| Catálogo | Unas 15 claves nuevas en los 9 idiomas: los números del 3 al 9, la pregunta, los mensajes y los textos de la Zona de Padres |
| Persistencia | Ninguna: el bloqueo de 30 s no necesita sobrevivir a un reinicio (un niño no cierra la app para saltárselo) |
| Tests | Lógica del desafío (incluido el test estadístico del criterio 7), widgets del desafío y de la zona, inactividad con `fake_async`, layout en los 9 idiomas |

## 8. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Qué tipo de desafío? | Opción A: multiplicación escrita en palabras con un teclado numérico propio | Sí |
| P2 | ¿Qué pasa al fallar? | Pregunta nueva en cada fallo y bloqueo de 30 s tras 3 fallos seguidos (R4, R5) | Sí |
| P3 | ¿Cuánto dura el acceso? | Hasta volver al menú, pasar a segundo plano o 2 minutos de inactividad (R7) | Sí |
| P4 | ¿Qué contiene la Zona de Padres en esta historia? | Solo la estructura y las instrucciones de «Fijar pantalla». Cada sección nueva llega con su historia (HU-012, HU-010, HU-005…) | Sí |
| P5 | ¿El «atrás» del sistema dentro de la Zona de Padres también pide repetir el gesto (D-025)? | No: es una zona de adultos y el «atrás» vuelve al menú directamente | No (hay recomendación) |
| P6 | ¿El teclado usa cifras occidentales (0–9) también en árabe? | Sí: son las que se usan habitualmente en los teléfonos de los países árabes, y la respuesta se compara como número | No (hay recomendación) |

## 9. Fuera de alcance

- Las secciones de ajustes: idioma (HU-012), inicio del juego de memoria (HU-010), sonido y dificultad (HU-005), tiempo diario (HU-009, salvo las instrucciones de «Fijar pantalla»).
- Compras y restauración (HU-006).
- Un PIN o contraseña configurables por los padres (se podría valorar más adelante si el desafío resulta incómodo).
