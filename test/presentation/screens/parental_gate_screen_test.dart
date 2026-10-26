import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/parental/parental_gate.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/blocs/parental_gate/parental_gate_cubit.dart';
import 'package:toddler_logic/presentation/screens/parental_gate_screen.dart';
import 'package:toddler_logic/presentation/screens/parents_zone_screen.dart';
import 'package:toddler_logic/presentation/widgets/parental_gate_message.dart';
import 'package:toddler_logic/presentation/widgets/parental_keypad.dart';

import '../l10n_test_support.dart';

const _seed = 11;
const _openKey = ValueKey<String>('open-gate');

final _question = find.byKey(const ValueKey<String>('parental-gate-question'));
final _message = find.byKey(const ValueKey<String>('parental-gate-message'));
final _retry = find.byKey(const ValueKey<String>('parental-gate-retry'));

/// Menú de prueba con un botón que abre el desafío, para comprobar las vueltas.
Future<void> _openGate(WidgetTester tester) async {
  await tester.pumpWidget(
    localizedApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            key: _openKey,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ParentalGateScreen(gate: ParentalGate(random: Random(_seed))),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_openKey));
  await tester.pumpAndSettle();
}

ParentalGateCubit _cubit(WidgetTester tester) => tester.element(find.byType(ParentalKeypad)).read<ParentalGateCubit>();

Future<void> _typeAndAccept(WidgetTester tester, int value) async {
  for (final char in '$value'.split('')) {
    await tester.tap(find.byKey(ValueKey<String>('parental-key-$char')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const ValueKey<String>('parental-key-accept')));
  await tester.pump();
}

Future<void> _answerWrong(WidgetTester tester) =>
    _typeAndAccept(tester, _cubit(tester).state.challenge!.answer + 1);

bool _isOnMenu(WidgetTester tester) => find.byKey(_openKey).hitTestable().evaluate().isNotEmpty;

void main() {
  final l10n = lookupAppLocalizations(testLocale);

  testWidgets('asks a multiplication written in words in the app language (R2, criterio 1)', (tester) async {
    await _openGate(tester);
    final ParentalGateChallenge expected = ParentalGate(random: Random(_seed)).start();

    final String text = tester.widget<Text>(_question).data!;
    expect(
      text,
      l10n.parentalGateQuestion(
        numberInWords(l10n, expected.firstFactor),
        numberInWords(l10n, expected.secondFactor),
      ),
    );
    expect(text, isNot(matches(RegExp(r'\d'))), reason: 'no digits to copy');
    expect(find.text('Solo para adultos'), findsOneWidget);
  });

  testWidgets('shows the 10 digits in the shuffled order, delete and accept (R3)', (tester) async {
    await _openGate(tester);
    final List<int> keypad = _cubit(tester).state.challenge!.keypad;

    Offset at(String key) => tester.getCenter(find.byKey(ValueKey<String>(key)));
    final List<Offset> digits = [for (final digit in keypad) at('parental-key-$digit')];

    // Filas de 3 en el orden barajado; la última es «borrar», la décima cifra y «aceptar».
    for (var index = 0; index < 9; index++) {
      final Offset key = digits[index];
      if (index % 3 > 0) {
        expect(key.dx, greaterThan(digits[index - 1].dx));
        expect(key.dy, digits[index - 1].dy);
      }
      if (index >= 3) expect(key.dy, greaterThan(digits[index - 3].dy));
    }
    expect(at('parental-key-delete').dx, lessThan(digits[9].dx));
    expect(at('parental-key-accept').dx, greaterThan(digits[9].dx));
    expect(at('parental-key-delete').dy, digits[9].dy);
    expect(find.text('Aceptar'), findsOneWidget);

    final accept = tester.widget<FilledButton>(
      find.descendant(of: find.byKey(const ValueKey<String>('parental-key-accept')), matching: find.byType(FilledButton)),
    );
    expect(accept.onPressed, isNull, reason: 'nothing typed yet');
  });

  testWidgets('the typed answer is shown and read by the screen reader (criterio 9)', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _openGate(tester);
    final answer = find.byKey(const ValueKey<String>('parental-gate-answer'));
    expect(find.bySemanticsLabel('Sin respuesta todavía'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('parental-key-4')));
    await tester.tap(find.byKey(const ValueKey<String>('parental-key-2')));
    await tester.pump();
    expect(find.descendant(of: answer, matching: find.text('42')), findsOneWidget);
    expect(find.bySemanticsLabel('Respuesta: 42'), findsOneWidget);
    expect(find.bySemanticsLabel('Borrar'), findsOneWidget);
    expect(find.bySemanticsLabel('Volver'), findsOneWidget, reason: 'read once, not twice');

    await tester.tap(find.byKey(const ValueKey<String>('parental-key-delete')));
    await tester.pump();
    expect(find.descendant(of: answer, matching: find.text('4')), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the right answer opens the Parents\' Zone (criterio 2)', (tester) async {
    await _openGate(tester);
    await _typeAndAccept(tester, _cubit(tester).state.challenge!.answer);
    await tester.pumpAndSettle();

    expect(find.byType(ParentsZoneScreen), findsOneWidget);
    expect(find.text('Zona de Padres'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('parents-zone-back-to-menu')));
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  testWidgets('a wrong answer shows the attempts left with retry, X and back to menu (criterio 3)', (tester) async {
    // En vertical, donde el contenido no llena el alto (visto en el emulador).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await _openGate(tester);
    await _answerWrong(tester);

    expect(_message, findsOneWidget);
    expect(find.text('Esa no es la respuesta'), findsOneWidget);
    expect(find.text('Quedan 2 intentos'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Volver al menú'), findsOneWidget);
    expect(find.byTooltip('Cerrar'), findsOneWidget);

    // El fondo del mensaje cubre toda la pantalla (visto en el emulador).
    final Size screen = tester.getSize(find.byType(Scaffold).last);
    expect(tester.getSize(find.byType(ParentalGateMessage)), screen);
    await tester.pump(ParentalGateCubit.messageTimeout);
    await tester.pumpAndSettle();
  });

  testWidgets('retry shows a new question with the keypad shuffled again (criterio 4, 10)', (tester) async {
    await _openGate(tester);
    final List<int> firstKeypad = _cubit(tester).state.challenge!.keypad;
    await _answerWrong(tester);

    await tester.tap(_retry);
    await tester.pump();

    expect(_message, findsNothing);
    expect(_cubit(tester).state.challenge!.keypad, isNot(orderedEquals(firstKeypad)));
    await _answerWrong(tester);
    expect(find.text('Queda 1 intento'), findsOneWidget);
    await tester.tap(_retry);
    await tester.pump();
  });

  testWidgets('X goes back to the menu (criterio 4)', (tester) async {
    await _openGate(tester);
    await _answerWrong(tester);

    await tester.tap(find.byKey(const ValueKey<String>('parental-gate-close')));
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  testWidgets('back to menu in the message goes back to the menu (criterio 4)', (tester) async {
    await _openGate(tester);
    await _answerWrong(tester);

    await tester.tap(find.byKey(const ValueKey<String>('parental-gate-back-to-menu')));
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  testWidgets('after 5 seconds without choosing, it goes back to the menu (criterio 4, R5)', (tester) async {
    await _openGate(tester);
    await _answerWrong(tester);

    await tester.pump(ParentalGateCubit.messageTimeout - const Duration(milliseconds: 100));
    expect(_message, findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  testWidgets('after the third wrong answer there is no retry and it goes back to the menu (S1, criterio 11)', (tester) async {
    await _openGate(tester);
    for (var attempt = 0; attempt < 2; attempt++) {
      await _answerWrong(tester);
      await tester.tap(_retry);
      await tester.pump();
    }
    await _answerWrong(tester);

    expect(find.text('No quedan intentos. Volvemos al menú.'), findsOneWidget);
    expect(_retry, findsNothing);
    await tester.pump(ParentalGateCubit.messageTimeout);
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);

    // Sin esperas ni bloqueos: se puede volver a entrar enseguida.
    await tester.tap(find.byKey(_openKey));
    await tester.pumpAndSettle();
    expect(_question, findsOneWidget);
    expect(_cubit(tester).state.challenge!.attemptsLeft, 3);
  });

  testWidgets('the back button returns to the menu (criterio 5)', (tester) async {
    await _openGate(tester);

    await tester.tap(find.byKey(const ValueKey<String>('parental-gate-back')));
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  testWidgets('the system back returns to the menu directly (P5)', (tester) async {
    await _openGate(tester);

    final NavigatorState navigator = tester.state(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(_isOnMenu(tester), isTrue);
  });

  test('numberInWords covers 3 to 9 and rejects other numbers', () {
    expect([for (var n = 3; n <= 9; n++) numberInWords(l10n, n)],
        ['tres', 'cuatro', 'cinco', 'seis', 'siete', 'ocho', 'nueve']);
    expect(() => numberInWords(l10n, 2), throwsRangeError);
    expect(() => numberInWords(l10n, 10), throwsRangeError);
  });
}
