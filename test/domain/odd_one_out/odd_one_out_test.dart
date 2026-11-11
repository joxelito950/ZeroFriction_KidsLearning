import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/odd_one_out/odd_one_out.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

import '../../support/emoji5.dart';

/// HU-025, entrega 1: escalera, rondas, contenido y estrellas.
void main() {
  group('ladder (11.1)', () {
    test('a tutorial of 3 objects and 4 levels of 4 to 6, each of 3 boards', () {
      expect([for (final level in OddOneOut.levels) level.objects], [3, 4, 4, 5, 6]);
      expect(OddOneOut.boardsPerLevel, 3);
      expect(() => OddOneOut.levelAt(6), throwsRangeError);
    });

    test('times per round, and the tutorial without time', () {
      List<int?> series(GameDifficulty round) =>
          [for (var level = 1; level <= 5; level++) OddOneOut.rounds.limitFor(round, level)?.inSeconds];
      expect(series(GameDifficulty.easy), [null, 60, 50, 45, 40]);
      expect(series(GameDifficulty.normal), [null, 40, 35, 30, 25]);
      expect(series(GameDifficulty.impossible), [null, 25, 20, 18, 15]);
      expect(OddOneOut.rounds.maxStars, 36);
    });

    test('Impossible is Premium; without it the game stays in Normal (P1, P6)', () {
      expect(OddOneOut.playableRound(GameDifficulty.impossible, premium: false), GameDifficulty.normal);
      expect(OddOneOut.playableRound(GameDifficulty.impossible, premium: true), GameDifficulty.impossible);
      expect(OddOneOut.playableRound(GameDifficulty.easy, premium: false), GameDifficulty.easy);
    });
  });

  group('content (4.5, D-024, D-026)', () {
    test('every emoji is Emoji 5.0 or earlier', () {
      for (final group in OddOneOut.groups) {
        for (final symbol in group.symbols) {
          expect(whyNotEmoji5(symbol), isNull, reason: '${group.id} $symbol');
        }
      }
    });

    test('each board has exactly one object from another group, at a random place (R2)', () {
      String groupOf(String symbol, OddBoard board) =>
          OddOneOut.groups.firstWhere((group) => group.symbols.contains(symbol)).family;
      final places = <int>{};
      for (var seed = 0; seed < 60; seed++) {
        final random = Random(seed);
        for (final level in OddOneOut.levels) {
          final OddBoard board = OddOneOut.board(random, level);
          expect(board.objects, hasLength(level.objects));
          expect(board.objects.toSet(), hasLength(level.objects), reason: 'no repeated object');
          final List<String> same = [
            for (var i = 0; i < board.objects.length; i++)
              if (i != board.oddIndex) board.objects[i],
          ];
          bool inGroup(String id, String symbol) => OddOneOut.group(id).symbols.contains(symbol);
          switch (level.kind) {
            case OddKind.veryDifferent:
              final family = groupOf(same.first, board);
              expect(same.map((symbol) => groupOf(symbol, board)).toSet(), {family});
            case OddKind.farmOrWild:
              final String majority = inGroup('farm', same.first) ? 'farm' : 'wild';
              expect(same.every((symbol) => inGroup(majority, symbol)), isTrue);
              expect(inGroup(majority == 'farm' ? 'wild' : 'farm', board.odd), isTrue);
            case OddKind.landOrAir:
              expect(same.every((symbol) => inGroup('land', symbol)), isTrue);
              expect(inGroup('air', board.odd), isTrue);
            case OddKind.colour:
              expect(same.every((symbol) => inGroup('reds', symbol)), isTrue);
              expect(inGroup('yellows', board.odd), isTrue);
          }
          if (level.number == 5) places.add(board.oddIndex);
        }
      }
      expect(places, hasLength(6), reason: 'the odd one can be anywhere');
    });
  });

  group('stars (11.2)', () {
    test('count the mistakes of the 3 boards', () {
      expect([for (final fails in [0, 1, 2, 3, 4, 6, 7]) OddOneOutStars.forWin(fails: fails)], [3, 3, 2, 2, 1, 1, 0]);
      expect(() => OddOneOutStars.forWin(fails: -1), throwsRangeError);
    });
  });
}
