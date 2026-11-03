import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/presentation/widgets/gesture_hint.dart';

final Finder _hand = find.byKey(const ValueKey<String>('gesture-hint-hand'));

/// Un tablero de prueba con dos casillas y un contador de toques.
class _Board extends StatefulWidget {
  const _Board({
    required this.boardId,
    this.gesture = HintGesture.tap,
    this.enabled = true,
    this.disableAnimations = false,
  });

  final Object boardId;
  final HintGesture gesture;
  final bool enabled;
  final bool disableAnimations;

  @override
  State<_Board> createState() => _BoardState();
}

class _BoardState extends State<_Board> {
  final GlobalKey source = GlobalKey();
  final GlobalKey destination = GlobalKey();
  int taps = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: widget.disableAnimations),
        child: Scaffold(
          body: GestureHint(
            boardId: widget.boardId,
            target: source,
            dragTo: destination,
            gesture: widget.gesture,
            enabled: widget.enabled,
            dragGhost: const Text('🐘'),
            child: Column(
              children: [
                GestureDetector(
                  key: const ValueKey<String>('source'),
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => taps++),
                  child: SizedBox(key: source, width: 120, height: 120),
                ),
                const SizedBox(height: 200),
                SizedBox(key: destination, width: 120, height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lleva una demostración hasta su mitad.
Future<void> _midCycle(WidgetTester tester) => tester.pump(GestureHint.cycle ~/ 2);

void main() {
  group('GestureHint (HU-022)', () {
    testWidgets('appears after 4 s without touches and repeats every 8 s (R2, criterio 1)', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1));

      await tester.pump(const Duration(milliseconds: 3900));
      expect(_hand, findsNothing);

      await tester.pump(const Duration(milliseconds: 100));
      await _midCycle(tester);
      expect(_hand, findsOneWidget);

      await tester.pump(GestureHint.cycle);
      expect(_hand, findsNothing, reason: 'the demonstration ends');

      // 4 s + 8 s: la siguiente demostración.
      await tester.pump(GestureHint.defaultRepeatEvery - GestureHint.cycle - GestureHint.cycle ~/ 2);
      await _midCycle(tester);
      expect(_hand, findsOneWidget);
    });

    testWidgets('lets the touch through and never comes back on this board (R3, R4, criterios 2 y 3)', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1));
      await tester.pump(GestureHint.defaultFirstDelay);
      await _midCycle(tester);
      expect(_hand, findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('source')));
      await tester.pump(const Duration(milliseconds: 200));

      final _BoardState board = tester.state(find.byType(_Board));
      expect(board.taps, 1, reason: 'the hint does not swallow the touch');
      final AnimatedOpacity fade =
          tester.widget(find.descendant(of: find.byType(GestureHint), matching: find.byType(AnimatedOpacity)));
      expect(fade.opacity, 0, reason: 'the hand fades out');

      await tester.pump(const Duration(seconds: 30));
      expect(_hand, findsNothing);
    });

    testWidgets('a new board brings it back (R3)', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1));
      await tester.tap(find.byKey(const ValueKey<String>('source')));
      await tester.pump(const Duration(seconds: 10));
      expect(_hand, findsNothing);

      await tester.pumpWidget(const _Board(boardId: 2));
      await tester.pump(GestureHint.defaultFirstDelay);
      await _midCycle(tester);
      expect(_hand, findsOneWidget);
    });

    testWidgets('stays hidden while disabled', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1, enabled: false));
      await tester.pump(const Duration(seconds: 20));
      expect(_hand, findsNothing);

      await tester.pumpWidget(const _Board(boardId: 1));
      await tester.pump(GestureHint.defaultFirstDelay);
      await _midCycle(tester);
      expect(_hand, findsOneWidget);
    });

    testWidgets('the tap demonstration shows the touch circle on the target', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1));
      await tester.pump(GestureHint.defaultFirstDelay);
      await tester.pump(GestureHint.cycle * 0.65);

      final Offset ripple = tester.getCenter(find.byKey(const ValueKey<String>('gesture-hint-ripple')));
      expect(ripple, offsetMoreOrLessEquals(tester.getCenter(find.byKey(const ValueKey<String>('source'))), epsilon: 1));
    });

    testWidgets('the drag demonstration carries a ghost from the target to the destination', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1, gesture: HintGesture.drag));
      await tester.pump(GestureHint.defaultFirstDelay);
      await tester.pump(GestureHint.cycle * 0.2);
      final Offset start = tester.getCenter(find.byKey(const ValueKey<String>('gesture-hint-ghost')));

      await tester.pump(GestureHint.cycle * 0.6);
      final Offset end = tester.getCenter(find.byKey(const ValueKey<String>('gesture-hint-ghost')));

      expect(start.dy, lessThan(end.dy), reason: 'the ghost moves down towards the destination');
      expect(find.byKey(const ValueKey<String>('gesture-hint-ripple')), findsNothing);
    });

    testWidgets('with reduced motion the hand stays still on the target (R7, criterio 5)', (tester) async {
      await tester.pumpWidget(const _Board(boardId: 1, disableAnimations: true));
      await tester.pump(GestureHint.defaultFirstDelay);
      await tester.pump(GestureHint.cycle * 0.3);
      final Offset first = tester.getTopLeft(_hand);

      await tester.pump(GestureHint.cycle * 0.3);
      expect(tester.getTopLeft(_hand), first);
      expect(find.byKey(const ValueKey<String>('gesture-hint-ripple')), findsNothing);
    });
  });

  group('handPoseAt', () {
    const from = Offset(100, 100);
    const to = Offset(100, 400);

    test('fades in and out', () {
      expect(handPoseAt(0, gesture: HintGesture.tap, from: from, to: from).opacity, 0);
      expect(handPoseAt(0.5, gesture: HintGesture.tap, from: from, to: from).opacity, 1);
      expect(handPoseAt(1, gesture: HintGesture.tap, from: from, to: from).opacity, 0);
    });

    test('a tap ends on the target, pressed', () {
      final HandPose pose = handPoseAt(0.55, gesture: HintGesture.tap, from: from, to: from);

      expect(pose.fingertip, from);
      expect(pose.scale, lessThan(1));
    });

    test('a drag starts on the target and ends on the destination', () {
      expect(handPoseAt(0.15, gesture: HintGesture.drag, from: from, to: to).fingertip, from);
      expect(handPoseAt(0.85, gesture: HintGesture.drag, from: from, to: to).fingertip, to);
    });

    test('still stays on the target', () {
      for (final t in [0.2, 0.5, 0.8]) {
        expect(handPoseAt(t, gesture: HintGesture.drag, from: from, to: to, still: true).fingertip, from);
      }
    });
  });
}
