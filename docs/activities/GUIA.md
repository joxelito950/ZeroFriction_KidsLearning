# Guía del contenido · Actividades sin pantallas (HU-047)

Cómo añadir actividades y traducirlas hasta la meta de **1000 actividades en casa**, con materiales y tiempos variados. La app no necesita cambios para crecer: todo el contenido vive en `assets/activities/`.

## 1. Dónde está cada cosa

| Archivo | Qué guarda |
|---|---|
| `catalog.json` | La **estructura**, igual para todos los idiomas: `id`, `category`, `minutes`, `ageFrom` y, si se quiere, `recommended` |
| `es.json`, `en.json`… | Los **textos** de cada idioma: las actividades, las sugerencias de búsqueda (`searchHints`) y la frase sin resultados (`noResults`) |

- **El inglés es la base:** tiene que estar completo. Una actividad que aún no esté traducida a otro idioma se muestra en inglés, así que se puede traducir poco a poco.
- Un idioma sin archivo también sale en inglés. Para empezar uno nuevo, basta con crear `fr.json` con las primeras actividades traducidas.

## 2. Una actividad

```json
// catalog.json
{ "id": "sort-socks", "category": "sort", "minutes": 10, "ageFrom": 2, "recommended": ["sort-colors", "routine-shoe-pairs", "art-sock-puppet"] }

// es.json → "activities"
"sort-socks": {
  "title": "Parejas de calcetines",
  "goal": "Una frase: qué practica el niño.",
  "materials": ["6 a 10 calcetines de colores distintos"],
  "steps": ["Paso corto en imperativo para el adulto.", "…", "…"],
  "variants": ["Más fácil: …", "Más difícil: …"],
  "safety": "La advertencia propia de esta actividad.",
  "tags": ["calcetines", "ropa", "colores", "parejas", "sin hacer ruido"]
}
```

| Campo | Regla |
|---|---|
| `id` | `<categoría>-<palabras-en-inglés>`, en minúsculas y con guiones, y **no se cambia nunca**: la sugerencia del día y las recomendadas lo usan |
| `category` | `search` (buscar y encontrar), `sort` (emparejar y clasificar), `move` (movimiento), `art` (arte), `language` (lenguaje y cuentos), `routine` (rutina y orden) |
| `minutes` | De 1 a 60. Los filtros son «hasta 5, 10, 15 y 30 min» |
| `ageFrom` | 2, 3, 4 o 5 años |
| `recommended` | **Opcional:** hasta 3 `id` elegidos a mano, uno de la misma categoría un paso más difícil y dos de otras que usen los mismos materiales. Si faltan, la app elige las que más materiales y etiquetas comparten |
| `steps` | De 3 a 5 pasos cortos, en imperativo y dirigidos al adulto |
| `variants` | Exactamente 2: una más fácil y otra más difícil o distinta |
| `tags` | De 5 a 8 palabras en minúsculas: **materiales** («cajas»), **gustos** («animales», «coches», «música») y **momentos** («para un día de lluvia», «antes de dormir», «sin hacer ruido», «en la cocina») |

## 3. Tono

- Para el **adulto**, no para el niño. Se usa «tú» y un tono tranquilo y cálido, sin prisas ni exclamaciones de más.
- Frases cortas y concretas: qué hacer, con qué y cuánto tiempo.
- Sin premios, competición ni «ganar». Si el niño se frustra, la variante más fácil.
- Español neutro: «marcador» y no «rotulador», «tazas de plástico» y no «vasos de plástico duro»…

## 4. Seguridad (obligatoria)

Cada actividad lleva su propia advertencia, y la sección muestra además una general.

**Nunca se proponen:**
- objetos que quepan en la boca (botones, cuentas, monedas, canicas, legumbres, arroz);
- pilas al alcance: la linterna la sostiene el adulto;
- bolsas de plástico, globos, objetos afilados, vidrio, productos químicos, ni comida que pueda atragantar.

**Además:**
- agua, solo un poco y siempre a la vista;
- saltos, en el suelo y sobre cojines, lejos de esquinas y muebles;
- siempre con un adulto al lado.

El test `activity_assets_test.dart` falla si una de esas palabras aparece en el título, los materiales, los pasos, las variantes o las etiquetas. Solo pueden aparecer en la advertencia que las prohíbe.

## 5. Cómo crecer hasta 1000

1. **Por tandas de 50 a 100**, repartidas entre las 6 categorías y con variedad de tiempos (5 a 30 min) y de edades (2 a 5 años). `dart run tool/activities_report.dart` dice cuántas hay de cada cosa.
2. Primero en **español y en inglés**: el inglés debe estar completo.
3. Cada tanda pasa los tests: `flutter test test/data/activities test/domain/activities`.
4. **Que no se repitan:** antes de escribir una nueva, se busca en la sección por sus materiales para ver si ya existe una parecida. Variar el material, el espacio de la casa (cocina, baño, patio), el momento del día y la habilidad.
5. **Sugerencias de búsqueda:** cada una tiene que encontrar al menos 2 actividades. Conviene renovarlas cuando crezca el catálogo.
6. **Traducciones:** el resto de idiomas se va traduciendo por tandas. Cada uno lo revisa un hablante nativo (TD-011) antes de pasar a producción.
7. **Tamaño:** cada actividad ocupa alrededor de 1 KB por idioma. Con 1000 actividades en 9 idiomas son unos 9 MB de texto, unos 2 MB comprimidos dentro del paquete. Se vigila con TD-012.
