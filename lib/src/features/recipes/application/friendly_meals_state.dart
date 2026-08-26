import 'package:friendly_meals/src/features/grocery/domain/grocery_item.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';

class FriendlyMealsState {
  const FriendlyMealsState({
    this.recipes = const [],
    this.groceries = const [],
    this.filters = const RecipeFilters(),
  });

  final List<Recipe> recipes;
  final List<GroceryItem> groceries;
  final RecipeFilters filters;

  FriendlyMealsState copyWith({
    List<Recipe>? recipes,
    List<GroceryItem>? groceries,
    RecipeFilters? filters,
  }) => FriendlyMealsState(
    recipes: recipes ?? this.recipes,
    groceries: groceries ?? this.groceries,
    filters: filters ?? this.filters,
  );
}
