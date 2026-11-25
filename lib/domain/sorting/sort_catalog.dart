/// Catálogo de «Clasificar» por color (HU-027 5.1): cada objeto tiene **un
/// solo** color, así que en un tablero nunca hay dos cestas válidas. Solo
/// Emoji 5.0 o anterior y sin ZWJ, para Android 8 (D-024, D-026); fuera los de
/// color dudoso o distinto según la fuente (🍉, 🍑, 🐝, 🌈, 🦋, 🐦, 🚙, 💎, 🧢,
/// ☂️, 🍍) y los corazones, que son símbolos.
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

enum SortObject {
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
  crystalBall('🔮', SortColor.purple);

  const SortObject(this.symbol, this.color);

  final String symbol;
  final SortColor color;
}

abstract final class SortCatalog {
  /// Objetos de [color], con la muestra de su cesta o sin ella.
  static List<SortObject> objectsOf(SortColor color, {bool withSample = true}) => [
        for (final SortObject object in SortObject.values)
          if (object.color == color && (withSample || object != color.sample)) object,
      ];
}
