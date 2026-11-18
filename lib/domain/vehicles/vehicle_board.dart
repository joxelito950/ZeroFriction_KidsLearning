import 'dart:math';

import 'vehicle_catalog.dart';
import 'vehicle_ladder.dart';

/// Un tablero de «A su sitio» (HU-052 7.1): los sitios, arriba, y los
/// vehículos de la bandeja. Cada vehículo tiene un solo sitio correcto: el
/// suyo en la [family] del tablero; un sitio puede recibir hasta 2.
final class VehicleBoard {
  VehicleBoard({required this.family, required List<Place> places, required List<Vehicle> vehicles})
      : places = List.unmodifiable(places),
        vehicles = List.unmodifiable(vehicles) {
    for (final Vehicle vehicle in vehicles) {
      if (!places.contains(vehicle.placeIn(family))) {
        throw ArgumentError.value(vehicle, 'vehicles', 'its place is not on the board');
      }
    }
  }

  final VehicleFamily family;

  /// Los sitios en el orden en que se muestran.
  final List<Place> places;

  /// Los vehículos en el orden de la bandeja.
  final List<Vehicle> vehicles;

  /// Como mucho, vehículos que van a un mismo sitio (HU-052 7.2).
  static const int maxPerPlace = 2;

  Place targetOf(Vehicle vehicle) => vehicle.placeIn(family);

  /// ¿Encaja [vehicle] en [place]? Si no, vuelve a la bandeja y cuenta como
  /// fallo para las estrellas.
  bool accepts(Place place, Vehicle vehicle) => targetOf(vehicle) == place;

  /// Sitios a los que no va ningún vehículo del tablero.
  List<Place> get freePlaces => [
        for (final Place place in places)
          if (!vehicles.any((vehicle) => targetOf(vehicle) == place)) place,
      ];

  /// Sortea el tablero de [level] con las reglas de la ronda:
  ///
  /// 1. La familia: en bronce y plata, «Por dónde va»; desde oro, al azar entre
  ///    las que tienen sitios suficientes (con el sitio libre).
  /// 2. En Navidad, el trineo siempre está.
  /// 3. Los sitios que reciben 2 vehículos: tantos como vehículos sobren
  ///    respecto a los sitios ([VehicleLevel.vehicles] − [VehicleLevel.places]).
  /// 4. En los niveles de parecidos con «A qué se dedica», hasta 3 vehículos
  ///    parecidos, cada uno a un sitio nuevo.
  /// 5. Un vehículo por cada sitio que falte, hasta [VehicleLevel.places].
  /// 6. El sitio libre, si toca, y el orden al azar.
  static VehicleBoard pick(Random random, VehicleLevel level, VehicleRules rules) {
    final bool christmas = rules.christmas;
    final bool withFree = rules.freePlaces && level.freePlace;
    final int needed = level.places + (withFree ? 1 : 0);
    final List<VehicleFamily> families = [
      for (final VehicleFamily family in rules.families)
        if (VehicleCatalog.placesOf(family, christmas: christmas).length >= needed) family,
    ];
    if (families.isEmpty) throw StateError('No family has $needed places');
    final VehicleFamily family = families[random.nextInt(families.length)];

    // Varios intentos: una mala elección de sitios puede no tener vehículos
    // suficientes (por ejemplo, el espacio solo tiene el cohete).
    for (var attempt = 0; attempt < 50; attempt++) {
      final List<Vehicle>? chosen = _chooseVehicles(random, level, family, christmas: christmas);
      if (chosen == null) continue;
      final Set<Place> targets = {for (final Vehicle vehicle in chosen) vehicle.placeIn(family)};
      final List<Place> places = targets.toList();
      if (withFree) {
        final List<Place> spare = [
          for (final Place place in VehicleCatalog.placesOf(family, christmas: christmas))
            if (!targets.contains(place)) place,
        ];
        places.add(spare[random.nextInt(spare.length)]);
      }
      return VehicleBoard(
        family: family,
        places: places..shuffle(random),
        vehicles: chosen..shuffle(random),
      );
    }
    throw StateError('Could not pick a board for level ${level.number}');
  }

  static List<Vehicle>? _chooseVehicles(Random random, VehicleLevel level, VehicleFamily family,
      {required bool christmas}) {
    final List<Vehicle> chosen = [];
    final Map<Place, int> perPlace = {};
    bool add(Vehicle vehicle) {
      final Place place = vehicle.placeIn(family);
      final int count = perPlace[place] ?? 0;
      if (chosen.contains(vehicle) || count >= maxPerPlace) return false;
      if (count == 0 && perPlace.length >= level.places) return false;
      chosen.add(vehicle);
      perPlace[place] = count + 1;
      return true;
    }

    List<Vehicle> shuffledFor(Place place) =>
        VehicleCatalog.vehiclesFor(place, family, christmas: christmas)..shuffle(random);

    if (christmas) add(Vehicle.sled);

    // Los sitios dobles primero: con más vehículos que sitios, algunos sitios
    // reciben 2, y en «A qué se dedica» solo unos pocos tienen dos vehículos.
    final int doubles = level.vehicles - level.places;
    final List<Place> doubleCapable = [
      for (final Place place in VehicleCatalog.placesOf(family, christmas: christmas))
        if (VehicleCatalog.vehiclesFor(place, family, christmas: christmas).length >= maxPerPlace) place,
    ]..shuffle(random);
    for (final Place place in doubleCapable.take(doubles)) {
      for (final Vehicle vehicle in shuffledFor(place).take(maxPerPlace)) {
        add(vehicle);
      }
    }

    // Parecidos: hasta 3 de un grupo, cada uno a un sitio nuevo.
    if (level.lookalikes && family == VehicleFamily.purpose) {
      final LookalikeGroup group = LookalikeGroup.values[random.nextInt(LookalikeGroup.values.length)];
      final List<Vehicle> members = [
        for (final Vehicle vehicle in Vehicle.values)
          if (vehicle.group == group) vehicle,
      ]..shuffle(random);
      var added = 0;
      for (final Vehicle vehicle in members) {
        if (added == 3) break;
        if (!perPlace.containsKey(vehicle.placeIn(family)) && add(vehicle)) added++;
      }
    }

    // El resto, un vehículo por cada sitio nuevo.
    final List<Place> candidates = VehicleCatalog.placesOf(family, christmas: christmas)..shuffle(random);
    for (final Place place in candidates) {
      if (perPlace.length >= level.places) break;
      if (!perPlace.containsKey(place)) add(shuffledFor(place).first);
    }
    return chosen.length == level.vehicles && perPlace.length == level.places ? chosen : null;
  }
}
