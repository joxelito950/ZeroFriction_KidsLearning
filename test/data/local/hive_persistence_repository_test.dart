import 'package:hive_ce/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/data/local/hive_persistence_repository.dart';
import 'package:toddler_logic/data/local/models/level_state_hive_model.dart';
import 'package:toddler_logic/data/local/models/memory_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/data/local/models/shadow_progress_hive_model.dart';
import 'package:toddler_logic/data/local/models/user_profile_hive_model.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/parental/daily_play_time.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

class _MockLevelStateBox extends Mock implements Box<LevelStateHiveModel> {}

class _MockUserProfileBox extends Mock implements Box<UserProfileHiveModel> {}

class _MockMemoryProgressBox extends Mock implements Box<MemoryProgressHiveModel> {}

class _FakeMemoryProgressHiveModel extends Fake implements MemoryProgressHiveModel {}

class _MockParentalSettingsBox extends Mock implements Box<ParentalSettingsHiveModel> {}

class _FakeParentalSettingsHiveModel extends Fake implements ParentalSettingsHiveModel {}

class _MockShadowProgressBox extends Mock implements Box<ShadowProgressHiveModel> {}

class _FakeShadowProgressHiveModel extends Fake implements ShadowProgressHiveModel {}

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
    registerFallbackValue(_FakeParentalSettingsHiveModel());
    registerFallbackValue(_FakeShadowProgressHiveModel());
  });

  group('HivePersistenceRepository', () {
    late _MockLevelStateBox levelStateBox;
    late _MockUserProfileBox userProfileBox;
    late _MockMemoryProgressBox memoryProgressBox;
    late _MockParentalSettingsBox parentalSettingsBox;
    late _MockShadowProgressBox shadowProgressBox;
    late HivePersistenceRepository repository;

    setUp(() {
      levelStateBox = _MockLevelStateBox();
      userProfileBox = _MockUserProfileBox();
      memoryProgressBox = _MockMemoryProgressBox();
      parentalSettingsBox = _MockParentalSettingsBox();
      shadowProgressBox = _MockShadowProgressBox();
      repository = HivePersistenceRepository(
        levelStateBox: levelStateBox,
        userProfileBox: userProfileBox,
        memoryProgressBox: memoryProgressBox,
        parentalSettingsBox: parentalSettingsBox,
        shadowProgressBox: shadowProgressBox,
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
    test('readParentalSettings returns the defaults when nothing is stored', () async {
      when(() => parentalSettingsBox.get('current_parental_settings')).thenReturn(null);

      expect(await repository.readParentalSettings(), ParentalSettings.initial);
    });

    test('saveParentalSettings stores the persistence model under a fixed key and reads it back', () async {
      final settings = ParentalSettings(
        dailyLimitMinutes: 30,
        playTime: DailyPlayTime(day: DateTime(2026, 11, 4), played: const Duration(seconds: 754), extraMinutes: 15),
      );
      when(() => parentalSettingsBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveParentalSettings(settings);

      final saved = verify(() => parentalSettingsBox.put('current_parental_settings', captureAny()))
          .captured
          .single as ParentalSettingsHiveModel;
      expect(saved.playedSeconds, 754);
      when(() => parentalSettingsBox.get('current_parental_settings')).thenReturn(saved);
      expect(await repository.readParentalSettings(), settings);
    });

    test('updateParentalSettings changes only what the update touches and saves it', () async {
      when(() => parentalSettingsBox.get('current_parental_settings'))
          .thenReturn(ParentalSettingsHiveModel.fromEntity(ParentalSettings(dailyLimitMinutes: 30)));
      when(() => parentalSettingsBox.put(any(), any())).thenAnswer((_) async {});

      final ParentalSettings next =
          await repository.updateParentalSettings((current) => current.withDifficulty(GameDifficulty.easy));

      expect(next, ParentalSettings(dailyLimitMinutes: 30, difficulty: GameDifficulty.easy));
      final saved = verify(() => parentalSettingsBox.put('current_parental_settings', captureAny()))
          .captured
          .single as ParentalSettingsHiveModel;
      expect(saved.toEntity(), next);
    });

    test('updateParentalSettings starts from the defaults when nothing is stored', () async {
      when(() => parentalSettingsBox.get('current_parental_settings')).thenReturn(null);
      when(() => parentalSettingsBox.put(any(), any())).thenAnswer((_) async {});

      expect(
        await repository.updateParentalSettings((current) => current.withTimerDisabled(true)),
        ParentalSettings(timerDisabled: true),
      );
    });
  });
}
