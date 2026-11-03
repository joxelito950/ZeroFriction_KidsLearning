# SPIKE · Viabilidad de la escalera de Sombras (HU-007)

| | |
|---|---|
| **Estado** | En curso: espacio en pantalla ✅ medido (2026-11-03); tiempo ⏳ pendiente de jugar en el moto g55 |
| **Decidido** | 2026-11-03, en lugar de aprobar las tablas 4.2 y 4.3 de [HU-007](../hu/HU-007-sombras.md) sin medir |
| **Código** | Rama `spike/hu-007-shadows` (**no se fusiona**): prototipo jugable `lib/spike/shadow_spike.dart`, con su propio punto de entrada `lib/spike/main_spike.dart`, y la medición `test/spike/shadow_spike_layout_test.dart` |

## 1. Preguntas

1. ¿Caben los objetos y las sombras de cada nivel con un tamaño cómodo para un niño de 3 años, en los teléfonos de referencia y en las dos orientaciones?
2. ¿Cuánto se tarda en completar cada nivel, para fijar la serie de tiempos de Premium (tabla 4.3)?

## 2. Prototipo

- La escalera de la tabla 4.2 (8 niveles) y el contenido de la sección 4.5.
- **Disposición:** sombras arriba y bandeja abajo en vertical (3/5 y 2/5 del alto); en horizontal, una al lado de la otra (3/5 y 2/5 del ancho). Cada zona usa la cuadrícula de celdas cuadradas más grandes posible.
- **Sombras:** el mismo emoji pintado en teal profundo con `ColorFiltered` (`BlendMode.srcIn`). Funciona: la silueta coincide siempre con el objeto.
- **Zona magnética:** encaja si se suelta a menos de 3/4 del lado de la sombra desde su centro; soltar en el vacío no cuenta como fallo (R9).
- **Medición de tiempo:** desde que se empieza a arrastrar el primer objeto hasta que se encaja el último. Al terminar, el prototipo muestra los segundos y los fallos y los escribe en el log (`SPIKE level=… seconds=… fails=…`).

## 3. Resultado: espacio en pantalla ✅

Tests de diseño con los 4 teléfonos de referencia (los de `responsive_layout_test.dart`), reservando **110 dp** para la cabecera real del juego (título, puntos de nivel y barra de tiempo). Lado de cada objeto y de cada sombra, en dp:

| Nivel | Objetos / sombras | moto g55 vertical | compacto vertical | moto g55 horizontal | compacto horizontal |
|---|---|---|---|---|---|
| 1 | 2 / 2 | 206 / 254 | 162 / 188 | 200 / 263 | 158 / 174 |
| 2 | 3 / 3 | 167 / 206 | 123 / 162 | 129 / 198 | 101 / 156 |
| 3 | 4 / 4 | 167 / 206 | 123 / 162 | 125 / 145 | 81 / 114 |
| 4 | 4 / 5 | 167 / 165 | 123 / 121 | 125 / 125 | 81 / 89 |
| 5 | 5 / 6 | 133 / 165 | 104 / 121 | 125 / 125 | 81 / 81 |
| 6 | 5 / 6 | 133 / 165 | 104 / 121 | 125 / 125 | 81 / 81 |
| 7 | 6 / 7 | 133 / 133 | 104 / 104 | 125 / 125 | 81 / 81 |
| 8 | 6 / 8 | 133 / 133 | 104 / 104 | 125 / 125 | 81 / 81 |

**Conclusión:** la escalera cabe en todos los casos sin salirse de su zona. El peor caso (teléfono compacto en horizontal, niveles 3 a 8) da **81 dp**, por encima del mínimo de 48 dp de Material y del objetivo de 64 dp que proponemos para dedos de 3 años. Hay margen para la escalera tal como está; no hace falta quitar objetos al nivel 8.

## 4. Resultado: tiempo ⏳

Pendiente. Protocolo:

1. Instalar el prototipo en el moto g55 (sustituye a la app hasta reinstalarla; el progreso se conserva porque la firma es la misma):
   ```powershell
   flutter build apk --debug -t lib/spike/main_spike.dart
   adb install -r build/app/outputs/flutter-apk/app-debug.apk
   ```
2. **Adulto:** jugar cada nivel 3 veces y anotar el **mejor** tiempo (equivale al «adulto con memoria perfecta» de HU-001 §5).
3. **Niño:** jugar los niveles 1 a 5 (los gratuitos más representativos) las veces que quiera, sin presionarle; anotar todos los tiempos.
4. Leer los resultados del log: `adb logcat -s flutter | findstr SPIKE`.
5. Volver a instalar la app normal.

Criterio para la serie de Premium (Normal): el límite de cada nivel debería ser al menos **2 veces el tiempo típico del niño** en los niveles que ya domina y, en el nivel 8, un reto real para un adulto (como el 4×4 de la memoria con 30 s). Fácil (×3) e Imposible (÷2) salen de esa serie (HU-030).

| Nivel | Adulto (mejor de 3) | Niño (mediana) | Límite propuesto | Límite tras medir |
|---|---|---|---|---|
| 1 | | | Sin tiempo | Sin tiempo |
| 2 | | | 90 s | |
| 3 | | | 75 s | |
| 4 | | | 60 s | |
| 5 | | | 50 s | |
| 6 | | | 40 s | |
| 7 | | | 35 s | |
| 8 | | | 30 s | |
