import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/privacy_policy_assets.dart';
import 'policy_document.dart';

/// Sección «Privacidad» de la Zona de Padres (HU-014 R5): un resumen y la
/// política completa al desplegarla. Va dentro de la Zona de Padres, no en otra
/// pantalla, para que desplazarse por el texto cuente como actividad para
/// [AdultSessionGuard] y la sesión no se cierre mientras el adulto lee.
class ParentsPrivacySection extends StatefulWidget {
  const ParentsPrivacySection({super.key});

  @override
  State<ParentsPrivacySection> createState() => _ParentsPrivacySectionState();
}

class _ParentsPrivacySectionState extends State<ParentsPrivacySection> {
  String? _asset;

  /// Se carga al abrir la sección por primera vez, no antes.
  Future<String>? _policy;

  void _load() {
    final String asset = privacyPolicyAsset(Localizations.localeOf(context).languageCode);
    if (asset == _asset) return;
    _asset = asset;
    _policy = DefaultAssetBundle.of(context).loadString(asset);
  }

  /// Se vuelve a cargar si se cambia de idioma con la política ya cargada (HU-012).
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_policy != null) _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('parents-zone-privacy'),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        key: const ValueKey<String>('parents-zone-privacy-toggle'),
        leading: const Icon(Icons.privacy_tip_outlined),
        title: Text(
          l10n.parentsZonePrivacyTitle,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(l10n.parentsZonePrivacyIntro, style: theme.textTheme.bodyMedium),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        onExpansionChanged: (expanded) {
          if (expanded) setState(_load);
        },
        children: [
          FutureBuilder<String>(
            future: _policy,
            builder: (context, snapshot) {
              final String? markdown = snapshot.data;
              if (markdown == null) return const Center(child: CircularProgressIndicator.adaptive());
              return PolicyDocument(key: const ValueKey<String>('parents-zone-privacy-policy'), markdown: markdown);
            },
          ),
        ],
      ),
    );
  }
}
