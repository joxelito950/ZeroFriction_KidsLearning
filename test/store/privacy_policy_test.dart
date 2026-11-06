import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_logic/l10n/privacy_policy_assets.dart';
import 'package:toddler_logic/presentation/widgets/policy_document.dart';

/// La política de privacidad (HU-014 R4, R5): la misma en la web (GitHub Pages)
/// y en la app, con la misma estructura en cada idioma de la ficha.
void main() {
  final String pubspec = File('pubspec.yaml').readAsStringSync();

  for (final language in privacyPolicyLanguages) {
    final String asset = privacyPolicyAsset(language);

    test('the $language policy exists and is bundled with the app', () {
      expect(File(asset).existsSync(), isTrue, reason: asset);
      expect(pubspec, contains('- $asset'), reason: 'declare $asset under flutter > assets');
    });
  }

  test('every language has the same sections and bullets as the English one', () {
    List<PolicyBlockKind> structure(String language) => parsePolicy(File(privacyPolicyAsset(language)).readAsStringSync())
        .map((block) => block.kind)
        .where((kind) => kind != PolicyBlockKind.paragraph)
        .toList();

    final List<PolicyBlockKind> english = structure('en');
    for (final language in privacyPolicyLanguages) {
      expect(structure(language), english, reason: language);
    }
  });

  test('no policy has a pending placeholder, and all give the same contact email', () {
    final Set<String> emails = {};
    for (final language in privacyPolicyLanguages) {
      final String text = File(privacyPolicyAsset(language)).readAsStringSync();
      expect(text, isNot(contains('PENDIENTE')), reason: language);
      expect(text, isNot(contains('PENDING')), reason: language);
      emails.addAll(RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+').allMatches(text).map((match) => match.group(0)!));
    }
    expect(emails, {'toddler.logic.app@outlook.com'});
  });

  test('a language without its own policy falls back to English', () {
    expect(privacyPolicyAsset('fr'), privacyPolicyAsset('en'));
  });

  test('GitHub Pages publishes only the privacy policy (P4)', () {
    final String config = File('docs/_config.yml').readAsStringSync();
    final Iterable<String> published = Directory('docs')
        .listSync()
        .whereType<Directory>()
        .map((directory) => directory.uri.pathSegments.where((segment) => segment.isNotEmpty).last)
        .where((name) => name != 'privacy');

    for (final name in published) {
      expect(config, contains('  - $name'), reason: 'exclude docs/$name from GitHub Pages');
    }
  });
}
