import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/page_heading.dart';
import 'package:friendly_meals/src/core/widgets/rating_picker.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';
import 'package:go_router/go_router.dart';

class RecipeFilterScreen extends ConsumerStatefulWidget {
  const RecipeFilterScreen({super.key});

  @override
  ConsumerState<RecipeFilterScreen> createState() =>
      _RecipeFilterScreenState();
}

class _RecipeFilterScreenState extends ConsumerState<RecipeFilterScreen> {
  late final TextEditingController _searchController;
  late final TextEditingController _titleController;
  RecipeFilters _filters = const RecipeFilters();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _titleController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final next = _filters.copyWith(
      search: _searchController.text,
      title: _titleController.text,
    );
    await ref.read(friendlyMealsControllerProvider.notifier).setFilters(next);
    if (mounted) context.go('/recipes');
  }

  Future<void> _reset() async {
    await ref.read(friendlyMealsControllerProvider.notifier).resetFilters();
    if (mounted) context.go('/recipes');
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(friendlyMealsControllerProvider).value;
    if (data == null) return const Center(child: CircularProgressIndicator());
    if (!_initialized) {
      _filters = data.filters;
      _searchController.text = data.filters.search;
      _titleController.text = data.filters.title;
      _initialized = true;
    }
    final tags = <String>{
      'Italienisch',
      'Vegetarisch',
      'Schnell',
      'Glutenfrei',
      for (final recipe in data.recipes) ...recipe.tags,
    }.toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        PageHeading(
          eyebrow: 'Rezeptsammlung',
          title: 'Rezepte filtern',
          action: IconButton.outlined(
            tooltip: 'Zurück',
            onPressed: () => context.go('/recipes'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: const Color(0x0D000000)),
                boxShadow: AppShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LabelledField(
                    label: 'Suche',
                    controller: _searchController,
                    hint: 'Rezepte durchsuchen …',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _LabelledField(
                    label: 'Rezepttitel',
                    controller: _titleController,
                    hint: 'z. B. Arrabbiata-Sauce',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SwitchListTile.adaptive(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    tileColor: const Color(0xFFF9FAFB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    title: const Text(
                      'Nur meine Rezepte',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    value: _filters.mine,
                    onChanged: (value) =>
                        setState(() => _filters = _filters.copyWith(mine: value)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _Label('Bewertung'),
                  RatingPicker(
                    compact: true,
                    value: _filters.rating,
                    onChanged: (value) => setState(
                      () => _filters = _filters.copyWith(rating: value),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _Label('Tags'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final tag in tags)
                        FilterChip(
                          label: Text(tag),
                          selected: _filters.tags.contains(tag),
                          onSelected: (selected) {
                            final selectedTags = [..._filters.tags];
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                            setState(
                              () => _filters =
                                  _filters.copyWith(tags: selectedTags),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const _Label('Sortieren nach'),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final sort in RecipeSort.values)
                        ChoiceChip(
                          label: Text(_sortLabel(sort)),
                          selected: _filters.sort == sort,
                          selectedColor: AppColors.ink,
                          labelStyle: TextStyle(
                            color: _filters.sort == sort
                                ? Colors.white
                                : AppColors.ink,
                          ),
                          onSelected: (_) => setState(
                            () => _filters = _filters.copyWith(sort: sort),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _reset,
                          child: const Text('Zurücksetzen'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: FilledButton(
                          onPressed: _apply,
                          child: const Text('Filter anwenden'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _sortLabel(RecipeSort sort) => switch (sort) {
    RecipeSort.standard => 'Standard',
    RecipeSort.rating => 'Bewertung',
    RecipeSort.alphabetisch => 'Alphabetisch',
    RecipeSort.beliebtheit => 'Beliebtheit',
  };
}

class _LabelledField extends StatelessWidget {
  const _LabelledField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  final String label;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label(label),
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}
