import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/src/features/recipes/presentation/generate_recipe_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('zeigt das deutsche Formular zur Rezeptgenerierung', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: GenerateRecipeScreen())),
      ),
    );

    expect(find.text('Neues Rezept'), findsOneWidget);
    expect(find.text('Rezept erstellen'), findsOneWidget);
    expect(find.byKey(const Key('ingredientsField')), findsOneWidget);
  });
}
