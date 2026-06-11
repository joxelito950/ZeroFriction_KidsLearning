import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:toddler_logic/domain/entities/level_state.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_game_cubit.dart';

class _MockPersistenceRepository extends Mock implements IPersistenceRepository {}

class _FakeLevelState extends Fake implements LevelState {}

class _FakeUserProfile extends Fake implements UserProfile {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLevelState());
    registerFallbackValue(_FakeUserProfile());
  });

  group('MemoryGameCubit', () {
    late _MockPersistenceRepository repository;
    late MemoryGameCubit cubit;

    setUp(() {
      repository = _MockPersistenceRepository();

      when(() => repository.saveLevelState(any())).thenAnswer((_) async {});
      when(() => repository.readAllLevelStates()).thenAnswer((_) async => const []);
      when(() => repository.readLevelState(any())).thenAnswer((_) async => null);
      when(() => repository.readUserProfile()).thenAnswer(
        (_) async => const UserProfile(isPremium: false, isSoundEnabled: true),
      );
      when(() => repository.saveUserProfile(any())).thenAnswer((_) async {});
      when(() => repository.saveLevelStates(any())).thenAnswer((_) async {});

      cubit = MemoryGameCubit(
        persistenceRepository: repository,
        levelId: 'level_memory_1',
      );
    });

    tearDown(() async {
      await cubit.close();
    });

    test('startGame creates paired cards and resets game flags', () {
      cubit.startGame(const ['a.png', 'b.png']);

      final state = cubit.state;
      expect(state.cards.length, 4);
      expect(state.moves, 0);
      expect(state.isProcessing, isFalse);
      expect(state.isCompleted, isFalse);
      expect(state.firstSelectedCardIndex, isNull);

      final pairCountByAsset = <String, int>{};
      for (final card in state.cards) {
        pairCountByAsset.update(card.assetPath, (value) => value + 1, ifAbsent: () => 1);
        expect(card.isFaceUp, isFalse);
        expect(card.isMatched, isFalse);
      }

      expect(pairCountByAsset['a.png'], 2);
      expect(pairCountByAsset['b.png'], 2);
    });

    test('flipCard first selection turns card face up and stores selected index', () async {
      cubit.startGame(const ['a.png', 'b.png']);

      await cubit.flipCard(0);

      expect(cubit.state.cards[0].isFaceUp, isTrue);
      expect(cubit.state.firstSelectedCardIndex, 0);
      expect(cubit.state.moves, 0);
      verifyNever(() => repository.saveLevelState(any()));
    });

    test('flipCard ignores out-of-range index and keeps state unchanged', () async {
      cubit.startGame(const ['a.png']);
      final initialState = cubit.state;

      await cubit.flipCard(-1);
      await cubit.flipCard(999);

      expect(cubit.state, same(initialState));
      verifyNever(() => repository.saveLevelState(any()));
    });

    test('matching second card increments moves, marks pair, and persists when game completes', () async {
      cubit.startGame(const ['a.png']);
      final firstIndex = cubit.state.cards.indexWhere((card) => card.assetPath == 'a.png');
      final secondIndex = cubit.state.cards.indexWhere(
        (card) => card.assetPath == 'a.png' && card.id != cubit.state.cards[firstIndex].id,
      );

      await cubit.flipCard(firstIndex);
      await cubit.flipCard(secondIndex);

      final state = cubit.state;
      expect(state.moves, 1);
      expect(state.firstSelectedCardIndex, isNull);
      expect(state.isProcessing, isFalse);
      expect(state.isCompleted, isTrue);
      expect(state.cards[firstIndex].isMatched, isTrue);
      expect(state.cards[secondIndex].isMatched, isTrue);

      verify(
        () => repository.saveLevelState(
          any(
            that: predicate<LevelState>((value) =>
                value.levelId == 'level_memory_1' &&
                value.isCompleted &&
                value.stars == 3),
          ),
        ),
      ).called(1);
    });

    test('non-matching second card increments moves and flips both cards back down', () async {
      cubit.startGame(const ['a.png', 'b.png']);

      final firstIndex = cubit.state.cards.indexWhere((card) => card.assetPath == 'a.png');
      final secondIndex = cubit.state.cards.indexWhere((card) => card.assetPath == 'b.png');

      await cubit.flipCard(firstIndex);
      await cubit.flipCard(secondIndex);

      final state = cubit.state;
      expect(state.moves, 1);
      expect(state.isProcessing, isFalse);
      expect(state.firstSelectedCardIndex, isNull);
      expect(state.cards[firstIndex].isFaceUp, isFalse);
      expect(state.cards[secondIndex].isFaceUp, isFalse);
      expect(state.cards[firstIndex].isMatched, isFalse);
      expect(state.cards[secondIndex].isMatched, isFalse);
      expect(state.isCompleted, isFalse);
      verifyNever(() => repository.saveLevelState(any()));
    });
  });
}
