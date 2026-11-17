import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

/// HU-034 R4 y P7: el niño está atascado si llega 3 veces al mismo nivel y las
/// 3 veces vuelve a bajar sin superarlo.
void main() {
  const easy = GameDifficulty.bronze;
  const normal = GameDifficulty.gold;
  final RoundLadder memory = MemoryLadder.rounds;
  final DateTime day = DateTime(2026, 11, 16, 10);

  GameProgress lose(GameProgress progress, RoundPosition at) =>
      progress.recordLoss(lost: at, step: memory.afterLoss(at), at: day);

  GameProgress win(GameProgress progress, RoundPosition at) =>
      progress.recordWin(won: at, stars: 2, step: memory.afterWin(at), at: day);

  final RoundPosition normal3 = memory.arrival(normal, 3);
  final RoundPosition normal4 = memory.arrival(normal, 4);

  test('nobody starts stuck, and the two counters go together', () {
    final GameProgress initial = GameProgress.initial();
    expect(initial.stuckLevel, isNull);
    expect(initial.stuckFalls, 0);
    expect(initial.isStuck, isFalse);
    expect(() => GameProgress(position: normal4, stuckLevel: 4), throwsArgumentError);
    expect(() => GameProgress(position: normal4, stuckFalls: 1), throwsArgumentError);
    expect(() => GameProgress(position: normal4, stuckLevel: 4, stuckFalls: -1), throwsRangeError);
  });

  test('losing three times at the same level, coming back in between, is being stuck', () {
    GameProgress progress = GameProgress(position: normal4);
    for (var fall = 1; fall <= GameProgress.stuckThreshold; fall++) {
      progress = lose(progress, normal4);
      expect(progress.stuckLevel, 4);
      expect(progress.stuckFalls, fall);
      expect(progress.isStuck, fall == GameProgress.stuckThreshold);
      if (fall < GameProgress.stuckThreshold) progress = win(progress, normal3); // vuelve a llegar al 4
    }
  });

  test('two falls are not enough (criterion 6)', () {
    GameProgress progress = lose(GameProgress(position: normal4), normal4);
    progress = lose(win(progress, normal3), normal4);
    expect(progress.isStuck, isFalse);
  });

  test('losing at a lower level does not change the count; at a higher one it starts there', () {
    GameProgress progress = lose(lose(GameProgress(position: normal4), normal4), normal3);
    expect((progress.stuckLevel, progress.stuckFalls), (4, 1));

    progress = lose(progress, memory.arrival(normal, 5));
    expect((progress.stuckLevel, progress.stuckFalls), (5, 1));
  });

  test('passing the level clears the count; winning a lower one keeps it', () {
    GameProgress progress = lose(GameProgress(position: normal4), normal4);
    progress = win(progress, normal3);
    expect(progress.stuckFalls, 1);
    progress = win(progress, normal4);
    expect(progress.stuckLevel, isNull);
    expect(progress.stuckFalls, 0);
  });

  test('changing round, by the adult or by falling twice to the tutorial, starts again', () {
    final GameProgress stuck = GameProgress(position: normal4, stuckLevel: 4, stuckFalls: 2);
    expect(stuck.withRound(easy).stuckFalls, 0);

    final RoundPosition firstTimed = RoundPosition(
      round: normal,
      level: RoundLadder.firstTimedLevel,
      timeLimit: memory.limitFor(normal, RoundLadder.firstTimedLevel),
      tutorialFalls: 1,
    );
    final GameProgress dropped = lose(stuck, firstTimed);
    expect(dropped.position.round, GameDifficulty.silver, reason: 'one step down (HU-051 P7)');
    expect(dropped.stuckLevel, isNull);
  });

  test('completing the round clears it too', () {
    final RoundPosition last = memory.arrival(normal, memory.levels);
    final GameProgress progress = win(GameProgress(position: last, stuckLevel: 5, stuckFalls: 2), last);
    expect(progress.position.round, GameDifficulty.ruby, reason: 'the round after gold');
    expect(progress.stuckFalls, 0);
  });

  test('losing stars and playing again keep the count, and it takes part in equality', () {
    final GameProgress stuck = GameProgress(position: normal4, stuckLevel: 4, stuckFalls: 2);
    expect(stuck.loseStars(1).stuckFalls, 2);
    expect(stuck.playedAt(day).stuckLevel, 4);
    expect(stuck, isNot(GameProgress(position: normal4)));
    expect(stuck, GameProgress(position: normal4, stuckLevel: 4, stuckFalls: 2));
    expect(stuck.hashCode, GameProgress(position: normal4, stuckLevel: 4, stuckFalls: 2).hashCode);
  });
}
