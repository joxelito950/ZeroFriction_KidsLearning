import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';

import 'presentation/memory_game_test_support.dart';
import 'presentation/l10n_test_support.dart';

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  group('ToddlerLogicApp', () {
    late MockPersistenceRepository repository;

    /// Veces que la app pidió cerrarse (`SystemNavigator.pop`).
    late int closeRequests;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
      closeRequests = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'SystemNavigator.pop') closeRequests++;
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    final badgeFinder = find.byKey(const ValueKey<String>('menu-memory-badge'));

    testWidgets('shows the main menu with a single memory game button', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      expect(find.text('ToddlerLogic'), findsOneWidget);
      expect(find.text('Memoria'), findsOneWidget);
      expect(find.text('Encuentra las parejas'), findsOneWidget);
      expect(find.text('Zona de Padres'), findsOneWidget);
    });

    // TD-006: sin mascota ni iconos de juegos hasta definir la identidad visual (HU-013).
    testWidgets('does not show the mascot or game icons in the menu', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      for (final icon in ['🧸', '🚜', '🌴']) {
        expect(find.text(icon), findsNothing, reason: '$icon should not be shown');
      }
    });

    // HU-004 R1, criterio 1: doble toque para entrar al desafío.
    group('Zona de Padres', () {
      final hint = find.byKey(const ValueKey<String>('parents-zone-tap-again-hint'));
      final question = find.byKey(const ValueKey<String>('parental-gate-question'));

      testWidgets('a single tap only shows a small notice that goes away by itself', (tester) async {
        await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

        await tester.tap(find.text('Zona de Padres'));
        await tester.pump();

        expect(find.text('Toca otra vez para entrar'), findsOneWidget);
        expect(find.descendant(of: hint, matching: find.byType(ButtonStyleButton)), findsNothing);
        expect(question, findsNothing);
        expect(find.text('Memoria'), findsOneWidget);

        await tester.pump(MainMenuScreen.parentsZoneTapWindow);
        expect(hint, findsNothing);
      });

      testWidgets('a second tap within 2 seconds opens the challenge', (tester) async {
        await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

        await tester.tap(find.text('Zona de Padres'));
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.tap(find.text('Zona de Padres'));
        await tester.pumpAndSettle();

        expect(question, findsOneWidget);
        expect(hint, findsNothing);
      });

      testWidgets('a second tap after the window starts over with the notice', (tester) async {
        await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

        await tester.tap(find.text('Zona de Padres'));
        await tester.pump(MainMenuScreen.parentsZoneTapWindow);
        await tester.tap(find.text('Zona de Padres'));
        await tester.pump();

        expect(hint, findsOneWidget);
        expect(question, findsNothing);
        await tester.pump(MainMenuScreen.parentsZoneTapWindow);
      });
    });

    testWidgets('opens the memory game at the saved level', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      await tester.tap(find.text('Memoria'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MemoryGameScreen), findsOneWidget);
      expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(4));
    });

    testWidgets('shows no medal until the memory badge is earned', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
      await tester.pump();

      expect(badgeFinder, findsNothing);
    });

    testWidgets('shows the medal next to Memoria once the badge is earned', (tester) async {
      when(() => repository.readMemoryProgress())
          .thenAnswer((_) async => MemoryProgress(currentLevel: 1, hasBadge: true));

      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
      await tester.pump();

      expect(badgeFinder, findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == 'Insignia dorada conseguida'),
        findsOneWidget,
      );
    });

    testWidgets('refreshes the medal when coming back from the game', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
      await tester.tap(find.text('Memoria'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      when(() => repository.readMemoryProgress())
          .thenAnswer((_) async => MemoryProgress(currentLevel: 1, hasBadge: true));
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(MemoryGameScreen), findsNothing);
      expect(badgeFinder, findsOneWidget);
    });

    testWidgets('still shows the menu without medal if the progress cannot be read', (tester) async {
      when(() => repository.readMemoryProgress()).thenThrow(Exception('disk error'));

      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
      await tester.pump();

      expect(find.text('Memoria'), findsOneWidget);
      expect(badgeFinder, findsNothing);
    });

    testWidgets('Salir closes the app right away, without confirmation', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      await tester.tap(find.text('Salir'));
      await tester.pump();

      expect(closeRequests, 1);
    });

    testWidgets('back in the menu asks to repeat the gesture before closing the app', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(find.text('Repite el gesto para salir'), findsOneWidget);
      expect(closeRequests, 0);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(closeRequests, 1);
    });
  });
}
