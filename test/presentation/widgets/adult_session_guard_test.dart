import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/adult_session_guard.dart';

const _menuKey = ValueKey<String>('menu');
const _openKey = ValueKey<String>('open');
const _adultKey = ValueKey<String>('adult');

/// Menú → pantalla intermedia → pantalla de adultos, para comprobar que el
/// cierre vuelve hasta el menú principal y no solo una pantalla atrás.
Future<void> _openAdultScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          key: _menuKey,
          body: TextButton(
            key: _openKey,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const Scaffold()));
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AdultSessionGuard(
                    child: Scaffold(key: _adultKey, body: SizedBox.expand()),
                  ),
                ),
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.byKey(_openKey));
  await tester.pumpAndSettle();
}

bool _isOnMenu(WidgetTester tester) => find.byKey(_openKey).hitTestable().evaluate().isNotEmpty;

void _sendToBackground(WidgetTester tester) {
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
}

void main() {
  group('AdultSessionGuard (HU-004 R7, S4)', () {
    testWidgets('goes back to the main menu after 1 minute without touches', (tester) async {
      await _openAdultScreen(tester);

      await tester.pump(AdultSessionGuard.defaultInactivity - const Duration(seconds: 1));
      expect(find.byKey(_adultKey), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(_isOnMenu(tester), isTrue);
      expect(find.byKey(_adultKey), findsNothing);
    });

    testWidgets('each touch restarts the minute', (tester) async {
      await _openAdultScreen(tester);

      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 50));
        await tester.tap(find.byKey(_adultKey), warnIfMissed: false);
      }
      await tester.pump(const Duration(seconds: 50));
      expect(find.byKey(_adultKey), findsOneWidget);

      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(_isOnMenu(tester), isTrue);
    });

    testWidgets('goes back to the main menu when the app goes to the background or the screen turns off', (tester) async {
      await _openAdultScreen(tester);

      _sendToBackground(tester);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(_isOnMenu(tester), isTrue);
      expect(find.byKey(_menuKey), findsOneWidget);
    });

    testWidgets('stays open while only inactive (for example, the notification shade)', (tester) async {
      await _openAdultScreen(tester);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(find.byKey(_adultKey), findsOneWidget);
    });
  });
}
