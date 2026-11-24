import 'package:flutter/material.dart';

import '../../domain/activities/activity.dart';
import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';
import '../widgets/activity_widgets.dart';
import '../widgets/off_play_time.dart';

/// «Actividades sin pantallas» (HU-047 §13): una sección propia de la app, ni
/// en la Zona de Padres ni dentro del menú. Arriba, siempre, la advertencia
/// general (D6); debajo, el buscador con textos que enseñan al adulto a buscar,
/// las búsquedas de ejemplo y los filtros de categoría y tiempo (P12); y la
/// lista de resultados, que se construye a medida que se desplaza (el catálogo
/// crecerá hasta mil). Sin resultados, una frase que propone otra búsqueda y
/// las búsquedas de ejemplo: nunca una pantalla vacía.
///
/// Es para el adulto: no cuenta como tiempo de juego (P9), se abre sin
/// desafío (P8) y en todo momento, también desde la pantalla de descanso (D4).
class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ActivitiesScreen()));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return OffPlayTime(
      child: Scaffold(
        key: const ValueKey<String>('activities-screen'),
        appBar: AppBar(title: Text(l10n.activitiesTitle)),
        body: SafeArea(
          child: ActivityLibraryLoader(
            builder: (context, library) => library == null
                ? const Center(child: CircularProgressIndicator())
                : _ActivitiesBrowser(library: library),
          ),
        ),
      ),
    );
  }
}

class _ActivitiesBrowser extends StatefulWidget {
  const _ActivitiesBrowser({required this.library});

  final ActivityLibrary library;

  @override
  State<_ActivitiesBrowser> createState() => _ActivitiesBrowserState();
}

class _ActivitiesBrowserState extends State<_ActivitiesBrowser> {
  final TextEditingController _query = TextEditingController();
  ActivityCategory? _category;
  int? _maxMinutes;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _onQueryChanged() => setState(() {});

  /// Tocar una búsqueda de ejemplo la escribe en el campo y busca.
  void _searchFor(String hint) {
    FocusScope.of(context).unfocus();
    _query.value = TextEditingValue(text: hint, selection: TextSelection.collapsed(offset: hint.length));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final ActivityLibrary library = widget.library;
    final List<Activity> results = library.search(_query.text, category: _category, maxMinutes: _maxMinutes);

    return CustomScrollView(
      key: const ValueKey<String>('activities-list'),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverList.list(
            children: [
              ActivityNotice(
                key: const ValueKey<String>('activities-safety'),
                text: l10n.activitiesSafetyWarning,
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey<String>('activities-search'),
                controller: _query,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: l10n.activitiesSearchLabel,
                  hintMaxLines: 3,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.text.isEmpty
                      ? null
                      : IconButton(
                          key: const ValueKey<String>('activities-search-clear'),
                          tooltip: l10n.activitiesClearSearch,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: _query.clear,
                        ),
                  filled: true,
                  fillColor: AppPalette.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 10),
              _SearchHints(hints: library.searchHints, onTap: _searchFor),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final ActivityCategory category in ActivityCategory.values)
                    ChoiceChip(
                      key: ValueKey<String>('activities-category-${category.name}'),
                      label: Text(l10n.activitiesCategory(category.name)),
                      selected: _category == category,
                      onSelected: (selected) => setState(() => _category = selected ? category : null),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final int minutes in Activity.durations)
                    ChoiceChip(
                      key: ValueKey<String>('activities-minutes-$minutes'),
                      avatar: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(l10n.activitiesUpToMinutes(minutes)),
                      selected: _maxMinutes == minutes,
                      onSelected: (selected) => setState(() => _maxMinutes = selected ? minutes : null),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Text(
                  l10n.activitiesCount(results.length),
                  key: const ValueKey<String>('activities-count'),
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        if (results.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            sliver: SliverList.list(
              key: const ValueKey<String>('activities-no-results'),
              children: [
                Text(library.noResults, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 10),
                _SearchHints(hints: library.searchHints, onTap: _searchFor, keyPrefix: 'activities-retry-hint'),
              ],
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
            // Perezosa: solo se construyen las tarjetas que se ven.
            sliver: SliverList.builder(
              itemCount: results.length,
              itemBuilder: (context, index) => ActivityCard(activity: results[index], library: library),
            ),
          ),
      ],
    );
  }
}

/// Las búsquedas de ejemplo (P12): materiales, gustos e ideas que se tocan.
class _SearchHints extends StatelessWidget {
  const _SearchHints({required this.hints, required this.onTap, this.keyPrefix = 'activities-hint'});

  final List<String> hints;
  final ValueChanged<String> onTap;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (hints.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.activitiesTryHints, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final (index, hint) in hints.indexed)
              ActionChip(
                key: ValueKey<String>('$keyPrefix-$index'),
                avatar: const Icon(Icons.search_rounded, size: 18),
                label: Text(hint),
                onPressed: () => onTap(hint),
              ),
          ],
        ),
      ],
    );
  }
}
