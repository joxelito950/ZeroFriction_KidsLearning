# TD-013 · Rendimiento en teléfonos de gama baja

| | |
|---|---|
| **Estado** | En refinamiento (iniciado el 2026-11-10; preguntas en la sección 6) |
| **Prioridad** | P2: antes de producción |
| **Tamaño** | S (1–2 días, más lo que haya que corregir) |
| **Depende de** | Nada. Conviene hacerlo con TD-012 |

## 1. Objetivo

Que la app se vea fluida en los teléfonos que tienen muchas familias: Android 8 o posterior, 2–3 GB de RAM y procesadores modestos. Un tirón al arrastrar una figura o al voltear una carta se nota mucho a los 3 años.

## 2. Qué puede pesar (2026-11-10)

| Pieza | Por qué | Ya mitigado |
|---|---|---|
| Dorado líquido del menú (HU-002) | Única animación continua: una ola y burbujas con `CustomPainter`, en dos botones | Se para con «reducir movimiento», al 0 % y fuera de la pantalla; un solo `AnimationController` de 6 s por botón |
| Recorte del dorado con la forma del icono (`ShaderMask` con `ImageShader`) | Una capa más por botón en cada fotograma | — |
| Sombras (HU-007) | Hasta 14 emojis grandes, siluetas con `ColorFiltered`, arrastre a 60 fps y la animación de inicio | Tope de 220 px físicos por emoji (R13) |
| Memoria | El volteo en 3D de 16 cartas | Sin volteo con «reducir movimiento» |
| Sonidos (HU-005) | El primer sonido crea su reproductor | Modo de baja latencia; un reproductor por sonido |

## 3. Propuesta

1. **Medir** con `flutter run --profile` y la superposición de rendimiento en:
   - un **emulador limitado** (Android 8.1, 2 núcleos, 2 GB de RAM, GPU por software) para el peor caso;
   - el **moto g55** como referencia;
   - un teléfono real de gama baja si algún tester lo tiene (P1).
2. **Escenarios:** el menú quieto 10 s (dorado), abrir y jugar la memoria 4×4, arrastrar en Sombras nivel 7, la animación de inicio y la celebración.
3. **Objetivo** (P2): sin fotogramas por encima de 16 ms en el moto g55; en el emulador limitado, 30 fps estables y ningún tirón de más de 100 ms al tocar.
4. **Correcciones probables**, en este orden y solo si la medición lo pide:
   - `RepaintBoundary` alrededor de cada botón del menú, para que la ola no repinte el resto;
   - dorado a 30 fps en gama baja (detectado por la duración de los fotogramas, no por el modelo);
   - silueta de Sombras dibujada una vez a imagen y reutilizada, en vez de filtrar el emoji en cada fotograma;
   - precargar los sonidos al abrir el juego.
5. **Documentar** las cifras en la sección 1.1 de la especificación.

## 4. Criterios de aceptación

1. Hay cifras de los cinco escenarios en el moto g55 y en el emulador limitado, en la especificación.
2. Se cumplen los objetivos de P2, o hay una historia o un pendiente con lo que falta.
3. Ningún cambio altera lo que se ve en los teléfonos rápidos (los tests de diseño siguen pasando).

## 5. Impacto

| Área | Cambio |
|---|---|
| Código | Solo lo que la medición pida (sección 3.4) |
| Documentos | Especificación 1.1 |
| Tests | Los que acompañen a cada corrección |

## 6. Preguntas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿Hay algún teléfono real de gama baja disponible (de un tester o de la familia)? | Pedirlo a los testers de la prueba cerrada con «Enviar comentarios» (HU-032). Si no, basta el emulador limitado | No |
| P2 | ¿Qué objetivo se fija? | El de la sección 3.3: 60 fps en el moto g55; 30 fps estables en gama baja | Sí |
