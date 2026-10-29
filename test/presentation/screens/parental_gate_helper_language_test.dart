import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/parental_gate.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/blocs/parental_gate/parental_gate_cubit.dart';
import 'package:toddler_logic/presentation/screens/main_menu_screen.dart';
import 'package:toddler_logic/presentation/screens/parental_gate_screen.dart';
import 'package:toddler_logic/presentation/widgets/parental_gate_message.dart';
import 'package:toddler_logic/presentation/widgets/parental_keypad.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// HU-021: la pregunta del desafío y los avisos del camino a la Zona de Padres
/// también en un idioma que el adulto entienda.
const _seed = 11;

final _question = find.byKey(const ValueKey<String>('parental-gate-question'));
final _questionHelper = find.byKey(const ValueKey<String>('parental-gate-question-helper'));

void _usePhoneLanguages(WidgetTester tester, List<Locale> locales) {
  tester.platformDispatcher.localesTestValue = locales;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
}

Future<void> _openGate(WidgetTester tester, Locale appLocale) async {
  await tester.pumpWidget(
    localizedApp(locale: appLocale, home: ParentalGateScreen(gate: ParentalGate(random: Random(_seed)))),
  );
  await tester.pumpAndSettle();
}

String _questionIn(Locale locale) {
  final l10n = lookupAppLocalizations(locale);
  final ParentalGateChallenge expected = ParentalGate(random: Random(_seed)).start();
  return l10n.parentalGateQuestion(
    numberInWords(l10n, expected.firstFactor),
    numberInWords(l10n, expected.secondFactor),
  );
}

String? _helperText(WidgetTester tester) {
  final Finder text = find.descendant(of: _questionHelper, matching: find.byType(Text));
  return text.evaluate().isEmpty ? null : tester.widget<Text>(text).data;
}

TextDirection _helperDirection(WidgetTester tester, Finder helper) =>
    tester.widget<Directionality>(find.descendant(of: helper, matching: find.byType(Directionality))).textDirection;

void main() {
  testWidgets('repeats the question in the phone language under the app one (R1, R3, criterio 1)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('es', 'CO')]);
    await _openGate(tester, const Locale('de'));

    expect(tester.widget<Text>(_question).data, _questionIn(const Locale('de')));
    expect(_helperText(tester), _questionIn(const Locale('es')));
    expect(tester.getTopLeft(_questionHelper).dy, greaterThan(tester.getTopLeft(_question).dy));
  });

  testWidgets('uses English when the phone and the app share the language (R1, P2, criterio 2)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('de', 'DE')]);
    await _openGate(tester, const Locale('de'));

    expect(_helperText(tester), _questionIn(const Locale('en')));
  });

  testWidgets('takes the first phone language that differs from the app (R1)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('es', 'ES'), Locale('ru'), Locale('fr', 'FR')]);
    await _openGate(tester, testLocale);

    expect(_helperText(tester), _questionIn(const Locale('fr')));
  });

  testWidgets('shows no helper when the app is in English and the phone offers nothing else (criterio 3)', (tester) async {
    for (final List<Locale> phone in [
      const [Locale('en', 'US')],
      const [Locale('ru', 'RU')],
    ]) {
      _usePhoneLanguages(tester, phone);
      await _openGate(tester, const Locale('en'));

      expect(_helperText(tester), isNull, reason: '$phone');
      expect(tester.getSize(_questionHelper).height, 0);
    }
  });

  testWidgets('reads the phone language again when the challenge opens (R2, criterio 4)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('de')]);
    await _openGate(tester, testLocale);
    expect(_helperText(tester), _questionIn(const Locale('de')));

    tester.platformDispatcher.localesTestValue = const [Locale('it')];
    await tester.pumpWidget(const SizedBox());
    await _openGate(tester, testLocale);
    expect(_helperText(tester), _questionIn(const Locale('it')));
  });

  testWidgets('each line keeps its own writing direction (R4, criterio 5)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('en')]);
    await _openGate(tester, const Locale('ar'));
    expect(Directionality.of(tester.element(_question)), TextDirection.rtl);
    expect(_helperDirection(tester, _questionHelper), TextDirection.ltr);

    _usePhoneLanguages(tester, const [Locale('ar', 'EG')]);
    await tester.pumpWidget(const SizedBox());
    await _openGate(tester, const Locale('en'));
    expect(Directionality.of(tester.element(_question)), TextDirection.ltr);
    expect(_helperDirection(tester, _questionHelper), TextDirection.rtl);
    expect(_helperText(tester), _questionIn(const Locale('ar')));
  });

  testWidgets('the screen reader reads the helper after the question, in its own language (R5, criterio 6)',
      (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    _usePhoneLanguages(tester, const [Locale('ja', 'JP')]);
    await _openGate(tester, const Locale('de'));

    final SemanticsNode node = tester.getSemantics(
      find.descendant(of: _questionHelper, matching: find.byType(Semantics)).first,
    );
    expect(node.label, _questionIn(const Locale('ja')));
    final LocaleStringAttribute attribute = node.attributedLabel.attributes.single as LocaleStringAttribute;
    expect(attribute.locale, const Locale('ja'));
    semantics.dispose();
  });

  testWidgets('the wrong-answer message has its helper line and icons on its buttons (R6, R7, criterio 7, 8)',
      (tester) async {
    _usePhoneLanguages(tester, const [Locale('en')]);
    await _openGate(tester, testLocale);
    final cubit = tester.element(find.byType(ParentalKeypad)).read<ParentalGateCubit>();
    for (final char in '${cubit.state.challenge!.answer + 1}'.split('')) {
      await tester.tap(find.byKey(ValueKey<String>('parental-key-$char')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey<String>('parental-key-accept')));
    await tester.pump();

    final Finder helper = find.byKey(const ValueKey<String>('parental-gate-message-helper'));
    expect(find.descendant(of: helper, matching: find.text(lookupAppLocalizations(const Locale('en')).parentalGateWrongAnswer)),
        findsOneWidget);
    expect(find.descendant(of: find.byType(ParentalGateMessage), matching: find.byIcon(Icons.refresh_rounded)), findsOneWidget);
    expect(find.descendant(of: find.byType(ParentalGateMessage), matching: find.byIcon(Icons.home_rounded)), findsOneWidget);
  });

  testWidgets('the accept key has a check icon besides its text (R7, criterio 8)', (tester) async {
    await _openGate(tester, testLocale);

    final Finder accept = find.byKey(const ValueKey<String>('parental-key-accept'));
    expect(find.descendant(of: accept, matching: find.byIcon(Icons.check_rounded)), findsOneWidget);
    expect(find.descendant(of: accept, matching: find.text(lookupAppLocalizations(testLocale).parentalGateAccept)),
        findsOneWidget);
  });

  testWidgets('the "tap again" hint of the menu has its helper line (R6, criterio 7)', (tester) async {
    _usePhoneLanguages(tester, const [Locale('pt', 'BR')]);
    registerMemoryGameFallbacks();
    final repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: const Locale('de')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('menu-parents-zone')));
    await tester.pump();

    final Finder helper = find.byKey(const ValueKey<String>('quiet-hint-helper'));
    expect(
      find.descendant(of: helper, matching: find.text(lookupAppLocalizations(const Locale('pt')).parentsZoneTapAgainHint)),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 3));
  });

  test('no language writes the question with digits (criterio 9)', () {
    final digits = RegExp(r'[0-9٠-٩۰-۹０-９]');
    for (final locale in AppLocalizations.supportedLocales) {
      final l10n = lookupAppLocalizations(locale);
      for (var first = ParentalGate.minFactor; first <= ParentalGate.maxFactor; first++) {
        for (var second = ParentalGate.minFactor; second <= ParentalGate.maxFactor; second++) {
          final String question = l10n.parentalGateQuestion(numberInWords(l10n, first), numberInWords(l10n, second));
          expect(digits.hasMatch(question), isFalse, reason: '${locale.languageCode}: $question');
        }
      }
    }
  });

  testWidgets('an adult who reads only the helper gets in and switches the app to their language (criterio 11)',
      (tester) async {
    _usePhoneLanguages(tester, const [Locale('es', 'CO')]);
    registerMemoryGameFallbacks();
    final repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: const Locale('de')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey<String>('menu-parents-zone')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey<String>('menu-parents-zone')));
    await tester.pumpAndSettle();

    final ParentalGateChallenge challenge =
        tester.element(find.byType(ParentalKeypad)).read<ParentalGateCubit>().state.challenge!;
    final es = lookupAppLocalizations(const Locale('es'));
    expect(
      _helperText(tester),
      es.parentalGateQuestion(numberInWords(es, challenge.firstFactor), numberInWords(es, challenge.secondFactor)),
    );

    for (final char in '${challenge.answer}'.split('')) {
      await tester.tap(find.byKey(ValueKey<String>('parental-key-$char')));
      await tester.pump();
    }
    await tester.tap(find.byKey(const ValueKey<String>('parental-key-accept')));
    await tester.pumpAndSettle();

    final Finder spanish = find.byKey(const ValueKey<String>('language-es'));
    await tester.ensureVisible(spanish);
    await tester.tap(spanish);
    await tester.pumpAndSettle();

    expect(find.text(es.parentsZoneTitle), findsOneWidget);
    expect(find.byType(MainMenuScreen, skipOffstage: false), findsOneWidget);
  });
}
