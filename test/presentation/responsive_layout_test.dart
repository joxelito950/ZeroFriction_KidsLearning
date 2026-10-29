import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/app_language.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/domain/memory/memory_ladder.dart';
import 'package:toddler_logic/domain/parental/parental_gate.dart';
import 'package:toddler_logic/domain/repositories/i_persistence_repository.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/blocs/parental_gate/parental_gate_cubit.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/screens/memory_game_screen.dart';
import 'package:toddler_logic/presentation/screens/parental_gate_screen.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/widgets/parental_keypad.dart';

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

/// Idiomas de ayuda del desafío que más exigen al diseño (HU-021, criterio 10):
/// el de la pregunta más larga y, si es otro, el de dirección contraria.
List<Locale> _worstHelpers(Locale app) {
  final challenge = ParentalGate(random: Random(3)).start();
  int length(Locale locale) {
    final l10n = lookupAppLocalizations(locale);
    return l10n
        .parentalGateQuestion(
          numberInWords(l10n, challenge.firstFactor),
          numberInWords(l10n, challenge.secondFactor),
        )
        .length;
  }

  final others = AppLocalizations.supportedLocales.where((locale) => locale != app).toList()
    ..sort((a, b) => length(b).compareTo(length(a)));
  final bool appIsRtl = app.languageCode == 'ar';
  final Locale opposite = others.firstWhere((locale) => (locale.languageCode == 'ar') != appIsRtl);
  return {others.first, opposite}.toList();
}

void _usePhoneLanguage(WidgetTester tester, Locale locale) {
  tester.platformDispatcher.localesTestValue = [locale];
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
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

          for (final label in [l10n.menuMemoryTitle, l10n.menuParentsZone, l10n.menuExit]) {
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

        // HU-004, criterio 8: la pregunta, la respuesta y las 12 teclas se ven sin scroll,
        // también con la pregunta repetida en el idioma de ayuda (HU-021, criterio 10).
        for (final helper in _worstHelpers(locale)) {
          testWidgets('parental gate fits with every key reachable (helper ${helper.languageCode})', (tester) async {
            _usePhone(tester, phone);
            _usePhoneLanguage(tester, helper);
            await tester.pumpWidget(
              localizedApp(locale: locale, home: ParentalGateScreen(gate: ParentalGate(random: Random(3)))),
            );

            for (final key in [
              'parental-gate-back',
              'parental-gate-question',
              'parental-gate-question-helper',
              'parental-gate-answer',
              'parental-key-delete',
              'parental-key-accept',
              for (var digit = 0; digit <= 9; digit++) 'parental-key-$digit',
            ]) {
              expect(find.byKey(ValueKey<String>(key)).hitTestable(), findsOneWidget, reason: key);
            }

            final double keyHeight = tester.getSize(find.byKey(const ValueKey<String>('parental-key-0'))).height;
            expect(keyHeight, greaterThanOrEqualTo(48), reason: 'keys must stay easy to tap');
          });
        }

        for (final helper in _worstHelpers(locale)) {
          testWidgets('parental gate message fits with every choice reachable (helper ${helper.languageCode})',
              (tester) async {
            _usePhone(tester, phone);
            _usePhoneLanguage(tester, helper);
            await tester.pumpWidget(
              localizedApp(locale: locale, home: ParentalGateScreen(gate: ParentalGate(random: Random(3)))),
            );
            final ParentalGateCubit cubit =
                tester.element(find.byType(ParentalKeypad)).read<ParentalGateCubit>();
            for (final char in '${cubit.state.challenge!.answer + 1}'.split('')) {
              cubit.typeDigit(int.parse(char));
            }
            cubit.submit();
            await tester.pump();

            for (final key in [
              'parental-gate-close',
              'parental-gate-message-helper',
              'parental-gate-back-to-menu',
              'parental-gate-retry',
            ]) {
              await tester.ensureVisible(find.byKey(ValueKey<String>(key)));
              expect(find.byKey(ValueKey<String>(key)).hitTestable(), findsOneWidget, reason: key);
            }
            expect(find.text(l10n.parentalGateAttemptsLeft(2)), findsOneWidget);
            await tester.pump(ParentalGateCubit.messageTimeout);
          });
        }

        testWidgets('parents zone fits', (tester) async {
          _usePhone(tester, phone);
          await tester.pumpWidget(localizedApp(locale: locale, home: const ParentsZoneScreen()));

          expect(find.text(l10n.parentsZoneTitle).hitTestable(), findsOneWidget);
          expect(find.byKey(const ValueKey<String>('parents-zone-back-to-menu')).hitTestable(), findsOneWidget);
          // La lista solo construye lo que se ve: se desplaza hasta el final.
          for (final code in AppLanguage.supported) {
            await tester.scrollUntilVisible(find.byKey(ValueKey<String>('language-$code')), 100);
          }
          await tester.scrollUntilVisible(find.text(l10n.parentsZonePinNote), 200);
          await tester.pump(); // ensureVisible necesita un fotograma más para verse
          expect(find.text(l10n.parentsZonePinNote).hitTestable(), findsOneWidget);
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
