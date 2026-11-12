# HU-034 · Resumen del progreso para padres

| | |
|---|---|
| **Estado** | En refinamiento (borrador del 2026-11-12). Faltan las respuestas del dueño a P1–P6 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P3 |
| **Tamaño** | M (2 entregas, unos 3 días) |
| **Depende de** | HU-037 (rondas, medallas y récords por nivel en `GameProgress`). HU-009 (tiempo de hoy). Necesita un **historial diario** de tiempo que hoy no existe |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** ver de un vistazo a qué ha jugado mi hijo y lo que ha ido consiguiendo,
**para** acompañarlo, celebrar con él y elegir bien la dificultad, **sin que nada me preocupe ni lo compare con otros niños**.

## 2. Premisa

**Nunca generar preocupación, ni al niño ni a los padres.** De ella salen todas las decisiones de esta historia:

| Se muestra | No se muestra nunca |
|---|---|
| Logros: medallas, estrellas, niveles alcanzados | Fallos, tiempos agotados, veces que bajó de nivel o de ronda |
| Lo que está explorando ahora («Está jugando la ronda Normal») | Porcentajes de acierto o «nivel esperado para su edad» |
| Cuánto ha jugado, como información neutra | Comparaciones con otros niños, medias, rankings |
| Su juego favorito de la semana | Rachas («lleva 3 días sin jugar») ni estrellas perdidas (D-037) |
| | Colores de alarma (rojo, ámbar como aviso) |

Las palabras siguen la misma idea: «ha conseguido», «está explorando», «le gusta». Nunca «le falta», «solo», «todavía no».

## 3. ¿Dónde y en qué formato? (la pregunta del dueño)

| Opción | Valoración |
|---|---|
| **PDF** | ❌ Descartado. Exige generar y compartir un archivo (permisos, otra app), invita a enviarlo y compararlo, y un informe impreso se lee como una evaluación. Además va contra «todo en el teléfono» |
| **Nueva vista dentro de la Zona de Padres** | ✅ **Recomendado.** Una pantalla «Su progreso» que se abre con un botón al principio de la Zona de Padres, detrás del desafío de siempre (el niño no la ve). Se lee en 10 segundos |
| Submenú con gráficos y porcentajes | ⚠️ Los gráficos, sí, pocos y amables; los **porcentajes, no**: «33 %» se lee como una nota |

## 4. Qué mide y cómo lo presenta

La pantalla «Su progreso» tiene tres bloques, de arriba abajo.

### 4.1 Una frase de resumen

Una sola frase, generada a partir de los datos y siempre positiva:

- «Esta semana ha jugado sobre todo a **Sombras** y ha conseguido **la medalla de bronce**».
- Si no ha jugado: «Esta semana no ha jugado. ¡Cuando quiera, aquí estaremos!»

### 4.2 Una tarjeta por juego

Con el icono del juego (como en el menú) y:

- **Medallas conseguidas**: bronce, plata y oro con sus colores de `RoundStyle`. Las que aún no tiene **no aparecen** (nada de huecos vacíos que se lean como «le falta»).
- **Qué está explorando**: «Ronda Normal · nivel 4». Es información para elegir la dificultad (HU-030), sin juicio.
- **Estrellas reunidas**: el número total, con una estrella («★ 23»), igual que el dorado del menú pero en número.
- Un juego que nunca ha abierto se muestra como «Aún por descubrir», con su icono en color, como una invitación.

### 4.3 Tiempo de juego de los últimos 7 días

- Un **gráfico de 7 barras** (una por día), en teal profundo sobre crema, con el día de la semana debajo y los minutos encima de cada barra.
- Sin línea del límite diario ni barras de otro color al pasarlo: el límite ya lo aplica la app, y marcarlo convertiría el gráfico en un parte de incumplimientos.
- Debajo, en texto: «Total: 1 h 10 min esta semana».

## 5. Reglas

- **R1.** Solo lectura. Nada en esta pantalla cambia el progreso.
- **R2.** Todo sale de lo que ya se guarda en el teléfono, más el historial diario nuevo (R3). No se envía nada; la política de privacidad no cambia.
- **R3.** Se guarda el **tiempo jugado por día y por juego** de los **últimos 7 días** (P2). Los días más antiguos se borran solos.
- **R4.** El lector de pantalla lee cada barra («martes, 12 minutos») y cada tarjeta como una frase.
- **R5.** Los textos están en los 9 idiomas, y el gráfico se invierte en árabe (el lunes a la derecha).

## 6. Criterios de aceptación (borrador)

1. Desde la Zona de Padres se abre «Su progreso» y se vuelve con «atrás».
2. Con un niño que nunca ha jugado, la pantalla muestra los tres juegos «por descubrir» y una semana vacía sin mensajes de alarma.
3. Con progreso de varias rondas, cada tarjeta muestra solo las medallas conseguidas, la ronda y el nivel actuales y el total de estrellas.
4. El gráfico muestra los minutos de los últimos 7 días y suma bien el total.
5. En ningún texto aparecen porcentajes, fallos ni comparaciones (se comprueba con una prueba sobre las cadenas de los 9 idiomas).
6. Contraste AA con la paleta, sin colores fuera de ella (`palette_test`).

## 7. Impacto técnico previsto

| Capa | Cambio |
|---|---|
| Dominio | `PlayHistory` (minutos por día y por `GameId`, ventana de 7 días) y `ProgressSummary`, que reúne `GameProgress` de cada juego y el historial y elige la frase |
| Datos | **typeId 6** (`PlayDayHiveModel`), caja nueva `play_history` con clave por fecha. El tiempo lo suma `PlayTimeCubit`, que ya cuenta los segundos de hoy; se le añade el juego en curso |
| Presentación | `ParentsProgressScreen` con las tarjetas y un gráfico de barras dibujado con `CustomPaint` (sin dependencia nueva) |

**Entregas:** (1) historial diario y su guardado (empieza a acumular cuanto antes); (2) la pantalla.

## 8. Preguntas

| # | Pregunta | Recomendación |
|---|---|---|
| P1 | ¿Pantalla propia o sección dentro de la Zona de Padres? | **Pantalla propia** con un botón arriba de todo: la Zona de Padres ya es larga |
| P2 | ¿Cuántos días de historia? | **7.** Más días invitan a buscar tendencias («juega menos que el mes pasado») |
| P3 | ¿Se muestran las estrellas por nivel (3 por nivel)? | **No**, solo el total: por nivel aparecen los niveles con 1 estrella, que se leen como «lo hace mal» |
| P4 | ¿Se muestra la ronda en la que está aunque haya bajado? | **Sí**, como «está explorando», sin decir que bajó |
| P5 | ¿Se puede borrar el progreso desde aquí? | **No**: ya se hace borrando los datos de la app; un botón aquí se pulsaría por error |
| P6 | ¿Se desarrolla la entrega 1 pronto, para que haya datos cuando llegue la pantalla? | **Sí**, es pequeña y no se ve |

## 9. Fuera de alcance

- Exportar, compartir o imprimir (PDF, imagen, correo).
- Sincronizar entre teléfonos o con una cuenta.
- Recomendaciones automáticas de dificultad.
