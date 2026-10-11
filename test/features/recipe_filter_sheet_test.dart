import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendly_meals/src/features/recipes/application/friendly_meals_controller.dart';
import 'package:friendly_meals/src/features/recipes/presentation/recipe_filter_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> openSheet(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await container.read(friendlyMealsControllerProvider.future);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showRecipeFilterSheet(context),
                child: const Text('Filter öffnen'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Filter öffnen'));
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('footer remains visible while filters scroll', (tester) async {
    await openSheet(tester);
    final before = tester.getRect(find.text('Filter anwenden'));
    await tester.drag(find.byType(ListView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Filter anwenden')), before);
    expect(find.text('Zurücksetzen').hitTestable(), findsOneWidget);
    expect(find.text('Filter anwenden').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('apply saves the draft and closes the sheet', (tester) async {
    final container = await openSheet(tester);
    await tester.enterText(find.byType(TextField).first, 'Pasta');
    await tester.tap(find.text('Filter anwenden'));
    await tester.pumpAndSettle();
    expect(
      container.read(friendlyMealsControllerProvider).value!.filters.search,
      'Pasta',
    );
    expect(find.byType(DraggableScrollableSheet), findsNothing);
  });

  testWidgets('closing discards the draft', (tester) async {
    final container = await openSheet(tester);
    await tester.enterText(find.byType(TextField).first, 'Pasta');
    await tester.tap(find.byTooltip('Zurück'));
    await tester.pumpAndSettle();
    expect(
      container.read(friendlyMealsControllerProvider).value!.filters.search,
      isEmpty,
    );
  });

  testWidgets('footer stays above the keyboard on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await openSheet(tester);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpAndSettle();
    expect(find.text('Filter anwenden').hitTestable(), findsOneWidget);
    expect(
      tester.getRect(find.text('Filter anwenden')).bottom,
      lessThanOrEqualTo(544),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('reset clears saved filters', (tester) async {
    final container = await openSheet(tester);
    await tester.enterText(find.byType(TextField).first, 'Pasta');
    await tester.tap(find.text('Filter anwenden'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filter öffnen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen'));
    await tester.pumpAndSettle();
    expect(
      container.read(friendlyMealsControllerProvider).value!.filters.search,
      isEmpty,
    );
  });
}
