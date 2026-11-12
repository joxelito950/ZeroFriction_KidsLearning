import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/sound/game_sound.dart';
import 'package:toddler_logic/presentation/blocs/odd_one_out/odd_one_out_cubit.dart';
import 'package:toddler_logic/presentation/blocs/odd_one_out/odd_one_out_state.dart';
import 'package:toddler_logic/presentation/blocs/sound/game_sound_events.dart';
import 'package:toddler_logic/presentation/blocs/sound/sound_cubit.dart';
import 'package:toddler_logic/presentation/screens/odd_one_out_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

class _FakeEffects implements ISoundEffects {
  final List<GameSound> played = [];

  @override
  Future<void> play(GameSound sound) async => played.add(sound);
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute<void>(builder: (_) => OddOneOutScreen(random: Random(4)))),
            child: const Text('launcher'),
          ),
        ),
      );
}

/// HU-025, entrega 3: la pantalla de «¿Cuál es diferente?».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;
  late _FakeEffects effects;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    effects = _FakeEffects();
  });

  Future<void> pumpScreen(WidgetTester tester, {int level = 1, GameDifficulty round = GameDifficulty.normal}) async {
    when(() => repository.readGameProgress(GameId.oddOneOut))
        .thenAnswer((_) async => progressAt(level, round: round));
    await tester.pumpWidget(RepositoryProvider<IPersistenceRepository>.value(
      value: repository,
      child: BlocProvider<SoundCubit>(
        create: (_) => SoundCubit(repository: repository, effects: effects),
        child: localizedApp(home: const _Launcher()),
      ),
    ));
    await tester.tap(find.text('launcher'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
  }

  OddOneOutState stateOf(WidgetTester tester) =>
      tester.element(find.byType(GestureHint)).read<OddOneOutCubit>().state;
  Finder card(int index) => find.byKey(ValueKey<String>('odd-object-$index'));

  testWidgets('shows the title, icon, 5 level dots and one card per object', (tester) async {
    await pumpScreen(tester, level: 2);
    expect(find.text('¿Cuál es diferente?'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('odd-one-out-game-icon')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('memory-level-dot-5-pending')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('memory-time-bar')), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      expect(card(index), findsOneWidget);
    }
  });

  testWidgets('a wrong tap counts and the right one jumps, sounds and deals the next board (R3)', (tester) async {
    await pumpScreen(tester, level: 2);
    final int odd = stateOf(tester).oddIndex;
    await tester.tap(card(odd == 0 ? 1 : 0));
    await tester.pump(const Duration(milliseconds: 500));
    expect(stateOf(tester).fails, 1);
    expect(effects.played, isEmpty, reason: 'mistakes never sound');

    await tester.tap(card(odd));
    await tester.pump();
    expect(stateOf(tester).phase, OddPhase.solved);
    expect(effects.played, [GameSound.match]);
    await tester.pump(OddOneOutCubit.solvedDuration);
    await tester.pump(const Duration(milliseconds: 400));
    expect(stateOf(tester).board, 1);
  });

  testWidgets('three right boards celebrate the level', (tester) async {
    await pumpScreen(tester, level: 2);
    for (var board = 0; board < 3; board++) {
      await tester.tap(card(stateOf(tester).oddIndex));
      await tester.pump(OddOneOutCubit.solvedDuration);
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.byKey(const ValueKey<String>('memory-celebration')), findsOneWidget);
    await tester.pump(OddOneOutCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 400));
    expect(stateOf(tester).level, 3);
  });

  testWidgets('the tutorial ends with the invitation to play (HU-037 R9)', (tester) async {
    await pumpScreen(tester);
    for (var board = 0; board < 3; board++) {
      await tester.tap(card(stateOf(tester).oddIndex));
      await tester.pump(OddOneOutCubit.solvedDuration);
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.byKey(const ValueKey<String>('play-invitation')), findsOneWidget);
    await tester.pump(OddOneOutCubit.invitationDuration);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('the screen reader chooses an object by its picture (R6)', (tester) async {
    await pumpScreen(tester, level: 2);
    final int odd = stateOf(tester).oddIndex;
    final Semantics semantics = tester.widget<Semantics>(
      find.descendant(of: card(odd), matching: find.byType(Semantics), matchRoot: true).first,
    );
    expect(semantics.properties.label, 'Dibujo ${stateOf(tester).objects[odd]}');
    semantics.properties.onTap!();
    await tester.pump();
    expect(stateOf(tester).phase, OddPhase.solved);
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('time up shows a helpful notice; the hand shows the odd one when nobody touches', (tester) async {
    await pumpScreen(tester, level: 3);
    await tester.pump(GestureHint.defaultFirstDelay);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey<String>('gesture-hint-hand')), findsOneWidget);

    final int odd = stateOf(tester).oddIndex;
    await tester.tap(card(odd == 0 ? 1 : 0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 5));
    expect(stateOf(tester).elapsed, Duration.zero);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 36));
    expect(find.text('¡Se acabó el tiempo! Probemos con menos dibujos.'), findsOneWidget);
    await tester.pump(OddOneOutCubit.timeUpDuration);
    await tester.pump(const Duration(milliseconds: 400));
  });

  testWidgets('the help hop only in Easy and Normal; Premium removes nothing for the child', (tester) async {
    when(() => repository.readUserProfile()).thenAnswer((_) async => const UserProfile(isPremium: true, isSoundEnabled: true));
    await pumpScreen(tester, level: 2, round: GameDifficulty.impossible);
    expect(stateOf(tester).gameRound, GameDifficulty.impossible);
    expect(stateOf(tester).timeLimit, const Duration(seconds: 25));
  });

  testWidgets('a board only counts as in progress once touched (HU-009 R4)', (tester) async {
    expect(OddOneOutScreen.boardInProgress(const OddOneOutState(phase: OddPhase.playing)), isFalse);
    expect(OddOneOutScreen.boardInProgress(const OddOneOutState(phase: OddPhase.playing, fails: 1)), isTrue);
    expect(OddOneOutScreen.boardInProgress(const OddOneOutState(phase: OddPhase.solved)), isTrue);
    expect(OddOneOutScreen.boardInProgress(const OddOneOutState()), isFalse);
    expect(GameSoundEvents.oddOneOut(const OddOneOutState(phase: OddPhase.playing),
        const OddOneOutState(phase: OddPhase.celebrating, medal: GameDifficulty.easy)), GameSound.badge);
    expect(GameSoundEvents.oddOneOut(const OddOneOutState(phase: OddPhase.solved),
        const OddOneOutState(phase: OddPhase.celebrating)), GameSound.complete);
  });

  testWidgets('two «back» presses leave the game (D-025)', (tester) async {
    await pumpScreen(tester);
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byType(OddOneOutScreen), findsNothing);
  });
}
