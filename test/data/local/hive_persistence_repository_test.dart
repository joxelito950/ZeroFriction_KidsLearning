import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/hive_persistence_repository.dart';
import 'package:toddler_logic/data/local/models/level_state_hive_model.dart';
import 'package:toddler_logic/data/local/models/memory_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

class _MockLevelStateBox extends Mock implements Box<LevelStateHiveModel> {}

class _MockUserProfileBox extends Mock implements Box<UserProfileHiveModel> {}

class _MockMemoryProgressBox extends Mock implements Box<MemoryProgressHiveModel> {}

class _FakeMemoryProgressHiveModel extends Fake implements MemoryProgressHiveModel {}

class _FakeLevelStateHiveModel extends Fake implements LevelStateHiveModel {}

class _FakeUserProfileHiveModel extends Fake implements UserProfileHiveModel {}

LevelStateHiveModel _levelModel(String id, {required bool completed, required int stars}) =>
    LevelStateHiveModel(levelId: id, isCompleted: completed, stars: stars);

/// Compara un modelo guardado con la entidad esperada, convirtiéndolo.
Matcher _isLevelModelOf(LevelState expected) =>
    isA<LevelStateHiveModel>().having((model) => model.toEntity(), 'toEntity()', expected);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLevelStateHiveModel());
    registerFallbackValue(_FakeUserProfileHiveModel());
    registerFallbackValue(_FakeMemoryProgressHiveModel());
  });

  group('HivePersistenceRepository', () {
    late _MockLevelStateBox levelStateBox;
    late _MockUserProfileBox userProfileBox;
    late _MockMemoryProgressBox memoryProgressBox;
    late HivePersistenceRepository repository;

    setUp(() {
      levelStateBox = _MockLevelStateBox();
      userProfileBox = _MockUserProfileBox();
      memoryProgressBox = _MockMemoryProgressBox();
      repository = HivePersistenceRepository(
        levelStateBox: levelStateBox,
        userProfileBox: userProfileBox,
        memoryProgressBox: memoryProgressBox,
      );
    });

    test('readAllLevelStates returns all stored levels as domain entities', () async {
      when(() => levelStateBox.values).thenReturn([
        _levelModel('level_1', completed: true, stars: 3),
        _levelModel('level_2', completed: false, stars: 0),
      ]);

      final result = await repository.readAllLevelStates();

      expect(result, [
        LevelState(levelId: 'level_1', isCompleted: true, stars: 3),
        LevelState(levelId: 'level_2', isCompleted: false, stars: 0),
      ]);
      verify(() => levelStateBox.values).called(1);
    });

    test('readLevelState returns a level state by id', () async {
      when(() => levelStateBox.get('level_1'))
          .thenReturn(_levelModel('level_1', completed: true, stars: 2));

      final result = await repository.readLevelState('level_1');

      expect(result, LevelState(levelId: 'level_1', isCompleted: true, stars: 2));
      verify(() => levelStateBox.get('level_1')).called(1);
    });

    test('readLevelState returns null when id does not exist', () async {
      when(() => levelStateBox.get('missing_level')).thenReturn(null);

      final result = await repository.readLevelState('missing_level');

      expect(result, isNull);
      verify(() => levelStateBox.get('missing_level')).called(1);
    });

    test('saveLevelState stores the persistence model under the level id', () async {
      final level = LevelState(levelId: 'level_3', isCompleted: false, stars: 1);
      when(() => levelStateBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveLevelState(level);

      verify(() => levelStateBox.put('level_3', any(that: _isLevelModelOf(level)))).called(1);
    });

    test('saveLevelStates stores every level keyed by its id', () async {
      final levelStates = <LevelState>[
        LevelState(levelId: 'level_10', isCompleted: true, stars: 3),
        LevelState(levelId: 'level_11', isCompleted: false, stars: 1),
      ];
      when(() => levelStateBox.putAll(any())).thenAnswer((_) async {});

      await repository.saveLevelStates(levelStates);

      final saved = verify(() => levelStateBox.putAll(captureAny())).captured.single
          as Map<dynamic, LevelStateHiveModel>;
      expect(saved.keys, ['level_10', 'level_11']);
      expect(saved['level_10']!.toEntity(), levelStates[0]);
      expect(saved['level_11']!.toEntity(), levelStates[1]);
    });

    test('readUserProfile returns saved profile when it exists', () async {
      when(() => userProfileBox.get('current_user_profile'))
          .thenReturn(const UserProfileHiveModel(isPremium: true, isSoundEnabled: false));

      final result = await repository.readUserProfile();

      expect(result, const UserProfile(isPremium: true, isSoundEnabled: false));
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verifyNever(() => userProfileBox.isNotEmpty);
    });

    test('readUserProfile returns default profile when box is empty', () async {
      when(() => userProfileBox.get('current_user_profile')).thenReturn(null);
      when(() => userProfileBox.isNotEmpty).thenReturn(false);

      final result = await repository.readUserProfile();

      expect(result, const UserProfile(isPremium: false, isSoundEnabled: true));
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verify(() => userProfileBox.isNotEmpty).called(1);
    });

    test('readUserProfile returns first value when key is missing', () async {
      when(() => userProfileBox.get('current_user_profile')).thenReturn(null);
      when(() => userProfileBox.isNotEmpty).thenReturn(true);
      when(() => userProfileBox.values)
          .thenReturn([const UserProfileHiveModel(isPremium: false, isSoundEnabled: false)]);

      final result = await repository.readUserProfile();

      expect(result, const UserProfile(isPremium: false, isSoundEnabled: false));
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verify(() => userProfileBox.isNotEmpty).called(1);
      verify(() => userProfileBox.values).called(1);
    });

    test('saveUserProfile stores the persistence model under the fixed key', () async {
      const userProfile = UserProfile(isPremium: true, isSoundEnabled: true);
      when(() => userProfileBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveUserProfile(userProfile);

      final saved = verify(() => userProfileBox.put('current_user_profile', captureAny()))
          .captured
          .single as UserProfileHiveModel;
      expect(saved.toEntity(), userProfile);
    });
    test('readMemoryProgress returns the initial progress when nothing is stored', () async {
      when(() => memoryProgressBox.get('current_memory_progress')).thenReturn(null);

      expect(await repository.readMemoryProgress(), MemoryProgress.initial);
    });

    test('readMemoryProgress converts the stored model to the domain entity', () async {
      final playedAt = DateTime.utc(2026, 10, 22, 9);
      when(() => memoryProgressBox.get('current_memory_progress')).thenReturn(
        MemoryProgressHiveModel(
          currentLevel: 3,
          hasBadge: true,
          bestStarsByLevel: const {1: 3, 2: 2},
          achievedAtByLevel: {1: playedAt, 2: playedAt},
          lastPlayedAt: playedAt,
        ),
      );

      final progress = await repository.readMemoryProgress();

      expect(progress.currentLevel, 3);
      expect(progress.hasBadge, isTrue);
      expect(progress.levelRecords[2], MemoryLevelRecord(bestStars: 2, achievedAt: playedAt));
      expect(progress.lastPlayedAt, playedAt);
    });

    test('saveMemoryProgress stores the persistence model under a fixed key', () async {
      final progress = MemoryProgress(
        currentLevel: 4,
        levelRecords: {3: MemoryLevelRecord(bestStars: 1, achievedAt: DateTime.utc(2026, 10, 22))},
      );
      when(() => memoryProgressBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveMemoryProgress(progress);

      final saved = verify(() => memoryProgressBox.put('current_memory_progress', captureAny()))
          .captured
          .single as MemoryProgressHiveModel;
      expect(saved.toEntity(), progress);
    });
  });
}
