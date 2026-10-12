import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Запити до TheMealDB.
///
/// [client] передається ззовні, щоб у тестах підставити MockClient.
class MealApi {
  MealApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// GET /api/json/v1/1/search.php?s=...
  Future<List<Meal>> search(String query) async {
    final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {
      's': query,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Помилка запиту: ${response.statusCode}');
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw FormatException('Очікувалась JSON-мапа, отримано: $decoded');
    }

    return MealResponse.fromJson(Map<String, Object?>.from(decoded)).meals;
  }

  void close() {
    _client.close();
  }
}
