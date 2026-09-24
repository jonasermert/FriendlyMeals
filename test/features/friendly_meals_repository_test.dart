import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/src/features/recipes/data/friendly_meals_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('behält gültige Einkaufsdaten bei beschädigten Rezepten', () async {
    SharedPreferences.setMockInitialValues({
      'friendly_recipes': '{kaputt',
      'friendly_groceries': jsonEncode([
        {'id': '1', 'name': 'Tomaten', 'checked': false},
      ]),
      'friendly_filters': '{kaputt',
    });

    final state = await FriendlyMealsRepository().load();

    expect(state.recipes, isEmpty);
    expect(state.groceries.single.name, 'Tomaten');
  });
}
