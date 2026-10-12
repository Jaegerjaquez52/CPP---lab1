import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Meal', () {
    final meal = Meal(
      id: '52777',
      name: 'Mediterranean Pasta Salad',
      category: 'Seafood',
      area: 'Italian',
      instructions: 'Boil pasta',
      thumbUrl: 'https://example.com/pasta.jpg',
      ingredients: const [
        Ingredient(name: 'farfalle', measure: '350 g'),
        Ingredient(name: 'tuna', measure: '200 g'),
      ],
    );

    test('toJson повертає правильну мапу', () {
      expect(meal.toJson(), {
        'id': '52777',
        'name': 'Mediterranean Pasta Salad',
        'category': 'Seafood',
        'area': 'Italian',
        'instructions': 'Boil pasta',
        'thumbUrl': 'https://example.com/pasta.jpg',
        'ingredients': [
          {'name': 'farfalle', 'measure': '350 g'},
          {'name': 'tuna', 'measure': '200 g'},
        ],
      });
    });

    test('fromJson відновлює обʼєкт (туди й назад)', () {
      final restored = Meal.fromJson(meal.toJson());
      expect(restored.id, equals(meal.id));
      expect(restored.name, equals(meal.name));
      expect(restored.category, equals(meal.category));
      expect(restored.area, equals(meal.area));
      expect(restored.ingredients, hasLength(2));
      expect(restored.ingredients.first.name, equals('farfalle'));
    });

    test('fromJson читає формат TheMealDB (strIngredientN)', () {
      final fromApi = Meal.fromJson({
        'idMeal': '1',
        'strMeal': 'Pasta',
        'strCategory': 'Seafood',
        'strArea': 'Italian',
        'strInstructions': 'Cook',
        'strMealThumb': '',
        'strIngredient1': 'pasta',
        'strMeasure1': '200 g',
        'strIngredient2': '',
        'strMeasure2': '',
      });

      expect(fromApi.name, equals('Pasta'));
      expect(fromApi.ingredients, hasLength(1));
      expect(fromApi.ingredients.first.toString(), equals('pasta (200 g)'));
    });

    test('некоректні дані спричиняють FormatException', () {
      expect(
        () => Meal.fromJson({'category': 'Seafood'}),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
