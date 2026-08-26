import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';

class RecipeService {
  const RecipeService();

  Future<String> detectIngredients() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    return 'Tomaten, Knoblauch, Pasta, Olivenöl';
  }

  Future<Recipe> generate(String ingredientsText, String notes) async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    final ingredients = _split(ingredientsText);
    final tags = _split(notes);
    final firstIngredient = ingredients.isEmpty ? 'Frisches' : ingredients.first;
    final title = notes.trim().isEmpty
        ? '$firstIngredient Küchenrezept'
        : '${notes.split(RegExp(r'[,.-]')).first.trim()} $firstIngredient';
    return Recipe(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      ingredients: ingredients,
      instructions: const [
        'Alle Zutaten vorbereiten und abmessen.',
        'Die Zutaten gemeinsam garen, bis sie zart und aromatisch sind.',
        'Nach Geschmack würzen, anrichten und warm servieren.',
      ],
      tags: tags,
      prepTime: '15 Min.',
      cookTime: '25 Min.',
      servings: '4',
    );
  }

  List<Recipe> filter(List<Recipe> recipes, RecipeFilters filters) {
    final search = filters.search.toLowerCase();
    final title = filters.title.toLowerCase();
    final result = recipes.where((recipe) {
      final searchable = [
        recipe.title,
        ...recipe.ingredients,
        ...recipe.tags,
      ].join(' ').toLowerCase();
      return (search.isEmpty || searchable.contains(search)) &&
          (title.isEmpty || recipe.title.toLowerCase().contains(title)) &&
          (!filters.mine || recipe.mine) &&
          (filters.rating == 0 || recipe.rating >= filters.rating) &&
          (filters.tags.isEmpty ||
              filters.tags.every(recipe.tags.contains));
    }).toList();
    switch (filters.sort) {
      case RecipeSort.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case RecipeSort.alphabetisch:
        result.sort((a, b) => a.title.compareTo(b.title));
        break;
      case RecipeSort.standard:
      case RecipeSort.beliebtheit:
        break;
    }
    return result;
  }

  List<String> _split(String value) => value
      .split(RegExp(r'[,\n]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}
