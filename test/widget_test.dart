import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';

import 'presentation/memory_game_test_support.dart';

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  group('ToddlerLogicApp', () {
    late MockPersistenceRepository repository;

    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
    });

    testWidgets('shows the main menu with both memory levels', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository));

      expect(find.text('ToddlerLogic'), findsOneWidget);
      expect(find.text('Animales de la Granja'), findsOneWidget);
      expect(find.text('Selva Sorpresa'), findsOneWidget);
      expect(find.text('Zona de Padres'), findsOneWidget);
    });

    testWidgets('opens the memory game when tapping a level', (tester) async {
      await tester.pumpWidget(ToddlerLogicApp(repository: repository));

      await tester.tap(find.text('Animales de la Granja'));
      await tester.pumpAndSettle();

      expect(find.byType(MemoryGameScreen), findsOneWidget);
      expect(find.byIcon(Icons.question_mark_rounded), findsNWidgets(4));
    });
  });
}
