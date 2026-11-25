import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/sorting/sort_board.dart';
import 'package:toddler_logic/domain/sorting/sort_catalog.dart';
import 'package:toddler_logic/domain/sorting/sort_ladder.dart';

/// HU-027, entregas 2 y 3: «Clasificar» por color, por tamaño y las dos cosas.
void main() {
  group('SortCatalog (5.1 and 5.2)', () {
    test('every object is a single emoji without ZWJ, and none repeats', () {
      final Set<String> symbols = {};
      for (final SortObject object in SortObject.values) {
        expect(object.symbol.runes.contains(0x200D), isFalse, reason: '${object.name} has no ZWJ');
        expect(symbols.add(object.symbol), isTrue, reason: '${object.name} is not repeated');
      }
    });

    test('objects of doubtful colour never sort by colour', () {
      const List<String> doubtful = ['🍉', '🍑', '🐝', '🌈', '🦋', '🐦', '🚙', '💎', '🧢', '☂️', '🍍', '❤️', '💛', '💚', '💙', '💜'];
      for (final SortObject object in SortObject.values.where((object) => object.color != null)) {
        expect(doubtful, isNot(contains(object.symbol)), reason: object.name);
      }
    });

    test('each colour basket has its own sample, of its colour, and enough objects to play', () {
      for (final SortColor color in SortColor.values) {
        expect(color.sample.color, color);
        expect(SortCatalog.objectsOf(color, withSample: false), isNot(contains(color.sample)));
        expect(SortCatalog.objectsOf(color, withSample: false).length, greaterThanOrEqualTo(2), reason: color.name);
      }
      for (final SortColor color in SortColor.basic) {
        expect(SortCatalog.objectsOf(color, withSample: false).length, greaterThanOrEqualTo(4),
            reason: '${color.name}: 4 baskets need 4 objects per colour (5.1)');
      }
    });

    test('each theme has its sample outside the tray and enough objects (P6)', () {
      for (final SortTheme theme in SortTheme.values) {
        expect(theme.objects, isNot(contains(theme.sample)), reason: theme.name);
        expect(theme.objects.length, greaterThanOrEqualTo(2), reason: theme.name);
      }
      expect(SortTheme.animals.sample.symbol, '🐻', reason: 'the three bears');
      expect(SortTheme.fruits.sample.symbol, '🍎');
      expect(SortTheme.vehicles.sample.symbol, '🚗');
    });

    test('sizes step by 1.5 and the baskets shrink too (3.4, P9)', () {
      expect(SortSize.values.map((size) => size.scale), [1, 0.7, 0.45]);
      expect(SortSize.big.cardScale, greaterThan(SortSize.medium.cardScale));
      expect(SortSize.medium.cardScale, greaterThan(SortSize.small.cardScale));
    });

    test('red and green alone are confusable; with a third colour, not', () {
      expect(SortColor.confusable({SortColor.red, SortColor.green}), isTrue);
      expect(SortColor.confusable({SortColor.red, SortColor.blue}), isFalse);
      expect(SortColor.confusable({SortColor.red, SortColor.green, SortColor.blue}), isFalse);
    });
  });

  group('SortRules (4.2)', () {
    test('colour first, then size, then both', () {
      final Map<GameDifficulty, SortCriterion> expected = {
        GameDifficulty.bronze: SortCriterion.color,
        GameDifficulty.silver: SortCriterion.color,
        GameDifficulty.gold: SortCriterion.size,
        GameDifficulty.ruby: SortCriterion.size,
        GameDifficulty.emerald: SortCriterion.color,
        GameDifficulty.sapphire: SortCriterion.size,
        GameDifficulty.obsidian: SortCriterion.colorAndSize,
        GameDifficulty.diamond: SortCriterion.colorAndSize,
      };
      for (final MapEntry<GameDifficulty, SortCriterion> entry in expected.entries) {
        expect(SortRules(round: entry.key, level: 4).criterion, entry.value, reason: entry.key.name);
      }
    });

    test('the sizes of each round and level', () {
      const List<SortSize> bigSmall = [SortSize.big, SortSize.small];
      expect(const SortRules(round: GameDifficulty.gold, level: 6).sizes, bigSmall, reason: 'gold: big and small');
      expect(const SortRules(round: GameDifficulty.ruby, level: 2).sizes, bigSmall);
      expect(const SortRules(round: GameDifficulty.ruby, level: 3).sizes, SortSize.values);
      expect(const SortRules(round: GameDifficulty.sapphire, level: 5).sizes, SortSize.values);
      expect(const SortRules(round: GameDifficulty.obsidian, level: 5).sizes, bigSmall);
      // Diamante alterna la pareja de tamaños (P5).
      for (final int level in [2, 5]) {
        expect(SortRules(round: GameDifficulty.diamond, level: level).sizes, bigSmall, reason: 'diamond $level');
      }
      for (final int level in [3, 6]) {
        expect(SortRules(round: GameDifficulty.diamond, level: level).sizes, [SortSize.big, SortSize.medium],
            reason: 'diamond $level');
      }
      for (final int level in [4, 7]) {
        expect(SortRules(round: GameDifficulty.diamond, level: level).sizes, [SortSize.medium, SortSize.small],
            reason: 'diamond $level');
      }
      expect(const SortRules(round: GameDifficulty.diamond, level: 8).sizes, SortSize.values);
    });

    test('orange and purple, free baskets, time and layout come in their rounds', () {
      for (final GameDifficulty round in GameDifficulty.values) {
        final SortRules rules = SortRules(round: round, level: 3);
        final bool fromEmerald = round.index >= GameDifficulty.emerald.index;
        expect(rules.colors, fromEmerald ? SortColor.values : SortColor.basic, reason: round.name);
        expect(rules.freeBaskets, round == GameDifficulty.emerald, reason: '${round.name}: only colour boards');
        expect(rules.timed, round.index >= GameDifficulty.gold.index, reason: round.name);
        expect(rules.randomLayout, round.index >= GameDifficulty.obsidian.index, reason: round.name);
      }
      expect(const SortRules(round: GameDifficulty.gold, level: 3, timerDisabled: true).timed, isFalse);
    });

    test('the sample in the tray is a help: only bronze levels 1 and 2', () {
      expect(const SortRules(round: GameDifficulty.bronze, level: 1).sampleInTray, isTrue);
      expect(const SortRules(round: GameDifficulty.bronze, level: 2).sampleInTray, isTrue);
      expect(const SortRules(round: GameDifficulty.bronze, level: 3).sampleInTray, isFalse);
      expect(const SortRules(round: GameDifficulty.silver, level: 2).sampleInTray, isFalse);
    });

    test('only diamond level 8 refills the tray, with more time for its 12 objects (4.3)', () {
      expect(const SortRules(round: GameDifficulty.diamond, level: 8).refill, isTrue);
      expect(const SortRules(round: GameDifficulty.diamond, level: 8).timeFactor, 1.5);
      expect(const SortRules(round: GameDifficulty.diamond, level: 7).refill, isFalse);
      expect(const SortRules(round: GameDifficulty.obsidian, level: 8).refill, isFalse);
      expect(const SortRules(round: GameDifficulty.obsidian, level: 8).timeFactor, 1);
    });

    test('without Premium, silver at most', () {
      expect(SortLadder.playableRound(GameDifficulty.gold, premium: false), GameDifficulty.silver);
      expect(SortLadder.playableRound(GameDifficulty.bronze, premium: false), GameDifficulty.bronze);
      expect(SortLadder.playableRound(GameDifficulty.diamond, premium: true), GameDifficulty.diamond);
    });

    test('stars like «A su sitio»', () {
      expect(SortStars.forWin(objects: 6, fails: 6), 3);
      expect(SortStars.forWin(objects: 6, fails: 12), 2);
      expect(SortStars.forWin(objects: 6, fails: 13), 1);
    });
  });

  group('SortBoard.pick', () {
    test('thousands of draws keep every rule of the table', () {
      for (final GameDifficulty round in GameDifficulty.values) {
        for (final SortLevel level in SortLadder.levels) {
          final SortRules rules = SortRules(round: round, level: level.number);
          for (var seed = 0; seed < 120; seed++) {
            final SortBoard board = SortBoard.pick(Random(seed), level, rules);
            final String where = '${round.name} level ${level.number} seed $seed';
            expect(board.criterion, rules.criterion, reason: where);
            // Cada objeto tiene una sola cesta, y ninguna se pasa de 3.
            for (final SortPiece piece in board.pieces) {
              expect(board.baskets.where((basket) => basket.accepts(piece)), hasLength(1), reason: where);
            }
            for (final SortBasket basket in board.baskets) {
              expect(board.pieces.where(basket.accepts).length, lessThanOrEqualTo(SortLadder.maxPerBasket),
                  reason: where);
            }
            // La muestra nunca está en la bandeja, salvo como ayuda (P6).
            for (final SortPiece piece in board.pieces) {
              final bool isSample = board.baskets.any((basket) => basket.sample == piece.object);
              expect(isSample, rules.sampleInTray, reason: '$where: ${piece.object.name}');
            }
            switch (rules.criterion) {
              case SortCriterion.color:
                expect(board.pieces, hasLength(level.objects), reason: where);
                final Set<SortColor> used = {for (final SortPiece piece in board.pieces) piece.color!};
                expect(used, hasLength(level.baskets), reason: where);
                expect(SortColor.confusable(used), isFalse, reason: where);
                expect(board.freeBaskets, hasLength(rules.freeBaskets && level.freeBasket ? 1 : 0), reason: where);
                expect(board.baskets.every((basket) => rules.colors.contains(basket.color)), isTrue, reason: where);
                expect(board.pieces.every((piece) => piece.size == SortSize.big), isTrue, reason: where);
                if (!rules.sampleInTray) {
                  expect(board.pieces.map((piece) => piece.object).toSet(), hasLength(board.pieces.length),
                      reason: '$where: no repeated objects');
                }
              case SortCriterion.size:
                expect(board.baskets.map((basket) => basket.size), rules.sizes, reason: '$where: big to small');
                expect(board.baskets.every((basket) => basket.color == null), isTrue, reason: where);
                expect(board.freeBaskets, isEmpty, reason: '$where: no empty size basket');
                final SortTheme theme =
                    SortTheme.values.firstWhere((theme) => theme.sample == board.baskets.first.sample);
                expect(board.pieces.every((piece) => theme.objects.contains(piece.object)), isTrue,
                    reason: '$where: objects of the theme');
                final Set<SortObject> objects = {for (final SortPiece piece in board.pieces) piece.object};
                expect(objects, hasLength(rules.sizeObjects), reason: where);
                for (final SortObject object in objects) {
                  if (board.pieces.length < 2 * objects.length) break;
                  expect(board.pieces.where((piece) => piece.object == object).map((piece) => piece.size).toSet().length,
                      greaterThanOrEqualTo(2), reason: '$where: ${object.name} is compared with itself');
                }
              case SortCriterion.colorAndSize:
                final Set<SortColor> colors = {for (final SortBasket basket in board.baskets) basket.color!};
                expect(colors, hasLength(2), reason: where);
                expect(SortColor.confusable(colors), isFalse, reason: where);
                expect(board.baskets, hasLength(2 * rules.sizes.length), reason: where);
                expect(board.freeBaskets, isEmpty, reason: '$where: every basket gets something');
                expect(board.pieces,
                    hasLength(rules.refill ? SortRules.refillTotal : max(level.objects, board.baskets.length)),
                    reason: where);
                expect(board.trayCapacity, rules.refill ? SortRules.refillVisible : isNull, reason: where);
            }
          }
        }
      }
    });

    test('the same seed gives the same board', () {
      for (final GameDifficulty round in [GameDifficulty.emerald, GameDifficulty.sapphire, GameDifficulty.diamond]) {
        final SortRules rules = SortRules(round: round, level: 6);
        final SortBoard a = SortBoard.pick(Random(4), SortLadder.levelAt(6), rules);
        final SortBoard b = SortBoard.pick(Random(4), SortLadder.levelAt(6), rules);
        expect(a.baskets, b.baskets, reason: round.name);
        expect(a.pieces, b.pieces, reason: round.name);
      }
    });

    test('a board refuses a fourth object in a basket or an object without its basket', () {
      SortPiece piece(int i, SortObject object) => SortPiece(id: '$i', object: object);
      const SortBasket red = SortBasket(color: SortColor.red, sample: SortObject.strawberry);
      expect(
        () => SortBoard(criterion: SortCriterion.color, baskets: const [red], pieces: [
          for (var i = 0; i < 4; i++) piece(i, SortObject.apple),
        ]),
        throwsArgumentError,
      );
      expect(() => SortBoard(criterion: SortCriterion.color, baskets: const [red], pieces: [piece(0, SortObject.banana)]),
          throwsArgumentError);
    });

    test('a basket id says what it sorts', () {
      expect(const SortBasket(color: SortColor.red, sample: SortObject.strawberry).id, 'red');
      expect(const SortBasket(size: SortSize.small, sample: SortObject.bear).id, 'small');
      expect(const SortBasket(color: SortColor.red, size: SortSize.big, sample: SortObject.strawberry).id, 'red-big');
    });
  });
}
