import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/domain/news/edition_check.dart';
import 'package:toddler_logic/domain/news/special_edition.dart';
import 'package:toddler_logic/domain/progress/game_progress.dart';
import 'package:toddler_logic/domain/settings/app_release.dart';

import '../../presentation/memory_game_test_support.dart';

/// HU-042: ediciones especiales con la protección del reloj (R7 a R9).
void main() {
  setUpAll(registerMemoryGameFallbacks);

  const SpecialEdition christmas = SpecialEditions.christmas;
  final DateTime built = DateTime(2026, 11, 19);

  bool open(DateTime now, {DateTime? seen}) =>
      SpecialEditions.isOpen(christmas, now: now, highestSeen: seen, builtOn: built);

  group('window (P1, P5)', () {
    test('from 20 November to 6 January, both included, every year', () {
      expect(christmas.contains(DateTime(2026, 11, 19)), isFalse);
      expect(christmas.contains(DateTime(2026, 11, 20)), isTrue);
      expect(christmas.contains(DateTime(2026, 12, 31, 23)), isTrue);
      expect(christmas.contains(DateTime(2027, 1, 6, 22)), isTrue);
      expect(christmas.contains(DateTime(2027, 1, 7)), isFalse);
      expect(christmas.contains(DateTime(2027, 11, 25)), isTrue);
      expect(christmas.contains(DateTime(2027, 6, 1)), isFalse);
    });

    test('a window inside the year works too', () {
      const SpecialEdition summer = SpecialEdition(game: GameId.vehicles, from: MonthDay(7, 1), until: MonthDay(7, 31));
      expect(summer.contains(DateTime(2027, 7, 15)), isTrue);
      expect(summer.contains(DateTime(2027, 8, 1)), isFalse);
    });
  });

  group('clock protection (R7, R8)', () {
    test('open on a real Christmas day', () {
      expect(open(DateTime(2026, 12, 1), seen: DateTime(2026, 11, 30)), isTrue);
      expect(open(DateTime(2026, 12, 1)), isTrue, reason: 'first start with HU-042');
    });

    test('setting the clock back after the edition never reopens it; 2 days of slack', () {
      expect(open(DateTime(2026, 12, 20), seen: DateTime(2027, 1, 8)), isFalse);
      expect(open(DateTime(2026, 12, 20), seen: DateTime(2026, 12, 21)), isTrue, reason: 'time zone change');
    });

    test('moving the clock beyond the support of the version does not open future editions', () {
      expect(open(DateTime(2027, 12, 1)), isTrue, reason: 'within 13 months');
      expect(open(DateTime(2028, 12, 1)), isFalse);
    });

    test('the highest date never goes down', () {
      expect(SpecialEditions.highest(null, DateTime(2026, 11, 19)), DateTime(2026, 11, 19));
      expect(SpecialEditions.highest(DateTime(2026, 12, 1), DateTime(2026, 11, 19)), DateTime(2026, 12, 1));
      expect(SpecialEditions.highest(DateTime(2026, 11, 1), DateTime(2026, 11, 19)), DateTime(2026, 11, 19));
    });

    test('the release date of this version is set', () {
      expect(AppRelease.builtOn.year, greaterThanOrEqualTo(2026));
    });
  });

  group('EditionCheck', () {
    late MockPersistenceRepository repository;
    setUp(() {
      repository = MockPersistenceRepository();
      stubPersistenceRepository(repository);
    });

    test('refresh saves the highest date and says which games are open', () async {
      when(() => repository.readUserProfile())
          .thenAnswer((_) async => const UserProfile(isPremium: false, isSoundEnabled: true));
      expect(await EditionCheck.refresh(repository, now: DateTime(2026, 12, 1), builtOn: built), {GameId.vehicles});
      final UserProfile saved = verify(() => repository.saveUserProfile(captureAny())).captured.single as UserProfile;
      expect(saved.highestSeenDate, DateTime(2026, 12, 1));
    });

    test('refresh does not save when the date did not go up', () async {
      when(() => repository.readUserProfile()).thenAnswer(
          (_) async => UserProfile(isPremium: false, isSoundEnabled: true, highestSeenDate: DateTime(2026, 12, 2)));
      expect(await EditionCheck.refresh(repository, now: DateTime(2026, 12, 1), builtOn: built), {GameId.vehicles});
      verifyNever(() => repository.saveUserProfile(any()));
    });

    test('openNow only reads; errors close every edition (R9)', () async {
      when(() => repository.readUserProfile()).thenAnswer((_) async => null);
      expect(await EditionCheck.openNow(repository, now: DateTime(2026, 12, 1), builtOn: built), {GameId.vehicles});
      verifyNever(() => repository.saveUserProfile(any()));
      when(() => repository.readUserProfile()).thenThrow(Exception('disk'));
      expect(await EditionCheck.openNow(repository, now: DateTime(2026, 12, 1)), isEmpty);
      expect(await EditionCheck.refresh(repository, now: DateTime(2026, 12, 1)), isEmpty);
    });
  });
}
