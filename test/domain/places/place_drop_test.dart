import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/places/place_drop.dart';
import 'package:toddler_logic/domain/shadows/shadow_drop.dart';

void main() {
  const ShadowBox red = ShadowBox(left: 0, top: 0, width: 200, height: 200);
  const ShadowBox blue = ShadowBox(left: 300, top: 0, width: 200, height: 200);
  const Map<String, ShadowBox> baskets = {'red': red, 'blue': blue};

  ShadowDropOutcome drop(ShadowBox piece) =>
      PlaceDrop.evaluate<String>(target: 'red', piece: piece, targets: baskets, threshold: 0.5);

  test('measures how much of the piece falls on the target', () {
    expect(PlaceDrop.overlap(const ShadowBox(left: 0, top: 0, width: 80, height: 80), red), 1);
    expect(PlaceDrop.overlap(const ShadowBox(left: 160, top: 0, width: 80, height: 80), red), closeTo(0.5, 1e-9));
  });

  test('snaps on its own target, fails on another one and misses elsewhere', () {
    expect(drop(const ShadowBox(left: 50, top: 50, width: 80, height: 80)), ShadowDropOutcome.snapped);
    expect(drop(const ShadowBox(left: 350, top: 50, width: 80, height: 80)), ShadowDropOutcome.wrongShadow);
    expect(drop(const ShadowBox(left: 50, top: 400, width: 80, height: 80)), ShadowDropOutcome.missed);
  });

  test('a full target is not in the map: dropping there is a miss, not a snap', () {
    expect(
      PlaceDrop.evaluate<String>(
        target: 'red',
        piece: const ShadowBox(left: 50, top: 50, width: 80, height: 80),
        targets: const {'blue': blue},
        threshold: 0.5,
      ),
      ShadowDropOutcome.missed,
    );
  });
}
