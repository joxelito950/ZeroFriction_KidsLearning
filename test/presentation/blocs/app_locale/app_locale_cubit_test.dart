import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/presentation/blocs/app_locale/app_locale_cubit.dart';

import '../../memory_game_test_support.dart';

void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  group('AppLocaleCubit (HU-012)', () {
    test('starts with the startup language', () {
      final cubit = AppLocaleCubit(repository: repository, initial: const Locale('es'));
      expect(cubit.state, const Locale('es'));
      cubit.close();
    });

    test('changes the language right away and saves it keeping the rest of the profile (R3)', () async {
      when(() => repository.readUserProfile()).thenAnswer(
        (_) async => const UserProfile(isPremium: true, isSoundEnabled: false, languageCode: 'es'),
      );
      final cubit = AppLocaleCubit(repository: repository, initial: const Locale('es'));

      final Future<void> change = cubit.select('ar');
      expect(cubit.state, const Locale('ar'), reason: 'before the save finishes');
      await change;

      verify(
        () => repository.saveUserProfile(
          const UserProfile(isPremium: true, isSoundEnabled: false, languageCode: 'ar'),
        ),
      ).called(1);
      await cubit.close();
    });

    test('saves a default profile when there is none yet', () async {
      when(() => repository.readUserProfile()).thenAnswer((_) async => null);
      final cubit = AppLocaleCubit(repository: repository, initial: const Locale('en'));

      await cubit.select('de');

      verify(
        () => repository.saveUserProfile(
          const UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'de'),
        ),
      ).called(1);
      await cubit.close();
    });

    test('keeps the new language for the session if it cannot be saved (R6)', () async {
      when(() => repository.saveUserProfile(any())).thenThrow(Exception('disk full'));
      final cubit = AppLocaleCubit(repository: repository, initial: const Locale('es'));

      await cubit.select('fr');

      expect(cubit.state, const Locale('fr'));
      await cubit.close();
    });

    test('ignores the current language and unsupported ones', () async {
      final cubit = AppLocaleCubit(repository: repository, initial: const Locale('es'));

      await cubit.select('es');
      await cubit.select('zh');

      expect(cubit.state, const Locale('es'));
      verifyNever(() => repository.saveUserProfile(any()));
      await cubit.close();
    });
  });
}
