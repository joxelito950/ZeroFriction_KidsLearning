import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:toddler_logic/data/local/hive_persistence_repository.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

class _MockLevelStateBox extends Mock implements Box<LevelState> {}

class _MockUserProfileBox extends Mock implements Box<UserProfile> {}

class _FakeLevelState extends Fake implements LevelState {}

class _FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLevelState());
    registerFallbackValue(_FakeUserProfile());
  });

  group('HivePersistenceRepository', () {
    late _MockLevelStateBox levelStateBox;
    late _MockUserProfileBox userProfileBox;
    late HivePersistenceRepository repository;

    setUp(() {
      levelStateBox = _MockLevelStateBox();
      userProfileBox = _MockUserProfileBox();
      repository = HivePersistenceRepository(
        levelStateBox: levelStateBox,
        userProfileBox: userProfileBox,
      );
    });

    test('readAllLevelStates returns all level states from box', () async {
      final levelStates = <LevelState>[
        LevelState(levelId: 'level_1', isCompleted: true, stars: 3),
        LevelState(levelId: 'level_2', isCompleted: false, stars: 0),
      ];

      when(() => levelStateBox.values).thenReturn(levelStates);

      final result = await repository.readAllLevelStates();

      expect(result, equals(levelStates));
      verify(() => levelStateBox.values).called(1);
    });

    test('readLevelState returns a level state by id', () async {
      final level = LevelState(levelId: 'level_1', isCompleted: true, stars: 2);

      when(() => levelStateBox.get('level_1')).thenReturn(level);

      final result = await repository.readLevelState('level_1');

      expect(result, equals(level));
      verify(() => levelStateBox.get('level_1')).called(1);
    });

    test('readLevelState returns null when id does not exist', () async {
      when(() => levelStateBox.get('missing_level')).thenReturn(null);

      final result = await repository.readLevelState('missing_level');

      expect(result, isNull);
      verify(() => levelStateBox.get('missing_level')).called(1);
    });

    test('saveLevelState calls put with correct key and value', () async {
      final level = LevelState(levelId: 'level_3', isCompleted: false, stars: 1);

      when(() => levelStateBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveLevelState(level);

      verify(() => levelStateBox.put('level_3', level)).called(1);
    });

    test('saveLevelStates calls putAll with levelId map', () async {
      final levelStates = <LevelState>[
        LevelState(levelId: 'level_10', isCompleted: true, stars: 3),
        LevelState(levelId: 'level_11', isCompleted: false, stars: 1),
      ];

      when(() => levelStateBox.putAll(any())).thenAnswer((_) async {});

      await repository.saveLevelStates(levelStates);

      verify(
        () => levelStateBox.putAll(
          any(that: predicate<Map<dynamic, LevelState>>((m) =>
              m.length == 2 &&
              m['level_10'] == levelStates[0] &&
              m['level_11'] == levelStates[1])),
        ),
      ).called(1);
    });

    test('readUserProfile returns saved profile when it exists', () async {
      const savedProfile = UserProfile(isPremium: true, isSoundEnabled: false);

      when(() => userProfileBox.get('current_user_profile'))
          .thenReturn(savedProfile);

      final result = await repository.readUserProfile();

      expect(result, equals(savedProfile));
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verifyNever(() => userProfileBox.isNotEmpty);
    });

    test('readUserProfile returns default profile when box is empty', () async {
      when(() => userProfileBox.get('current_user_profile')).thenReturn(null);
      when(() => userProfileBox.isNotEmpty).thenReturn(false);

      final result = await repository.readUserProfile();

      expect(
        result,
        equals(const UserProfile(isPremium: false, isSoundEnabled: true)),
      );
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verify(() => userProfileBox.isNotEmpty).called(1);
    });

    test('readUserProfile returns first value when key is missing', () async {
      const fallbackProfile = UserProfile(isPremium: false, isSoundEnabled: false);

      when(() => userProfileBox.get('current_user_profile')).thenReturn(null);
      when(() => userProfileBox.isNotEmpty).thenReturn(true);
      when(() => userProfileBox.values).thenReturn(<UserProfile>[fallbackProfile]);

      final result = await repository.readUserProfile();

      expect(result, equals(fallbackProfile));
      verify(() => userProfileBox.get('current_user_profile')).called(1);
      verify(() => userProfileBox.isNotEmpty).called(1);
      verify(() => userProfileBox.values).called(1);
    });

    test('saveUserProfile calls put with fixed key', () async {
      const userProfile = UserProfile(isPremium: true, isSoundEnabled: true);

      when(() => userProfileBox.put(any(), any())).thenAnswer((_) async {});

      await repository.saveUserProfile(userProfile);

      verify(() => userProfileBox.put('current_user_profile', userProfile))
          .called(1);
    });
  });
}
