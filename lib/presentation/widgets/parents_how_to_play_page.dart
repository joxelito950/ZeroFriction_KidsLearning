import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/settings/how_to_play.dart';
import '../../l10n/app_localizations.dart';
import '../blocs/how_to_play/how_to_play_cubit.dart';
import 'parents_setting_page.dart';

/// Los textos de «Cómo juega» (HU-039, HU-031).
abstract final class ParentsHowToPlayTexts {
  static String mode(AppLocalizations l10n, MoveMode mode) => switch (mode) {
        MoveMode.drag => l10n.moveModeDrag,
        MoveMode.tap => l10n.moveModeTap,
        MoveMode.both => l10n.moveModeBoth,
      };

  static String hand(AppLocalizations l10n, PlayingHand hand) => switch (hand) {
        PlayingHand.right => l10n.playingHandRight,
        PlayingHand.left => l10n.playingHandLeft,
      };

  /// Resumen de la fila: «Ambas · Mano derecha».
  static String summary(AppLocalizations l10n, HowToPlay how) =>
      '${mode(l10n, how.moveMode)} · ${hand(l10n, how.hand)}';
}

/// Pantalla «Cómo juega» (HU-039, HU-031): cómo se mueven las piezas y con qué
/// mano juega. Un borrador que se aplica con «Guardar» a todos los juegos a la
/// vez (HU-039 P5).
class ParentsHowToPlayPage extends StatefulWidget {
  const ParentsHowToPlayPage({super.key});

  @override
  State<ParentsHowToPlayPage> createState() => _ParentsHowToPlayPageState();
}

class _ParentsHowToPlayPageState extends State<ParentsHowToPlayPage> {
  late HowToPlay _draft = context.read<HowToPlayCubit>().state;

  Future<bool> _save() async {
    await context.read<HowToPlayCubit>().save(_draft);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final HowToPlay saved = context.watch<HowToPlayCubit>().state;

    return ParentsSettingPage(
      key: const ValueKey<String>('parents-zone-how-to-play'),
      title: l10n.parentsHowToPlayTitle,
      dirty: _draft != saved,
      onSave: _save,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.parentsHowToPlayMoveLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<MoveMode>(
            key: const ValueKey<String>('how-to-play-move-mode'),
            showSelectedIcon: false,
            segments: [
              for (final MoveMode mode in MoveMode.values)
                ButtonSegment<MoveMode>(
                  value: mode,
                  label: Text(ParentsHowToPlayTexts.mode(l10n, mode), key: ValueKey<String>('move-mode-${mode.name}')),
                ),
            ],
            selected: {_draft.moveMode},
            onSelectionChanged: (selection) =>
                setState(() => _draft = HowToPlay(moveMode: selection.single, hand: _draft.hand)),
          ),
          const SizedBox(height: 8),
          Text(l10n.parentsHowToPlayMoveHelp, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Text(l10n.parentsHowToPlayHandLabel, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          SegmentedButton<PlayingHand>(
            key: const ValueKey<String>('how-to-play-hand'),
            showSelectedIcon: false,
            segments: [
              for (final PlayingHand hand in PlayingHand.values)
                ButtonSegment<PlayingHand>(
                  value: hand,
                  label:
                      Text(ParentsHowToPlayTexts.hand(l10n, hand), key: ValueKey<String>('playing-hand-${hand.name}')),
                ),
            ],
            selected: {_draft.hand},
            onSelectionChanged: (selection) =>
                setState(() => _draft = HowToPlay(moveMode: _draft.moveMode, hand: selection.single)),
          ),
          const SizedBox(height: 8),
          Text(l10n.parentsHowToPlayHandHelp, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
