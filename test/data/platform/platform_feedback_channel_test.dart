import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toddler_logic/data/platform/platform_feedback_channel.dart';
import 'package:toddler_logic/domain/feedback/feedback_email.dart';

/// HU-032: los datos técnicos y la app de correo, con los plugins sustituidos.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('by default it uses the plugins: the version from the package, and no email app in tests', () async {
    PackageInfo.setMockInitialValues(
      appName: 'ToddlerLogic',
      packageName: 'com.zerofriction.toddler_logic',
      version: '1.0.0-rc.2',
      buildNumber: '3',
      buildSignature: '',
    );
    final channel = PlatformFeedbackChannel();
    final DeviceReport report = await channel.readReport(language: 'es');
    expect(report.appVersion, '1.0.0-rc.2+3');
    // Sin el plugin del sistema (tests), el modelo sale como «?» y no hay app de correo.
    expect(report.model, PlatformFeedbackChannel.unknown);
    expect(await channel.openEmail(Uri.parse('mailto:a@b.c')), isFalse);
  });

  test('reads the app version, Android and model, with the app language', () async {
    final channel = PlatformFeedbackChannel(
      appVersion: () async => '1.0.0+3',
      device: () async => ('14 (SDK 34)', 'motorola moto g55'),
    );
    final DeviceReport report = await channel.readReport(language: 'ar');
    expect(
      [report.appVersion, report.androidVersion, report.model, report.language],
      ['1.0.0+3', '14 (SDK 34)', 'motorola moto g55', 'ar'],
    );
  });

  test('a value that cannot be read becomes «?»: the email still opens', () async {
    final channel = PlatformFeedbackChannel(
      appVersion: () async => throw StateError('no plugin'),
      device: () async => throw StateError('no plugin'),
    );
    final DeviceReport report = await channel.readReport(language: 'es');
    expect([report.appVersion, report.androidVersion, report.model], everyElement(PlatformFeedbackChannel.unknown));
  });

  test('opening the email app reports whether it worked; an error means «no email app» (R6)', () async {
    final Uri email = Uri.parse('mailto:a@b.c');
    final opened = <Uri>[];
    final ok = PlatformFeedbackChannel(launch: (uri) async {
      opened.add(uri);
      return true;
    });
    expect(await ok.openEmail(email), isTrue);
    expect(opened, [email]);
    expect(await PlatformFeedbackChannel(launch: (_) async => false).openEmail(email), isFalse);
    expect(await PlatformFeedbackChannel(launch: (_) async => throw StateError('none')).openEmail(email), isFalse);
  });
}
