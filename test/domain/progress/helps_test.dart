import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/progress/helps.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

void main() {
  test('helps only in the tutorial and in the base round, bronze', () {
    expect(Helps.allowedAt(GameDifficulty.bronze, RoundLadder.tutorial), isTrue);
    for (var level = 2; level <= 8; level++) {
      expect(Helps.allowedAt(GameDifficulty.bronze, level), isTrue, reason: 'bronze level $level');
    }
    for (final GameDifficulty round in GameDifficulty.values.where((round) => round != GameDifficulty.bronze)) {
      expect(Helps.allowedAt(round, RoundLadder.firstTimedLevel), isFalse, reason: round.name);
      expect(Helps.allowedAt(round, 8), isFalse, reason: round.name);
    }
  });
}
