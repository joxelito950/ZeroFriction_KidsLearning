import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/domain/settings/game_difficulty.dart';
import 'package:toddler_logic/presentation/theme/app_palette.dart';
import 'package:toddler_logic/presentation/widgets/medal_badge.dart';
import 'package:toddler_logic/presentation/widgets/memory_level_indicator.dart';
import 'package:toddler_logic/presentation/widgets/memory_round_overlay.dart';
import 'package:toddler_logic/presentation/widgets/round_style.dart';

import '../l10n_test_support.dart';

/// HU-048 (medallas que se distinguen) y HU-049 (el niño en las celebraciones).
void main() {
  group('MedalStyle (HU-048)', () {
    test('gold is clearly lighter than bronze, so they differ even in grey (criterion 2)', () {
      final double gold = MedalStyle.gold.fill.computeLuminance();
      final double bronze = MedalStyle.bronze.fill.computeLuminance();
      expect(gold, greaterThanOrEqualTo(bronze * 1.8));
    });

    test('bronze, silver and gold have 1, 2 and 3 stars, a signal that does not depend on colour', () {
      expect([MedalStyle.bronze.stars, MedalStyle.silver.stars, MedalStyle.gold.stars], [1, 2, 3]);
    });

    test('each round has its medal; the round colour is the medal fill and the rim its border (P3)', () {
      expect(RoundStyle.medalStyleOf(GameDifficulty.bronze), MedalStyle.bronze);
      expect(RoundStyle.medalStyleOf(GameDifficulty.silver), MedalStyle.silver);
      expect(RoundStyle.medalStyleOf(GameDifficulty.gold), MedalStyle.gold);
      expect(RoundStyle.colorOf(GameDifficulty.gold), AppPalette.amber);
      expect(RoundStyle.rimOf(GameDifficulty.gold), AppPalette.gold);
    });

    test('the five new medals are gems, each its own colour; diamond with sparkles (HU-051 3.4)', () {
      final List<MedalStyle> gems = [
        for (final round in GameDifficulty.values.skip(3)) RoundStyle.medalStyleOf(round),
      ];
      expect(gems.map((style) => style.shape),
          [MedalShape.gem, MedalShape.gem, MedalShape.gem, MedalShape.gem, MedalShape.diamond]);
      expect(gems.map((style) => style.fill).toSet(), hasLength(5));
      expect(gems.map((style) => style.stars), everyElement(0));
      expect(MedalStyle.ruby.fill, AppPalette.medalRuby);
      expect(MedalStyle.emerald.fill, AppPalette.medalEmerald);
    });

    test('ruby and emerald stay inside the medal: their rounds use the progress gold elsewhere', () {
      expect(RoundStyle.colorOf(GameDifficulty.ruby), AppPalette.gold);
      expect(RoundStyle.colorOf(GameDifficulty.emerald), AppPalette.gold);
      expect(RoundStyle.colorOf(GameDifficulty.sapphire), AppPalette.petrolBlue);
    });

    test('styles compare by value', () {
      expect(MedalStyle.gold, isNot(MedalStyle.bronze));
      expect(MedalStyle.gold.hashCode, MedalStyle.gold.hashCode);
      expect(const MedalPainter(MedalStyle.gold).shouldRepaint(MedalPainter(MedalStyle.bronze)), isTrue);
      expect(const MedalPainter(MedalStyle.gold).shouldRepaint(const MedalPainter(MedalStyle.gold)), isFalse);
    });
  });

  group('MedalBadge', () {
    testWidgets('is drawn by the app at the asked size, with a label when given (criterion 3)', (tester) async {
      final SemanticsHandle semantics = tester.ensureSemantics();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final MedalStyle style in [MedalStyle.bronze, MedalStyle.silver, MedalStyle.gold])
                MedalBadge(style: style, size: 40, semanticLabel: 'medal ${style.stars}'),
              for (final MedalStyle style in [MedalStyle.ruby, MedalStyle.obsidian, MedalStyle.diamond])
                MedalBadge(style: style, size: 40),
              MedalBadge(style: MedalStyle.gold, size: 20),
            ],
          ),
        ),
      ));
      expect(tester.getSize(find.byType(MedalBadge).first), const Size(40, 40));
      expect(find.bySemanticsLabel('medal 3'), findsOneWidget);
      expect(find.byType(Icon), findsNothing, reason: 'no system icon (criterion 1)');
      semantics.dispose();
    });
  });

  group('celebration and invitation (HU-049)', () {
    Future<void> pumpOverlay(WidgetTester tester, Widget overlay, {Locale locale = testLocale}) =>
        tester.pumpWidget(localizedApp(locale: locale, home: Scaffold(body: overlay)));

    testWidgets('a medal celebration shows the child with the round medal on the chest (criteria 1, 3)',
        (tester) async {
      for (final GameDifficulty round in GameDifficulty.values) {
        await pumpOverlay(tester, MemoryCelebration(stars: 3, badgeEarned: true, medal: round));
        final Image image = tester.widget<Image>(
          find.descendant(of: find.byKey(const ValueKey<String>('celebrating-child')), matching: find.byType(Image)),
        );
        expect((image.image as AssetImage).assetName, BrandAssets.childCelebrating);
        final MedalBadge medal = tester.widget<MedalBadge>(find.byKey(const ValueKey<String>('celebrating-child-medal')));
        expect(medal.style, RoundStyle.medalStyleOf(round));

        // El disco de la medalla cubre el hueco del pecho.
        final Rect child = tester.getRect(find.byKey(const ValueKey<String>('celebrating-child')));
        final Rect badge = tester.getRect(find.byKey(const ValueKey<String>('celebrating-child-medal')));
        final Offset hole = child.topLeft +
            Offset(CelebratingChild.holeCenter.dx * child.width, CelebratingChild.holeCenter.dy * child.height);
        final Offset disc = badge.topLeft +
            Offset(MedalBadge.discCenter.dx * badge.width, MedalBadge.discCenter.dy * badge.height);
        expect((disc - hole).distance, lessThan(0.5));
        expect(MedalBadge.discRadius * badge.width, greaterThan(CelebratingChild.holeRadius * child.width));

        // Sin cinta (2026-11-19): no seguía el cuello del niño.
        expect(find.byKey(const ValueKey<String>('celebrating-child-ribbon')), findsNothing);
      }
    });

    testWidgets('a level celebration keeps the cup, without the child (P1)', (tester) async {
      await pumpOverlay(tester, const MemoryCelebration(stars: 2, badgeEarned: false));
      expect(find.byKey(const ValueKey<String>('celebrating-child')), findsNothing);
      expect(find.byIcon(Icons.emoji_events_rounded), findsOneWidget);
    });

    testWidgets('the invitation to play shows the inviting child, not the system hand (criterion 2)', (tester) async {
      await pumpOverlay(tester, const PlayInvitation(round: GameDifficulty.bronze));
      final Image image = tester.widget<Image>(find.byKey(const ValueKey<String>('play-invitation-child')));
      expect((image.image as AssetImage).assetName, BrandAssets.childInviting);
      expect(find.byIcon(Icons.touch_app_rounded), findsNothing);
      final Transform flip = tester.widget<Transform>(
        find.ancestor(of: find.byKey(const ValueKey<String>('play-invitation-child')), matching: find.byType(Transform)).first,
      );
      expect(flip.transform.storage[0], 1, reason: 'not mirrored left to right');
    });

    testWidgets('in Arabic the inviting child is mirrored to point at the content', (tester) async {
      await pumpOverlay(tester, const PlayInvitation(round: GameDifficulty.bronze), locale: const Locale('ar'));
      final Transform flip = tester.widget<Transform>(
        find.ancestor(of: find.byKey(const ValueKey<String>('play-invitation-child')), matching: find.byType(Transform)).first,
      );
      expect(flip.transform.storage[0], -1);
    });
  });

  testWidgets('reached level dots carry the rim of the round medal (HU-048 P3)', (tester) async {
    await tester.pumpWidget(localizedApp(
      home: Scaffold(
        body: MemoryLevelIndicator(
          level: 2,
          total: 3,
          color: RoundStyle.colorOf(GameDifficulty.gold),
          rim: RoundStyle.rimOf(GameDifficulty.gold),
        ),
      ),
    ));
    final BoxDecoration reached = tester
        .widget<Container>(find.byKey(const ValueKey<String>('memory-level-dot-1-reached')))
        .decoration! as BoxDecoration;
    final BoxDecoration pending = tester
        .widget<Container>(find.byKey(const ValueKey<String>('memory-level-dot-3-pending')))
        .decoration! as BoxDecoration;
    expect((reached.border! as Border).top.color, AppPalette.gold);
    expect(pending.border, isNull);
  });
}
