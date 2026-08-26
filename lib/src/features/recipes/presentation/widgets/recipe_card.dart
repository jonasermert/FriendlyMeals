import 'package:flutter/material.dart';
import 'package:friendly_meals/src/core/theme/app_colors.dart';
import 'package:friendly_meals/src/core/theme/app_radius.dart';
import 'package:friendly_meals/src/core/theme/app_shadows.dart';
import 'package:friendly_meals/src/core/theme/app_spacing.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:go_router/go_router.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Rezept ${recipe.title} öffnen',
      child: InkWell(
        onTap: () => context.go('/recipes/${recipe.id}'),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: const Color(0x0D000000)),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 154,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  ),
                  gradient: RadialGradient(
                    colors: [AppColors.tealSoft, Color(0xFFF3F4F6)],
                    radius: 1.1,
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.teal,
                  size: 52,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.muted,
                        ),
                        const SizedBox(width: 4),
                        Text(recipe.cookTime),
                        const Spacer(),
                        const Icon(
                          Icons.star_rounded,
                          size: 18,
                          color: AppColors.amber,
                        ),
                        Text('${recipe.rating},0'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
