import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:recipe_app/models/meal.dart';
import 'package:recipe_app/services/favorites_provider.dart';
import 'package:recipe_app/widgets/async_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Meal.fromJson collapses the 20 ingredient slots into a clean list', () {
    final meal = Meal.fromJson({
      'idMeal': '1',
      'strMeal': 'Test Dish',
      'strCategory': 'Dessert',
      'strArea': 'Nowhere',
      'strInstructions': 'Mix and bake.',
      'strMealThumb': 'http://example.com/x.jpg',
      'strYoutube': '',
      'strSource': null,
      'strIngredient1': 'Flour',
      'strMeasure1': '2 cups',
      'strIngredient2': 'Sugar',
      'strMeasure2': '1 cup',
      'strIngredient3': '   ',
      'strMeasure3': '',
    });

    expect(meal.ingredients, hasLength(2));
    expect(meal.ingredients.first.name, 'Flour');
    expect(meal.ingredients.first.measure, '2 cups');
    expect(meal.youtubeUrl, isNull);
    expect(meal.sourceUrl, isNull);
  });

  testWidgets('AsyncView shows a spinner, then the built data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: AsyncView<String>(
          future: Future.value('hello'),
          onRetry: () {},
          builder: (context, data) => Text(data),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    expect(find.text('hello'), findsOneWidget);
  });

  test('FavoritesProvider.toggle adds then removes a meal', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = FavoritesProvider();
    const meal = MealSummary(id: '42', name: 'Pie', thumbnail: '');

    expect(provider.contains('42'), isFalse);
    await provider.toggle(meal);
    expect(provider.contains('42'), isTrue);
    await provider.toggle(meal);
    expect(provider.contains('42'), isFalse);
  });
}
