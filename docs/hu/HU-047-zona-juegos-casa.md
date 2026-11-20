# HU-047 · Actividades en casa con materiales del hogar

| | |
|---|---|
| **Estado** | En refinamiento (2026-11-20): **el dueño cambió el planteamiento** (sección 12) y la adelanta a antes de HU-006 |
| **Épica** | E2 · Zona de Padres |
| **Prioridad** | P2 |
| **Tamaño** | M (estimación: 2–3 días) |
| **Depende de** | HU-046 (Zona de Padres por filas), HU-009 (tiempo de juego diario) y HU-030 (dificultad general) |

## 1. Historia

**Como** madre, padre o adulto a cargo,
**quiero** ver ideas rápidas de actividades para hacer con mi hijo en casa usando materiales cotidianos,
**para** reforzar aprendizaje y jugar sin necesidad de comprar material ni descargar contenido adicional.

**Como** niño o niña de 2 a 5 años,
**quiero** participar en actividades sencillas, seguras y claras,
**para** aprender a través del juego con cosas de la casa.

## 2. Situación actual

- La app ya ofrece juegos y un buen control parental, pero no hay una zona de “ideas de juego” para usar fuera del tablero.
- Los adultos necesitan propuestas rápidas, concretas y seguras que no exijan preparación compleja.
- El proyecto ya prioriza experiencias calmadas, visuales y sin fricción; esto encaja con actividades domésticas simples.
- No hay una estructura de “ideas por edad/material/tipo de juego” dentro de la app ni en la zona de padres.

## 3. Propuesta

Crear una sección dentro de la Zona de Padres llamada **“Actividades en casa”** con una colección de ideas diseñadas para jugar con materiales del hogar y productos comunes, sin riesgo de piezas pequeñas ni materiales peligrosos.

### 3.1 Tipo de contenido

Cada idea se presenta como una tarjeta con:

- Título corto y claro
- Icono o miniatura visual
- Tiempo estimado
- Materiales necesarios
- Nivel de dificultad / edad orientar
- Indicadores de “5 minutos”, “10 minutos”, “sin pantalla”
- Botón o acceso a una vista detallada de la actividad

### 3.2 Categorías sugeridas

1. **Buscar y encontrar**
   - Buscar objetos por color, forma o función
   - “Busca algo rojo”, “¿Dónde está la cuchara?”, “Trae algo suave”

2. **Emparejar y clasificar**
   - Agrupar calcetines, botones, cucharas o camisas por color
   - Ordenar por tamaño
   - Separar objetos por textura

3. **Movimiento y coordinación**
   - Saltos siguiendo una línea
   - “Pisa la manta”, “salta a la almohada”, “pasa por el túnel de una sábana”
   - Juegos de equilibrio con cojines o cuerdas

4. **Arte y creatividad**
   - Pintar con dedos sobre papel
   - Hacer formas con cinta adhesiva
   - Pegar papel con cinta para crear una escena

5. **Lenguaje y narración**
   - Historias con muñecos, cucharas o ropa
   - Nombrar animales, colores y objetos
   - “¿Qué hace este objeto?”

6. **Rutina y orden**
   - Ordenar juguetes por tamaño
   - Recoger en contenedores
   - “Ayuda a poner cada cosa en su sitio”

### 3.3 Materiales recomendados

Los materiales deben ser:

- Seguros y comunes en el hogar
- De uso cotidiano
- Fáciles de limpiar y guardar
- Sin piezas pequeñas para niños pequeños
- Equilibrados para evitar frustración o riesgo

Ejemplos:

- Calcetines
- Tazas o recipientes
- Toallas
- Cinta adhesiva
- Papel de cocina o de seda
- Envases de plástico grandes
- Paños
- Juguetes grandes
- Cojines
- Cubos, cajas o platos

Se evita:

- Botones pequeños
- Objetos afilados
- Comidas con riesgo de atragantamiento
- Productos químicos o materiales tóxicos
- Piezas pequeñas y desmontables

### 3.4 Diseño de la sección

La vista debe sentirse tranquila y útil para adultos:

- Una lista de tarjetas o mosaicos
- Cada tarjeta con un indicativo visual
- Agrupación por tipo de actividad
- Filtro por “5 min / 10 min / sin materiales” o “fácil / medio”
- En la parte inferior, un enlace a “Más ideas” si se amplía en el futuro

## 4. Reglas (borrador)

| # | Regla |
|---|---|
| R1 | La sección vive dentro de la Zona de Padres, no en el menú principal del niño. |
| R2 | Cada idea se presenta con materiales, duración estimada, edad sugerida y pasos sencillos. |
| R3 | Las actividades se basan en materiales del hogar comunes y seguros. |
| R4 | Los textos deben ser breves, claros y fáciles de leer por adultos. |
| R5 | Las ideas no deben requerir pantallas ni compras extra. |
| R6 | La app no debe incluir materiales de riesgo ni piezas pequeñas. |
| R7 | La actividad debe ser amigable, sin frustración ni instrucciones largas. |
| R8 | La sección puede tener hasta 2–3 niveles de profundidad: resumen y detalle de la actividad. |
| R9 | La información no guarda historial ni datos del niño, solo la intención de la actividad. |
| R10 | La zona debe tener un aspecto sereno y visualmente equivalente a la identidad de la app. |

## 5. Impacto técnico previsto

| Área | Cambio |
|---|---|
| Dominio | Nueva estructura de “ideas de actividad” como contenido editorial simple; sin lógica compleja de juego |
| Persistencia | No es necesario un tipo nuevo si la lista es estática; opcionalmente, guardado de “ideas preferidas” o “actividades realizadas” en el futuro |
| Presentación | Nueva sección en la Zona de Padres, lista de tarjetas y detalle por actividad |
| Catálogo | Nuevas cadenas de texto para cada actividad, con soporte de 9 idiomas |
| Tests | Verificación visual de la composición, textos y layout en vertical y horizontal |

## 6. Encaje con lo ya decidido

| Decisión | Impacto |
|---|---|
| HU-046 | La sección encaja mejor dentro de la nueva estructura de la Zona de Padres por filas |
| HU-009 | La sección no debería competir con el tiempo de juego diario ni influir en él |
| HU-030 | Las actividades se presentan como una ayuda parental, no como juego infantil |
| D-034 | Se mantiene el enfoque visual y la sencillez |
| D-032 | Se usan los colores de la paleta cerrada; sin colores nuevos |
| D-033 | La información se mantiene local y sin telemetría |

## 7. Ejemplo de contenido

### Tarjeta ejemplo
**Buscar por color**
- Materiales: 5 objetos de colores
- Duración: 5 minutos
- Edad: 2–5 años
- Objetivo: reconocer colores

### Detalle ejemplo
**1. Reúne 4–6 objetos de color rojo**
**2. Muestra uno y pide que lo busque**
**3. Cuando lo encuentre, repítelo con otro color**
**4. Si se frustra, hazlo más largo o más corto según el ritmo**

## 8. Preguntas y decisiones

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿La sección va dentro de la Zona de Padres o dentro del menú infantil? | **Dentro de la Zona de Padres** | Sí |
| P2 | ¿Es solo contenido editorial o también se guarda “favoritos”? | **Solo contenido editorial por ahora** | No |
| P3 | ¿Se usan materiales del hogar o de la app? | **Materiales del hogar** | No |
| P4 | ¿Cuántas actividades se muestran en la primera versión? | **8–12 ideas** en una sola pantalla con scroll si hace falta | No |
| P5 | ¿Se usa para adultos o para niños? | **Primero para adultos; luego puede ampliarse a “ideas para jugar con mamá/papá”** | No |
| P6 | ¿Es una funcionalidad de app o una simple sección documental? | **Sección funcional dentro de la app** | No |

## 9. Criterios de aceptación

1. Dado que el adulto abre la Zona de Padres, entonces puede entrar a “Actividades en casa”.
2. Dado que la sección está abierta, entonces cada tarjeta muestra materiales, duración y objetivo.
3. Dado que el adulto mira una actividad, entonces puede ver una versión resumida y otra detallada.
4. Dado que se muestran materiales, entonces no hay piezas pequeñas ni elementos riesgosos.
5. Dado que la sección está en 9 idiomas, entonces no se desborda ni atraviesa el layout.
6. Dado que el adulto toca una actividad, entonces la pantalla de detalle se abre sin fricción.
7. Dado que la actividad es simple, entonces la información cabe en vertical y horizontal y se mantiene legible.

## 10. Fuera de alcance

- Juegos interactivos dentro de la app con esos materiales.
- Subida de contenido dinámico desde backend.
- Recomendaciones con materiales peligrosos o no recomendados.
- Recolección de métricas de uso de la actividad.

## 11. Propuesta de alcance inicial

Para la primera entrega se recomienda:

- 8 ideas base
- 1 categoría principal en la vista general
- 1 vista detalle por actividad
- 1 pantalla de “sin resultados” o “más ideas”
- textos en 9 idiomas
- revisión visual en un teléfono real

## 12. Decisiones del dueño (2026-11-20)

Sustituyen a las secciones 3.4, 4 (R1, R8) y 8 donde no coincidan.

| # | Decisión |
|---|---|
| D1 | **No va en la Zona de Padres.** En el **menú principal**, entre el logo y los juegos, aparece **una tarjeta con la sugerencia del día** |
| D2 | En el pie del menú, junto a «Zona de padres» y «Salir», un botón **«Actividades sin pantallas»** abre el **listado de sugerencias con una barra de búsqueda** |
| D3 | **Cada sugerencia abre su propia pantalla** con: instrucciones claras, lista de materiales, categoría, tiempo, **variantes** y, al final, **actividades recomendadas** para seguir jugando en casa sin pantallas, sin que se vuelvan repetitivas |
| D4 | **Se puede abrir en todo momento**, también de noche, en la siesta o con el límite diario superado: también desde la pantalla de descanso |
| D5 | Contenido: las **6 categorías genéricas** de la sección 3.2 (buscar y encontrar, emparejar y clasificar, movimiento, arte, lenguaje y rutina) |
| D6 | Seguridad: **una advertencia general** y **otra en cada actividad** |

### 12.1 Preguntas que abren estas decisiones

| # | Pregunta | Recomendación |
|---|---|---|
| P7 | ¿Cuántas actividades en la primera versión? Con buscador y sugerencia diaria conviene que no se repitan pronto | **24**, 4 por categoría: casi un mes de sugerencias distintas. Son unos 24 × 7 textos en 9 idiomas, el grueso del trabajo |
| P8 | ¿El niño puede abrirlas sin el desafío de adultos? La tarjeta y el botón están en su menú | **Sí, sin desafío:** no cambian nada ni compran nada, y el texto es para leerlo con un adulto. La tarjeta lleva un aspecto de «para mamá o papá», con el niño y un adulto, para que no parezca un juego |
| P9 | ¿El tiempo que se pasa leyéndolas cuenta como tiempo de pantalla (HU-009)? | **No cuenta**, como la Zona de Padres: es tiempo de preparar un juego sin pantalla |
| P10 | ¿Cómo se elige la sugerencia del día? | **Por la fecha**, la misma todo el día y en orden por categorías, para no repetir hasta recorrer todas; sin guardar historial (R9) |
| P11 | ¿Qué son las «recomendadas» al final de cada actividad? | **3 actividades**: una de la misma categoría que sube un paso la dificultad y dos de otras categorías que encajan con los mismos materiales. Se eligen a mano al escribir el contenido, para que tengan sentido y no se repitan |
| P12 | ¿La búsqueda filtra solo por texto o también por categoría y tiempo? | **Texto más chips de categoría** (las 6) y de tiempo (5 · 10 · 15 min) |
| P13 | ¿Se oculta la tarjeta del día en algún momento? | **Se puede cerrar por hoy** con una ✕ pequeña; vuelve mañana con otra sugerencia |
