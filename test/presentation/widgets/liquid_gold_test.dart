import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/liquid_gold.dart';

/// Dorado líquido (HU-002 R15–R17).
void main() {
  Future<void> pump(WidgetTester tester, Widget gold, {bool reduceMotion = false}) {
    return tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: reduceMotion),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(child: SizedBox(width: 200, height: 100, child: gold)),
        ),
      ),
    );
  }

  LiquidGoldPainter painter(WidgetTester tester) {
    final CustomPaint paint = tester.widget<CustomPaint>(find.byKey(const ValueKey<String>('liquid-gold')));
    return paint.painter! as LiquidGoldPainter;
  }

  testWidgets('the surface rocks and the bubbles rise while it is on screen (criterion 14)', (tester) async {
    await pump(tester, const LiquidGold(fraction: 0.6));

    expect(painter(tester).moving, isTrue);
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(LiquidGold.period);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stays still with reduced motion (criterion 15)', (tester) async {
    await pump(tester, const LiquidGold(fraction: 0.6), reduceMotion: true);

    expect(painter(tester).moving, isFalse);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('does not animate when empty or when asked to stay still', (tester) async {
    await pump(tester, const LiquidGold(fraction: 0));
    expect(tester.hasRunningAnimations, isFalse);

    await pump(tester, const LiquidGold(fraction: 0.5, animate: false));
    expect(tester.hasRunningAnimations, isFalse);

    await pump(tester, const LiquidGold(fraction: 0.5));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('stops when the screen is not visible (R17, criterion 16)', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: TickerMode(enabled: false, child: SizedBox(width: 200, height: 100, child: LiquidGold(fraction: 0.6))),
      ),
    );
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('can be translucent, to let an icon show through', (tester) async {
    await pump(tester, const LiquidGold(fraction: 0.3, translucent: true));

    expect(painter(tester).translucent, isTrue);
    await tester.pump(const Duration(milliseconds: 500));
  });

  test('the surface is at the height of the fraction, and repaints when it changes', () {
    expect(LiquidGoldPainter.surfaceY(100, 0), 100);
    expect(LiquidGoldPainter.surfaceY(100, 0.6), closeTo(40, 1e-9));
    expect(LiquidGoldPainter.surfaceY(100, 1), 0);

    const animation = AlwaysStoppedAnimation<double>(0);
    final a = LiquidGoldPainter(fraction: 0.5, animation: animation, moving: true);
    expect(a.shouldRepaint(LiquidGoldPainter(fraction: 0.5, animation: animation, moving: true)), isFalse);
    expect(a.shouldRepaint(LiquidGoldPainter(fraction: 0.6, animation: animation, moving: true)), isTrue);
    expect(a.shouldRepaint(LiquidGoldPainter(fraction: 0.5, animation: animation, moving: true, translucent: true)),
        isTrue);
  });

  test('rejects a fraction outside 0 to 1', () {
    expect(() => LiquidGold(fraction: 1.2), throwsAssertionError);
  });
}
