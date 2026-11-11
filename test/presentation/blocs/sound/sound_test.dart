import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/data/platform/audioplayers_sound_effects.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/sound/game_sound.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_card_model.dart';
import 'package:toddler_logic/presentation/blocs/memory_game/memory_ladder_state.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_state.dart';
import 'package:toddler_logic/presentation/blocs/sound/game_sound_events.dart';
import 'package:toddler_logic/presentation/blocs/sound/sound_cubit.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/screens/shadow_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/memory_board.dart';
import 'package:toddler_logic/presentation/widgets/shadow_board.dart';

import '../../l10n_test_support.dart';
import '../../memory_game_test_support.dart';

class _FakeEffects implements ISoundEffects {
  final List<GameSound> played = [];

  @override
  Future<void> play(GameSound sound) async => played.add(sound);
}

/// HU-005: sonidos suaves y su interruptor.
void main() {
  setUpAll(registerMemoryGameFallbacks);

  group('which sound each change makes (R1, R2)', () {
    const card = MemoryCard(id: 0, assetPath: '🐶');
    MemoryLadderState memory(List<MemoryCard> cards, {MemoryRoundPhase phase = MemoryRoundPhase.playing}) =>
        MemoryLadderState(phase: phase, round: 1, cards: cards);
    final List<MemoryCard> closed = [card, card.copyWith(id: 1), card.copyWith(id: 2, assetPath: '🐱')];

    test('memory: a flip, a pair, the board and the badge; no sound for mistakes or the preview', () {
      final List<MemoryCard> oneUp = [closed[0].copyWith(isFaceUp: true), closed[1], closed[2]];
      final List<MemoryCard> pair = [
        closed[0].copyWith(isFaceUp: true, isMatched: true),
        closed[1].copyWith(isFaceUp: true, isMatched: true),
        closed[2],
      ];
      expect(GameSoundEvents.memory(memory(closed), memory(oneUp)), GameSound.flip);
      expect(GameSoundEvents.memory(memory(oneUp), memory(pair)), GameSound.match);
      expect(GameSoundEvents.memory(memory(oneUp), memory(closed)), isNull, reason: 'hiding two different cards');
      expect(
        GameSoundEvents.memory(memory(closed, phase: MemoryRoundPhase.previewing), memory(closed)),
        isNull,
        reason: 'the preview turns every card at once',
      );
      final List<MemoryCard> allMatched = [for (final c in closed) c.copyWith(isFaceUp: true, isMatched: true)];
      expect(GameSoundEvents.memory(memory(pair), memory(allMatched)), isNull, reason: 'the board sound comes next');
      expect(
        GameSoundEvents.memory(memory(allMatched), memory(allMatched, phase: MemoryRoundPhase.celebrating)),
        GameSound.complete,
      );
      expect(
        GameSoundEvents.memory(
          memory(allMatched),
          MemoryLadderState(phase: MemoryRoundPhase.celebrating, round: 1, cards: allMatched, badgeEarned: true),
        ),
        GameSound.badge,
      );
      expect(GameSoundEvents.memory(memory(closed), memory(closed, phase: MemoryRoundPhase.timeUp)), isNull);
    });

    test('shadows: placing an object, the board and the medal; a wrong shadow makes no sound', () {
      ShadowGameState shadows(Set<String> placed, {ShadowRoundPhase phase = ShadowRoundPhase.playing, int fails = 0}) =>
          ShadowGameState(phase: phase, round: 1, objects: const ['a', 'b'], shadows: const ['a', 'b'], placed: placed, fails: fails);

      expect(GameSoundEvents.shadows(shadows({}), shadows({'a'})), GameSound.match);
      expect(GameSoundEvents.shadows(shadows({}), shadows({}, fails: 1)), isNull);
      expect(GameSoundEvents.shadows(shadows({'a'}), shadows({'a', 'b'})), isNull, reason: 'the board sound comes next');
      expect(
        GameSoundEvents.shadows(shadows({'a', 'b'}), shadows({'a', 'b'}, phase: ShadowRoundPhase.celebrating)),
        GameSound.complete,
      );
      expect(
        GameSoundEvents.shadows(
          shadows({'a', 'b'}),
          const ShadowGameState(phase: ShadowRoundPhase.celebrating, round: 1, medalEarned: true),
        ),
        GameSound.badge,
      );
      expect(
        GameSoundEvents.shadows(shadows({'a'}), const ShadowGameState(phase: ShadowRoundPhase.introducing, round: 2)),
        isNull,
      );
    });
  });

  group('SoundCubit (R4, R7, P2)', () {
    late MockPersistenceRepository repository;
    late _FakeEffects effects;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
      effects = _FakeEffects();
    });

    test('is on by default and plays; turned off it stays silent and is saved', () async {
      final cubit = SoundCubit(repository: repository, effects: effects);
      await cubit.load();
      expect(cubit.state, isTrue);
      cubit.play(GameSound.flip);

      await cubit.setEnabled(false);
      cubit.play(GameSound.match);
      expect(effects.played, [GameSound.flip]);
      final saved = verify(() => repository.saveUserProfile(captureAny())).captured.single as UserProfile;
      expect(saved.isSoundEnabled, isFalse);
      await cubit.close();
    });

    test('reads a silenced app, and keeps going if the profile cannot be read or saved', () async {
      when(() => repository.readUserProfile())
          .thenAnswer((_) async => const UserProfile(isPremium: false, isSoundEnabled: false));
      final cubit = SoundCubit(repository: repository, effects: effects);
      await cubit.load();
      expect(cubit.state, isFalse);

      when(() => repository.readUserProfile()).thenThrow(StateError('disk'));
      await cubit.load();
      await cubit.setEnabled(true);
      expect(cubit.state, isTrue);
      await cubit.close();
    });

    test('with no saved profile, turning it off saves a new one', () async {
      when(() => repository.readUserProfile()).thenAnswer((_) async => null);
      final cubit = SoundCubit(repository: repository, effects: effects);
      await cubit.setEnabled(false);
      final saved = verify(() => repository.saveUserProfile(captureAny())).captured.single as UserProfile;
      expect(saved.isSoundEnabled, isFalse);
      await cubit.close();
    });
  });

  group('AudioplayersSoundEffects (R6, R7)', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    test('plays the bundled asset of each sound and swallows failures', () async {
      final played = <GameSound>[];
      await AudioplayersSoundEffects(playAsset: (sound) async => played.add(sound)).play(GameSound.complete);
      expect(played, [GameSound.complete]);
      expect(AudioplayersSoundEffects.assetOf(GameSound.badge), 'sounds/badge.wav');

      await AudioplayersSoundEffects(playAsset: (_) async => throw StateError('no audio')).play(GameSound.flip);
      // Sin el plugin (tests), tampoco falla.
      await AudioplayersSoundEffects().play(GameSound.flip);
    });
  });

  group('in the app', () {
    late MockPersistenceRepository repository;
    late _FakeEffects effects;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
      effects = _FakeEffects();
    });

    Widget withSound(Widget child) => RepositoryProvider<IPersistenceRepository>.value(
          value: repository,
          child: BlocProvider<SoundCubit>(
            create: (_) => SoundCubit(repository: repository, effects: effects),
            child: child,
          ),
        );

    testWidgets('the memory game sounds when a card turns', (tester) async {
      await tester.pumpWidget(localizedApp(
        home: withSound(MemoryGameScreen(random: Random(1), preview: Duration.zero)),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const ValueKey<String>('memory-card-0')));
      await tester.pump(const Duration(milliseconds: 450));
      expect(find.byType(MemoryBoard), findsOneWidget);
      expect(effects.played, [GameSound.flip]);
    });

    testWidgets('Shadows sounds when an object snaps into its shadow', (tester) async {
      await tester.pumpWidget(localizedApp(home: withSound(ShadowGameScreen(random: Random(1)))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();
      await tester.pump(ShadowBoard.introDuration + const Duration(milliseconds: 50));
      await tester.pump();
      final element = tester.element(find.byType(ShadowBoard));
      final String object = (element.widget as ShadowBoard).state.objects.first;
      (element.widget as ShadowBoard).onMatch(object, object);
      await tester.pump();
      expect(effects.played, [GameSound.match]);
    });

    testWidgets('the Parents zone switch silences the app right away', (tester) async {
      await tester.pumpWidget(localizedApp(home: withSound(const ParentsZoneScreen())));
      await tester.pump();
      final Finder toggle = find.byKey(const ValueKey<String>('parents-zone-sound-switch'));
      await tester.scrollUntilVisible(toggle, 200);
      await tester.ensureVisible(toggle);
      await tester.pumpAndSettle();
      expect(find.text('Sonido'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(toggle).value, isTrue);

      await tester.tap(toggle);
      await tester.pump();
      expect(tester.widget<SwitchListTile>(toggle).value, isFalse);
      expect(tester.element(toggle).read<SoundCubit>().state, isFalse);
    });
  });
}
