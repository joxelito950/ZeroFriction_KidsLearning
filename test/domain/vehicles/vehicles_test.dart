import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_board.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_catalog.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_ladder.dart';

/// HU-052: la lógica de «A su sitio».
void main() {
  group('catalog (7.2)', () {
    test('every vehicle has exactly one place in each family (criterion 2)', () {
      for (final Vehicle vehicle in Vehicle.values) {
        for (final VehicleFamily family in VehicleFamily.values) {
          final List<Place> valid = [for (final Place place in Place.values) if (vehicle.placeIn(family) == place) place];
          expect(valid, hasLength(1), reason: '${vehicle.name} in ${family.name}');
        }
      }
    });

    test('symbols are unique, without ZWJ sequences (Android 8, criterion 1)', () {
      final List<String> symbols = [
        for (final Vehicle vehicle in Vehicle.values) vehicle.symbol,
        for (final Place place in Place.values) place.symbol,
      ];
      expect(symbols.where((symbol) => symbol.contains('‍')), isEmpty);
      expect(Vehicle.values.map((vehicle) => vehicle.symbol).toSet(), hasLength(Vehicle.values.length));
      expect(Place.values.map((place) => place.symbol).toSet(), hasLength(Place.values.length));
    });

    test('the sled and its places only exist at Christmas (section 6)', () {
      expect(VehicleCatalog.vehicles(christmas: false), isNot(contains(Vehicle.sled)));
      expect(VehicleCatalog.vehicles(christmas: true), contains(Vehicle.sled));
      expect(VehicleCatalog.placesOf(VehicleFamily.route, christmas: false),
          unorderedEquals([Place.road, Place.rail, Place.water, Place.sky, Place.space]));
      expect(VehicleCatalog.placesOf(VehicleFamily.route, christmas: true), contains(Place.snow));
      expect(VehicleCatalog.placesOf(VehicleFamily.purpose, christmas: true), contains(Place.christmasTree));
    });

    test('lookalikes go to different places when the family is «what it does» (7.3)', () {
      for (final LookalikeGroup group in LookalikeGroup.values) {
        final List<Vehicle> members = [for (final Vehicle vehicle in Vehicle.values) if (vehicle.group == group) vehicle];
        expect(members.length, greaterThanOrEqualTo(3), reason: group.name);
        expect(members.map((vehicle) => vehicle.purpose).toSet(), hasLength(members.length), reason: group.name);
      }
    });
  });

  group('ladder and rules (7.3, 7.4)', () {
    test('8 levels, the first is the tutorial, growing in vehicles', () {
      expect(VehicleLadder.maxLevel, 8);
      expect(VehicleLadder.rounds.levels, 8);
      expect(VehicleLadder.levels.map((level) => level.vehicles), [2, 3, 3, 4, 4, 5, 6, 6]);
      expect(VehicleLadder.levels.map((level) => level.places), [2, 2, 3, 3, 4, 4, 4, 5]);
      expect(VehicleLadder.levelAt(6).lookalikes, isTrue);
      expect(() => VehicleLadder.levelAt(9), throwsRangeError);
    });

    test('bronze and silver: only «where it goes», no free places and no time (D-043)', () {
      for (final GameDifficulty round in [GameDifficulty.bronze, GameDifficulty.silver]) {
        final VehicleRules rules = VehicleRules(round: round);
        expect(rules.families, [VehicleFamily.route]);
        expect(rules.freePlaces, isFalse);
        expect(rules.timed, isFalse);
      }
    });

    test('from gold: both families, free places and time unless «play without time»', () {
      const VehicleRules gold = VehicleRules(round: GameDifficulty.gold);
      expect(gold.families, VehicleFamily.values);
      expect(gold.freePlaces, isTrue);
      expect(gold.timed, isTrue);
      expect(const VehicleRules(round: GameDifficulty.gold, timerDisabled: true).timed, isFalse);
    });

    test('the magnet gets stricter and the layout random at the top', () {
      expect(const VehicleRules(round: GameDifficulty.bronze).coverageToSnap, 0.4);
      expect(const VehicleRules(round: GameDifficulty.diamond).coverageToSnap, 0.9);
      expect(const VehicleRules(round: GameDifficulty.sapphire).randomLayout, isFalse);
      expect(const VehicleRules(round: GameDifficulty.obsidian).randomLayout, isTrue);
    });

    test('rules compare by value', () {
      expect(const VehicleRules(round: GameDifficulty.gold), const VehicleRules(round: GameDifficulty.gold));
      expect(const VehicleRules(round: GameDifficulty.gold).hashCode,
          const VehicleRules(round: GameDifficulty.gold).hashCode);
      expect(const VehicleRules(round: GameDifficulty.gold, christmas: true),
          isNot(const VehicleRules(round: GameDifficulty.gold)));
    });

    test('stars: 3 with N fails or fewer, also in the free rounds; 2 up to 2N; 1 after', () {
      expect(VehicleStars.forWin(vehicles: 4, fails: 0), 3);
      expect(VehicleStars.forWin(vehicles: 4, fails: 4), 3);
      expect(VehicleStars.forWin(vehicles: 4, fails: 8), 2);
      expect(VehicleStars.forWin(vehicles: 4, fails: 9), 1);
      expect(() => VehicleStars.forWin(vehicles: 4, fails: -1), throwsRangeError);
      expect(() => VehicleStars.forWin(vehicles: 0, fails: 0), throwsRangeError);
    });
  });

  group('board (7.1)', () {
    void checkBoard(VehicleBoard board, VehicleLevel level, VehicleRules rules) {
      final String why = 'level ${level.number}, ${rules.round.name}, christmas ${rules.christmas}';
      expect(board.vehicles, hasLength(level.vehicles), reason: why);
      expect(board.vehicles.toSet(), hasLength(level.vehicles), reason: why);
      expect(rules.families, contains(board.family), reason: why);
      final Set<Place> targets = {for (final Vehicle vehicle in board.vehicles) board.targetOf(vehicle)};
      expect(targets, hasLength(level.places), reason: why);
      for (final Place place in targets) {
        expect(board.vehicles.where((vehicle) => board.targetOf(vehicle) == place).length,
            lessThanOrEqualTo(VehicleBoard.maxPerPlace), reason: why);
      }
      expect(board.freePlaces, hasLength(rules.freePlaces && level.freePlace ? 1 : 0), reason: why);
      expect(board.places.toSet(), hasLength(board.places.length), reason: why);
      for (final Vehicle vehicle in board.vehicles) {
        expect(board.places.where((place) => board.accepts(place, vehicle)), hasLength(1), reason: why);
      }
      expect(board.vehicles.contains(Vehicle.sled), rules.christmas, reason: why);
    }

    test('every board of every level and round follows the rules (seeded sweep)', () {
      final Random random = Random(52);
      for (final GameDifficulty round in GameDifficulty.values) {
        for (final bool christmas in [false, true]) {
          final VehicleRules rules = VehicleRules(round: round, christmas: christmas);
          for (final VehicleLevel level in VehicleLadder.levels) {
            for (var i = 0; i < 40; i++) {
              checkBoard(VehicleBoard.pick(random, level, rules), level, rules);
            }
          }
        }
      }
    });

    test('from gold both families come out; lookalike levels bring a group of lookalikes', () {
      final Random random = Random(7);
      const VehicleRules gold = VehicleRules(round: GameDifficulty.gold);
      final Set<VehicleFamily> seen = {};
      var lookalikeBoards = 0;
      for (var i = 0; i < 200; i++) {
        final VehicleBoard board = VehicleBoard.pick(random, VehicleLadder.levelAt(7), gold);
        seen.add(board.family);
        if (board.family != VehicleFamily.purpose) continue;
        final Map<LookalikeGroup, int> groups = {};
        for (final Vehicle vehicle in board.vehicles) {
          if (vehicle.group case final LookalikeGroup group) groups[group] = (groups[group] ?? 0) + 1;
        }
        if (groups.values.any((count) => count >= 2)) lookalikeBoards++;
      }
      expect(seen, VehicleFamily.values.toSet());
      expect(lookalikeBoards, greaterThan(0));
    });

    test('the same seed gives the same board', () {
      VehicleBoard pick() => VehicleBoard.pick(Random(3), VehicleLadder.levelAt(5), const VehicleRules(round: GameDifficulty.ruby));
      expect(pick().vehicles, pick().vehicles);
      expect(pick().places, pick().places);
    });

    test('a vehicle whose place is not on the board is rejected', () {
      expect(
        () => VehicleBoard(family: VehicleFamily.route, places: const [Place.road], vehicles: const [Vehicle.ship]),
        throwsArgumentError,
      );
      final VehicleBoard board =
          VehicleBoard(family: VehicleFamily.purpose, places: const [Place.hospital, Place.fire], vehicles: const [Vehicle.ambulance]);
      expect(board.accepts(Place.hospital, Vehicle.ambulance), isTrue);
      expect(board.accepts(Place.fire, Vehicle.ambulance), isFalse);
      expect(board.freePlaces, [Place.fire]);
    });
  });
}
