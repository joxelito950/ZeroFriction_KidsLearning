import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/presentation/widgets/game_icon.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget icon) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: Center(child: icon))));

  testWidgets('shows the game image at its size, hidden from the screen reader', (tester) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pump(tester, const GameIcon.memory(size: 48));

    final Image image = tester.widget<Image>(find.byType(Image));
    expect((image.image as AssetImage).assetName, BrandAssets.memoryIcon);
    expect(tester.getSize(find.byType(Image)), const Size(48, 48));
    expect(find.byKey(const ValueKey<String>('game-icon-gold')), findsNothing);
    expect(tester.getSemantics(find.byType(GameIcon)).label, isEmpty);
    semantics.dispose();
  });

  testWidgets('fills the silhouette with gold from the bottom up (HU-002 preparation)', (tester) async {
    await pump(tester, const GameIcon.memory(size: 48, goldFraction: 0.4));

    final ShaderMask mask = tester.widget<ShaderMask>(find.byKey(const ValueKey<String>('game-icon-gold')));
    expect(mask.blendMode, BlendMode.srcATop);
    final Shader shader = mask.shaderCallback(const Rect.fromLTWH(0, 0, 48, 48));
    expect(shader, isA<Shader>());
    expect(find.byType(Image), findsNWidgets(2));
  });

  test('rejects a gold fraction outside 0 to 1', () {
    expect(() => GameIcon(asset: BrandAssets.memoryIcon, size: 10, goldFraction: 1.5), throwsAssertionError);
  });

  testWidgets('a missing image leaves an empty space instead of an error', (tester) async {
    await pump(tester, const GameIcon(asset: 'assets/brand/missing.png', size: 30));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(GameIcon)), const Size(30, 30));
  });
}
