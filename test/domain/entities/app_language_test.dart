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
}
