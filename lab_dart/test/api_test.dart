import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MealApi', () {
    test('розбирає відповідь без реального запиту (MockClient)', () async {
      final client = MockClient((request) async {
        expect(request.url.path, contains('search.php'));
        expect(request.url.queryParameters['s'], equals('pasta'));

        return http.Response(
          jsonEncode({
            'meals': [
              {
                'idMeal': '52777',
                'strMeal': 'Mediterranean Pasta Salad',
                'strCategory': 'Seafood',
                'strArea': 'Italian',
                'strInstructions': 'Bring water to the boil',
                'strMealThumb': 'https://example.com/pasta.jpg',
                'strIngredient1': 'farfalle',
                'strMeasure1': '350 g',
                'strIngredient2': 'tuna',
                'strMeasure2': '200 g',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = MealApi(client: client);
      final meals = await api.search('pasta');

      expect(meals, hasLength(1));
      expect(meals.first.name, equals('Mediterranean Pasta Salad'));
      expect(meals.first.ingredients, hasLength(2));

      api.close();
    });

    test('meals: null дає порожній список', () async {
      final client = MockClient(
        (request) async => http.Response('{"meals":null}', 200),
      );

      final api = MealApi(client: client);
      expect(await api.search('zzz'), isEmpty);
      api.close();
    });

    test('некоректний statusCode кидає Exception', () async {
      final client = MockClient((request) async => http.Response('error', 500));

      final api = MealApi(client: client);
      expect(() => api.search('pasta'), throwsA(isA<Exception>()));
      api.close();
    });
  });
}
