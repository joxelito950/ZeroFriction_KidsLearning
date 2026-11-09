import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
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

  group('MemoryProgress gold', () {
    MemoryProgress progress(Map<int, (int, int)> starsAndDay) => MemoryProgress(
          currentLevel: 1,
          hasBadge: true,
          levelRecords: {
            for (final entry in starsAndDay.entries)
              entry.key: MemoryLevelRecord(
                bestStars: entry.value.$1,
                achievedAt: DateTime(2026, 10, entry.value.$2),
              ),
          },
          lastPlayedAt: played,
        );

    test('is the best stars of each level over 15 (R2, criteria 4 and 5)', () {
      expect(MemoryProgress.maxStars, 15);
      expect(MemoryProgress.initial.goldFraction, 0);
      final nine = progress({1: (3, 1), 2: (3, 2), 3: (3, 3)});
      expect(nine.stars, 9);
      expect(nine.goldFraction, closeTo(0.6, 1e-9));
      expect(progress({for (var level = 1; level <= 5; level++) level: (3, level)}).goldFraction, 1);
    });

    test('losing empties the oldest achievement first, keeping dates and the badge (R8, R10, R14, criterion 13)', () {
      final before = progress({1: (3, 5), 2: (2, 1), 3: (3, 9)});

      final after = before.loseStars(3);

      expect(after.levelRecords[2]!.bestStars, 0);
      expect(after.levelRecords[2]!.achievedAt, DateTime(2026, 10, 1));
      expect(after.levelRecords[1]!.bestStars, 2);
      expect(after.levelRecords[3]!.bestStars, 3);
      expect(after.hasBadge, isTrue);
      expect(after.lastPlayedAt, played);
    });

    test('cannot lose more than there is, nor a negative amount', () {
      expect(progress({1: (1, 1)}).loseStars(10).stars, 0);
      expect(progress({1: (1, 1)}).loseStars(0).stars, 1);
      expect(() => progress({1: (1, 1)}).loseStars(-1), throwsRangeError);
    });

    test('opening the game counts as playing (R13)', () {
      final DateTime now = DateTime(2026, 11, 30);
      final opened = progress({1: (2, 1)}).playedAt(now);
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
