import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_release_permissions.dart';

String _manifest(String body) => '''
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.zerofriction.toddler_logic"
    android:versionCode="2"
    android:versionName="1.0.0-rc.1" >
$body
    <application android:label="ToddlerLogic" />
</manifest>
''';

const String _androidxPermission = '''
    <permission
        android:name="com.zerofriction.toddler_logic.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION"
        android:protectionLevel="signature" />
    <uses-permission android:name="com.zerofriction.toddler_logic.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" />
''';

void main() {
  group('forbiddenPermissions (HU-014 R3)', () {
    test('a manifest without permissions passes', () {
      expect(forbiddenPermissions(_manifest('')), isEmpty);
    });

    test('the internal AndroidX permission of the app itself is allowed', () {
      final String manifest = _manifest(_androidxPermission);

      expect(declaredPermissions(manifest), hasLength(2));
      expect(forbiddenPermissions(manifest), isEmpty);
    });

    test('any other permission fails, once per name', () {
      final String manifest = _manifest('''
$_androidxPermission
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission-sdk-23 android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.INTERNET" />
''');

      expect(forbiddenPermissions(manifest), unorderedEquals(['android.permission.INTERNET', 'android.permission.CAMERA']));
    });

    test('the AndroidX permission of another package is not allowed', () {
      final String manifest = _manifest(
        '    <uses-permission android:name="com.example.other.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION" />',
      );

      expect(forbiddenPermissions(manifest), ['com.example.other.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION']);
    });
  });
}
