import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/feedback/feedback_email.dart';

/// [IFeedbackChannel] con los plugins del teléfono (HU-032). Ninguno añade
/// permisos (R2). Las tres lecturas se pueden sustituir en los tests.
class PlatformFeedbackChannel implements IFeedbackChannel {
  PlatformFeedbackChannel({
    Future<String> Function()? appVersion,
    Future<(String android, String model)> Function()? device,
    Future<bool> Function(Uri email)? launch,
  })  : _appVersion = appVersion ?? _readAppVersion,
        _device = device ?? _readDevice,
        _launch = launch ?? _launchEmail;

  final Future<String> Function() _appVersion;
  final Future<(String, String)> Function() _device;
  final Future<bool> Function(Uri) _launch;

  /// Si un dato no se puede leer, se pone esto: el correo sale igual.
  static const String unknown = '?';

  @override
  Future<DeviceReport> readReport({required String language}) async {
    String appVersion = unknown;
    var (String android, String model) = (unknown, unknown);
    try {
      appVersion = await _appVersion();
    } catch (_) {}
    try {
      (android, model) = await _device();
    } catch (_) {}
    return DeviceReport(appVersion: appVersion, androidVersion: android, model: model, language: language);
  }

  /// Sin app de correo, `launchUrl` devuelve `false` o lanza: los dos casos
  /// son «no se pudo» (R6).
  @override
  Future<bool> openEmail(Uri email) async {
    try {
      return await _launch(email);
    } catch (_) {
      return false;
    }
  }

  static Future<String> _readAppVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return '${info.version}+${info.buildNumber}';
  }

  static Future<(String, String)> _readDevice() async {
    final AndroidDeviceInfo info = await DeviceInfoPlugin().androidInfo;
    return ('${info.version.release} (SDK ${info.version.sdkInt})', '${info.manufacturer} ${info.model}');
  }

  static Future<bool> _launchEmail(Uri email) => launchUrl(email, mode: LaunchMode.externalApplication);
}
