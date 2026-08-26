import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/core/widgets/empty_state.dart';
import 'package:friendly_meals/src/core/widgets/page_heading.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:friendly_meals/src/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:go_router/go_router.dart';

class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(friendlyMealsControllerProvider);
    return state.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => const Center(
        child: Text('Die Rezepte konnten nicht geladen werden.'),
      ),
      data: (data) {
        final recipes = ref
            .read(recipeServiceProvider)
            .filter(data.recipes, data.filters);
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                0,
              ),
              sliver: SliverToBoxAdapter(
                child: PageHeading(
                  eyebrow: 'Deine Sammlung',
                  title: 'Alle Rezepte',
                  action: OutlinedButton.icon(
                    onPressed: () => context.go('/recipes/filter'),
                    icon: const Icon(Icons.tune),
                    label: const Text('Filter'),
                  ),
                ),
              ),
            ),
            if (recipes.isEmpty)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverToBoxAdapter(
                  child: EmptyState(
                    title: 'Noch keine Rezepte',
                    message:
                        'Erstelle dein erstes Rezept oder setze die Filter zurück.',
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 1000 ? 3 : width >= 620 ? 2 : 1;
                    return SliverGrid.builder(
                      itemCount: recipes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: AppSpacing.lg,
                        crossAxisSpacing: AppSpacing.lg,
                        childAspectRatio: columns == 1 ? 1.45 : 1.05,
                      ),
                      itemBuilder: (context, index) =>
                          RecipeCard(recipe: recipes[index]),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
