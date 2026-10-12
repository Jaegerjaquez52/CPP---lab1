import 'dart:convert';
import 'dart:io';

import 'models.dart';

/// Збереження та читання списку страв у data.json.
class MealRepository {
  MealRepository({this.filePath = 'data.json'});

  final String filePath;

  Future<List<Meal>> load() async {
    final file = File(filePath);
    if (!await file.exists()) {
      return [];
    }

    try {
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        stdout.writeln(
          'Файл $filePath має невірний формат. Починаємо з порожнього списку.',
        );
        return [];
      }

      final meals = <Meal>[];
      for (final Object? item in decoded) {
        if (item is! Map) {
          continue;
        }
        meals.add(Meal.fromJson(Map<String, Object?>.from(item)));
      }
      return meals;
    } on FormatException catch (e) {
      stdout.writeln('Не вдалося прочитати $filePath: $e');
      return [];
    } catch (e) {
      stdout.writeln('Помилка читання $filePath: $e');
      return [];
    }
  }

  Future<void> save(List<Meal> meals) async {
    final file = File(filePath);
    final list = [for (final Meal meal in meals) meal.toJson()];
    final pretty = const JsonEncoder.withIndent('  ').convert(list);
    await file.writeAsString(pretty);
  }
}
