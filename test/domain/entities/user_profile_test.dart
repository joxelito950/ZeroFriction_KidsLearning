import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';

void main() {
  group('UserProfile', () {
    const profile = UserProfile(isPremium: false, isSoundEnabled: true);

    test('soundEnabled mirrors isSoundEnabled', () {
      expect(profile.soundEnabled, isTrue);
      expect(profile.copyWith(isSoundEnabled: false).soundEnabled, isFalse);
    });

    test('copyWith replaces only the provided fields', () {
      final premium = profile.copyWith(isPremium: true);

      expect(premium.isPremium, isTrue);
      expect(premium.isSoundEnabled, isTrue);
      expect(profile.copyWith(), profile);
    });

    test('implements value equality and a consistent hashCode', () {
      const same = UserProfile(isPremium: false, isSoundEnabled: true);
      const different = UserProfile(isPremium: true, isSoundEnabled: true);

      expect(profile, same);
      expect(profile.hashCode, same.hashCode);
      expect(profile, isNot(different));
    });
  });
}
