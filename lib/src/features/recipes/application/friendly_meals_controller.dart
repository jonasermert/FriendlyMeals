import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:friendly_meals/src/features/grocery/domain/grocery_item.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_state.dart';
import 'package:friendly_meals/src/features/recipes/application/recipe_service.dart';
import 'package:friendly_meals/src/features/recipes/data/friendly_meals_repository.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';

final friendlyMealsRepositoryProvider = Provider<FriendlyMealsRepository>(
  (ref) => FriendlyMealsRepository(),
);

final recipeServiceProvider = Provider<RecipeService>(
  (ref) => const RecipeService(),
);

final friendlyMealsControllerProvider = AsyncNotifierProvider<
    FriendlyMealsController, FriendlyMealsState>(FriendlyMealsController.new);

class FriendlyMealsController extends AsyncNotifier<FriendlyMealsState> {
  FriendlyMealsRepository get _repository =>
      ref.read(friendlyMealsRepositoryProvider);

  @override
  Future<FriendlyMealsState> build() => _repository.load();

  Future<void> saveRecipe(Recipe recipe) async {
    final current = state.value ?? const FriendlyMealsState();
    final next = current.copyWith(
      recipes: [
        recipe,
        ...current.recipes.where((item) => item.id != recipe.id),
      ],
    );
    await _commit(next);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final current = state.value ?? const FriendlyMealsState();
    await _commit(
      current.copyWith(
        recipes: current.recipes
            .map((item) => item.id == recipe.id ? recipe : item)
            .toList(),
      ),
    );
  }

  Future<void> setFilters(RecipeFilters filters) async {
    final current = state.value ?? const FriendlyMealsState();
    await _commit(current.copyWith(filters: filters));
  }

  Future<void> resetFilters() => setFilters(const RecipeFilters());

  Future<void> addGrocery(String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) return;
    final current = state.value ?? const FriendlyMealsState();
    if (current.groceries.any(
      (item) => item.name.trim().toLowerCase() == normalized.toLowerCase(),
    )) return;
    await _commit(
      current.copyWith(
        groceries: [
          ...current.groceries,
          GroceryItem(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            name: normalized,
          ),
        ],
      ),
    );
  }

  Future<void> addIngredients(List<String> names) async {
    final current = state.value ?? const FriendlyMealsState();
    final existing = current.groceries
        .map((item) => item.name.trim().toLowerCase())
        .toSet();
    final additions = names
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty && existing.add(name.toLowerCase()))
        .toList();
    if (additions.isEmpty) return;
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    await _commit(
      current.copyWith(
        groceries: [
          ...current.groceries,
          for (var index = 0; index < additions.length; index++)
            GroceryItem(
              id: '${timestamp}_$index',
              name: additions[index],
            ),
        ],
      ),
    );
  }

  Future<void> toggleGrocery(String id) async {
    final current = state.value ?? const FriendlyMealsState();
    await _commit(
      current.copyWith(
        groceries: current.groceries
            .map(
              (item) => item.id == id
                  ? item.copyWith(checked: !item.checked)
                  : item,
            )
            .toList(),
      ),
    );
  }

  Future<void> deleteGrocery(String id) async {
    final current = state.value ?? const FriendlyMealsState();
    await _commit(
      current.copyWith(
        groceries: current.groceries
            .where((item) => item.id != id)
            .toList(),
      ),
    );
  }

  Future<void> _commit(FriendlyMealsState next) async {
    await _repository.save(next);
    state = AsyncData(next);
  }
}
