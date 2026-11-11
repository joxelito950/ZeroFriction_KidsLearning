import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/progress/star_decay.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';

/// HU-037, entrega 1: rondas de dificultad, medallas y progreso común (D-038).
void main() {
  const easy = GameDifficulty.easy;
  const normal = GameDifficulty.normal;
  const impossible = GameDifficulty.impossible;
  final RoundLadder memory = MemoryLadder.rounds;
  final DateTime day = DateTime(2026, 11, 11, 10);

  group('rounds', () {
    test('go Easy → Normal → Impossible, and stay in Impossible (P4); Easy has no previous round', () {
      expect([easy.nextRound, normal.nextRound, impossible.nextRound], [normal, impossible, impossible]);
      expect([easy.previousRound, normal.previousRound, impossible.previousRound], [null, easy, normal]);
    });
  });

  group('RoundLadder', () {
    test('the tutorial has no time; each round uses its own series (HU-030)', () {
      expect(memory.limitFor(easy, 1), isNull);
      expect(memory.limitFor(easy, 2), const Duration(seconds: 270));
      expect(memory.limitFor(normal, 5), const Duration(seconds: 30));
      expect(memory.limitFor(impossible, 5), const Duration(seconds: 15));
      expect(memory.limitFor(normal, 3, timed: false), isNull, reason: 'Play without time');
      expect(() => memory.limitFor(normal, 6), throwsRangeError);
      expect(ShadowLadder.rounds.limitFor(normal, 8), const Duration(seconds: 25));
    });

    test('needs one limit per level after the tutorial, in every round', () {
      expect(() => RoundLadder(levels: 3, timeLimits: {easy: const [Duration(seconds: 1)]}), throwsArgumentError);
      expect(() => RoundLadder(levels: 1, timeLimits: const {}), throwsRangeError);
    });

    test('stars: the tutorial gives none (P2), so the gold covers the other levels of the three rounds', () {
      expect(memory.levelsWithStars, 4);
      expect(memory.maxStars, 36);
      expect(ShadowLadder.rounds.maxStars, 63);
    });

    test('winning the tutorial invites to play and moves to the first timed level (R9)', () {
      final RoundStep step = memory.afterWin(memory.arrival(easy, 1));
      expect(step.fromTutorial, isTrue);
      expect(step.next, memory.arrival(easy, 2));
      expect(step.medal, isNull);
    });

    test('winning the last level gives the round medal and goes to the next tutorial (R2)', () {
      final RoundStep easyDone = memory.afterWin(memory.arrival(easy, 5));
      expect(easyDone.medal, easy);
      expect(easyDone.next, memory.arrival(normal, 1));
      final RoundStep gold = memory.afterWin(memory.arrival(impossible, 5));
      expect(gold.medal, impossible);
      expect(gold.next, memory.arrival(impossible, 1), reason: 'stays in Impossible (P4)');
    });

    test('Shadows without Premium ends each round at level 7 with its medal (P16)', () {
      final RoundLadder shadows = ShadowLadder.rounds;
      final int free = ShadowLadder.lastLevelFor(premium: false);
      expect(free, 7);
      expect(shadows.afterWin(shadows.arrival(easy, 7), lastLevel: free).medal, easy);
      expect(shadows.afterWin(shadows.arrival(easy, 7), lastLevel: ShadowLadder.lastLevelFor(premium: true)).medal,
          isNull);
      expect(() => shadows.afterWin(shadows.arrival(easy, 2), lastLevel: 1), throwsRangeError);
    });

    test('losing goes down one level keeping the limit; from the first timed level, to the tutorial', () {
      final RoundStep down = memory.afterLoss(memory.arrival(normal, 4));
      expect(down.next, const RoundPosition(round: normal, level: 3, timeLimit: Duration(seconds: 45)));
      final RoundStep fall = memory.afterLoss(memory.arrival(normal, 2));
      expect(fall.next, const RoundPosition(round: normal, level: 1, tutorialFalls: 1));
      expect(fall.droppedRound, isFalse);
      expect(() => memory.afterLoss(memory.arrival(normal, 1)), throwsStateError);
    });

    test('a second fall to the tutorial drops to the previous round, at its first timed level (R10, P14, P15)', () {
      // Primera caída: tutorial de Normal. Al ganarlo y volver a caer, baja a Fácil.
      RoundPosition position = memory.afterLoss(memory.arrival(normal, 2)).next;
      position = memory.afterWin(position).next;
      expect(position.tutorialFalls, 1, reason: 'falls keep counting inside the round');
      final RoundStep second = memory.afterLoss(position);
      expect(second.droppedRound, isTrue);
      expect(second.next, memory.arrival(easy, 2));
      expect(second.next.tutorialFalls, 0, reason: 'the count starts again in the new round');
    });

    test('entering a round through its tutorial does not count as a fall (P15), and Easy never drops', () {
      final RoundPosition entered = memory.afterWin(memory.arrival(easy, 5)).next;
      expect(entered.tutorialFalls, 0);
      RoundPosition easyFall = memory.afterLoss(memory.arrival(easy, 2)).next;
      easyFall = memory.afterWin(easyFall).next;
      final RoundStep again = memory.afterLoss(easyFall);
      expect(again.droppedRound, isFalse);
      expect(again.next.round, easy);
      expect(again.next.isTutorial, isTrue);
      expect(again.next.toString(), contains('easy'));
    });
  });

  group('GameProgress', () {
    test('a new player starts in the Easy tutorial with no medals (R1)', () {
      final progress = GameProgress.initial();
      expect(progress.position, memory.arrival(easy, 1));
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
      expect(progress.records[const RoundLevel(easy, 2)]!.bestStars, 2);
      expect(progress.goldFraction(memory), 2 / 36);
      expect(
        () => GameProgress(position: tutorial, records: {const RoundLevel(easy, 1): LevelRecord(bestStars: 1, achievedAt: day)}),
        throwsArgumentError,
      );
    });

    test('medals add up and the best one is shown (P5); a loss only moves the position', () {
      GameProgress progress = GameProgress.initial();
      progress = progress.recordWin(
          won: memory.arrival(easy, 5), stars: 3, step: memory.afterWin(memory.arrival(easy, 5)), at: day);
      progress = progress.recordWin(
          won: memory.arrival(normal, 5), stars: 3, step: memory.afterWin(memory.arrival(normal, 5)), at: day);
      expect(progress.medals, {easy, normal});
      expect(progress.bestMedal, normal);

      final GameProgress lost = progress.recordLoss(step: memory.afterLoss(memory.arrival(impossible, 3)), at: day);
      expect(lost.position.level, 2);
      expect(lost.medals, progress.medals);
      expect(lost.stars, progress.stars);
    });

    test('the adult changes the round without losing anything (P1, R5)', () {
      final progress = GameProgress(
        position: memory.arrival(impossible, 4),
        medals: const {easy},
        records: {const RoundLevel(normal, 3): LevelRecord(bestStars: 3, achievedAt: day)},
      );
      final GameProgress back = progress.withRound(easy);
      expect(back.position, memory.arrival(easy, 1));
      expect(back.medals, {easy});
      expect(back.stars, 3);
    });

    test('stars are lost from the oldest achievement in any round, never the medals (R6)', () {
      final progress = GameProgress(
        position: memory.arrival(normal, 2),
        medals: const {easy},
        records: {
          const RoundLevel(easy, 2): LevelRecord(bestStars: 3, achievedAt: day.subtract(const Duration(days: 9))),
          const RoundLevel(normal, 2): LevelRecord(bestStars: 3, achievedAt: day),
        },
        lastPlayedAt: day.subtract(const Duration(days: 13)),
      );
      final GameProgress settled = StarDecay.settle(progress, settings: ParentalSettings.initial, now: day);
      expect(settled.records[const RoundLevel(easy, 2)]!.bestStars, 1);
      expect(settled.records[const RoundLevel(normal, 2)]!.bestStars, 3);
      expect(settled.medals, {easy});
      expect(settled.lastPlayedAt, day);
    });

    test('migrates today\'s progress to Normal (P7): badge to bronze and silver, level-1 stars dropped', () {
      final migrated = GameProgress.migrate(
        currentLevel: 4,
        hadBadge: true,
        levelRecords: {
          1: LevelRecord(bestStars: 3, achievedAt: day),
          3: LevelRecord(bestStars: 2, achievedAt: day),
        },
        lastPlayedAt: day,
      );
      expect(migrated.position, const RoundPosition(round: normal, level: 4));
      expect(migrated.medals, {easy, normal});
      expect(migrated.records.keys, [const RoundLevel(normal, 3)]);
      expect(migrated.lastPlayedAt, day);
      expect(GameProgress.migrate(currentLevel: 1, hadBadge: false, levelRecords: const {}).medals, isEmpty);
    });

    test('round-level keys round-trip, and equality looks at every field', () {
      expect(RoundLevel.fromKey(const RoundLevel(impossible, 7).key), const RoundLevel(impossible, 7));
      expect(const RoundLevel(normal, 2).toString(), 'normal/2');
      GameProgress build() => GameProgress(
            position: memory.arrival(normal, 2),
            medals: const {easy},
            records: {const RoundLevel(normal, 2): LevelRecord(bestStars: 1, achievedAt: day)},
            lastPlayedAt: day,
          );
      expect(build(), build());
      expect(build().hashCode, build().hashCode);
      expect(build(), isNot(GameProgress.initial()));
      expect(memory.arrival(normal, 2), isNot(memory.arrival(normal, 3)));
      expect(memory.arrival(normal, 2).hashCode, memory.arrival(normal, 2).hashCode);
    });
  });
}
