import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/memory_progress.dart';
import 'package:toddler_logic/main.dart';
import 'package:toddler_logic/presentation/widgets/game_icon.dart';
import 'package:toddler_logic/presentation/widgets/liquid_gold.dart';

import '../l10n_test_support.dart';
import '../memory_game_test_support.dart';

/// HU-013, criterios 3 a 5: logo en el menú, icono en el botón y en la cabecera
/// del juego, todos ignorados por el lector de pantalla.
void main() {
  setUpAll(registerMemoryGameFallbacks);
  final AppLocalizations l10n = lookupAppLocalizations(testLocale);

  Future<void> pumpApp(WidgetTester tester) async {
    final repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
    await tester.pump();
  }

  testWidgets('the menu shows the logo above the title and the game icon in the button', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpApp(tester);

    final Finder logo = find.byKey(const ValueKey<String>('menu-logo'));
    expect((tester.widget<Image>(logo).image as AssetImage).assetName, BrandAssets.logo);
    expect(tester.getBottomLeft(logo).dy, lessThanOrEqualTo(tester.getTopLeft(find.text(l10n.appTitle)).dy));
    expect(tester.widget<Image>(logo).excludeFromSemantics, isTrue);

    final Finder icon = find.byKey(const ValueKey<String>('menu-memory-icon'));
    expect(icon, findsOneWidget);
    expect(tester.getCenter(icon).dx, lessThan(tester.getCenter(find.text(l10n.menuMemoryTitle)).dx));
    // El botón se sigue anunciando solo con su texto.
    expect(find.bySemanticsLabel(RegExp(l10n.menuMemoryTitle)), findsWidgets);
    semantics.dispose();
  });

  testWidgets('the Memory button fills with liquid gold and announces it (HU-002 R6, R16)', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    final repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
    when(() => repository.readMemoryProgress()).thenAnswer(
      (_) async => MemoryProgress(
        currentLevel: 1,
        levelRecords: {
          for (var level = 1; level <= 3; level++) level: MemoryLevelRecord(bestStars: 3, achievedAt: DateTime(2026)),
        },
      ),
    );
    await tester.pumpWidget(ToddlerLogicApp(repository: repository, locale: testLocale));
    await tester.pump();

    final LiquidGold gold = tester.widget<LiquidGold>(find.byType(LiquidGold).first);
    expect(gold.fraction, closeTo(0.6, 1e-9));
    expect(find.bySemanticsLabel(RegExp(l10n.menuMemoryTitle)), findsWidgets);
    final String expected = l10n.menuGameGoldSemantics(60, 9, 15);
    expect(find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.value == expected),
        findsOneWidget);
    semantics.dispose();
  });

  testWidgets('the memory game header shows the game icon instead of the placeholder', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text(l10n.menuMemoryTitle));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const ValueKey<String>('memory-game-icon')), findsOneWidget);
    expect(find.byType(GameIcon), findsWidgets);
    expect(find.byIcon(Icons.child_care_rounded), findsNothing);
  });
}
