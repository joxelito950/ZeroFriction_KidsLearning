import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/domain/vehicles/vehicle_catalog.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_cubit.dart';
import 'package:toddler_logic/presentation/blocs/vehicle_game/vehicle_game_state.dart';
import 'package:toddler_logic/presentation/screens/vehicle_game_screen.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';
import 'package:toddler_logic/presentation/widgets/memory_time_bar.dart';
import 'package:toddler_logic/presentation/widgets/vehicle_board_view.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

class _Launcher extends StatelessWidget {
  const _Launcher({this.christmas = false});

  final bool christmas;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => VehicleGameScreen(random: Random(7), christmas: (_) => christmas)),
            ),
            child: const Text('launcher'),
          ),
        ),
      );
}

/// HU-052, entrega 2: la pantalla de «A su sitio».
void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  const Size portrait = Size(411, 914);
  const Size landscape = Size(914, 411);

  Future<void> pumpScreen(
    WidgetTester tester, {
    int level = 4,
    GameDifficulty round = GameDifficulty.bronze,
    Size size = portrait,
    Locale locale = testLocale,
    bool christmas = false,
  }) async {
    tester.view.physicalSize = size * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    when(() => repository.readGameProgress(GameId.vehicles)).thenAnswer((_) async => progressAt(level, round: round));
    await tester.pumpWidget(
      RepositoryProvider<IPersistenceRepository>.value(
        value: repository,
        child: localizedApp(locale: locale, home: _Launcher(christmas: christmas)),
      ),
    );
    await tester.tap(find.text('launcher'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  VehicleGameCubit cubitOf(WidgetTester tester) =>
      tester.element(find.byType(VehicleBoardView)).read<VehicleGameCubit>();
  VehicleGameState stateOf(WidgetTester tester) => cubitOf(tester).state;
  Offset centerOf(WidgetTester tester, String key) => tester.getCenter(find.byKey(ValueKey<String>(key)));

  Future<void> dragTo(WidgetTester tester, Vehicle vehicle, Place place) async {
    final Offset from = centerOf(tester, 'vehicle-tray-${vehicle.name}');
    await tester.dragFrom(from, centerOf(tester, 'vehicle-place-${place.name}') - from);
    await tester.pump();
    await tester.pump(VehicleBoardView.flightDuration + const Duration(milliseconds: 50));
  }

  testWidgets('shows the title, the instructions, the places and the tray', (tester) async {
    await pumpScreen(tester);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    expect(find.text(l10n.vehiclesGameTitle), findsOneWidget);
    expect(find.text(l10n.vehiclesGameInstructions), findsOneWidget);
    final VehicleGameState state = stateOf(tester);
    for (final Place place in state.board!.places) {
      expect(find.byKey(ValueKey<String>('vehicle-place-${place.name}')), findsOneWidget);
    }
    for (final Vehicle vehicle in state.vehicles) {
      expect(find.byKey(ValueKey<String>('vehicle-tray-${vehicle.name}')), findsOneWidget);
    }
    expect(find.byType(MemoryTimeBar), findsNothing, reason: 'bronze has no time');
    // Los sitios, arriba en vertical.
    expect(tester.getCenter(find.byKey(const ValueKey<String>('vehicle-zone-places'))).dy,
        lessThan(tester.getCenter(find.byKey(const ValueKey<String>('vehicle-zone-tray'))).dy));
  });

  testWidgets('a vehicle dropped on its place stays there; on another place it goes back and counts a mistake',
      (tester) async {
    await pumpScreen(tester);
    final VehicleGameState state = stateOf(tester);
    final Vehicle vehicle = state.vehicles.first;
    final Place wrong = state.board!.places.firstWhere((place) => !state.board!.accepts(place, vehicle));

    await dragTo(tester, vehicle, wrong);
    expect(stateOf(tester).fails, 1);
    expect(find.byKey(ValueKey<String>('vehicle-tray-${vehicle.name}')), findsOneWidget);

    final TestGesture gesture = await tester.startGesture(centerOf(tester, 'vehicle-tray-${vehicle.name}'));
    await gesture.moveBy(const Offset(0, -30));
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('vehicle-dragged')), findsOneWidget);
    final Place target = state.board!.targetOf(vehicle);
    await gesture.moveTo(centerOf(tester, 'vehicle-place-${target.name}'));
    await tester.pump();
    expect(find.byKey(ValueKey<String>('vehicle-almost-${target.name}')), findsOneWidget,
        reason: 'the place lights up when the vehicle would snap');
    await gesture.up();
    await tester.pump();
    expect(find.byKey(const ValueKey<String>('vehicle-flying')), findsOneWidget);
    await tester.pump(VehicleBoardView.flightDuration + const Duration(milliseconds: 50));
    expect(find.byKey(ValueKey<String>('vehicle-placed-${vehicle.name}')), findsOneWidget);
    expect(find.byKey(ValueKey<String>('vehicle-tray-${vehicle.name}')), findsNothing);
  });

  testWidgets('with the screen reader: choose a vehicle, then its place', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpScreen(tester);
    final AppLocalizations l10n = lookupAppLocalizations(testLocale);
    final VehicleGameState state = stateOf(tester);
    final Vehicle vehicle = state.vehicles.first;
    final Place target = state.board!.targetOf(vehicle);
    final String vehicleName = l10n.vehiclesVehicleName(vehicle.name);
    final String placeName = l10n.vehiclesPlaceName(target.name);

    expect(find.bySemanticsLabel(l10n.vehiclesVehicleSemantics(vehicleName)), findsOneWidget);
    tester.semantics.tap(find.semantics.byLabel(l10n.vehiclesVehicleSemantics(vehicleName)));
    await tester.pump();
    tester.semantics.tap(find.semantics.byLabel(placeName));
    await tester.pump();
    expect(stateOf(tester).placed, {vehicle});
    expect(find.bySemanticsLabel(RegExp('^${RegExp.escape(placeName)}: .*${RegExp.escape(vehicleName)}')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('every vehicle and place has its own name in each language', (tester) async {
    for (final Locale locale in AppLocalizations.supportedLocales) {
      final AppLocalizations l10n = lookupAppLocalizations(locale);
      final Set<String> vehicles = {for (final Vehicle vehicle in Vehicle.values) l10n.vehiclesVehicleName(vehicle.name)};
      expect(vehicles, hasLength(Vehicle.values.length), reason: locale.languageCode);
      expect(vehicles, isNot(contains(l10n.vehiclesVehicleName('unknown'))), reason: locale.languageCode);
      for (final Place place in Place.values) {
        expect(l10n.vehiclesPlaceName(place.name), isNot(l10n.vehiclesPlaceName('unknown')),
            reason: '${locale.languageCode} ${place.name}');
      }
    }
  });

  testWidgets('placing every vehicle celebrates and moves to the next level', (tester) async {
    await pumpScreen(tester);
    final VehicleGameState state = stateOf(tester);
    for (final Vehicle vehicle in state.vehicles) {
      await dragTo(tester, vehicle, state.board!.targetOf(vehicle));
    }
    expect(stateOf(tester).phase, VehiclePhase.celebrating);
    await tester.pump(VehicleGameCubit.celebrationDuration);
    await tester.pump(const Duration(milliseconds: 500));
    expect(stateOf(tester).level, 5);
  });

  testWidgets('from gold the time bar shows and running out shows a helpful notice', (tester) async {
    await pumpScreen(tester, round: GameDifficulty.gold);
    expect(find.byType(MemoryTimeBar), findsOneWidget);
    final Vehicle vehicle = stateOf(tester).vehicles.first;
    cubitOf(tester).grab(vehicle);
    await tester.pump(stateOf(tester).timeLimit! + const Duration(milliseconds: 200));
    expect(stateOf(tester).phase, VehiclePhase.timeUp);
    expect(find.text(lookupAppLocalizations(testLocale).vehiclesTimeUpFewerVehicles), findsOneWidget);
    await tester.pump(VehicleGameCubit.timeUpDuration);
    await tester.pump(const Duration(milliseconds: 500));
  });

  testWidgets('the hand shows the drag after a few seconds without touching', (tester) async {
    await pumpScreen(tester);
    await tester.pump(GestureHint.defaultFirstDelay);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey<String>('gesture-hint-hand')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('gesture-hint-ghost')), findsOneWidget);
  });

  testWidgets('a board only counts as in progress once touched (HU-009 R4)', (tester) async {
    await pumpScreen(tester);
    final VehicleGameState state = stateOf(tester);
    expect(VehicleGameScreen.boardInProgress(state), isFalse);
    expect(VehicleGameScreen.boardInProgress(state.copyWith(fails: 1)), isTrue);
    expect(VehicleGameScreen.boardInProgress(state.copyWith(phase: VehiclePhase.celebrating)), isTrue);
    expect(VehicleGameScreen.boardInProgress(const VehicleGameState()), isFalse);
  });

  testWidgets('at Christmas the sled is in the tray', (tester) async {
    await pumpScreen(tester, christmas: true);
    expect(find.byKey(const ValueKey<String>('vehicle-tray-sled')), findsOneWidget);
  });

  // HU-052 criterio 4: el tablero más grande cabe en el teléfono compacto, en
  // vertical y en horizontal, en todos los idiomas.
  for (final Locale locale in AppLocalizations.supportedLocales) {
    for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
      testWidgets('level 8 fits in compact $name (${locale.languageCode})', (tester) async {
        await pumpScreen(tester, level: 8, round: GameDifficulty.gold, size: size, locale: locale);
        final Rect screen = Offset.zero & size;
        final VehicleGameState state = stateOf(tester);
        for (final Place place in state.board!.places) {
          final Rect rect = tester.getRect(find.byKey(ValueKey<String>('vehicle-place-${place.name}')));
          expect(screen.contains(rect.topLeft) && screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue,
              reason: place.name);
          expect(rect.width, greaterThan(48), reason: '${place.name} is big enough to aim at');
        }
        for (final Vehicle vehicle in state.vehicles) {
          final Rect rect = tester.getRect(find.byKey(ValueKey<String>('vehicle-tray-${vehicle.name}')));
          expect(screen.contains(rect.bottomRight - const Offset(0.1, 0.1)), isTrue, reason: vehicle.name);
          expect(rect.width, greaterThanOrEqualTo(44), reason: '${vehicle.name} is a touch target');
        }
      });
    }
  }

  // Con el texto del sistema al máximo (TD-007): sin desbordes.
  for (final (String name, Size size) in [('portrait', portrait), ('landscape', landscape)]) {
    for (final Locale locale in const [Locale('de'), Locale('ar')]) {
      testWidgets('level 8 fits with the largest text in compact $name (${locale.languageCode})', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2.0;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await pumpScreen(tester, level: 8, round: GameDifficulty.gold, size: size, locale: locale);
        expect(tester.takeException(), isNull);
        expect(find.byType(VehicleBoardView), findsOneWidget);
      });
    }
  }
}
