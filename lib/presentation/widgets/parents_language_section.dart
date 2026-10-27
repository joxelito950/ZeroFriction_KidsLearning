import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_language.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/app_locale/app_locale_cubit.dart';

/// Sección «Idioma» de la Zona de Padres (HU-012): los 9 idiomas con su nombre
/// propio, sin banderas, en orden fijo y con el actual marcado (R1, R2, P4).
class ParentsLanguageSection extends StatelessWidget {
  const ParentsLanguageSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String current = context.watch<AppLocaleCubit>().state.languageCode;

    return Card(
      key: const ValueKey<String>('parents-zone-language'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.translate_rounded),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.parentsZoneLanguageTitle,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(l10n.parentsZoneLanguageIntro, style: theme.textTheme.bodyMedium),
            ),
            for (final code in AppLanguage.supported)
              _LanguageTile(code: code, selected: code == current),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({required this.code, required this.selected});

  final String code;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final String name = AppLanguage.nativeNames[code]!;
    final Locale locale = Locale(code);

    return ListTile(
      key: ValueKey<String>('language-$code'),
      selected: selected,
      onTap: () => context.read<AppLocaleCubit>().select(code),
      // El lector de pantalla pronuncia cada nombre en su idioma (criterio 7).
      title: Semantics(
        attributedLabel: AttributedString(
          name,
          attributes: [LocaleStringAttribute(range: TextRange(start: 0, end: name.length), locale: locale)],
        ),
        excludeSemantics: true,
        child: Text(name, locale: locale),
      ),
      trailing: selected ? const Icon(Icons.check_rounded) : null,
    );
  }
}
