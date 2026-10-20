import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toddler_logic/domain/entities/app_language.dart';
import 'package:toddler_logic/domain/entities/user_profile.dart';
import 'package:toddler_logic/l10n/app_localizations.dart';
import 'package:toddler_logic/presentation/l10n/startup_locale.dart';

import '../memory_game_test_support.dart';

void main() {
  setUpAll(registerMemoryGameFallbacks);

  late MockPersistenceRepository repository;

  setUp(() {
    repository = MockPersistenceRepository();
    stubPersistenceRepository(repository);
  });

  test('first launch takes the device language and saves it', () async {
    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('zh', 'CN'), Locale('de', 'AT')],
    );

    expect(locale, const Locale('de'));
    verify(
      () => repository.saveUserProfile(
        const UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'de'),
      ),
    ).called(1);
  });

  test('first launch on an unsupported device language uses US English', () async {
    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('ru', 'RU')],
    );

    expect(locale, const Locale('en'));
    verify(
      () => repository.saveUserProfile(
        any(that: isA<UserProfile>().having((p) => p.languageCode, 'languageCode', 'en')),
      ),
    ).called(1);
  });

  test('a saved language wins even if the device language changed', () async {
    when(() => repository.readUserProfile()).thenAnswer(
      (_) async => const UserProfile(isPremium: true, isSoundEnabled: false, languageCode: 'ja'),
    );

    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('fr', 'FR')],
    );

    expect(locale, const Locale('ja'));
    verifyNever(() => repository.saveUserProfile(any()));
  });

  test('keeps the other profile values when saving the language', () async {
    when(() => repository.readUserProfile()).thenAnswer(
      (_) async => const UserProfile(isPremium: true, isSoundEnabled: false),
    );

    await resolveStartupLocale(repository: repository, systemLocales: const [Locale('ko')]);

    verify(
      () => repository.saveUserProfile(
        const UserProfile(isPremium: true, isSoundEnabled: false, languageCode: 'ko'),
      ),
    ).called(1);
  });

  test('a saved but no longer supported language is resolved again', () async {
    when(() => repository.readUserProfile()).thenAnswer(
      (_) async => const UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'xx'),
    );

    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('it', 'IT')],
    );

    expect(locale, const Locale('it'));
  });

  test('uses the default profile when none is stored', () async {
    when(() => repository.readUserProfile()).thenAnswer((_) async => null);

    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('pt', 'BR')],
    );

    expect(locale, const Locale('pt'));
    verify(
      () => repository.saveUserProfile(
        const UserProfile(isPremium: false, isSoundEnabled: true, languageCode: 'pt'),
      ),
    ).called(1);
  });

  test('a failure while saving does not block the start-up', () async {
    when(() => repository.saveUserProfile(any())).thenThrow(StateError('disk full'));

    final locale = await resolveStartupLocale(
      repository: repository,
      systemLocales: const [Locale('es', 'CO')],
    );

    expect(locale, const Locale('es'));
  });

  test('the domain language list matches the generated catalog', () {
    expect(
      AppLocalizations.supportedLocales.map((locale) => locale.languageCode).toSet(),
      AppLanguage.supported.toSet(),
    );
  });
}
