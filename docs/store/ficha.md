# Ficha de Google Play (HU-014, entrega 3)

Textos e imágenes de la ficha de la tienda, en los dos idiomas de la ficha (español e inglés, HU-014 P7). Borrador del 2026-11-05: **pendiente de la revisión de TD-011** (al menos español e inglés antes de publicar).

Límites de Google Play: nombre ≤ 30 caracteres, descripción breve ≤ 80, descripción completa ≤ 4000. Sin palabras como «el mejor», «gratis», «n.º 1» ni emojis en el nombre (política de metadatos), y nada que prometa lo que la app no hace (política de Familias).

## Imágenes

| Pieza | Archivo | Estado |
|---|---|---|
| Icono (512 × 512) | [icon-512.png](icon-512.png) | ✅ (HU-013) |
| Gráfico destacado (1024 × 500, sin texto) | [feature-graphic.png](feature-graphic.png) | ✅ Borrador; se regenera con `tool/brand/prepare_brand_images.py` |
| Capturas de teléfono (mín. 2, recomendadas 4–8) | [`capturas/`](capturas/) | ✅ Hechas el 2026-11-09 en el moto g55 con la versión `1.0.0-rc.2` y la barra de estado limpia. **Español (6):** menú en vertical y en horizontal (con el dorado), tablero, vista previa de las cartas, celebración con estrellas, mano del tutorial, Zona de padres (`es-*.png`). **Inglés (5):** menú, tablero, vista previa, mano del tutorial y Zona de padres (`en-*.png`); falta la celebración en inglés, opcional |

## Español (es-419 / es-ES)

**Nombre (21):** ToddlerLogic: memoria

**Descripción breve (75):** Juegos de memoria y lógica para niños de 2 a 5 años, sin anuncios ni datos.

**Descripción completa:**

ToddlerLogic reúne juegos de memoria y lógica pensados para los más pequeños, con animales, frutas, vehículos y mucho más.

Tres juegos
• Memoria: encontrar las parejas de cartas, de 4 a 16 cartas.
• Sombras: llevar cada dibujo hasta la sombra con su misma forma.
• ¿Cuál es diferente?: tocar el que no es como los demás, de formas y colores a grupos como selva o granja.

Hecho para niños de 2 a 5 años
• Se entiende mirando: sin textos que leer y una mano animada que enseña a jugar.
• Cada juego empieza fácil y sube solo de reto en ocho rondas, con medallas de bronce a diamante.
• Celebra cada logro con estrellas y sonidos suaves, sin sonidos de error ni mensajes negativos.

Tranquilidad para la familia
• Sin anuncios.
• Sin recoger datos: todo se queda en el teléfono y funciona sin internet.
• Zona de padres protegida con un desafío para adultos.
• Tiempo de juego diario: elige un límite y, al llegar, una pantalla de descanso tranquila.
• Recomendaciones para usar los controles parentales del teléfono.
• Desde la Zona de padres, escríbenos con un correo ya preparado: la app no envía nada por su cuenta.

En 9 idiomas: español, inglés, portugués, alemán, francés, italiano, japonés, coreano y árabe.

## English (en-US)

**Name (25):** ToddlerLogic: memory game

**Short description (73):** Memory and logic games for children aged 2 to 5, with no ads and no data.

**Full description:**

ToddlerLogic brings together memory and logic games made for little ones, with animals, fruit, vehicles and much more.

Three games
• Memory: find the matching pairs of cards, from 4 to 16 cards.
• Shadows: drag each picture onto the shadow with the same shape.
• Odd one out: tap the one that is not like the others, from shapes and colours to groups like jungle or farm.

Made for children aged 2 to 5
• Easy to understand just by looking: no text to read, and an animated hand shows how to play.
• Each game starts easy and grows by itself in eight rounds, with medals from bronze to diamond.
• Every win is celebrated with stars and gentle sounds, with no error sounds or negative messages.

Peace of mind for families
• No ads.
• No data collected: everything stays on the phone and works offline.
• Parents' Zone protected by a grown-ups-only challenge.
• Daily play time: choose a limit and, when it is reached, a calm rest screen appears.
• Tips for using the phone's own parental controls.
• From the Parents' Zone, write to us with a ready-made email: the app sends nothing by itself.

In 9 languages: English, Spanish, Portuguese, German, French, Italian, Japanese, Korean and Arabic.

## Notas para el revisor de Google (acceso a la app)

> All features are available without an account. The Parents' Zone is opened by tapping "Parents' Zone" twice on the main menu and answering a multiplication written in words (for example, "seven times three" → 21). The app has no ads, no in-app purchases, no network access and requests no permissions. "Send feedback" in the Parents' Zone only opens the phone's email app with a prepared, unsent email; the app itself sends nothing.

## Pendiente antes de subir

- Revisión de los textos (TD-011, español e inglés).
- ✅ Correo de contacto de la ficha: `toddler.logic.app@outlook.com` (el mismo que el de la política).
- ✅ URL de la política: `https://joxelito950.github.io/ZeroFriction_KidsLearning/privacy/` (activa; se actualiza al pasar a `main`).
- Capturas.
- ✅ Sombras (HU-007) y «Enviar comentarios» (HU-032) ya están en la descripción (2026-11-10, versión `1.0.0-rc.3`). Cuando llegue el pago (HU-006), actualizarla otra vez.
- Capturas de Sombras y de «¿Cuál es diferente?»: faltan (hacerlas en el moto g55 con la versión `1.0.0-rc.5`, que trae las medallas nuevas y el niño en las celebraciones).

## Novedades de la versión (campo «Notas de la versión» de Play Console, máx. 500 caracteres)

**`1.0.0-rc.7` · es-419:**

> Nuevo: Actividades sin pantallas. Ideas para jugar en casa con cosas cotidianas, con buscador y una idea para cada día.
> Hora de dormir y siestas: la app invita a descansar a la hora que elijas, con media hora de preparación tranquila.
> Cómo juega: tocar o arrastrar las piezas, y la opción para zurdos.
> Cada juego muestra sus movimientos.
> Tus medallas y estrellas se conservan.

**`1.0.0-rc.7` · en-US:**

> New: Screen-free activities. Ideas to play at home with everyday things, with a search and an idea for each day.
> Bedtime and naps: the app invites to rest at the time you choose, with a calm half hour to wind down.
> How they play: tap or drag the pieces, and a left-handed option.
> Every game shows its moves.
> Your medals and stars are kept.

**`1.0.0-rc.6` · es-419:**

> Nuevo juego: A su sitio. Lleva cada vehículo a su sitio: por dónde va y a qué se dedica.
> Edición de Navidad, del 20 de noviembre al 6 de enero: llegan el trineo y los regalos.
> Menú en cuadrícula, con «Nuevo» en lo que acaba de llegar.
> Cada juego muestra su ronda, y «Su progreso» dice si la juega por primera vez o la repasa.
> Tus medallas y estrellas se conservan.

**`1.0.0-rc.6` · en-US:**

> New game: To its place. Take each vehicle where it belongs: where it goes and what it does.
> Christmas edition, from 20 November to 6 January: the sled and the presents arrive.
> A grid menu, with «New» on what just arrived.
> Each game shows its round, and «Their progress» tells whether it is the first time or a replay.
> Your medals and stars are kept.

**`1.0.0-rc.5` · es-419:**

> Ocho rondas con medallas, de bronce a diamante: cada juego sube de reto en pasos más pequeños.
> El niño de ToddlerLogic celebra cada medalla y te invita a jugar.
> En Sombras, la sombra se ve mientras llevas el dibujo.
> Zona de padres más ordenada.
> Tus medallas y estrellas se conservan: no hace falta borrar los datos.

**`1.0.0-rc.5` · en-US:**

> Eight rounds with medals, from bronze to diamond: each game grows in smaller steps.
> The ToddlerLogic kid celebrates every medal and invites you to play.
> In Shadows, the shadow stays visible while you drag the picture.
> A tidier Parents' Zone.
> Your medals and stars are kept: no need to clear the app's data.

**`1.0.0-rc.4` · es-419:**

> Nuevo juego: ¿Cuál es diferente? Toca el que no es como los demás.
> Cada juego empieza fácil y sube solo de reto: rondas Fácil, Normal y Reto máximo, con medallas de bronce, plata y oro.
> Sonidos suaves (se pueden apagar en la Zona de padres). Durante la prueba, todo es gratis.
> Te pedimos borrar los datos de la app antes de probar esta versión.

**`1.0.0-rc.4` · en-US:**

> New game: Odd one out. Tap the one that is not like the others.
> Each game starts easy and grows by itself: Easy, Normal and Impossible rounds, with bronze, silver and gold medals.
> Gentle sounds (can be turned off in the Parents' Zone). During the test, everything is free.
> Please clear the app's data before testing this version.

**`1.0.0-rc.3` · es-419:**

> Nuevo juego: Sombras. Lleva cada dibujo hasta la sombra con su misma forma, en siete niveles.
> En la Zona de padres, «Enviar comentarios» abre tu correo con un mensaje ya preparado para contarnos fallos o ideas.

**`1.0.0-rc.3` · en-US:**

> New game: Shadows. Drag each picture onto the shadow with the same shape, across seven levels.
> In the Parents' Zone, "Send feedback" opens your email app with a ready-made message so you can tell us about bugs or ideas.
