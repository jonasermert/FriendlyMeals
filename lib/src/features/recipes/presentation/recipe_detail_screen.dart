import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/empty_state.dart';
import 'package:friendly_meals/src/core/widgets/rating_picker.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:go_router/go_router.dart';

class RecipeDetailScreen extends ConsumerWidget {
  const RecipeDetailScreen({required this.recipeId, super.key});

  final String recipeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(friendlyMealsControllerProvider).value;
    if (data == null) return const Center(child: CircularProgressIndicator());
    Recipe? foundRecipe;
    for (final item in data.recipes) {
      if (item.id == recipeId) {
        foundRecipe = item;
        break;
      }
    }
    if (foundRecipe == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: EmptyState(
          title: 'Rezept nicht gefunden',
          message: 'Kehre zu „Alle Rezepte“ zurück und wähle ein Rezept aus.',
        ),
      );
    }
    final recipe = foundRecipe;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: const Color(0x0D000000)),
                boxShadow: AppShadows.card,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _RecipeHero(recipe: recipe),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.title,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        FilledButton.icon(
                          onPressed: () =>
                              context.go('/recipes/$recipeId/live'),
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text('Live-Kochassistent'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 54),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                label: 'Vorbereitung',
                                value: recipe.prepTime,
                                icon: Icons.timer_outlined,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _InfoCard(
                                label: 'Kochzeit',
                                value: recipe.cookTime,
                                icon: Icons.soup_kitchen_outlined,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: _InfoCard(
                                label: 'Portionen',
                                value: recipe.servings,
                                icon: Icons.people_outline,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final ingredients = _Ingredients(recipe: recipe);
                            final instructions = _Instructions(recipe: recipe);
                            if (constraints.maxWidth >= 760) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: ingredients),
                                  const SizedBox(width: AppSpacing.xxl),
                                  Expanded(child: instructions),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                ingredients,
                                const SizedBox(height: AppSpacing.xxl),
                                instructions,
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const Divider(),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Bewerte dieses Rezept',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        RatingPicker(
                          value: recipe.rating,
                          onChanged: (rating) => ref
                              .read(friendlyMealsControllerProvider.notifier)
                              .updateRecipe(recipe.copyWith(rating: rating)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecipeHero extends ConsumerWidget {
  const _RecipeHero({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 280,
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          colors: [AppColors.tealSoft, Color(0xFFF3F4F6)],
          radius: 1.1,
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.auto_awesome,
              color: AppColors.teal,
              size: 74,
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            top: AppSpacing.lg,
            child: IconButton.filledTonal(
              tooltip: 'Zurück',
              onPressed: () => context.go('/recipes'),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          Positioned(
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            child: IconButton.filledTonal(
              tooltip: 'Favorit',
              onPressed: () => ref
                  .read(friendlyMealsControllerProvider.notifier)
                  .updateRecipe(
                    recipe.copyWith(favorite: !recipe.favorite),
                  ),
              icon: Icon(
                recipe.favorite ? Icons.favorite : Icons.favorite_border,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(AppRadius.md),
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.teal),
        const SizedBox(height: AppSpacing.sm),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        const SizedBox(height: AppSpacing.xs),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}

class _Ingredients extends ConsumerWidget {
  const _Ingredients({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Zutaten',
        style: TextStyle(
          color: AppColors.teal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      for (final ingredient in recipe.ingredients)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Row(
            children: [
              const Icon(Icons.check, color: AppColors.teal, size: 18),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(ingredient)),
            ],
          ),
        ),
      const SizedBox(height: AppSpacing.md),
      FilledButton.tonalIcon(
        onPressed: () async {
          await ref
              .read(friendlyMealsControllerProvider.notifier)
              .addIngredients(recipe.ingredients);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Zur Einkaufsliste hinzugefügt!')),
            );
          }
        },
        icon: const Icon(Icons.playlist_add_check),
        label: const Text('Zur Einkaufsliste hinzufügen'),
      ),
    ],
  );
}

class _Instructions extends StatelessWidget {
  const _Instructions({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Zubereitung',
        style: TextStyle(
          color: AppColors.teal,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: AppSpacing.lg),
      for (final (index, instruction) in recipe.instructions.indexed)
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.ink,
                foregroundColor: Colors.white,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(instruction)),
            ],
          ),
        ),
    ],
  );
}
