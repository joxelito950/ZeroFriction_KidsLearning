import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_language.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/app_locale/app_locale_cubit.dart';
import 'parents_setting_page.dart';

/// Pantalla «Idioma» (HU-012, HU-046): los 9 idiomas con su nombre propio,
/// sin banderas, en orden fijo y con el actual marcado (R1, R2, P4). Elegir uno
/// lo aplica y vuelve a la Zona de Padres, sin «Guardar» (HU-046 P2): es la
/// única forma de leer la pantalla si se eligió uno por error.
class ParentsLanguagePage extends StatelessWidget {
  const ParentsLanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String current = context.watch<AppLocaleCubit>().state.languageCode;

    return ParentsSettingPage(
      key: const ValueKey<String>('parents-zone-language'),
      title: l10n.parentsZoneLanguageTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.parentsZoneLanguageIntro, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final code in AppLanguage.supported) _LanguageTile(code: code, selected: code == current),
              ],
            ),
          ),
        ],
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
      onTap: () {
        context.read<AppLocaleCubit>().select(code);
        Navigator.of(context).maybePop();
      },
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
