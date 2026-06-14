import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';

class MockPersistenceRepository extends Mock implements IPersistenceRepository {}

class FakeLevelState extends Fake implements LevelState {}

class FakeUserProfile extends Fake implements UserProfile {}

void registerMemoryGameFallbacks() {
  registerFallbackValue(FakeLevelState());
  registerFallbackValue(FakeUserProfile());
}

void stubPersistenceRepository(MockPersistenceRepository repository) {
  when(() => repository.saveLevelState(any())).thenAnswer((_) async {});
  when(() => repository.readAllLevelStates()).thenAnswer((_) async => const []);
  when(() => repository.readLevelState(any())).thenAnswer((_) async => null);
  when(() => repository.readUserProfile()).thenAnswer(
    (_) async => const UserProfile(isPremium: false, isSoundEnabled: true),
  );
  when(() => repository.saveUserProfile(any())).thenAnswer((_) async {});
  when(() => repository.saveLevelStates(any())).thenAnswer((_) async {});
}
