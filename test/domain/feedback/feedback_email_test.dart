import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/domain/feedback/feedback_email.dart';

/// HU-032: el correo de comentarios preparado.
void main() {
  const report = DeviceReport(
    appVersion: '1.0.0-rc.2+3',
    androidVersion: '14 (SDK 34)',
    model: 'motorola moto g55 5G',
    language: 'es',
  );
  const texts = FeedbackEmailTexts(
    subject: 'ToddlerLogic · Comentarios (1.0.0-rc.2+3)',
    whatHappened: '¿Qué pasó?',
    whatExpected: '¿Qué esperabas?',
  );

  test('goes to the contact address with the subject and the body (R2, R5)', () {
    final Uri uri = FeedbackEmail.uri(texts, report);
    expect(uri.scheme, 'mailto');
    expect(uri.path, 'toddler.logic.app@outlook.com');
    expect(uri.queryParameters['subject'], texts.subject);
    expect(uri.queryParameters['body'], FeedbackEmail.body(texts, report));
  });

  test('spaces are encoded as %20, never as «+» (some email apps show it as is)', () {
    final String query = FeedbackEmail.uri(texts, report).toString().split('?').last;
    expect(query, contains('%20'));
    expect(query, isNot(contains(' ')));
    expect(query.replaceAll('%2B', ''), isNot(contains('+')));
  });

  test('the body has the two guide lines first and the technical data last, nothing else (R4)', () {
    final List<String> lines = FeedbackEmail.body(texts, report).split('\n');
    expect(lines.first, '¿Qué pasó?');
    expect(lines, contains('¿Qué esperabas?'));
    expect(lines.sublist(lines.indexOf('---')), [
      '---',
      'App: 1.0.0-rc.2+3',
      'Android: 14 (SDK 34)',
      'Device: motorola moto g55 5G',
      'Language: es',
    ]);
  });
}
