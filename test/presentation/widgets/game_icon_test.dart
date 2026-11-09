import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/brand/brand_assets.dart';
import 'package:toddler_logic/presentation/widgets/game_icon.dart';
import 'package:toddler_logic/presentation/widgets/liquid_gold.dart';

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

  testWidgets('fills the silhouette with liquid gold, cut out by the icon itself (HU-002 R15, R16)', (tester) async {
    // La imagen se decodifica de verdad: hace falta tiempo real.
    await tester.runAsync(() async {
      await pump(tester, const GameIcon.memory(size: 48, goldFraction: 0.4));
      for (var i = 0; i < 50 && find.byKey(const ValueKey<String>('game-icon-gold')).evaluate().isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        await tester.pump();
      }
    });

    final ShaderMask mask = tester.widget<ShaderMask>(find.byKey(const ValueKey<String>('game-icon-gold')));
    expect(mask.blendMode, BlendMode.dstIn);
    expect(mask.shaderCallback(const Rect.fromLTWH(0, 0, 48, 48)), isA<ImageShader>());
    final LiquidGold gold = tester.widget<LiquidGold>(find.byType(LiquidGold));
    expect(gold.fraction, 0.4);
    expect(gold.translucent, isTrue);
    expect(gold.animate, isFalse);
  });

  test('the mask sits where BoxFit.contain puts the image', () async {
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint());
    final ui.Image image = await recorder.endRecording().toImage(200, 100);

    final Matrix4 transform = GameIcon.containTransform(const Size(50, 50), image);

    // Escala 0,25: 200 × 100 pasa a 50 × 25, centrado en vertical.
    expect(transform.storage[0], closeTo(0.25, 1e-9));
    expect(transform.storage[5], closeTo(0.25, 1e-9));
    expect(transform.getTranslation().y, closeTo(12.5, 1e-9));
    expect(transform.getTranslation().x, closeTo(0, 1e-9));
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
