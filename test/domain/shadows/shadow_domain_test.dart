import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_drop.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/domain/shadows/shadow_themes.dart';

import '../../support/emoji5.dart';

/// HU-007, entrega 1: escalera, acceso, tiempo, estrellas, colocación y contenido.
void main() {
  const free = ShadowRules();
  const premium = ShadowRules(premium: true);

  group('ladder (4.2)', () {
    test('has 8 levels following table 4.2', () {
      expect([
        for (final level in ShadowLadder.levels) (level.objects, level.shadows)
      ], [
        (2, 2),
        (3, 3),
        (4, 4),
        (4, 5),
        (5, 6),
        (5, 6),
        (6, 7),
        (6, 8),
      ]);
      expect([for (final level in ShadowLadder.levels) level.freeShadows], [0, 0, 0, 1, 1, 1, 1, 2]);
      expect(ShadowLadder.levels.where((level) => level.sameTheme).map((level) => level.number), [6, 7, 8]);
      expect(() => ShadowLadder.levelAt(9), throwsRangeError);
    });
  });

  group('free mode (R6)', () {
    test('never has time, and after level 7 goes back to level 1 without a medal', () {
      for (var level = 1; level <= 7; level++) {
        expect(ShadowLadder.arrivalPosition(level, free).isTimed, isFalse);
      }
      final ShadowStep step = ShadowLadder.afterWin(const ShadowPosition(level: 7), free);
      expect(step.next, ShadowLadder.start);
      expect(step.medalEarned, isFalse);
    });

    test('level 8 is not playable: it plays level 7', () {
      expect(ShadowLadder.arrivalPosition(8, free), const ShadowPosition(level: 7));
    });

    test('a board without time cannot be lost', () {
      expect(() => ShadowLadder.afterLoss(const ShadowPosition(level: 3)), throwsStateError);
    });
  });

  group('Premium (R7, R10, 4.3)', () {
    List<int?> arrivals(ShadowRules rules) =>
        [for (var level = 1; level <= 8; level++) ShadowLadder.arrivalPosition(level, rules).timeLimit?.inSeconds];

    test('time per difficulty from level 2', () {
      expect(arrivals(const ShadowRules(premium: true, difficulty: GameDifficulty.easy)),
          [null, 90, 80, 70, 60, 50, 40, 30]);
      expect(arrivals(premium), [null, 60, 50, 45, 40, 35, 30, 25]);
      expect(arrivals(const ShadowRules(premium: true, difficulty: GameDifficulty.impossible)),
          [null, 50, 45, 40, 35, 30, 25, 20]);
    });

    test('winning goes up with the next limit, and level 8 gives the medal', () {
      expect(ShadowLadder.afterWin(ShadowLadder.start, premium).next,
          const ShadowPosition(level: 2, timeLimit: Duration(seconds: 60)));
      final ShadowStep last = ShadowLadder.afterWin(const ShadowPosition(level: 8), premium);
      expect(last.medalEarned, isTrue);
      expect(last.next, ShadowLadder.start);
    });

    test('losing goes down keeping the limit; in timed level 1 it restarts', () {
      final ShadowStep down = ShadowLadder.afterLoss(const ShadowPosition(level: 5, timeLimit: Duration(seconds: 40)));
      expect(down.next, const ShadowPosition(level: 4, timeLimit: Duration(seconds: 40)));
      expect(down.lost, isTrue);
      expect(ShadowLadder.afterLoss(const ShadowPosition(level: 1, timeLimit: Duration(seconds: 60))).next,
          ShadowLadder.start);
    });

    test('without time (R18) there is no limit but level 8 and the medal remain', () {
      const noTime = ShadowRules(premium: true, timerDisabled: true);
      expect(noTime.timed, isFalse);
      expect(arrivals(noTime), everyElement(isNull));
      expect(ShadowLadder.afterWin(const ShadowPosition(level: 8), noTime).medalEarned, isTrue);
      expect(const ShadowRules(timerDisabled: true).timed, isFalse);
    });
  });

  group('rules per difficulty (HU-030 3.2, P4, P14, R19)', () {
    test('Easy has no free shadows and the lowest coverage; Impossible, random layout and no start animation', () {
      const easy = ShadowRules(difficulty: GameDifficulty.easy);
      const impossible = ShadowRules(difficulty: GameDifficulty.impossible);
      expect([easy.coverageToSnap, free.coverageToSnap, impossible.coverageToSnap], [0.4, 0.6, 0.9]);
      expect([easy.freeShadows, free.freeShadows], [false, true]);
      expect([free.randomLayout, impossible.randomLayout], [false, true]);
      expect([easy.startAnimation, free.startAnimation, impossible.startAnimation], [true, true, false]);
      expect(premium, const ShadowRules(premium: true));
      expect(premium.hashCode, const ShadowRules(premium: true).hashCode);
      expect(premium, isNot(free));
    });
  });

  group('stars (R9)', () {
    test('count shape mistakes against the number of objects', () {
      expect(ShadowStars.forWin(objects: 4, fails: 0, premium: true), 3);
      expect(ShadowStars.forWin(objects: 4, fails: 4, premium: true), 3);
      expect(ShadowStars.forWin(objects: 4, fails: 4, premium: false), 2);
      expect(ShadowStars.forWin(objects: 4, fails: 8, premium: true), 1);
      expect(ShadowStars.forWin(objects: 4, fails: 9, premium: true), 0);
      expect(() => ShadowStars.forWin(objects: 4, fails: -1, premium: true), throwsRangeError);
    });
  });

  group('drop by coverage (R4, R5, P4)', () {
    const shadow = ShadowBox(left: 100, top: 100, width: 100, height: 100);
    const other = ShadowBox(left: 300, top: 100, width: 100, height: 100);
    ShadowBox objectAt(double left, double top) => ShadowBox(left: left, top: top, width: 100, height: 100);

    test('coverage is the part of the shadow under the object', () {
      expect(ShadowDrop.coverage(objectAt(100, 100), shadow), 1);
      expect(ShadowDrop.coverage(objectAt(150, 100), shadow), 0.5);
      expect(ShadowDrop.coverage(objectAt(150, 150), shadow), 0.25);
      expect(ShadowDrop.coverage(objectAt(500, 500), shadow), 0);
      expect(ShadowDrop.coverage(objectAt(0, 0), const ShadowBox(left: 0, top: 0, width: 0, height: 10)), 0);
    });

    test('snaps when its own shadow is covered enough for the difficulty', () {
      ShadowDropOutcome drop(double left, double threshold) => ShadowDrop.evaluate(
          symbol: 'a', object: objectAt(left, 100), shadows: {'a': shadow, 'b': other}, threshold: threshold);

      // 45 % cubierto: encaja en Fácil (40 %), no en Normal (60 %).
      expect(drop(155, 0.4), ShadowDropOutcome.snapped);
      expect(drop(155, 0.6), ShadowDropOutcome.missed);
      expect(drop(105, 0.9), ShadowDropOutcome.snapped);
      expect(drop(115, 0.9), ShadowDropOutcome.missed);
    });

    test('covering another shadow is a shape mistake; covering nothing is not', () {
      expect(
        ShadowDrop.evaluate(
            symbol: 'a', object: objectAt(300, 100), shadows: {'a': shadow, 'b': other}, threshold: 0.6),
        ShadowDropOutcome.wrongShadow,
      );
      expect(
        ShadowDrop.evaluate(
            symbol: 'a', object: objectAt(700, 700), shadows: {'a': shadow, 'b': other}, threshold: 0.4),
        ShadowDropOutcome.missed,
      );
      // Su sombra ya ocupada: aunque caiga encima, no encaja.
      expect(
        ShadowDrop.evaluate(symbol: 'a', object: objectAt(100, 100), shadows: {'b': other}, threshold: 0.4),
        ShadowDropOutcome.missed,
      );
    });
  });

  group('content (4.5, D-024, D-026)', () {
    test('every emoji is Emoji 5.0 or earlier and none repeats', () {
      final symbols = [for (final theme in ShadowThemes.all) ...theme.symbols];
      for (final symbol in symbols) {
        expect(whyNotEmoji5(symbol), isNull, reason: symbol);
      }
      expect(symbols.toSet().length, symbols.length);
    });

    test('there are themes with enough shapes for every same-theme level', () {
      for (final level in ShadowLadder.levels.where((level) => level.sameTheme)) {
        expect(ShadowThemes.all.any((theme) => theme.symbols.length >= level.shadows), isTrue,
            reason: '${level.number}');
      }
    });

    test('each board has its objects among its shadows, plus the free ones', () {
      for (var seed = 0; seed < 40; seed++) {
        for (final level in ShadowLadder.levels) {
          final content = ShadowThemes.pick(Random(seed), level);
          expect(content.objects, hasLength(level.objects));
          expect(content.shadows, hasLength(level.shadows));
          expect(content.shadows.toSet(), hasLength(level.shadows), reason: 'no repeated shapes');
          expect(content.shadows, containsAll(content.objects));
          expect(content.freeShadows, hasLength(level.freeShadows));
          if (level.sameTheme) {
            expect(ShadowThemes.all.any((theme) => theme.symbols.toSet().containsAll(content.shadows)), isTrue);
          }
        }
      }
    });

    test('level 1 mixes two different themes; Easy has no free shadows', () {
      for (var seed = 0; seed < 20; seed++) {
        final content = ShadowThemes.pick(Random(seed), ShadowLadder.levelAt(1));
        final themes = {
          for (final symbol in content.objects)
            ShadowThemes.all.firstWhere((theme) => theme.symbols.contains(symbol)).id,
        };
        expect(themes, hasLength(2));
        expect(ShadowThemes.pick(Random(seed), ShadowLadder.levelAt(8), freeShadows: false).freeShadows, isEmpty);
      }
    });
  });
}
