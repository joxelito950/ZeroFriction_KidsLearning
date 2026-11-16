# HU-046 · Zona de Padres por filas

| | |
|---|---|
| **Estado** | En refinamiento (2026-11-12). Nace de HU-034 P1 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P1 (es la entrega 2 de HU-034) |
| **Tamaño** | M (unos 2 días) |
| **Depende de** | HU-004 (Zona de Padres y `AdultSessionGuard`). La necesitan HU-034, HU-038, HU-031, HU-039 y HU-006, que añaden opciones |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** ver todas las opciones de la Zona de Padres de un vistazo, con lo que tengo elegido en cada una,
**para** encontrar enseguida lo que busco sin recorrer una página larga, y cambiarlo sin perderme en menús.

## 2. Situación actual

La Zona de Padres es **una sola página larga** de tarjetas: Volver al menú, Idioma (lista de 9), Sonido, Juegos (ronda de cada juego con chips, «Mantener las estrellas», «Jugar sin tiempo»), Tiempo de juego (recomendación del sistema, leyenda de la OMS, chips del límite, personalizado y «15 minutos más»), Fijar pantalla (3 pasos), Comentarios y Privacidad.

Están por llegar «Su progreso» (HU-034), «Hora de dormir» (HU-038), «Cómo juega» (HU-031 y HU-039) y «Premium» (HU-006). Con ellas, la página no cabe ni se recorre en el minuto de inactividad que cierra la zona (HU-004 R7).

## 3. ¿Acordeón o filas que abren su configuración? (HU-034 P1)

| Opción | Valoración |
|---|---|
| **Acordeón** (secciones que se pliegan) | ⚠️ Todo en una pantalla, pero al abrir una sección el contenido de debajo salta; con dos abiertas vuelve la página larga; en un teléfono pequeño o con el texto ampliado (TD-007) la sección «Tiempo de juego» ocupa más de una pantalla. Y los cambios se aplican al momento, sin «Guardar» |
| **Filas con resumen que abren su configuración** | ✅ **Recomendado.** Es el patrón de los Ajustes de Android, que el adulto ya conoce. Cada fila dice qué está elegido; al tocarla se abre una pantalla con esa opción, **Guardar** y vuelta a la Zona de Padres. **Un solo nivel de profundidad**, como pide el dueño |

## 4. Comportamiento propuesto

### 4.1 La página principal

Una lista de filas. Cada fila tiene icono, título y **la opción elegida** en una línea:

| Fila | Resumen (ejemplo) | Al tocarla |
|---|---|---|
| **Su progreso** (HU-034) | «Le gusta Sombras · 1 h 10 min estos días» | Pantalla «Su progreso» (solo lectura) |
| **Idioma** | «Español» | Pantalla con la lista de idiomas |
| **Sonido** | Interruptor en la propia fila | — (un solo control: se cambia aquí, sin abrir nada) |
| **Juegos** | «Memoria: Normal · Sombras: Fácil · ¿Cuál es diferente?: Fácil» | Pantalla con la ronda de cada juego, «Mantener las estrellas» y «Jugar sin tiempo» |
| **Tiempo de juego** | «1 h al día · Dormir de 19:30 a 7:00» | Pantalla con la recomendación del sistema, la leyenda de la OMS, el límite y la hora de dormir (HU-038) |
| **Fijar pantalla** | «Mantener al niño dentro de la app» | Pantalla con los 3 pasos (solo lectura) |
| **Enviar comentarios** | «Por correo» | Abre el correo directamente, como hoy |
| **Privacidad** | «Todo se queda en el teléfono» | Abre la política, como hoy |

- Arriba de todo sigue «Volver al menú».
- **«15 minutos más»** (HU-009 y HU-038) sale de «Tiempo de juego» y aparece **como botón arriba de la página** solo cuando el niño está en la pantalla de descanso o de noche: es lo que el adulto busca en ese momento.
- Las secciones futuras («Cómo juega», «Premium») son filas nuevas, no páginas nuevas.

### 4.2 Las pantallas de configuración

- **R1.** Una opción con **un solo control** (un interruptor) se cambia en la fila. Las que tienen **más de un texto o un botón** abren su pantalla.
- **R2.** Cada pantalla tiene **«Guardar»**, activo solo si hay cambios. Al guardar, se aplica y se vuelve a la Zona de Padres.
- **R3.** Con «atrás» y cambios sin guardar, se pregunta «¿Guardar los cambios?» con **Guardar** y **Descartar**. Sin cambios, se vuelve sin preguntar.
- **R4.** **Nunca hay un segundo nivel**: dentro de una pantalla de configuración no hay filas que abran otra pantalla. Lo que haga falta (la hora de dormir, el tiempo personalizado, el detalle de estrellas) va en un **diálogo** o un selector del sistema.
- **R5.** Las pantallas de configuración están dentro del `AdultSessionGuard`: al pasar a segundo plano o tras 1 minuto sin tocar, se cierra todo y **se descartan los cambios sin guardar** (nada queda aplicado a medias).
- **R6.** Las pantallas de solo lectura («Su progreso», «Fijar pantalla») no tienen «Guardar».

## 5. Criterios de aceptación

1. La Zona de Padres muestra una fila por opción, con su resumen, y cabe en un teléfono compacto en vertical con el texto a 1,0 (a 2,0 se desplaza).
2. El sonido se cambia desde la fila; el resto abre su pantalla y vuelve con «Guardar».
3. Con cambios sin guardar, «atrás» pregunta; sin cambios, no.
4. Tras 1 minuto sin tocar una pantalla de configuración, se vuelve al menú y los cambios no se aplican.
5. «15 minutos más» aparece arriba solo durante el descanso o la noche.
6. Ninguna pantalla de configuración abre otra pantalla.
7. Los tests de layout de la Zona de Padres pasan en los 9 idiomas, en vertical y horizontal, a 1,0 y 2,0.

## 6. Impacto técnico

| Capa | Cambio |
|---|---|
| Presentación | `ParentsZoneScreen` pasa a una lista de `ParentsSettingRow`. Cada sección actual (`ParentsLanguageSection`, `ParentsGamesSection`, `ParentsPlayTimeSection`…) pasa a una pantalla con un borrador local y «Guardar» (`ParentsSettingPage`), que solo llama al cubit al guardar |
| Dominio y datos | Sin cambios |
| Tests | Los de widget de cada sección cambian para abrir su pantalla; nuevos para Guardar, Descartar y el cierre por inactividad |

Al cerrarla se registra la decisión (Zona de Padres en un nivel, con Guardar) en la sección 8 de la especificación.

## 7. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Filas o acordeón? | ✅ Decidido por el dueño en HU-034 P1 (2026-11-12): **filas que abren su configuración, un nivel como máximo**, con Guardar |
| P2 | ¿El idioma también con «Guardar»? | **No:** elegir un idioma de la lista lo aplica y vuelve, porque cambiar el idioma es la única forma de leer la pantalla si se eligió uno por error. Es la excepción a R2 |
| P3 | ¿Orden de las filas? | El de la tabla 4.1: primero lo que se mira (progreso), después lo que más se cambia, y al final la ayuda y la privacidad |
