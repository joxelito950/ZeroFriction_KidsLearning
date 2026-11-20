import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/data/local/models/parental_settings_hive_model.dart';
import 'package:toddler_logic/domain/entities/parental_settings.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/settings/how_to_play.dart';
import 'package:toddler_logic/domain/shadows/shadow_ladder.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/how_to_play/how_to_play_cubit.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/shadow_game/shadow_game_state.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_state.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/screens/shadow_game_screen.dart';
import 'package:toddler_logic/presentation/screens/vehicle_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';
import 'package:toddler_logic/presentation/widgets/parents_how_to_play_page.dart';
import 'package:toddler_logic/presentation/widgets/shadow_board.dart';
import 'package:toddler_logic/presentation/widgets/vehicle_board_view.dart';

import 'l10n_test_support.dart';
import 'memory_game_test_support.dart';

/// HU-039 (tocar, arrastrar o ambas) y HU-031 (mano dominante).
void main() {
  setUpAll(registerMemoryGameFallbacks);

  final AppLocalizations l10n = lookupAppLocalizations(testLocale);
  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  void storeHowToPlay(MoveMode mode, {PlayingHand hand = PlayingHand.right}) {
    when(() => repository.readParentalSettings())
        .thenAnswer((_) async => ParentalSettings(moveMode: mode, playingHand: hand));
  }

  group('domain and storage', () {
    test('drag, tap or both; unknown names fall back to the defaults', () {
      expect(MoveMode.drag.allowsDrag && !MoveMode.drag.allowsTap, isTrue);
      expect(!MoveMode.tap.allowsDrag && MoveMode.tap.allowsTap, isTrue);
      expect(MoveMode.both.allowsDrag && MoveMode.both.allowsTap, isTrue);
      expect(MoveMode.fromName('tap'), MoveMode.tap);
      expect(MoveMode.fromName(null), MoveMode.both, reason: 'P1: Both by default');
      expect(MoveMode.fromName('other'), MoveMode.both);
      expect(PlayingHand.fromName('left'), PlayingHand.left);
      expect(PlayingHand.fromName(null), PlayingHand.right);
      expect(ParentalSettings.initial.moveMode, MoveMode.both);
      expect(ParentalSettings.initial.playingHand, PlayingHand.right);
    });

    test('Hive fields 12 and 13 keep both settings; old data reads as Both and right', () {
      final settings = ParentalSettings().withMoveMode(MoveMode.tap).withPlayingHand(PlayingHand.left);
      final model = ParentalSettingsHiveModel.fromEntity(settings);
      expect(model.moveMode, 'tap');
      expect(model.playingHand, 'left');
      expect(model.toEntity(), settings);
      expect(settings == ParentalSettings(), isFalse);
      expect(settings.hashCode, ParentalSettings(moveMode: MoveMode.tap, playingHand: PlayingHand.left).hashCode);
      expect(const ParentalSettingsHiveModel().toEntity().moveMode, MoveMode.both);
      expect(const ParentalSettingsHiveModel().toEntity().playingHand, PlayingHand.right);
    });

    test('the cubit loads, saves only its two fields, and survives failures', () async {
      storeHowToPlay(MoveMode.drag, hand: PlayingHand.left);
      final cubit = HowToPlayCubit(repository: repository);
      await cubit.load();
      expect(cubit.state, const HowToPlay(moveMode: MoveMode.drag, hand: PlayingHand.left));
      expect(cubit.state.leftHanded, isTrue);
      expect(cubit.state.hashCode, const HowToPlay(moveMode: MoveMode.drag, hand: PlayingHand.left).hashCode);

      await cubit.save(const HowToPlay(moveMode: MoveMode.tap));
      final saved = verify(() => repository.saveParentalSettings(captureAny())).captured.last as ParentalSettings;
      expect(saved.moveMode, MoveMode.tap);
      expect(saved.playingHand, PlayingHand.right);

      when(() => repository.readParentalSettings()).thenThrow(StateError('disk'));
      when(() => repository.updateParentalSettings(any())).thenThrow(StateError('disk'));
      final broken = HowToPlayCubit(repository: repository);
      await broken.load();
      expect(broken.state, const HowToPlay());
      await broken.save(const HowToPlay(hand: PlayingHand.left));
      expect(broken.state.leftHanded, isTrue, reason: 'applies even if it cannot be saved');
      await cubit.close();
      await broken.close();
    });
  });

  group('Shadows (HU-039 §3.2, HU-031 R1)', () {
    const Size portrait = Size(411, 914);
    const Size landscape = Size(914, 411);

    Future<ShadowGameCubit> pumpShadows(WidgetTester tester, {Size size = portrait}) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      when(() => repository.readGameProgress(GameId.shadows))
          .thenAnswer((_) async => progressAt(3, round: GameDifficulty.bronze));
      when(() => repository.readUserProfile())
          .thenAnswer((_) async => const UserProfile(isPremium: false, isSoundEnabled: true));
      await tester.pumpWidget(RepositoryProvider<IPersistenceRepository>.value(
        value: repository,
        child: localizedApp(repository: repository, home: ShadowGameScreen(random: Random(7))),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(ShadowBoard.introDuration + const Duration(milliseconds: 50));
      await tester.pump();
      return tester.element(find.byType(ShadowBoard)).read<ShadowGameCubit>();
    }

    Finder object(String symbol) => find.byKey(ValueKey<String>('shadow-object-$symbol'));
    Finder shadow(String symbol) => find.byKey(ValueKey<String>('shadow-target-$symbol'));

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(ShadowBoard.flightDuration + const Duration(milliseconds: 50));
    }

    testWidgets('with Tap, tapping the object and then its shadow places it; dragging does nothing', (tester) async {
      storeHowToPlay(MoveMode.tap);
      final cubit = await pumpShadows(tester);
      final ShadowGameState state = cubit.state;
      final String first = state.objects.first;

      await tester.dragFrom(
          tester.getCenter(object(first)), tester.getCenter(shadow(first)) - tester.getCenter(object(first)));
      await settle(tester);
      expect(cubit.state.placed, isEmpty, reason: 'drag is off');

      await tester.tap(object(first));
      await tester.pump();
      await tester.tap(object(first));
      await tester.pump();
      await tester.tap(shadow(first));
      await settle(tester);
      expect(cubit.state.placed, isEmpty, reason: 'tapping it again let it go');

      await tester.tap(object(first));
      await tester.pump();
      await tester.tap(shadow(first));
      await settle(tester);
      expect(cubit.state.placed, contains(first));
    });

    testWidgets('a wrong shadow counts as a mistake and the object goes back (R4)', (tester) async {
      storeHowToPlay(MoveMode.both);
      final cubit = await pumpShadows(tester);
      final String first = cubit.state.objects.first;
      final String other = cubit.state.shadows.firstWhere((s) => s != first);
      await tester.tap(object(first));
      await tester.pump();
      await tester.tap(shadow(other));
      await settle(tester);
      expect(cubit.state.fails, 1);
      expect(cubit.state.placed, isEmpty);
      expect(object(first), findsOneWidget);
    });

    testWidgets('with Drag, tapping does not select (criterion 1)', (tester) async {
      storeHowToPlay(MoveMode.drag);
      final cubit = await pumpShadows(tester);
      final String first = cubit.state.objects.first;
      await tester.tap(object(first));
      await tester.pump();
      await tester.tap(shadow(first));
      await settle(tester);
      expect(cubit.state.placed, isEmpty);
    });

    testWidgets('left hand in landscape: the shadows go to the right; in portrait, still on top (HU-031 R1)',
        (tester) async {
      storeHowToPlay(MoveMode.both, hand: PlayingHand.left);
      await pumpShadows(tester, size: landscape);
      final double shadows = tester.getCenter(find.byKey(const ValueKey<String>('shadow-zone-shadows'))).dx;
      final double tray = tester.getCenter(find.byKey(const ValueKey<String>('shadow-zone-tray'))).dx;
      expect(shadows, greaterThan(tray));
    });

    test('the geometry mirrors only in landscape', () {
      ShadowBoardGeometry geometry(Size size, {required bool left}) => ShadowBoardGeometry.compute(
            size: size,
            layout: ShadowLayout.shadowsFirst,
            shadows: const ['🐶', '🐱'],
            objects: const ['🐶', '🐱'],
            devicePixelRatio: 2,
            leftHanded: left,
          );
      expect(geometry(landscape, left: true).shadowZone.left, greaterThan(0));
      expect(geometry(landscape, left: false).shadowZone.left, 0);
      expect(geometry(portrait, left: true).shadowZone.top, 0);
    });
  });

  group('«A su sitio» (HU-039 §3.2, HU-031)', () {
    Future<VehicleGameCubit> pumpVehicles(WidgetTester tester, {Size size = const Size(411, 914)}) async {
      tester.view.physicalSize = size * 2;
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
      when(() => repository.readGameProgress(GameId.vehicles))
          .thenAnswer((_) async => progressAt(3, round: GameDifficulty.bronze));
      when(() => repository.readUserProfile())
          .thenAnswer((_) async => const UserProfile(isPremium: false, isSoundEnabled: true));
      await tester.pumpWidget(RepositoryProvider<IPersistenceRepository>.value(
        value: repository,
        child: localizedApp(repository: repository, home: VehicleGameScreen(random: Random(3), christmas: (_) => false)),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      return tester.element(find.byType(VehicleBoardView)).read<VehicleGameCubit>();
    }

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(VehicleBoardView.flightDuration + const Duration(milliseconds: 50));
    }

    testWidgets('with Tap, the vehicle and then its place; a wrong place is a mistake', (tester) async {
      storeHowToPlay(MoveMode.tap);
      final cubit = await pumpVehicles(tester);
      final VehicleGameState state = cubit.state;
      final vehicle = state.vehicles.first;
      final place = state.board!.targetOf(vehicle);
      final wrong = state.board!.places.firstWhere((p) => p != place);
      Finder tray(String name) => find.byKey(ValueKey<String>('vehicle-tray-$name'));
      Finder at(String name) => find.byKey(ValueKey<String>('vehicle-place-$name'));

      await tester.tap(tray(vehicle.name));
      await tester.pump();
      await tester.tap(at(wrong.name));
      await settle(tester);
      expect(cubit.state.fails, 1);

      await tester.tap(tray(vehicle.name));
      await tester.pump();
      await tester.tap(at(place.name));
      await settle(tester);
      expect(cubit.state.placed, contains(vehicle));
    });

    testWidgets('left hand in landscape: the places go to the right', (tester) async {
      storeHowToPlay(MoveMode.both, hand: PlayingHand.left);
      await pumpVehicles(tester, size: const Size(914, 411));
      final double places = tester.getCenter(find.byKey(const ValueKey<String>('vehicle-zone-places'))).dx;
      final double tray = tester.getCenter(find.byKey(const ValueKey<String>('vehicle-zone-tray'))).dx;
      expect(places, greaterThan(tray));
    });
  });

  group('guiding hand (HU-031 R3, HU-039 P3)', () {
    test('tap then tap: the fingertip taps the object, then travels to its place', () {
      const Offset from = Offset(100, 100);
      const Offset to = Offset(300, 100);
      HandPose at(double t, {bool left = false}) =>
          handPoseAt(t, gesture: HintGesture.tapThenTap, from: from, to: to, leftHanded: left);
      expect(at(0.4).fingertip, from);
      expect(at(0.4).ripple, greaterThan(0));
      expect(at(0.75).fingertip, to);
      expect(at(0.75).ripple, greaterThan(0));
      expect(at(0.55).ripple, 0);
      expect(at(0.1).fingertip.dx, greaterThan(from.dx), reason: 'a right hand comes from the right');
      expect(at(0.1, left: true).fingertip.dx, lessThan(from.dx), reason: 'a left hand comes from the left');
      expect(handPoseAt(0.2, gesture: HintGesture.tap, from: from, to: from, leftHanded: true).fingertip.dx,
          lessThan(from.dx));
      expect(GestureHint.leftFingertipAnchor.dx, closeTo(1 - GestureHint.fingertipAnchor.dx, 1e-9));
    });

    testWidgets(
        'a left-handed child sees a mirrored hand whose fingertip still lands on the target; Tap teaches two taps',
        (tester) async {
      storeHowToPlay(MoveMode.tap, hand: PlayingHand.left);
      final GlobalKey target = GlobalKey();
      final GlobalKey place = GlobalKey();
      await tester.pumpWidget(localizedApp(
        repository: repository,
        home: Scaffold(
          body: GestureHint(
            boardId: 1,
            target: target,
            dragTo: place,
            gesture: HintGesture.drag,
            firstDelay: const Duration(milliseconds: 10),
            child: Stack(children: [
              Positioned(left: 50, top: 300, child: SizedBox(key: target, width: 60, height: 60)),
              Positioned(left: 250, top: 300, child: SizedBox(key: place, width: 60, height: 60)),
            ]),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(GestureHint.cycle * 0.4);
      final Iterable<Transform> transforms = tester.widgetList<Transform>(
        find.ancestor(of: find.byKey(const ValueKey<String>('gesture-hint-hand')), matching: find.byType(Transform)),
      );
      expect(transforms.any((t) => t.transform.storage[0] == -1), isTrue, reason: 'flipped horizontally');
      expect(find.byKey(const ValueKey<String>('gesture-hint-ghost')), findsNothing,
          reason: 'no drag ghost when tapping');
      expect(find.byKey(const ValueKey<String>('gesture-hint-ripple')), findsOneWidget);
    });
  });

  group('parents zone (HU-039 §3.1)', () {
    testWidgets('the «How they play» row opens the page; saving applies to every game at once', (tester) async {
      await pumpSettingPage(tester, const ParentsZoneScreen(), repository: repository);
      final Finder row = find.byKey(const ValueKey<String>('parents-row-how-to-play'));
      await tester.scrollUntilVisible(row, 200);
      expect(find.text(ParentsHowToPlayTexts.summary(l10n, const HowToPlay())), findsOneWidget);
      await tester.tap(row);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text(l10n.parentsHowToPlayMoveHelp), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('move-mode-tap')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('playing-hand-left')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey<String>('parents-setting-save')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final HowToPlayCubit cubit = tester.element(find.byType(ParentsZoneScreen)).read<HowToPlayCubit>();
      expect(cubit.state, const HowToPlay(moveMode: MoveMode.tap, hand: PlayingHand.left));
      expect(find.text(ParentsHowToPlayTexts.summary(l10n, cubit.state)), findsOneWidget);
      expect(ParentsHowToPlayTexts.mode(l10n, MoveMode.drag), l10n.moveModeDrag);
      expect(ParentsHowToPlayTexts.mode(l10n, MoveMode.both), l10n.moveModeBoth);
    });
  });
}
