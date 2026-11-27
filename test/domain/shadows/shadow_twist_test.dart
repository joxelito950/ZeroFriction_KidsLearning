import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/domain/shadows/shadow_themes.dart';
import 'package:toddler_logic/domain/shadows/shadow_twist.dart';

/// Sombras dadas la vuelta (HU-040).
void main() {
  group('ShadowTwists.planFor (table 4.1)', () {
    test('bronze to ruby, and levels 1 to 3 of every round, never twist', () {
      for (final GameDifficulty round in GameDifficulty.values) {
        for (var level = 1; level <= ShadowLadder.maxLevel; level++) {
          final ShadowTwistPlan plan = ShadowTwists.planFor(round, level);
          if (round.index < GameDifficulty.emerald.index || level < 4) {
            expect(plan.isEmpty, isTrue, reason: '$round level $level');
          } else {
            expect(plan.isEmpty, isFalse, reason: '$round level $level');
          }
        }
      }
    });

    test('emerald: one mirrored shadow, with the hint', () {
      for (var level = 4; level <= 8; level++) {
        final ShadowTwistPlan plan = ShadowTwists.planFor(GameDifficulty.emerald, level);
        expect(plan.kinds, [ShadowTwist.mirror]);
        expect(plan.count, 1);
        expect(plan.hint, isTrue);
      }
    });

    test('until the validation with children (P2), later rounds keep the mirror, without the hint', () {
      expect(ShadowTwists.lateTwistsEnabled, isFalse);
      for (final GameDifficulty round in [GameDifficulty.sapphire, GameDifficulty.obsidian, GameDifficulty.diamond]) {
        for (var level = 4; level <= 8; level++) {
          final ShadowTwistPlan plan = ShadowTwists.planFor(round, level);
          expect(plan.kinds, [ShadowTwist.mirror], reason: '$round $level');
          expect(plan.count, 1);
          expect(plan.hint, isFalse);
        }
      }
    });
  });

  group('ShadowTwists.valid (table 5)', () {
    test('only shapes from the shadow themes, and the symmetric ones are out', () {
      final Set<String> themes = {for (final ShadowTheme theme in ShadowThemes.all) ...theme.symbols};
      for (final Set<String> symbols in ShadowTwists.valid.values) {
        expect(themes.containsAll(symbols), isTrue);
      }
      for (final String symmetric in ['🦋', '🍎', '🍉', '🎈', '⏰', '✂️', '🍇']) {
        expect(ShadowTwists.valid[ShadowTwist.mirror], isNot(contains(symmetric)));
      }
      for (final String round in ['🍎', '🍉', '🎈', '⏰', '🍇', '🦋', '🚀', '✈️']) {
        expect(ShadowTwists.valid[ShadowTwist.quarterTurn], isNot(contains(round)));
      }
    });

    test('a look-alike on the board keeps the other one straight', () {
      expect(ShadowTwists.fits('🦕', ShadowTwist.mirror, ['🦕', '🐘']), isTrue);
      expect(ShadowTwists.fits('🦕', ShadowTwist.mirror, ['🦕', '🦖']), isFalse);
      expect(ShadowTwists.fits('🍎', ShadowTwist.mirror, ['🍎']), isFalse);
    });
  });

  group('ShadowThemes.pick with twists (4.2)', () {
    const ShadowTwistPlan mirror = ShadowTwistPlan(kinds: [ShadowTwist.mirror], count: 1, hint: true);
    const ShadowTwistPlan mixed = ShadowTwistPlan(
      kinds: [ShadowTwist.mirror, ShadowTwist.upsideDown, ShadowTwist.quarterTurn],
      count: 2,
      hint: false,
    );

    void checkBoards(ShadowTwistPlan plan) {
      for (var seed = 0; seed < 2000; seed++) {
        final ShadowLevel level = ShadowLadder.levelAt(4 + seed % 5);
        final ShadowBoardContent content = ShadowThemes.pick(Random(seed), level, twists: plan);
        expect(content.twists.length, plan.count, reason: 'seed $seed, level ${level.number}');
        expect(content.twists.values.toSet().length, content.twists.length, reason: 'distinct twists');
        for (final MapEntry<String, ShadowTwist> entry in content.twists.entries) {
          expect(content.objects, contains(entry.key), reason: 'never a free shadow');
          expect(plan.kinds, contains(entry.value));
          expect(ShadowTwists.fits(entry.key, entry.value, content.shadows), isTrue, reason: 'seed $seed');
        }
      }
    }

    test('one mirrored object per board, valid and with no look-alike', () => checkBoards(mirror));

    test('two different twists in diamond 6 to 8 (delivery 2)', () => checkBoards(mixed));

    test('without a plan, the board is the same as before HU-040', () {
      for (var seed = 0; seed < 50; seed++) {
        final ShadowLevel level = ShadowLadder.levelAt(1 + seed % 8);
        final ShadowBoardContent before = ShadowThemes.pick(Random(seed), level);
        final ShadowBoardContent none = ShadowThemes.pick(Random(seed), level, twists: ShadowTwistPlan.none);
        expect(none.objects, before.objects);
        expect(none.shadows, before.shadows);
        expect(none.twists, isEmpty);
      }
    });
  });
}
