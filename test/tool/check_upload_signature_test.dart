import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_upload_signature.dart';

/// Salida de `keytool -printcert -jarfile` reducida a lo que se lee.
String _keytoolOutput({required String owner, required String sha256}) => '''
Signer #1:

Certificate #1:
Owner: $owner
Issuer: $owner
Valid from: Thu Oct 29 10:07:30 COT 2026 until: Mon Mar 16 10:07:30 COT 2054
Certificate fingerprints:
	 SHA1: 00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33
	 SHA256: $sha256
Signature algorithm name: SHA384withRSA
''';

void main() {
  group('classifySignature (HU-014 R2)', () {
    test('accepts the upload key', () {
      final String output = _keytoolOutput(owner: 'CN=Upload Key Owner, C=CO', sha256: uploadKeySha256);

      expect(classifySignature(output), SignatureVerdict.upload);
    });

    test('accepts the fingerprint in lowercase', () {
      final String output = _keytoolOutput(owner: 'CN=Owner', sha256: uploadKeySha256.toLowerCase());

      expect(classifySignature(output), SignatureVerdict.upload);
    });

    test('rejects the debug key', () {
      final String output = _keytoolOutput(
        owner: 'C=US, O=Android, CN=Android Debug',
        sha256: 'F7:4F:1B:10:ED:02:FD:74:49:DC:F2:8C:3F:75:33:42:B3:82:AA:CC:29:E1:9C:8F:8E:16:93:B4:09:EB:6B:97',
      );

      expect(classifySignature(output), SignatureVerdict.debug);
    });

    test('rejects any other key', () {
      final String output = _keytoolOutput(
        owner: 'CN=TD003 Throwaway Test',
        sha256: 'AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99',
      );

      expect(classifySignature(output), SignatureVerdict.otherKey);
    });

    test('reports an unsigned or unreadable file', () {
      expect(classifySignature('Not a signed jar file'), SignatureVerdict.unsigned);
      expect(classifySignature(''), SignatureVerdict.unsigned);
    });
  });
}
