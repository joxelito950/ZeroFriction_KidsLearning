import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/feedback/feedback_email.dart';
import '../../l10n/app_localizations.dart';

/// Tarjeta «Ayuda y comentarios» de la Zona de Padres (HU-032): abre la app de
/// correo con un correo preparado y sin enviar. Si no hay app de correo, o el
/// canal no está disponible, muestra la dirección para copiarla (R6).
class ParentsFeedbackSection extends StatefulWidget {
  const ParentsFeedbackSection({super.key});

  @override
  State<ParentsFeedbackSection> createState() => _ParentsFeedbackSectionState();
}

class _ParentsFeedbackSectionState extends State<ParentsFeedbackSection> {
  bool _opening = false;

  /// No se pudo abrir la app de correo: se ofrece la dirección.
  bool _showAddress = false;

  Future<void> _send() async {
    final l10n = AppLocalizations.of(context);
    final String language = Localizations.localeOf(context).languageCode;
    final IFeedbackChannel? channel = context.read<IFeedbackChannel?>();
    if (channel == null) {
      setState(() => _showAddress = true);
      return;
    }
    setState(() => _opening = true);
    final DeviceReport report = await channel.readReport(language: language);
    final Uri email = FeedbackEmail.uri(
      FeedbackEmailTexts(
        subject: l10n.feedbackEmailSubject(report.appVersion),
        whatHappened: l10n.feedbackEmailWhatHappened,
        whatExpected: l10n.feedbackEmailWhatExpected,
      ),
      report,
    );
    final bool opened = await channel.openEmail(email);
    if (!mounted) return;
    setState(() {
      _opening = false;
      _showAddress = !opened;
    });
  }

  Future<void> _copyAddress() async {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    final String copied = AppLocalizations.of(context).parentsFeedbackCopied;
    await Clipboard.setData(const ClipboardData(text: FeedbackEmail.address));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(copied)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      key: const ValueKey<String>('parents-zone-feedback'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mail_outline_rounded),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.parentsFeedbackTitle,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.parentsFeedbackIntro, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey<String>('parents-zone-feedback-send'),
              onPressed: _opening ? null : _send,
              icon: const Icon(Icons.send_rounded),
              label: Text(l10n.parentsFeedbackSend),
            ),
            if (_showAddress) ...[
              const SizedBox(height: 12),
              Text(l10n.parentsFeedbackNoEmailApp, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  const SelectableText(
                    FeedbackEmail.address,
                    key: ValueKey<String>('parents-zone-feedback-address'),
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextButton.icon(
                    key: const ValueKey<String>('parents-zone-feedback-copy'),
                    onPressed: _copyAddress,
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(l10n.parentsFeedbackCopy),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
