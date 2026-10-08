import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';

import 'memory_game_test_support.dart';

/// Teléfonos en horizontal: el alto útil es muy bajo, así que ninguna
/// pantalla debe desbordarse (un overflow hace fallar el test).
class _LandscapePhone {
  const _LandscapePhone(this.name, this.devicePixelRatio);

  final String name;
  final double devicePixelRatio;
}

const _phones = [
  _LandscapePhone('moto g55 (1129x508 dp)', 2.125),
  _LandscapePhone('compact phone (914x411 dp)', 2.625),
];

void _useLandscapePhone(WidgetTester tester, _LandscapePhone phone) {
  tester.view.physicalSize = const Size(2400, 1080);
  tester.view.devicePixelRatio = phone.devicePixelRatio;
  tester.view.padding = const FakeViewPadding(left: 90, top: 51, bottom: 40);
  tester.view.viewPadding = const FakeViewPadding(left: 90, top: 51, bottom: 40);
  addTearDown(tester.view.reset);
}

void main() {
  setUpAll(() {
    registerMemoryGameFallbacks();
  });

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  for (final phone in _phones) {
    group('Landscape on ${phone.name}', () {
      testWidgets('main menu fits without overflow and keeps every action reachable', (tester) async {
        _useLandscapePhone(tester, phone);

        await tester.pumpWidget(ToddlerLogicApp(repository: repository));

        for (final label in ['Animales de la Granja', 'Selva Sorpresa', 'Zona de Padres']) {
          await tester.ensureVisible(find.text(label));
          expect(find.text(label).hitTestable(), findsOneWidget);
        }
      });

      for (final emojis in const [
        ['🐶', '🐱'],
        ['🦁', '🐯', '🐼'],
      ]) {
        testWidgets('memory board with ${emojis.length * 2} cards fits above the footer', (tester) async {
          _useLandscapePhone(tester, phone);

          await tester.pumpWidget(
            MaterialApp(
              home: RepositoryProvider<IPersistenceRepository>.value(
                value: repository,
                child: MemoryGameScreen(levelId: 'landscape_test', emojis: emojis),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final double footerTop = tester.getTopLeft(find.text('Busquemos la pareja correcta.')).dy;
          final cardRects = [
            for (var index = 0; index < emojis.length * 2; index++)
              tester.getRect(find.byKey(ValueKey<String>('memory-card-$index'))),
          ];
          for (final (index, cardRect) in cardRects.indexed) {
            expect(cardRect.bottom, lessThan(footerTop), reason: 'card $index is clipped');
          }

          // Con tan poco alto, todas las cartas van en una sola fila completa.
          final rowTops = cardRects.map((rect) => rect.top.round()).toSet();
          expect(rowTops, hasLength(1), reason: 'cards should share a single row');
        });
      }
    });
  }
}
