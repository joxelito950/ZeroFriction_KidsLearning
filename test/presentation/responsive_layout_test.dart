import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';

import 'l10n_test_support.dart';
import 'memory_game_test_support.dart';

/// Ninguna pantalla debe desbordarse (un overflow hace fallar el test) ni recortar
/// cartas, en ningún idioma, en vertical u horizontal, en los dos tamaños de
/// teléfono de referencia de la especificación (HU-011, criterios 7 y 8).
class _Phone {
  const _Phone(this.name, this.devicePixelRatio, {required this.landscape});

  final String name;
  final double devicePixelRatio;
  final bool landscape;
}

const _phones = [
  _Phone('moto g55 portrait (508x1129 dp)', 2.125, landscape: false),
  _Phone('compact portrait (411x914 dp)', 2.625, landscape: false),
  _Phone('moto g55 landscape (1129x508 dp)', 2.125, landscape: true),
  _Phone('compact landscape (914x411 dp)', 2.625, landscape: true),
];

void _usePhone(WidgetTester tester, _Phone phone) {
  tester.view.physicalSize = phone.landscape ? const Size(2400, 1080) : const Size(1080, 2400);
  tester.view.devicePixelRatio = phone.devicePixelRatio;
  const insets = FakeViewPadding(left: 90, top: 51, bottom: 40);
  tester.view.padding = insets;
  tester.view.viewPadding = insets;
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

  for (final locale in AppLocalizations.supportedLocales) {
    final l10n = lookupAppLocalizations(locale);

    for (final phone in _phones) {
      group('[${locale.languageCode}] ${phone.name}', () {
        testWidgets('main menu fits and keeps every action reachable', (tester) async {
          _usePhone(tester, phone);

          await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: locale));

          for (final label in [l10n.menuMemoryTitle, l10n.menuParentsZone]) {
            await tester.ensureVisible(find.text(label));
            expect(find.text(label).hitTestable(), findsOneWidget, reason: label);
          }

          final TextDirection direction =
              Directionality.of(tester.element(find.byType(MainMenuScreen)));
          final double arrowX = tester.getCenter(find.byIcon(Icons.chevron_right_rounded).first).dx;
          final double titleX = tester.getCenter(find.text(l10n.menuMemoryTitle)).dx;
          if (locale.languageCode == 'ar') {
            expect(direction, TextDirection.rtl);
            expect(arrowX, lessThan(titleX), reason: 'in RTL the arrow sits on the left');
          } else {
            expect(direction, TextDirection.ltr);
            expect(arrowX, greaterThan(titleX));
          }
        });

        for (final level in MemoryLadder.levels) {
          testWidgets('memory level ${level.number} (${level.cards} cards) fits above the footer', (tester) async {
            _usePhone(tester, phone);
            when(() => repository.readMemoryProgress())
                .thenAnswer((_) async => MemoryProgress(currentLevel: level.number));

            await tester.pumpWidget(
              localizedApp(
                locale: locale,
                home: RepositoryProvider<IPersistenceRepository>.value(
                  value: repository,
                  child: MemoryGameScreen(random: Random(level.number)),
                ),
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 600));

            final double footerTop = tester.getTopLeft(find.text(l10n.memoryGameHintPlaying)).dy;
            final cardRects = [
              for (var index = 0; index < level.cards; index++)
                tester.getRect(find.byKey(ValueKey<String>('memory-card-$index'))),
            ];
            for (final (index, cardRect) in cardRects.indexed) {
              expect(cardRect.bottom, lessThan(footerTop), reason: 'card $index is clipped');
            }

            // En horizontal, con tan poco alto, los tableros pequeños van en una sola fila.
            if (phone.landscape && level.cards <= 6) {
              final rowTops = cardRects.map((rect) => rect.top.round()).toSet();
              expect(rowTops, hasLength(1), reason: 'cards should share a single row');
            }
          });
        }
      });
    }
  }
}
