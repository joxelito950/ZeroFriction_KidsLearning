/// Catálogo de «Clasificar» (HU-027 sección 5). Solo Emoji 5.0 o anterior y
/// sin ZWJ, para Android 8 (D-024, D-026).
///
/// - **Por color (5.1):** cada objeto con color tiene **un solo** color, así
///   que en un tablero nunca hay dos cestas válidas. Fuera los de color dudoso
///   o distinto según la fuente (🍉, 🍑, 🐝, 🌈, 🦋, 🐦, 🚙, 💎, 🧢, ☂️, 🍍) y los
///   corazones, que son símbolos.
/// - **Por tamaño (5.2):** cada tablero tiene una temática, y la muestra de
///   las cestas es de esa temática pero nunca está en la bandeja.
library;

/// Los colores de las cestas. Naranja y morado, solo desde esmeralda (P4).
enum SortColor {
  red,
  yellow,
  green,
  blue,
  orange,
  purple;

  /// La muestra de la cesta: dice qué va dentro sin texto (HU-027 3.1).
  SortObject get sample => switch (this) {
        red => SortObject.strawberry,
        yellow => SortObject.banana,
        green => SortObject.clover,
        blue => SortObject.droplet,
        orange => SortObject.tangerine,
        purple => SortObject.grapes,
      };

  /// Los cuatro primeros, para bronce, plata y oro.
  static const List<SortColor> basic = [red, yellow, green, blue];

  /// Las dos cestas de un tablero nunca son solo rojo y verde: un niño
  /// daltónico tendría que adivinar (HU-027 6).
  static bool confusable(Set<SortColor> colors) => colors.length == 2 && colors.containsAll(const {red, green});
}

/// Los tamaños (HU-027 3.4 y P9): el mismo emoji escalado dentro de su celda.
/// Cada paso es 1,5 veces el anterior. Las cestas también cambian de tamaño
/// (P6), algo menos, para que quepan.
enum SortSize {
  big(1, 1),
  medium(0.7, 0.85),
  small(0.45, 0.7);

  const SortSize(this.scale, this.cardScale);

  /// Escala del emoji del objeto.
  final double scale;

  /// Escala de la tarjeta de la cesta.
  final double cardScale;
}

enum SortObject {
  // Con color (5.1).
  apple('🍎', SortColor.red),
  strawberry('🍓', SortColor.red),
  cherries('🍒', SortColor.red),
  tomato('🍅', SortColor.red),
  rose('🌹', SortColor.red),
  ladybug('🐞', SortColor.red),
  balloon('🎈', SortColor.red),
  fireEngine('🚒', SortColor.red),
  crab('🦀', SortColor.red),
  banana('🍌', SortColor.yellow),
  corn('🌽', SortColor.yellow),
  lemon('🍋', SortColor.yellow),
  chick('🐤', SortColor.yellow),
  sunflower('🌻', SortColor.yellow),
  cheese('🧀', SortColor.yellow),
  star('⭐', SortColor.yellow),
  taxi('🚕', SortColor.yellow),
  greenApple('🍏', SortColor.green),
  broccoli('🥦', SortColor.green),
  cucumber('🥒', SortColor.green),
  frog('🐸', SortColor.green),
  turtle('🐢', SortColor.green),
  tree('🌲', SortColor.green),
  clover('🍀', SortColor.green),
  cactus('🌵', SortColor.green),
  avocado('🥑', SortColor.green),
  lizard('🦎', SortColor.green),
  droplet('💧', SortColor.blue),
  spoutingWhale('🐳', SortColor.blue),
  dolphin('🐬', SortColor.blue),
  whale('🐋', SortColor.blue),
  jeans('👖', SortColor.blue),
  wave('🌊', SortColor.blue),
  fish('🐟', SortColor.blue),
  tangerine('🍊', SortColor.orange),
  carrot('🥕', SortColor.orange),
  pumpkin('🎃', SortColor.orange),
  fox('🦊', SortColor.orange),
  basketball('🏀', SortColor.orange),
  grapes('🍇', SortColor.purple),
  eggplant('🍆', SortColor.purple),
  crystalBall('🔮', SortColor.purple),
  // Solo en los tableros de tamaño (5.2): su color no cuenta.
  dog('🐶'),
  cat('🐱'),
  rabbit('🐰'),
  pear('🍐'),
  peach('🍑'),
  bus('🚌'),
  tractor('🚜'),
  bicycle('🚲'),
  rocket('🚀'),
  soccerBall('⚽'),
  cookie('🍪'),
  doughnut('🍩'),
  blossom('🌸'),
  // Muestras de las cestas de tamaño (5.2).
  bear('🐻'),
  car('🚗'),
  blueCircle('🔵');

  const SortObject(this.symbol, [this.color]);

  final String symbol;

  /// El color, para los tableros de color; `null` si solo sale en los de tamaño.
  final SortColor? color;
}

/// Las temáticas de los tableros de tamaño (HU-027 P6, tabla 5.2). Se compara
/// dentro del tablero: el mismo emoji sale en varios tamaños, así que un 🐶
/// pequeño y uno grande no chocan con el mundo real. Nunca animales de tamaño
/// real muy marcado (🐘, 🐭, 🐳).
enum SortTheme {
  animals(SortObject.bear, [
    SortObject.dog,
    SortObject.cat,
    SortObject.rabbit,
    SortObject.chick,
    SortObject.fish,
    SortObject.ladybug,
    SortObject.turtle,
    SortObject.frog,
  ]),
  fruits(SortObject.apple, [
    SortObject.tangerine,
    SortObject.lemon,
    SortObject.strawberry,
    SortObject.pear,
    SortObject.banana,
    SortObject.peach,
  ]),
  vehicles(SortObject.car, [
    SortObject.taxi,
    SortObject.fireEngine,
    SortObject.bus,
    SortObject.tractor,
    SortObject.bicycle,
    SortObject.rocket,
  ]),
  mixed(SortObject.blueCircle, [
    SortObject.star,
    SortObject.soccerBall,
    SortObject.basketball,
    SortObject.balloon,
    SortObject.sunflower,
    SortObject.cookie,
    SortObject.doughnut,
    SortObject.blossom,
  ]);

  const SortTheme(this.sample, this.objects);

  /// La muestra de las cestas: no está en la bandeja, para que no sea una
  /// ayuda (las ayudas solo van en el tutorial y en bronce).
  final SortObject sample;
  final List<SortObject> objects;
}

abstract final class SortCatalog {
  /// Objetos de [color], con la muestra de su cesta o sin ella.
  static List<SortObject> objectsOf(SortColor color, {bool withSample = true}) => [
        for (final SortObject object in SortObject.values)
          if (object.color == color && (withSample || object != color.sample)) object,
      ];
}
