import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/models/level_state_hive_model.dart';
import 'package:toddler_logic/data/local/models/memory_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/data/local/models/shadow_progress_hive_model.dart';
import 'package:toddler_logic/domain/entities/shadow_progress.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';

void main() {
  group('LevelStateHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      final entity = LevelState(levelId: 'farm_easy', isCompleted: true, stars: 2);

      final model = LevelStateHiveModel.fromEntity(entity);

      expect(model.levelId, 'farm_easy');
      expect(model.isCompleted, isTrue);
      expect(model.stars, 2);
      expect(model.toEntity(), entity);
    });

    test('keeps the business rule in the entity: invalid stored stars are rejected', () {
      const corrupted = LevelStateHiveModel(levelId: 'farm_easy', isCompleted: true, stars: 7);

      expect(corrupted.toEntity, throwsRangeError);
    });
  });

  group('UserProfileHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      const entity = UserProfile(isPremium: true, isSoundEnabled: false);

      final model = UserProfileHiveModel.fromEntity(entity);

      expect(model.isPremium, isTrue);
      expect(model.isSoundEnabled, isFalse);
      expect(model.languageCode, isNull);
      expect(model.toEntity(), entity);
    });

    test('round-trips the language code', () {
      const entity = UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'ar');

      expect(UserProfileHiveModel.fromEntity(entity).toEntity(), entity);
    });
  });
  group('MemoryProgressHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      final at = DateTime.utc(2026, 10, 22, 7);
      final entity = MemoryProgress(
        currentLevel: 2,
        hasBadge: true,
        levelRecords: {1: MemoryLevelRecord(bestStars: 3, achievedAt: at)},
        lastPlayedAt: at,
      );

      final model = MemoryProgressHiveModel.fromEntity(entity);

      expect(model.bestStarsByLevel, {1: 3});
      expect(model.achievedAtByLevel, {1: at});
      expect(model.toEntity(), entity);
    });

    test('the initial progress round-trips', () {
      expect(MemoryProgressHiveModel.fromEntity(MemoryProgress.initial).toEntity(), MemoryProgress.initial);
    });

    test('ignores a star value without its date instead of inventing one', () {
      const model = MemoryProgressHiveModel(
        currentLevel: 1,
        hasBadge: false,
        bestStarsByLevel: {1: 2},
        achievedAtByLevel: {},
      );

      expect(model.toEntity().levelRecords, isEmpty);
    });

    test('keeps the business rules in the entity: an invalid stored level is rejected', () {
      const model = MemoryProgressHiveModel(
        currentLevel: 9,
        hasBadge: false,
        bestStarsByLevel: {},
        achievedAtByLevel: {},
      );

      expect(model.toEntity, throwsRangeError);
    });
  });

  group('ShadowProgressHiveModel', () {
    test('round-trips entity -> model -> entity without loss', () {
      final at = DateTime.utc(2026, 11, 9, 7);
      final entity = ShadowProgress(
        currentLevel: 5,
        hasMedal: true,
        levelRecords: {4: LevelRecord(bestStars: 2, achievedAt: at)},
        lastPlayedAt: at,
      );

      final model = ShadowProgressHiveModel.fromEntity(entity);

      expect(model.bestStarsByLevel, {4: 2});
      expect(model.achievedAtByLevel, {4: at});
      expect(model.toEntity(), entity);
      expect(ShadowProgressHiveModel.fromEntity(ShadowProgress.initial).toEntity(), ShadowProgress.initial);
    });

    test('ignores a star value without its date, and rejects an invalid level', () {
      const withoutDate =
          ShadowProgressHiveModel(currentLevel: 1, hasMedal: false, bestStarsByLevel: {1: 2}, achievedAtByLevel: {});
      const invalid =
          ShadowProgressHiveModel(currentLevel: 9, hasMedal: false, bestStarsByLevel: {}, achievedAtByLevel: {});

      expect(withoutDate.toEntity().levelRecords, isEmpty);
      expect(invalid.toEntity, throwsRangeError);
    });
  });
}
