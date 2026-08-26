import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/src/features/recipes/application/recipe_service.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe_filters.dart';

void main() {
  const service = RecipeService();

  test('filtert Rezepte nach Titel, Bewertung und Tag', () {
    const recipes = [
      Recipe(
        id: '1',
        title: 'Italienische Pasta',
        ingredients: ['Pasta'],
        instructions: ['Kochen'],
        tags: ['Italienisch'],
        prepTime: '10 Min.',
        cookTime: '20 Min.',
        servings: '2',
        rating: 5,
      ),
      Recipe(
        id: '2',
        title: 'Gemüsesuppe',
        ingredients: ['Karotte'],
        instructions: ['Kochen'],
        tags: ['Vegetarisch'],
        prepTime: '15 Min.',
        cookTime: '30 Min.',
        servings: '4',
        rating: 3,
      ),
    ];

    final result = service.filter(
      recipes,
      const RecipeFilters(
        title: 'Pasta',
        rating: 4,
        tags: ['Italienisch'],
      ),
    );

    expect(result, hasLength(1));
    expect(result.single.id, '1');
  });

  test('sortiert Rezepte alphabetisch', () {
    const recipes = [
      Recipe(
        id: '1',
        title: 'Suppe',
        ingredients: [],
        instructions: [],
        tags: [],
        prepTime: '',
        cookTime: '',
        servings: '',
      ),
      Recipe(
        id: '2',
        title: 'Pasta',
        ingredients: [],
        instructions: [],
        tags: [],
        prepTime: '',
        cookTime: '',
        servings: '',
      ),
    ];

    final result = service.filter(
      recipes,
      const RecipeFilters(sort: RecipeSort.alphabetisch),
    );

    expect(result.map((recipe) => recipe.title), ['Pasta', 'Suppe']);
  });
}
