# TD-007 · La app con el texto ampliado del sistema

| | |
|---|---|
| **Estado** | Hecha (desarrollada y verificada en el moto g55 el 2026-10-30) |
| **Prioridad** | P2: antes de las capturas y la prueba cerrada de HU-014 |
| **Tamaño** | S (1–2 días) |
| **Depende de** | Nada. Si HU-021 se hace antes, sus líneas de ayuda entran en estos tests; si se hace después, HU-021 las añade |

## 1. Objetivo

Que la app siga usable cuando el adulto tiene el **texto ampliado** en *Ajustes › Pantalla › Tamaño de fuente* (muchos adultos lo usan), y que el CI lo vigile.

## 2. Medición (2026-10-28)

Se ejecutaron los tests de diseño actuales (`responsive_layout_test.dart`: 9 idiomas × 4 teléfonos × 9 pantallas = 324 casos) con la escala de texto a 1,3 y a 2,0 (el máximo de Android 14 y posteriores):

| Pantalla | Escala 1,3 | Escala 2,0 |
|---|---|---|
| Menú principal | ✅ | ✅ (se desplaza) |
| Desafío de adultos | ✅ | ❌ 11 casos: en horizontal (y en vertical en el teléfono compacto en alemán y francés) **el recuadro de la respuesta o la tecla «borrar» quedan fuera de la vista**: el adulto teclea sin ver lo que escribe |
| Mensaje de respuesta incorrecta | ✅ | ✅ |
| Zona de Padres | ✅ | ✅ (se desplaza) |
| Tableros del juego (5 niveles) | ❌ 15 casos: teléfono compacto en vertical, en árabe, francés y portugués | ❌ 98 casos: casi todos los idiomas y teléfonos |

**Causa en el juego:** la cabecera (título, instrucciones, contador) y el pie crecen con el texto y no dejan alto para el tablero (`memory_game_screen.dart`, la columna principal se desborda hasta 158 px). Además, el **símbolo de cada carta** es un texto de 42 puntos que también crece: a 2,0 mide 84 y no cabe en las cartas del tablero de 16.

## 3. Propuesta

| # | Regla |
|---|---|
| A1 | **Pantallas de adultos** (menú, desafío, mensaje, Zona de Padres): respetan el texto del sistema **hasta 2,0** sin desbordes, desplazándose si hace falta |
| A2 | **Desafío:** el recuadro de la respuesta va **pegado al teclado** (encima de él), para que siempre se vea lo que se escribe; la pregunta puede desplazarse aparte. Las 12 teclas siguen midiendo al menos 48 dp |
| A3 | **Pantalla del juego:** los textos de la cabecera y el pie se limitan a **1,3** (`MediaQuery.withClampedTextScaling`). El niño de 3 años no los lee; el tablero es lo que importa. A 1,3 no se desborda en ningún teléfono ni idioma (se corrigen los 15 casos de hoy) |
| A4 | **Símbolos de las cartas:** no siguen el texto del sistema; son dibujos y se ajustan al tamaño de la carta (`TextScaler.noScaling` y tamaño relativo a la carta) |
| A5 | **Celebraciones y aviso de tiempo agotado:** como el juego, hasta 1,3 |
| A6 | Tests: `responsive_layout_test.dart` gana la escala como otra dimensión: **1,0 y 2,0** para las pantallas de adultos y **1,0 y 1,3** para el juego (con 2,0 debe comportarse igual que con 1,3). Un test comprueba que los símbolos de las cartas no cambian de tamaño con la escala |

## 4. Criterios de aceptación

1. **Dado** el texto del sistema a 2,0, **entonces** el menú, el desafío, el mensaje de fallo y la Zona de Padres no se desbordan en los 9 idiomas, en vertical y en horizontal, y todas sus acciones se pueden alcanzar.
2. **Dado** el desafío con el texto a 2,0, **cuando** tecleo, **entonces** veo el recuadro de la respuesta junto al teclado sin desplazar la pantalla.
3. **Dado** el texto del sistema a 1,3 o a 2,0, **entonces** los 5 tableros caben sin cortar cartas en los 4 teléfonos y los 9 idiomas, y la cabecera y el pie se ven como a 1,3.
4. **Dado** cualquier escala, **entonces** el símbolo de cada carta mide lo mismo que a 1,0.
5. El CI ejecuta estos casos en cada PR.

## 5. Preguntas abiertas

| # | Pregunta | Recomendación | Bloquea |
|---|---|---|---|
| P1 | ¿El juego limita su texto a 1,3 (A3) o debe crecer hasta 2,0 como el resto? | ✅ Decidido (2026-10-28): **limitar a 1,3.** Crecer hasta 2,0 obliga a encoger el tablero, que es lo que usa el niño; los textos del juego son para el adulto que lo acompaña y a 1,3 ya son grandes | — |
| P2 | ¿Las pantallas de adultos respetan el texto hasta 2,0 (el máximo de Android) o también se limitan? | ✅ Decidido (2026-10-28): **hasta 2,0.** Son las que lee el adulto; limitarlas va contra la accesibilidad, y hoy ya cumplen todas salvo el desafío | — |
| P3 | ¿Cuántas escalas prueba el CI? | ✅ Aceptada la recomendación: **1,0 y 2,0 en adultos, 1,0 y 1,3 en el juego** (A6). Probar también 1,3 en adultos o 1,5 añade casos sin encontrar más fallos en la medición | No |

## 6. Resultado (2026-10-30)

### 6.1 Nueva medición antes de empezar

Se repitió la medición de la sección 2 con HU-021 ya fusionada (380 casos por escala; ahora el desafío se prueba con dos idiomas de ayuda por idioma):

| Pantalla | Escala 1,3 | Escala 2,0 |
|---|---|---|
| Desafío de adultos | ✅ | ❌ 40 casos (antes 11): la línea de ayuda de HU-021 empuja la respuesta y el teclado fuera de la vista |
| Tableros del juego | ❌ 15 casos (los mismos) | ❌ 98 casos (los mismos) |
| Resto de pantallas de adultos | ✅ | ✅ |

**Causa real de los 15 casos a 1,3:** el contador de movimientos («Coups : 0») compartía fila con el título y le dejaba 49 dp de ancho; el título se partía letra a letra y ocupaba 444 dp de alto. Limitar el texto a 1,3 no bastaba.

### 6.2 Cambios

| # | Cambio |
|---|---|
| A1, A2 | `parental_gate_screen.dart`: la respuesta (`_AnswerBox`, 56 dp fijos, las cifras se encogen si no caben) va pegada encima del teclado y mide lo mismo de ancho; la pregunta, con su línea de ayuda, se desplaza aparte. En vertical, la pregunta ocupa lo que necesita y la respuesta y el teclado van justo debajo; en horizontal, la respuesta y el teclado ocupan la mitad derecha |
| A3, A5 | `memory_game_screen.dart`: `MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3)` envuelve toda la pantalla del juego, incluidas la celebración, el aviso de tiempo agotado y el aviso de salida (`MemoryGameScreen.maxTextScale`) |
| Cabecera del juego | El contador de movimientos pasa a la fila de los puntos de nivel, alineado al final, y se encoge si no cabe (árabe a 1,3 en el teléfono compacto). El título y las instrucciones tienen todo el ancho |
| A4 | `memory_card_widget.dart`: el símbolo usa `TextScaler.noScaling` y mide 42 o la mitad del lado corto de la carta si es menor |
| Teclado | Margen horizontal de 8 dp en las teclas: con el texto ampliado, «Aceptar» tocaba el borde (visto en el moto g55) |
| A6 | `responsive_layout_test.dart` añade la escala como dimensión: **1,0 y 2,0** en todas las pantallas (760 casos). Con 2,0 el juego aplica su límite de 1,3, así que esos casos prueban a la vez el límite y el diseño a 1,3 (ajuste respecto a A6, que proponía 1,3 en el juego: probar 2,0 también detecta si se quita el límite). En el desafío a 2,0, la respuesta y las 12 teclas se exigen visibles sin desplazar; la pregunta, tras desplazar. Tests nuevos: el símbolo no cambia con la escala y se encoge en cartas pequeñas; el juego limita su escala a 1,3 |

### 6.3 Criterios

| Criterio | Resultado |
|---|---|
| 1 | ✅ Tests de diseño a 2,0: menú, desafío, mensaje y Zona de Padres en los 9 idiomas, 4 teléfonos y las dos orientaciones |
| 2 | ✅ Test del desafío a 2,0, y visto en el moto g55 con el texto del sistema a 2,0 |
| 3 | ✅ Los 5 tableros a 2,0 (con el límite de 1,3) en todos los casos; visto el 3×4 en el moto g55 a 2,0 |
| 4 | ✅ Test del símbolo a 1,0 y 2,0 |
| 5 | ✅ Los casos están en `responsive_layout_test.dart`, que ejecuta el CI |

Checklist de la sección 5: `flutter analyze` sin incidencias, 1132 tests en verde y cobertura del 99,7 %. En el moto g55, el texto del sistema se subió a 2,0 solo durante las capturas y se restauró su valor (0,86).

## 7. Fuera de alcance

- Tablets y pantallas grandes (TD-010).
- Tamaño de visualización del sistema (*Tamaño de pantalla*), que cambia los dp y ya lo cubren en parte los dos teléfonos de referencia.
