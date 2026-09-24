import 'dart:convert';

import 'package:friendly_meals/src/features/grocery/domain/grocery_item.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_state.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendlyMealsRepository {
  static const _recipesKey = 'friendly_recipes';
  static const _groceriesKey = 'friendly_groceries';
  static const _filtersKey = 'friendly_filters';

  Future<FriendlyMealsState> load() async {
    final preferences = await SharedPreferences.getInstance();
    final recipes = _readOrDefault(
      () => _decodeList(preferences.getString(_recipesKey))
          .map(Recipe.fromJson)
          .toList(),
      <Recipe>[],
    );
    final groceries = _readOrDefault(
      () => _decodeList(preferences.getString(_groceriesKey))
          .map(GroceryItem.fromJson)
          .toList(),
      <GroceryItem>[],
    );
    final filters = _readOrDefault(() {
      final filtersValue = preferences.getString(_filtersKey);
      return filtersValue == null
          ? const RecipeFilters()
          : RecipeFilters.fromJson(
              (jsonDecode(filtersValue) as Map<Object?, Object?>).map(
                (key, value) => MapEntry(key.toString(), value),
              ),
            );
    }, const RecipeFilters());
    return FriendlyMealsState(
      recipes: recipes,
      groceries: groceries,
      filters: filters,
    );
  }

  T _readOrDefault<T>(T Function() read, T fallback) {
    try {
      return read();
    } on FormatException {
      return fallback;
    } on TypeError {
      return fallback;
    }
  }

  Future<void> save(FriendlyMealsState state) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setString(
        _recipesKey,
        jsonEncode(state.recipes.map((recipe) => recipe.toJson()).toList()),
      ),
      preferences.setString(
        _groceriesKey,
        jsonEncode(state.groceries.map((item) => item.toJson()).toList()),
      ),
      preferences.setString(_filtersKey, jsonEncode(state.filters.toJson())),
    ]);
  }

  List<Map<String, Object?>> _decodeList(String? value) {
    if (value == null) return const [];
    return (jsonDecode(value) as List<Object?>)
        .whereType<Map<Object?, Object?>>()
        .map(
          (item) => item.map(
            (key, value) => MapEntry(key.toString(), value),
          ),
        )
        .toList();
  }
}
