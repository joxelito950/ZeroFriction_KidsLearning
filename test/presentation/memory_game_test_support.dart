import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/progress/round_ladder.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/progress/level_record.dart';
import 'package:toddler_logic/domain/settings/access_policy.dart';

class MockPersistenceRepository extends Mock implements IPersistenceRepository {}

class FakeLevelState extends Fake implements LevelState {}

class FakeUserProfile extends Fake implements UserProfile {}

void registerMemoryGameFallbacks() {
  // Los tests prueban las reglas de pago tal como serán (D-040 las abre todas
  // durante la prueba cerrada; access_policy_test lo comprueba).
  AccessPolicy.everythingFree = false;
  registerFallbackValue(FakeLevelState());
  registerFallbackValue(FakeUserProfile());
  registerFallbackValue(ParentalSettings.initial);
  registerFallbackValue(GameProgress.initial());
  registerFallbackValue(GameId.memory);
  registerFallbackValue((ParentalSettings current) => current);
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
  when(() => repository.readGameProgress(any())).thenAnswer((_) async => GameProgress.initial());
  when(() => repository.saveGameProgress(any(), any())).thenAnswer((_) async {});
  when(() => repository.readParentalSettings()).thenAnswer((_) async => ParentalSettings.initial);
  when(() => repository.saveParentalSettings(any())).thenAnswer((_) async {});
  // Como el repositorio real: lee lo guardado, aplica el cambio y lo guarda.
  when(() => repository.updateParentalSettings(any())).thenAnswer((invocation) async {
    final update = invocation.positionalArguments.single as ParentalSettings Function(ParentalSettings);
    final ParentalSettings next = update(await repository.readParentalSettings());
    await repository.saveParentalSettings(next);
    return next;
  });
}

/// Progreso con rondas para los tests (HU-037): por defecto, en Normal, la
/// ronda que equivale al juego de antes de las rondas.
GameProgress progressAt(
  int level, {
  GameDifficulty round = GameDifficulty.normal,
  Set<GameDifficulty> medals = const {},
  Map<RoundLevel, LevelRecord> records = const {},
  DateTime? lastPlayedAt,
  int tutorialFalls = 0,
}) =>
    GameProgress(
      position: RoundPosition(round: round, level: level, tutorialFalls: tutorialFalls),
      medals: medals,
      records: records,
      lastPlayedAt: lastPlayedAt,
    );

