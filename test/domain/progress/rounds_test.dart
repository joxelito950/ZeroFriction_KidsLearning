import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/progress/star_decay.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';

/// Rondas y progreso común: HU-037 (D-038) con las ocho rondas de HU-051 (D-042).
void main() {
  const bronze = GameDifficulty.bronze;
  const silver = GameDifficulty.silver;
  const gold = GameDifficulty.gold;
  const diamond = GameDifficulty.diamond;
  final RoundLadder memory = MemoryLadder.rounds;
  final DateTime day = DateTime(2026, 11, 11, 10);

  group('rounds (HU-051)', () {
    test('eight rounds named after their medal, from bronze to diamond', () {
      expect(GameDifficulty.values.map((round) => round.name),
          ['bronze', 'silver', 'gold', 'ruby', 'emerald', 'sapphire', 'obsidian', 'diamond']);
    });

    test('each round leads to the next and diamond stays (P4); bronze has no previous round', () {
      for (var index = 0; index < GameDifficulty.values.length - 1; index++) {
        expect(GameDifficulty.values[index].nextRound, GameDifficulty.values[index + 1]);
        expect(GameDifficulty.values[index + 1].previousRound, GameDifficulty.values[index]);
      }
      expect(diamond.nextRound, diamond);
      expect(bronze.previousRound, isNull);
    });

    test('names saved before HU-051 are read as bronze, gold and diamond; unknown ones as gold', () {
      expect(GameDifficulty.fromName('easy'), bronze);
      expect(GameDifficulty.fromName('normal'), gold);
      expect(GameDifficulty.fromName('impossible'), diamond);
      expect(GameDifficulty.fromName('ruby'), GameDifficulty.ruby);
      expect(GameDifficulty.fromName(null), gold);
      expect(GameDifficulty.fromName('nightmare'), gold);
      expect(GameDifficulty.isLegacyName('normal'), isTrue);
      expect(GameDifficulty.isLegacyName('gold'), isFalse);
    });

    test('an old medal is worth every medal up to its round (section 6)', () {
      expect(GameDifficulty.medalsFromSaved('easy'), {bronze});
      expect(GameDifficulty.medalsFromSaved('normal'), {bronze, silver, gold});
      expect(GameDifficulty.medalsFromSaved('impossible'), GameDifficulty.values.toSet());
      expect(GameDifficulty.medalsFromSaved('emerald'), {GameDifficulty.emerald});
      expect([0, 1, 2, 9].map(GameDifficulty.fromLegacyIndex), [bronze, gold, diamond, diamond]);
    });
  });

  group('RoundLadder', () {
    test('the tutorial has no time; each round uses its own series (HU-051 3.1)', () {
      expect(memory.limitFor(bronze, 1), isNull);
      expect(memory.limitFor(bronze, 2), const Duration(seconds: 270));
      expect(memory.limitFor(gold, 5), const Duration(seconds: 55));
      expect(memory.limitFor(diamond, 5), const Duration(seconds: 15));
      expect(memory.limitFor(gold, 3, timed: false), isNull, reason: 'Play without time');
      expect(() => memory.limitFor(gold, 6), throwsRangeError);
      expect(ShadowLadder.rounds.limitFor(diamond, 8), const Duration(seconds: 20));
    });

    test('needs one limit per level after the tutorial, in every round', () {
      expect(() => RoundLadder(levels: 3, timeLimits: {bronze: const [Duration(seconds: 1)]}), throwsArgumentError);
      expect(() => RoundLadder(levels: 1, timeLimits: const {}), throwsRangeError);
    });

    test('stars: the tutorial gives none, so the gold covers the other levels of the eight rounds (R5)', () {
      expect(memory.levelsWithStars, 4);
      expect(memory.maxStars, 96);
      expect(ShadowLadder.rounds.maxStars, 168);
    });

    test('winning the tutorial invites to play and moves to the first timed level (R9)', () {
      final RoundStep step = memory.afterWin(memory.arrival(bronze, 1));
      expect(step.fromTutorial, isTrue);
      expect(step.next, memory.arrival(bronze, 2));
      expect(step.medal, isNull);
    });

    test('the last level gives the medal and goes to the first timed level of the next round (R2, R3b)', () {
      final RoundStep bronzeDone = memory.afterWin(memory.arrival(bronze, 5));
      expect(bronzeDone.medal, bronze);
      expect(bronzeDone.next, memory.arrival(silver, 2), reason: 'no tutorial again (P5)');
      final RoundStep diamondDone = memory.afterWin(memory.arrival(diamond, 5));
      expect(diamondDone.medal, diamond);
      expect(diamondDone.next, memory.arrival(diamond, 2), reason: 'stays in diamond');
    });

    test('Shadows without Premium ends each round at level 7 with its medal (P16)', () {
      final RoundLadder shadows = ShadowLadder.rounds;
      final int free = ShadowLadder.lastLevelFor(premium: false);
      expect(free, 7);
      expect(shadows.afterWin(shadows.arrival(bronze, 7), lastLevel: free).medal, bronze);
      expect(shadows.afterWin(shadows.arrival(bronze, 7), lastLevel: ShadowLadder.lastLevelFor(premium: true)).medal,
          isNull);
      expect(() => shadows.afterWin(shadows.arrival(bronze, 2), lastLevel: 1), throwsRangeError);
    });

    test('losing goes down one level keeping the limit; on the first timed level, it is played again (P5)', () {
      final RoundStep down = memory.afterLoss(memory.arrival(gold, 4));
      expect(down.next, const RoundPosition(round: gold, level: 3, timeLimit: Duration(seconds: 80)));
      expect(down.retry, isFalse);
      final RoundStep again = memory.afterLoss(memory.arrival(gold, 2));
      expect(again.next, const RoundPosition(round: gold, level: 2, timeLimit: Duration(seconds: 160), tutorialFalls: 1));
      expect(again.retry, isTrue);
      expect(again.droppedRound, isFalse);
      expect(() => memory.afterLoss(memory.arrival(gold, 1)), throwsStateError);
    });

    test('losing twice on the first level drops one step, to the first timed level of the previous round (P7)', () {
      final RoundPosition first = memory.afterLoss(memory.arrival(gold, 2)).next;
      final RoundStep second = memory.afterLoss(first);
      expect(second.droppedRound, isTrue);
      expect(second.next, memory.arrival(silver, 2), reason: 'one step, not to the start (R3)');
      expect(second.next.tutorialFalls, 0, reason: 'the count starts again in the new round');
    });

    test('a win in between keeps the count inside the round (P15); bronze never drops', () {
      RoundPosition position = memory.afterLoss(memory.arrival(gold, 2)).next;
      position = memory.afterWin(position).next;
      expect(position.tutorialFalls, 1);

      RoundPosition bronzeFall = memory.afterLoss(memory.arrival(bronze, 2)).next;
      bronzeFall = memory.afterLoss(bronzeFall).next;
      expect(bronzeFall.round, bronze);
      expect(bronzeFall.level, 2);
      expect(bronzeFall.toString(), contains('bronze'));
    });
  });

  group('GameProgress', () {
    test('a new player starts in the tutorial, at the start of bronze, with no medals (R1)', () {
      final progress = GameProgress.initial();
      expect(progress.position, memory.arrival(bronze, 1));
      expect(progress.bestMedal, isNull);
      expect(progress.goldFraction(memory), 0);
    });

    test('keeps the best stars per round and level; the tutorial gives none (P2)', () {
      GameProgress progress = GameProgress.initial();
      final RoundPosition tutorial = progress.position;
      progress = progress.recordWin(won: tutorial, stars: 3, step: memory.afterWin(tutorial), at: day);
      expect(progress.stars, 0);
      final RoundPosition level2 = progress.position;
      progress = progress.recordWin(won: level2, stars: 2, step: memory.afterWin(level2), at: day);
      progress = progress.recordWin(won: level2, stars: 1, step: memory.afterWin(level2), at: day);
      expect(progress.records[const RoundLevel(bronze, 2)]!.bestStars, 2);
      expect(progress.goldFraction(memory), 2 / 96);
      expect(
        () => GameProgress(position: tutorial, records: {const RoundLevel(bronze, 1): LevelRecord(bestStars: 1, achievedAt: day)}),
        throwsArgumentError,
      );
    });

    test('medals add up and the best one is shown (P5); a loss only moves the position', () {
      GameProgress progress = GameProgress.initial();
      progress = progress.recordWin(
          won: memory.arrival(bronze, 5), stars: 3, step: memory.afterWin(memory.arrival(bronze, 5)), at: day);
      progress = progress.recordWin(
          won: memory.arrival(gold, 5), stars: 3, step: memory.afterWin(memory.arrival(gold, 5)), at: day);
      expect(progress.medals, {bronze, gold});
      expect(progress.bestMedal, gold);

      final GameProgress lost = progress.recordLoss(
          lost: memory.arrival(diamond, 3), step: memory.afterLoss(memory.arrival(diamond, 3)), at: day);
      expect(lost.position.level, 2);
      expect(lost.medals, progress.medals);
      expect(lost.stars, progress.stars);
    });

    test('the adult changes the round, starting at its first timed level, without losing anything (R5, R3b)', () {
      final progress = GameProgress(
        position: memory.arrival(diamond, 4),
        medals: const {bronze},
        records: {const RoundLevel(gold, 3): LevelRecord(bestStars: 3, achievedAt: day)},
      );
      final GameProgress back = progress.withRound(bronze);
      expect(back.position, const RoundPosition(round: bronze, level: 2));
      expect(back.medals, {bronze});
      expect(back.stars, 3);
    });

    test('the tutorial is only for new players: a saved tutorial with progress, or in another round, is skipped (P8)',
        () {
      const tutorialPosition = RoundPosition(round: bronze, level: 1);
      expect(GameProgress.restored(position: tutorialPosition).position.level, 1, reason: 'a new player');
      expect(GameProgress.restored(position: tutorialPosition, medals: const {bronze}).position.level, 2);
      expect(
        GameProgress.restored(
          position: tutorialPosition,
          records: {const RoundLevel(bronze, 2): LevelRecord(bestStars: 1, achievedAt: day)},
        ).position.level,
        2,
      );
      expect(GameProgress.restored(position: const RoundPosition(round: gold, level: 1)).position.level, 2);
      expect(GameProgress.restored(position: memory.arrival(gold, 3)).position, memory.arrival(gold, 3));
    });

    test('stars are lost from the oldest achievement in any round, never the medals (R6)', () {
      final progress = GameProgress(
        position: memory.arrival(gold, 2),
        medals: const {bronze},
        records: {
          const RoundLevel(bronze, 2): LevelRecord(bestStars: 3, achievedAt: day.subtract(const Duration(days: 9))),
          const RoundLevel(gold, 2): LevelRecord(bestStars: 3, achievedAt: day),
        },
        lastPlayedAt: day.subtract(const Duration(days: 13)),
      );
      final GameProgress settled = StarDecay.settle(progress, settings: ParentalSettings.initial, now: day);
      expect(settled.records[const RoundLevel(bronze, 2)]!.bestStars, 1);
      expect(settled.records[const RoundLevel(gold, 2)]!.bestStars, 3);
      expect(settled.medals, {bronze});
      expect(settled.lastPlayedAt, day);
    });

    test('progress from before the rounds goes to gold (the old Normal): badge worth medals up to gold', () {
      final migrated = GameProgress.migrate(
        currentLevel: 4,
        hadBadge: true,
        levelRecords: {
          1: LevelRecord(bestStars: 3, achievedAt: day),
          3: LevelRecord(bestStars: 2, achievedAt: day),
        },
        lastPlayedAt: day,
      );
      expect(migrated.position, const RoundPosition(round: gold, level: 4));
      expect(migrated.medals, {bronze, silver, gold});
      expect(migrated.records.keys, [const RoundLevel(gold, 3)]);
      expect(migrated.lastPlayedAt, day);
      expect(GameProgress.migrate(currentLevel: 1, hadBadge: false, levelRecords: const {}).medals, isEmpty);
    });

    test('round-level keys round-trip, old keys are read as the new rounds, and equality looks at every field', () {
      expect(RoundLevel.fromKey(const RoundLevel(diamond, 7).key), const RoundLevel(diamond, 7));
      expect(RoundLevel.fromLegacyKey(12), const RoundLevel(gold, 2), reason: 'old Normal, level 2');
      expect(RoundLevel.fromSaved(22, legacy: true), const RoundLevel(diamond, 2));
      expect(RoundLevel.fromSaved(22, legacy: false), const RoundLevel(gold, 2));
      expect(const RoundLevel(gold, 2).toString(), 'gold/2');
      GameProgress build() => GameProgress(
            position: memory.arrival(gold, 2),
            medals: const {bronze},
            records: {const RoundLevel(gold, 2): LevelRecord(bestStars: 1, achievedAt: day)},
            lastPlayedAt: day,
          );
      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(build(), isNot(GameProgress.initial()));
      expect(memory.arrival(gold, 2), isNot(memory.arrival(gold, 3)));
      expect(memory.arrival(gold, 2).hashCode, memory.arrival(gold, 2).hashCode);
    });
  });
}
