import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/entities/app_language.dart';

void main() {
  group('AppLanguage.resolve', () {
    test('picks the first supported language from the device preferences', () {
      expect(AppLanguage.resolve(['de-DE', 'en-US']), 'de');
      expect(AppLanguage.resolve(['xx', 'ja-JP', 'en']), 'ja');
    });

    test('matches by language regardless of country or script', () {
      expect(AppLanguage.resolve(['es-MX']), 'es');
      expect(AppLanguage.resolve(['es-ES']), 'es');
      expect(AppLanguage.resolve(['es-419']), 'es');
      expect(AppLanguage.resolve(['pt-BR']), 'pt');
      expect(AppLanguage.resolve(['pt-PT']), 'pt');
      expect(AppLanguage.resolve(['ar-EG']), 'ar');
      expect(AppLanguage.resolve(['ko-Kore-KR']), 'ko');
    });

    test('accepts underscore separators and any letter case', () {
      expect(AppLanguage.resolve(['PT_br']), 'pt');
      expect(AppLanguage.resolve(['Fr_CA']), 'fr');
    });

    test('falls back to US English when nothing is supported or readable', () {
      expect(AppLanguage.resolve(['zh-CN', 'ru-RU']), 'en');
      expect(AppLanguage.resolve(const []), 'en');
      expect(AppLanguage.resolve(['', '  ']), 'en');
      expect(AppLanguage.fallback, 'en');
    });
  });

  group('AppLanguage.helperFor (HU-021 R1)', () {
    test('uses the first phone language that is supported and differs from the app', () {
      expect(AppLanguage.helperFor('de', ['es-CO']), 'es');
      expect(AppLanguage.helperFor('es', ['es-CO', 'en-US']), 'en');
      expect(AppLanguage.helperFor('es', ['ru-RU', 'fr-FR', 'en-US']), 'fr');
      expect(AppLanguage.helperFor('ar', ['pt_PT']), 'pt');
      expect(AppLanguage.helperFor('en', ['ja-JP']), 'ja');
    });

    test('falls back to English when the phone offers nothing else', () {
      expect(AppLanguage.helperFor('de', ['de-DE']), 'en');
      expect(AppLanguage.helperFor('ko', ['ru-RU', 'zh-CN']), 'en');
      expect(AppLanguage.helperFor('ja', const []), 'en');
    });

    test('gives no helper when the app is in English and nothing better exists', () {
      expect(AppLanguage.helperFor('en', ['en-US']), isNull);
      expect(AppLanguage.helperFor('en', ['ru-RU']), isNull);
      expect(AppLanguage.helperFor('en', const []), isNull);
    });
  });

  group('AppLanguage.isSupported', () {
    test('accepts exactly the nine supported language codes', () {
      expect(AppLanguage.supported, ['en', 'es', 'pt', 'de', 'ja', 'fr', 'it', 'ko', 'ar']);
      for (final code in AppLanguage.supported) {
        expect(AppLanguage.isSupported(code), isTrue, reason: code);
      }
      expect(AppLanguage.isSupported('zh'), isFalse);
      expect(AppLanguage.isSupported(null), isFalse);
    });
  });

  group('AppLanguage.nativeNames (HU-012 R2)', () {
    test('names every supported language, in the same order, in its own language', () {
      expect(AppLanguage.nativeNames.keys, orderedEquals(AppLanguage.supported));
      expect(AppLanguage.nativeNames['es'], 'Español');
      expect(AppLanguage.nativeNames['ja'], '日本語');
      expect(AppLanguage.nativeNames['ar'], 'العربية');
    });
  });
}
