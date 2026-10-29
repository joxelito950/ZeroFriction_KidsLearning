import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart' show Bidi;

import '../../domain/entities/app_language.dart';
import '../../l10n/app_localizations.dart';

/// Idioma de ayuda para un adulto que no lee el idioma de la app (HU-021 R1):
/// se calcula con los idiomas del teléfono **en cada construcción**, así que el
/// desafío lo toma al abrirse (R2). `null` si no hay ayuda.
String? helperLanguageOf(BuildContext context) {
  final String appLanguage = Localizations.localeOf(context).languageCode;
  final Iterable<String> phoneLanguages =
      View.of(context).platformDispatcher.locales.map((locale) => locale.toLanguageTag());
  return AppLanguage.helperFor(appLanguage, phoneLanguages);
}

/// El mismo texto de la app en el idioma de ayuda (HU-021 R3–R5), con su
/// dirección de escritura y su idioma para el lector de pantalla. No ocupa
/// nada si no hay idioma de ayuda.
class HelperLanguageText extends StatelessWidget {
  const HelperLanguageText({super.key, required this.text, this.style, this.textAlign});

  /// Elige el texto del catálogo; recibe el catálogo del idioma de ayuda.
  final String Function(AppLocalizations l10n) text;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final String? languageCode = helperLanguageOf(context);
    if (languageCode == null) return const SizedBox.shrink();

    final locale = Locale(languageCode);
    final String value = text(lookupAppLocalizations(locale));

    return Directionality(
      textDirection: Bidi.isRtlLanguage(languageCode) ? TextDirection.rtl : TextDirection.ltr,
      child: Semantics(
        attributedLabel: AttributedString(
          value,
          attributes: [LocaleStringAttribute(range: TextRange(start: 0, end: value.length), locale: locale)],
        ),
        excludeSemantics: true,
        child: Text(value, locale: locale, style: style, textAlign: textAlign),
      ),
    );
  }
}
