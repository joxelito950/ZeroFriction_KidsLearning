import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/odd_one_out/odd_one_out.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

import '../../support/emoji5.dart';

/// HU-025: escalera, rondas, contenido por ronda (sección 13) y estrellas.
void main() {
  const easy = GameDifficulty.easy;
  const normal = GameDifficulty.normal;
  const impossible = GameDifficulty.impossible;

  group('ladder (11.1)', () {
    test('a tutorial of 3 objects and 4 levels of 4 to 6, each of 3 boards', () {
      expect([for (final level in OddOneOut.levels) level.objects], [3, 4, 4, 5, 6]);
      expect(OddOneOut.boardsPerLevel, 3);
      expect(() => OddOneOut.levelAt(6), throwsRangeError);
    });

    test('times per round, and the tutorial without time', () {
      List<int?> series(GameDifficulty round) =>
          [for (var level = 1; level <= 5; level++) OddOneOut.rounds.limitFor(round, level)?.inSeconds];
      expect(series(easy), [null, 60, 50, 45, 40]);
      expect(series(normal), [null, 40, 35, 30, 25]);
      expect(series(impossible), [null, 25, 20, 18, 15]);
      expect(OddOneOut.rounds.maxStars, 36);
    });

    test('Impossible is Premium; without it the game stays in Normal (P1, P6)', () {
      expect(OddOneOut.playableRound(impossible, premium: false), normal);
      expect(OddOneOut.playableRound(impossible, premium: true), impossible);
      expect(OddOneOut.playableRound(easy, premium: false), easy);
    });
  });

  group('what each round compares (section 13, 2026-11-12)', () {
    test('Easy: identical shapes, then colours; Normal: very different; Reto máximo: several fine categories', () {
      List<List<OddKind>> of(GameDifficulty round) =>
          [for (var level = 1; level <= 5; level++) OddOneOut.kindsFor(round, level)];
      expect(of(easy), [
        [OddKind.identical],
        [OddKind.identical],
        [OddKind.colour],
        [OddKind.colour],
        [OddKind.colour],
      ]);
      expect(of(normal), everyElement([OddKind.veryDifferent]));
      expect(of(impossible), everyElement(OddOneOut.hardKinds));
      expect(OddOneOut.hardKinds, hasLength(4));
      expect(() => OddOneOut.kindsFor(easy, 6), throwsRangeError);
    });

    test('Reto máximo never repeats the comparison of the previous board, and uses all of them', () {
      final random = Random(9);
      final seen = <OddKind>{};
      OddKind? previous;
      for (var i = 0; i < 200; i++) {
        final OddBoard board = OddOneOut.board(random, OddOneOut.levelAt(1 + i % 5), impossible, previousKind: previous);
        expect(board.kind, isNot(previous));
        seen.add(board.kind);
        previous = board.kind;
      }
      expect(seen, OddOneOut.hardKinds.toSet());
    });

    test('the different object does not come back right away, in any round (2026-11-12)', () {
      for (final round in GameDifficulty.values) {
        final random = Random(round.index);
        final recent = <String>[];
        OddKind? previous;
        for (var i = 0; i < 90; i++) {
          // La misma memoria que el juego: los últimos 6 objetos.
          final List<String> window = recent.sublist(recent.length < 6 ? 0 : recent.length - 6);
          final OddBoard board =
              OddOneOut.board(random, OddOneOut.levelAt(1 + (i ~/ 3) % 5), round, previousKind: previous, recent: window);
          expect(recent.sublist(recent.length < 2 ? 0 : recent.length - 2), isNot(contains(board.odd)),
              reason: '${round.name} board $i repeats ${board.odd}');
          recent.add(board.odd);
          previous = board.kind;
        }
      }
    });
  });

  group('content (D-024, D-026)', () {
    test('every emoji is Emoji 5.0 or earlier', () {
      for (final group in OddOneOut.groups) {
        for (final symbol in group.symbols) {
          expect(whyNotEmoji5(symbol), isNull, reason: '${group.id} $symbol');
        }
      }
    });

    test('each board has exactly one different object, at a random place (R2)', () {
      bool inGroup(String id, String symbol) => OddOneOut.group(id).symbols.contains(symbol);
      String familyOf(String symbol, {required bool colours}) => OddOneOut.groups
          .firstWhere((group) =>
              (group.family == 'colours') == colours && group.family != 'wings' && group.symbols.contains(symbol))
          .family;
      String colourOf(String symbol) =>
          OddOneOut.groups.firstWhere((group) => group.family == 'colours' && group.symbols.contains(symbol)).id;

      final places = <int>{};
      for (var seed = 0; seed < 60; seed++) {
        final random = Random(seed);
        for (final round in GameDifficulty.values) {
          for (final level in OddOneOut.levels) {
            final OddBoard board = OddOneOut.board(random, level, round);
            expect(board.objects, hasLength(level.objects));
            expect(OddOneOut.kindsFor(round, level.number), contains(board.kind));
            final List<String> same = [
              for (var i = 0; i < board.objects.length; i++)
                if (i != board.oddIndex) board.objects[i],
            ];
            expect(same, isNot(contains(board.odd)), reason: 'the odd one is not among the others');
            switch (board.kind) {
              case OddKind.identical:
                expect(same.toSet(), hasLength(1), reason: 'the same shape repeated');
                expect(familyOf(board.odd, colours: false), isNot(familyOf(same.first, colours: false)));
              case OddKind.colour:
                expect(same.toSet(), hasLength(same.length), reason: 'different foods');
                expect(same.map(colourOf).toSet(), hasLength(1));
                expect(colourOf(board.odd), isNot(colourOf(same.first)));
              case OddKind.veryDifferent:
                expect(same.map((s) => familyOf(s, colours: false)).toSet(), hasLength(1));
                expect(familyOf(board.odd, colours: false), isNot(familyOf(same.first, colours: false)));
              case OddKind.farmOrWild:
                final String majority = inGroup('farm', same.first) ? 'farm' : 'wild';
                expect(same.every((symbol) => inGroup(majority, symbol)), isTrue);
                expect(inGroup(majority == 'farm' ? 'wild' : 'farm', board.odd), isTrue);
              case OddKind.landOrAir:
                expect(same.every((symbol) => inGroup('land', symbol)), isTrue);
                expect(inGroup('air', board.odd), isTrue);
              case OddKind.landOrWater:
                bool land(String symbol) => inGroup('land', symbol) || inGroup('farm', symbol) || inGroup('wild', symbol);
                bool water(String symbol) => inGroup('boats', symbol) || inGroup('water', symbol);
                expect(same.every(land) && water(board.odd) || same.every(water) && land(board.odd), isTrue,
                    reason: '$same / ${board.odd}');
              case OddKind.wheelsOrWings:
                expect(same.every((symbol) => inGroup('land', symbol)), isTrue);
                expect(inGroup('wings', board.odd), isTrue);
            }
            if (level.number == 5) places.add(board.oddIndex);
          }
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
