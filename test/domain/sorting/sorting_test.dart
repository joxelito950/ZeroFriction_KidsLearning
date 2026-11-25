import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/sorting/sort_board.dart';
import 'package:toddler_logic/domain/sorting/sort_catalog.dart';
import 'package:toddler_logic/domain/sorting/sort_ladder.dart';

/// HU-027, entrega 2: «Clasificar» por color.
void main() {
  group('SortCatalog (5.1)', () {
    test('every object is a single emoji without ZWJ, and none repeats', () {
      final Set<String> symbols = {};
      for (final SortObject object in SortObject.values) {
        expect(object.symbol.runes.contains(0x200D), isFalse, reason: '${object.name} has no ZWJ');
        expect(symbols.add(object.symbol), isTrue, reason: '${object.name} is not repeated');
      }
    });

    test('objects of doubtful colour stay out', () {
      const List<String> doubtful = [
        '🍉',
        '🍑',
        '🐝',
        '🌈',
        '🦋',
        '🐦',
        '🚙',
        '💎',
        '🧢',
        '☂️',
        '🍍',
        '❤️',
        '💛',
        '💚',
        '💙',
        '💜'
      ];
      for (final SortObject object in SortObject.values) {
        expect(doubtful, isNot(contains(object.symbol)), reason: object.name);
      }
    });

    test('each basket has its own sample, of its colour, and enough objects to play', () {
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

    test('red and green alone are confusable; with a third colour, not', () {
      expect(SortColor.confusable({SortColor.red, SortColor.green}), isTrue);
      expect(SortColor.confusable({SortColor.red, SortColor.blue}), isFalse);
      expect(SortColor.confusable({SortColor.red, SortColor.green, SortColor.blue}), isFalse);
    });
  });

  group('SortRules (4.2)', () {
    test('orange and purple, free baskets and time come in their rounds', () {
      for (final GameDifficulty round in GameDifficulty.values) {
        final SortRules rules = SortRules(round: round, level: 3);
        final bool fromEmerald = round.index >= GameDifficulty.emerald.index;
        expect(rules.colors, fromEmerald ? SortColor.values : SortColor.basic, reason: round.name);
        expect(rules.freeBaskets, fromEmerald, reason: round.name);
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
          for (var seed = 0; seed < 150; seed++) {
            final SortBoard board = SortBoard.pick(Random(seed), level, rules);
            final String where = '${round.name} level ${level.number} seed $seed';
            expect(board.pieces, hasLength(level.objects), reason: where);
            final Set<SortColor> used = {for (final SortPiece piece in board.pieces) piece.color};
            expect(used, hasLength(level.baskets), reason: where);
            expect(SortColor.confusable(used), isFalse, reason: where);
            final bool free = rules.freeBaskets && level.freeBasket;
            expect(board.freeBaskets, hasLength(free ? 1 : 0), reason: where);
            expect(board.baskets.every(rules.colors.contains), isTrue, reason: where);
            for (final SortColor basket in board.baskets) {
              expect(board.pieces.where((piece) => piece.color == basket).length,
                  lessThanOrEqualTo(SortLadder.maxPerBasket),
                  reason: where);
            }
            for (final SortPiece piece in board.pieces) {
              expect(board.baskets.where((basket) => board.accepts(basket, piece)), [piece.color],
                  reason: '$where: one right basket');
              final bool isSample = piece.object == piece.color.sample;
              if (rules.sampleInTray) {
                expect(isSample, isTrue, reason: '$where: bronze 1-2 shows the sample itself');
              } else {
                expect(isSample, isFalse, reason: '$where: the sample is never in the tray (P6)');
              }
            }
            if (!rules.sampleInTray) {
              expect(board.pieces.map((piece) => piece.object).toSet(), hasLength(board.pieces.length),
                  reason: '$where: no repeated objects');
            }
          }
        }
      }
    });

    test('the same seed gives the same board', () {
      final SortRules rules = const SortRules(round: GameDifficulty.emerald, level: 6);
      final SortBoard a = SortBoard.pick(Random(4), SortLadder.levelAt(6), rules);
      final SortBoard b = SortBoard.pick(Random(4), SortLadder.levelAt(6), rules);
      expect(a.baskets, b.baskets);
      expect(a.pieces, b.pieces);
    });

    test('a board refuses a fourth object in a basket or an object without its basket', () {
      SortPiece piece(int i, SortObject object) => SortPiece(id: '$i', object: object);
      expect(
        () => SortBoard(baskets: const [
          SortColor.red
        ], pieces: [
          for (var i = 0; i < 4; i++) piece(i, SortObject.apple),
        ]),
        throwsArgumentError,
      );
      expect(
          () => SortBoard(baskets: const [SortColor.red], pieces: [piece(0, SortObject.banana)]), throwsArgumentError);
    });
  });
}
