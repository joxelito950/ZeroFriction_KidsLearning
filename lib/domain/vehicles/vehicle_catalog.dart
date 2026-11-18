/// Catálogo de «A su sitio» (HU-052 7.2): cada vehículo tiene un sitio en cada
/// familia, así que en un tablero de una sola familia nunca hay dos respuestas
/// válidas. Solo Emoji 5.0 o anterior y sin ZWJ, para Android 8 (D-024, D-026).
library;

/// Las dos familias de sitios (HU-052 P6).
enum VehicleFamily {
  /// Por dónde va: carretera, vía, agua, cielo, espacio (y nieve en Navidad).
  route,

  /// A qué se dedica: hospital, fuego, campo… Desde la ronda de oro.
  purpose,
}

/// Un sitio. Algunos sirven en las dos familias (el espacio 🌙 del cohete).
enum Place {
  road('🛣️'),
  rail('🛤️'),
  water('🌊'),
  sky('☁️'),
  space('🌙'),
  snow('❄️'),
  home('🏠'),
  busStop('🚏'),
  hotel('🏨'),
  school('🏫'),
  trafficLight('🚦'),
  hospital('🏥'),
  fire('🔥'),
  parcels('📦'),
  factory('🏭'),
  field('🌾'),
  finish('🏁'),
  park('🏞️'),
  station('🚉'),
  island('🏝️'),
  fishing('🎣'),
  port('⚓'),
  mountain('🏔️'),
  christmasTree('🎄');

  const Place(this.symbol);

  final String symbol;
}

/// Grupos de vehículos de forma parecida (HU-052 7.3, niveles 6 a 8). En la
/// familia «A qué se dedica», cada uno de un grupo va a un sitio distinto.
enum LookalikeGroup { emergency, passengers, heavy, boats, aircraft }

enum Vehicle {
  car('🚗', route: Place.road, purpose: Place.home, group: LookalikeGroup.passengers),
  bus('🚌', route: Place.road, purpose: Place.busStop, group: LookalikeGroup.passengers),
  taxi('🚕', route: Place.road, purpose: Place.hotel, group: LookalikeGroup.passengers),
  minibus('🚐', route: Place.road, purpose: Place.school, group: LookalikeGroup.passengers),
  police('🚓', route: Place.road, purpose: Place.trafficLight, group: LookalikeGroup.emergency),
  ambulance('🚑', route: Place.road, purpose: Place.hospital, group: LookalikeGroup.emergency),
  fireEngine('🚒', route: Place.road, purpose: Place.fire, group: LookalikeGroup.emergency),
  truck('🚚', route: Place.road, purpose: Place.parcels, group: LookalikeGroup.heavy),
  lorry('🚛', route: Place.road, purpose: Place.factory, group: LookalikeGroup.heavy),
  tractor('🚜', route: Place.road, purpose: Place.field, group: LookalikeGroup.heavy),
  motorcycle('🏍️', route: Place.road, purpose: Place.finish),
  bicycle('🚲', route: Place.road, purpose: Place.park),
  scooter('🛴', route: Place.road, purpose: Place.park),
  locomotive('🚂', route: Place.rail, purpose: Place.station),
  train('🚆', route: Place.rail, purpose: Place.station),
  sailboat('⛵', route: Place.water, purpose: Place.island, group: LookalikeGroup.boats),
  speedboat('🚤', route: Place.water, purpose: Place.fishing, group: LookalikeGroup.boats),
  ship('🚢', route: Place.water, purpose: Place.port, group: LookalikeGroup.boats),
  airplane('✈️', route: Place.sky, purpose: Place.island, group: LookalikeGroup.aircraft),
  helicopter('🚁', route: Place.sky, purpose: Place.mountain, group: LookalikeGroup.aircraft),
  rocket('🚀', route: Place.space, purpose: Place.space, group: LookalikeGroup.aircraft),

  /// Solo durante la edición de Navidad (HU-052 sección 6, HU-042).
  sled('🛷', route: Place.snow, purpose: Place.christmasTree, christmas: true);

  const Vehicle(this.symbol, {required this.route, required this.purpose, this.group, this.christmas = false});

  final String symbol;
  final Place route;
  final Place purpose;
  final LookalikeGroup? group;
  final bool christmas;

  /// El único sitio correcto de este vehículo en un tablero de [family].
  Place placeIn(VehicleFamily family) => switch (family) {
        VehicleFamily.route => route,
        VehicleFamily.purpose => purpose,
      };
}

abstract final class VehicleCatalog {
  /// Los vehículos que pueden salir: el trineo, solo en Navidad.
  static List<Vehicle> vehicles({required bool christmas}) =>
      [for (final Vehicle vehicle in Vehicle.values) if (christmas || !vehicle.christmas) vehicle];

  /// Los sitios de [family] que tienen algún vehículo.
  static List<Place> placesOf(VehicleFamily family, {required bool christmas}) =>
      {for (final Vehicle vehicle in vehicles(christmas: christmas)) vehicle.placeIn(family)}.toList();

  /// Los vehículos que van a [place] en [family].
  static List<Vehicle> vehiclesFor(Place place, VehicleFamily family, {required bool christmas}) =>
      [for (final Vehicle vehicle in vehicles(christmas: christmas)) if (vehicle.placeIn(family) == place) vehicle];
}
