import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/core/widgets/app_shell.dart';
import 'package:friendly_meals/src/features/grocery/presentation/grocery_list_screen.dart';
import 'package:friendly_meals/src/features/live_assistant/presentation/live_assistant_screen.dart';
import 'package:friendly_meals/src/features/meal_scan/presentation/meal_scanner_screen.dart';
import 'package:friendly_meals/src/features/recipes/presentation/generate_recipe_screen.dart';
import 'package:friendly_meals/src/features/recipes/presentation/recipe_detail_screen.dart';
import 'package:friendly_meals/src/features/recipes/presentation/recipe_filter_screen.dart';
import 'package:friendly_meals/src/features/recipes/presentation/recipe_list_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/generate',
    routes: [
      GoRoute(
        path: '/recipes/:recipeId/live',
        builder: (context, state) => LiveAssistantScreen(
          recipeId: state.pathParameters['recipeId']!,
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          location: state.uri.path,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/generate',
            builder: (context, state) => const GenerateRecipeScreen(),
          ),
          GoRoute(
            path: '/recipes',
            builder: (context, state) => const RecipeListScreen(),
            routes: [
              GoRoute(
                path: 'filter',
                builder: (context, state) => const RecipeFilterScreen(),
              ),
              GoRoute(
                path: ':recipeId',
                builder: (context, state) => RecipeDetailScreen(
                  recipeId: state.pathParameters['recipeId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/scan-meal',
            builder: (context, state) => const MealScannerScreen(),
          ),
          GoRoute(
            path: '/grocery-list',
            builder: (context, state) => const GroceryListScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
