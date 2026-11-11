import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/progress/star_decay.dart';

/// HU-002 R2, R7–R14 y HU-016: dorado y pérdida gradual de estrellas.
void main() {
  final DateTime played = DateTime(2026, 11, 1, 18);

  group('StarDecay', () {
    test('nothing is lost during the 7-day grace (R7)', () {
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 7))), 0);
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 9, hours: 23))), 0);
    });

    test('then one star every 3 days (R8, criterion 9)', () {
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 10))), 1);
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 12, hours: 23))), 1);
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 13))), 2);
      // De 15 estrellas a 0 en 52 días.
      expect(StarDecay.starsLost(since: played, now: played.add(const Duration(days: 52))), 15);
    });

    test('counts from the latest of the last game and the reactivation (HU-016 R3)', () {
      final DateTime resumed = played.add(const Duration(days: 20));
      expect(StarDecay.since(lastPlayedAt: played, resumedAt: resumed), resumed);
      expect(StarDecay.since(lastPlayedAt: resumed, resumedAt: played), resumed);
      expect(StarDecay.since(lastPlayedAt: played), played);
      expect(StarDecay.since(resumedAt: resumed), isNull);
    });
  });

  group('gold with rounds (HU-002 with HU-037)', () {
    GameProgress progress(Map<int, (int, int)> starsAndDay) => GameProgress(
          position: const RoundPosition(round: GameDifficulty.normal, level: 2),
          medals: const {GameDifficulty.easy},
          records: {
            for (final entry in starsAndDay.entries)
              RoundLevel(GameDifficulty.normal, entry.key):
                  LevelRecord(bestStars: entry.value.$1, achievedAt: DateTime(2026, 10, entry.value.$2)),
          },
          lastPlayedAt: played,
        );

    test('is the best stars of each round and level over 36 in memory (R2)', () {
      expect(MemoryLadder.rounds.maxStars, 36);
      expect(GameProgress.initial().goldFraction(MemoryLadder.rounds), 0);
      final nine = progress({2: (3, 1), 3: (3, 2), 4: (3, 3)});
      expect(nine.stars, 9);
      expect(nine.goldFraction(MemoryLadder.rounds), closeTo(0.25, 1e-9));
    });

    test('losing empties the oldest achievement first, keeping dates and medals (R8, R10, R14, criterion 13)', () {
      final before = progress({2: (3, 5), 3: (2, 1), 4: (3, 9)});

      final after = before.loseStars(3);

      const RoundLevel oldest = RoundLevel(GameDifficulty.normal, 3);
      expect(after.records[oldest]!.bestStars, 0);
      expect(after.records[oldest]!.achievedAt, DateTime(2026, 10, 1));
      expect(after.records[const RoundLevel(GameDifficulty.normal, 2)]!.bestStars, 2);
      expect(after.records[const RoundLevel(GameDifficulty.normal, 4)]!.bestStars, 3);
      expect(after.medals, {GameDifficulty.easy});
      expect(after.lastPlayedAt, played);
    });

    test('cannot lose more than there is, nor a negative amount', () {
      expect(progress({2: (1, 1)}).loseStars(10).stars, 0);
      expect(progress({2: (1, 1)}).loseStars(0).stars, 1);
      expect(() => progress({2: (1, 1)}).loseStars(-1), throwsRangeError);
    });

    test('opening the game counts as playing (R13)', () {
      final DateTime now = DateTime(2026, 11, 30);
      final opened = progress({2: (2, 1)}).playedAt(now);
      expect(opened.lastPlayedAt, now);
      expect(opened.stars, 2);
    });
  });

  group('ParentalSettings keep stars (HU-016)', () {
    final DateTime now = DateTime(2026, 11, 6, 9);

    test('turning it on keeps the date; turning it off restarts the grace from now', () {
      final on = ParentalSettings.initial.withKeepStars(true, at: now);
      expect(on.keepStars, isTrue);
      expect(on.starDecayResumedAt, isNull);

      final off = on.withKeepStars(false, at: now);
      expect(off.keepStars, isFalse);
      expect(off.starDecayResumedAt, now);
      expect(off.withKeepStars(false, at: DateTime(2030)), same(off));
    });

    test('round-trips through the Hive model, and old data reads as off', () {
      final settings = ParentalSettings(keepStars: true, starDecayResumedAt: now);
      expect(ParentalSettingsHiveModel.fromEntity(settings).toEntity(), settings);
      expect(const ParentalSettingsHiveModel().toEntity().keepStars, isFalse);
    });
  });
}
