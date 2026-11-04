# SPIKE · Viabilidad de la escalera de Sombras (HU-007)

| | |
|---|---|
| **Estado** | En curso: espacio en pantalla ✅ medido (2026-11-03); tamaño de los emojis ✅ corregido en el moto g55; disposición ✅ decidida por el dueño (2026-11-04); tiempo ⏳ pendiente de jugar en el moto g55 |
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

**Objetos sin sombra (P12 de HU-007).** Con 1 o 2 objetos sin sombra en la bandeja, los niveles 5 a 8 bajan como mucho a **73 dp** por objeto (teléfono compacto en horizontal) y a 80 dp en vertical. Siguen por encima de 64 dp.

**Conclusión:** la escalera cabe en todos los casos sin salirse de su zona. El peor caso (teléfono compacto en horizontal, niveles 3 a 8) da **81 dp**, por encima del mínimo de 48 dp de Material y del objetivo de 64 dp que proponemos para dedos de 3 años. Hay margen para la escalera tal como está; no hace falta quitar objetos al nivel 8.

## 4. Hallazgo en el teléfono: emojis demasiado grandes ✅

Al instalar el prototipo en el moto g55, el nivel 1 no mostraba **ninguna** sombra y uno de los dos objetos salía en blanco. En el nivel 8 todo se veía bien. La causa es el tamaño: en el nivel 1 los emojis se pedían a unos 150 dp de fuente (más de 300 px físicos), y el motor gráfico del teléfono no los pinta, ni en color ni como silueta. A unos 80 dp (170 px) se ven perfectos.

**Corrección:** el emoji se pinta como mucho a **220 px físicos**, aunque la celda sea mayor. Comprobado en el teléfono: el nivel 1 muestra los dos objetos y sus siluetas. Pasa a ser una regla de HU-007 (R13). Los tests de diseño no lo detectan porque no pintan emojis reales.

## 5. Disposición: sombras primero u objetos primero ✅

**Decidido por el dueño el 2026-11-04, sin esperar a la prueba:** se mantienen las sombras arriba (vertical) y a la izquierda (horizontal), para que el niño vea el destino; en «Imposible», la disposición cambia al azar (HU-007, P13 y P14). Los objetos sin sombra se descartan (P12). Las opciones del menú ⋮ del prototipo quedan solo como referencia; para medir tiempos se juega con la disposición normal y sin objetos sobrantes.

Protocolo original, ya no necesario:

El prototipo permite, desde su menú ⋮, poner los objetos primero (arriba en vertical, a la izquierda en horizontal) y añadir 0, 1 o 2 objetos sin sombra. Cada resultado del registro indica la configuración (`extras=… layout=…`).

Protocolo: el niño juega los niveles 2 a 4 con cada disposición, alternando el orden. Se compara el tiempo, los fallos y, sobre todo, **si tapa el destino con la mano** o duda al buscar la sombra.

## 6. Resultado: tiempo ⏳

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

**Series decididas por el dueño el 2026-11-04** (HU-007, tabla 4.3): Fácil 90 → 30 s, Normal 60 → 25 s e Imposible 50 → 20 s. La medición sirve ahora para **validarlas**: Normal debería dejar al menos el doble del tiempo típico del niño en los niveles que ya domina, e Imposible ser un reto real para un adulto en el nivel 8.

| Nivel | Adulto (mejor de 3) | Niño (mediana) | Fácil | Normal | Imposible | ¿Alcanzable? |
|---|---|---|---|---|---|---|
| 1 | | | Sin tiempo | Sin tiempo | Sin tiempo | — |
| 2 | | | 90 s | 60 s | 50 s | |
| 3 | | | 80 s | 50 s | 45 s | |
| 4 | | | 70 s | 45 s | 40 s | |
| 5 | | | 60 s | 40 s | 35 s | |
| 6 | | | 50 s | 35 s | 30 s | |
| 7 | | | 40 s | 30 s | 25 s | |
| 8 | | | 30 s | 25 s | 20 s | |
