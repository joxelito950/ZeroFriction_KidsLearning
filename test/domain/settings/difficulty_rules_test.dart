import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';

/// HU-030: dificultad y «Jugar sin tiempo» en la escalera de la memoria y en
/// los ajustes guardados.
void main() {
  const easy = MemoryLadderRules(difficulty: GameDifficulty.easy);
  const impossible = MemoryLadderRules(difficulty: GameDifficulty.impossible);
  const noTime = MemoryLadderRules(timed: false);

  List<int?> arrivalSeconds(MemoryLadderRules rules) =>
      [for (final level in MemoryLadder.levels) MemoryLadder.arrivalPosition(level.number, rules).timeLimit?.inSeconds];

  group('GameDifficulty', () {
    test('only Easy and Normal show helps (R10)', () {
      expect(GameDifficulty.easy.showsHelps, isTrue);
      expect(GameDifficulty.normal.showsHelps, isTrue);
      expect(GameDifficulty.impossible.showsHelps, isFalse);
    });

    test('reads the stored name, and anything else is Normal', () {
      expect(GameDifficulty.fromName('impossible'), GameDifficulty.impossible);
      expect(GameDifficulty.fromName(null), GameDifficulty.normal);
      expect(GameDifficulty.fromName('nightmare'), GameDifficulty.normal);
    });
  });

  group('memory series per difficulty (3.2, criteria 2 and 3)', () {
    test('Normal keeps the HU-001 series', () {
      expect(arrivalSeconds(MemoryLadderRules.standard), [null, 90, 60, 45, 30]);
    });

    test('Easy triples it', () {
      expect(arrivalSeconds(easy), [null, 270, 180, 135, 90]);
    });

    test('Impossible halves it, rounding 22.5 s down', () {
      expect(arrivalSeconds(impossible), [null, 45, 30, 22, 15]);
    });

    test('winning follows the series of the difficulty and never goes below its last limit', () {
      var position = MemoryLadder.start;
      final seen = <int?>[];
      for (var i = 0; i < 4; i++) {
        position = MemoryLadder.afterWin(position, impossible).next;
        seen.add(position.timeLimit?.inSeconds);
      }
      expect(seen, [45, 30, 22, 15]);
      final MemoryLadderPosition looped = MemoryLadder.afterWin(
        const MemoryLadderPosition(level: 4, timeLimit: Duration(seconds: 15)),
        impossible,
      ).next;
      expect(looped.timeLimit, const Duration(seconds: 15));
    });

    test('a limit from another series is rejected', () {
      expect(
        () => MemoryLadder.afterWin(const MemoryLadderPosition(level: 2, timeLimit: Duration(seconds: 270))),
        throwsArgumentError,
      );
    });
  });

  group('play without time (R3, criterion 4)', () {
    test('no level has a time limit', () {
      expect(arrivalSeconds(noTime), [null, null, null, null, null]);
    });

    test('winning only goes up, and the 4x4 still gives the badge', () {
      var position = MemoryLadder.start;
      for (var level = 2; level <= MemoryLadder.maxLevel; level++) {
        position = MemoryLadder.afterWin(position, noTime).next;
        expect(position, MemoryLadderPosition(level: level));
      }
      final MemoryLadderStep last = MemoryLadder.afterWin(position, noTime);
      expect(last.badgeEarned, isTrue);
      expect(last.next, MemoryLadder.start);
    });

    test('a board without time can never be lost', () {
      expect(() => MemoryLadder.afterLoss(const MemoryLadderPosition(level: 3)), throwsStateError);
    });
  });

  test('rules: the preview is a help, equality by value', () {
    expect(MemoryLadderRules.standard.preview, isTrue);
    expect(impossible.preview, isFalse);
    expect(const MemoryLadderRules(difficulty: GameDifficulty.easy), easy);
    expect(easy.hashCode, const MemoryLadderRules(difficulty: GameDifficulty.easy).hashCode);
    expect(easy, isNot(noTime));
  });

  group('ParentalSettings (criteria 7 and 8)', () {
    test('defaults to Normal with time', () {
      expect(ParentalSettings.initial.difficulty, GameDifficulty.normal);
      expect(ParentalSettings.initial.timerDisabled, isFalse);
    });

    test('each change keeps the other fields', () {
      final settings = ParentalSettings(dailyLimitMinutes: 30)
          .withDifficulty(GameDifficulty.easy)
          .withTimerDisabled(true)
          .withLimit(45);

      expect(settings.dailyLimitMinutes, 45);
      expect(settings.difficulty, GameDifficulty.easy);
      expect(settings.timerDisabled, isTrue);
      expect(settings, isNot(settings.withDifficulty(GameDifficulty.normal)));
      expect(settings.hashCode, settings.withLimit(45).hashCode);
    });

    test('round-trips through the Hive model', () {
      final settings = ParentalSettings(difficulty: GameDifficulty.impossible, timerDisabled: true);
      final model = ParentalSettingsHiveModel.fromEntity(settings);

      expect(model.difficulty, 'impossible');
      expect(model.toEntity(), settings);
    });

    test('data saved before HU-030 reads as Normal with time', () {
      expect(
          const ParentalSettingsHiveModel(dailyLimitMinutes: 30).toEntity(), ParentalSettings(dailyLimitMinutes: 30));
    });
  });
}
