import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/domain/parental/rest_schedule.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/screens/rest_screen.dart';

import '../l10n_test_support.dart';

void main() {
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);

  // En el moto g55 el título cabe en una línea y la columna se encogía al
  // inicio de la pantalla; con la fuente de los tests el título se parte y
  // ocupa todo el ancho, así que se reduce el texto para que quepa.
  testWidgets('keeps its content centred even when the texts are short', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 0.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(localizedApp(home: const RestScreen()));

    final double centre = tester.getRect(find.byType(SingleChildScrollView)).center.dx;
    for (final finder in [
      find.text(l10n.restTitle),
      find.text(l10n.restSubtitle),
      find.byKey(const ValueKey<String>('rest-illustration')),
      find.byKey(const ValueKey<String>('rest-parents-zone')),
    ]) {
      expect(tester.getCenter(finder).dx, moreOrLessEquals(centre, epsilon: 1));
    }
  });

  testWidgets('shows the resting child instead of the system icon', (tester) async {
    await tester.pumpWidget(localizedApp(home: const RestScreen()));
    final Image image = tester.widget<Image>(find.byKey(const ValueKey<String>('rest-illustration')));
    expect((image.image as AssetImage).assetName, BrandAssets.childResting);
    expect(find.byIcon(Icons.bedtime_rounded), findsNothing);
  });

  // Reportado en la prueba cerrada: al acabar el tiempo no había salida directa.
  testWidgets('offers a direct exit that closes the app, as the menu does', (tester) async {
    int closeRequests = 0;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'SystemNavigator.pop') closeRequests++;
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(localizedApp(home: const RestScreen()));
    final Finder exit = find.byKey(const ValueKey<String>('rest-exit'));
    await tester.ensureVisible(exit);
    expect(find.descendant(of: exit, matching: find.text(l10n.menuExit)), findsOneWidget);
    await tester.tap(exit);
    await tester.pump();
    expect(closeRequests, 1);
  });

  group('bedtime (HU-038 R3)', () {
    testWidgets('at night: the sleeping child, deep teal and cream, «Time for bed!»', (tester) async {
      await tester.pumpWidget(localizedApp(home: const RestScreen(kind: RestKind.night)));
      expect(find.text(l10n.restNightTitle), findsOneWidget);
      expect(find.text(l10n.restNightSubtitle), findsOneWidget);
      final Image image = tester.widget<Image>(find.byKey(const ValueKey<String>('rest-illustration-night')));
      expect((image.image as AssetImage).assetName, BrandAssets.childSleeping);
      expect(tester.widget<Scaffold>(find.byKey(const ValueKey<String>('rest-screen'))).backgroundColor,
          AppPalette.deepTeal);
      expect(tester.widget<Text>(find.text(l10n.restNightTitle)).style?.color, AppPalette.warmCream);
      expect(find.byKey(const ValueKey<String>('rest-parents-zone')), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('rest-exit')), findsOneWidget);
    });

    testWidgets('at nap time: «Time for a rest!»', (tester) async {
      await tester.pumpWidget(localizedApp(home: const RestScreen(kind: RestKind.nap)));
      expect(find.text(l10n.restNapTitle), findsOneWidget);
      expect(find.text(l10n.restNapSubtitle), findsOneWidget);
    });

    testWidgets('without the illustration, the bedtime icon in cream', (tester) async {
      await tester.pumpWidget(localizedApp(home: const RestScreen(kind: RestKind.night)));
      final Image image = tester.widget<Image>(find.byKey(const ValueKey<String>('rest-illustration-night')));
      final Widget fallback = image.errorBuilder!(tester.element(find.byType(Image)), Object(), null);
      expect((fallback as Icon).color, AppPalette.warmCream.withValues(alpha: 0.85));
    });
  });
}
