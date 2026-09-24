import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:friendly_meals/src/features/recipes/domain/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('speichert Rezepte und vermeidet doppelte Einkaufszutaten', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(friendlyMealsControllerProvider.future);
    const recipe = Recipe(
      id: 'recipe-1',
      title: 'Pasta',
      ingredients: ['Tomaten', 'Knoblauch'],
      instructions: ['Kochen'],
      tags: ['Italienisch'],
      prepTime: '10 Min.',
      cookTime: '20 Min.',
      servings: '2',
    );

    final controller =
        container.read(friendlyMealsControllerProvider.notifier);
    await controller.saveRecipe(recipe);
    await controller.addIngredients(recipe.ingredients);
    await controller.addIngredients(['tomaten']);
    await controller.addIngredients([' TOMATEN ', 'Paprika', ' paprika ', '']);
    await controller.addGrocery('  ');
    await controller.addGrocery(' paprika ');

    final state = container.read(friendlyMealsControllerProvider).requireValue;
    expect(state.recipes.single, recipe);
    expect(state.groceries.map((item) => item.name), [
      'Tomaten', 'Knoblauch', 'Paprika',
    ]);
  });
}
