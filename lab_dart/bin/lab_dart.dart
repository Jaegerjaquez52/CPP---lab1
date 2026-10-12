import 'dart:io';

import 'package:lab_dart/lab_dart.dart';

Future<void> main(List<String> arguments) async {
  final repository = MealRepository();
  final api = MealApi();
  final List<Meal> meals = await repository.load();

  var running = true;
  while (running) {
    _clearScreen();
    stdout.writeln('Кулінарна книга рецептів (TheMealDB)');
    stdout.writeln('Страв у книзі: ${meals.length}');
    _printMenu();
    stdout.write('Оберіть пункт: ');
    final choice = stdin.readLineSync()?.trim() ?? '';

    switch (choice) {
      case '1':
        _showList(meals);
      case '2':
        await _addMeal(meals, repository);
      case '3':
        await _deleteMeal(meals, repository);
      case '4':
        await _loadFromApi(meals, repository, api);
      case '5':
        _searchLocal(meals);
      case '6':
        await _sortLocal(meals, repository);
      case '0':
        running = false;
        stdout.writeln('До побачення!');
      default:
        stdout.writeln('Невірний пункт меню. Спробуйте ще раз.');
    }

    // Щоб встигнути прочитати результат, перш ніж екран очиститься.
    if (running) {
      stdout.write('\nНатисніть Enter, щоб продовжити…');
      stdin.readLineSync();
    }
  }

  api.close();
}

/// Очищає консоль (Windows / Linux / macOS).
void _clearScreen() {
  if (stdout.supportsAnsiEscapes) {
    stdout.write('\x1B[2J\x1B[H');
    return;
  }
  // Запасний варіант для старої консолі Windows.
  Process.runSync(Platform.isWindows ? 'cls' : 'clear', [], runInShell: true);
}

void _printMenu() {
  stdout.writeln('');
  stdout.writeln('=== Меню ===');
  stdout.writeln('1 — показати список');
  stdout.writeln('2 — додати запис');
  stdout.writeln('3 — видалити запис');
  stdout.writeln('4 — завантажити з TheMealDB');
  stdout.writeln('5 — пошук');
  stdout.writeln('6 — сортування');
  stdout.writeln('0 — вихід');
}

void _showList(List<Meal> meals) {
  if (meals.isEmpty) {
    stdout.writeln('Список порожній.');
    return;
  }

  stdout.writeln('Страви (${meals.length}):');
  for (var i = 0; i < meals.length; i++) {
    stdout.writeln('${i + 1}. ${meals[i]}');
  }
}

Future<void> _addMeal(List<Meal> meals, MealRepository repository) async {
  stdout.write('Назва страви: ');
  final name = stdin.readLineSync()?.trim() ?? '';
  if (name.isEmpty) {
    stdout.writeln('Назва не може бути порожньою.');
    return;
  }

  stdout.write('Категорія (наприклад Seafood): ');
  final category = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Кухня / країна (наприклад Italian): ');
  final area = stdin.readLineSync()?.trim() ?? '';

  stdout.write('Інструкція (можна залишити порожньою): ');
  final instructions = stdin.readLineSync()?.trim() ?? '';

  final meal = Meal(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    name: name,
    category: category,
    area: area,
    instructions: instructions,
    thumbUrl: '',
    ingredients: const [],
  );

  meals.add(meal);
  await repository.save(meals);
  stdout.writeln('Додано: $meal');
}

Future<void> _deleteMeal(List<Meal> meals, MealRepository repository) async {
  if (meals.isEmpty) {
    stdout.writeln('Немає що видаляти — список порожній.');
    return;
  }

  _showList(meals);
  stdout.write('Номер запису для видалення: ');
  final raw = stdin.readLineSync()?.trim() ?? '';
  final index = int.tryParse(raw);

  if (index == null) {
    stdout.writeln('Потрібно ввести число.');
    return;
  }
  if (index < 1 || index > meals.length) {
    stdout.writeln('Номер поза діапазоном 1…${meals.length}.');
    return;
  }

  final removed = meals.removeAt(index - 1);
  await repository.save(meals);
  stdout.writeln('Видалено: $removed');
}

Future<void> _loadFromApi(
  List<Meal> meals,
  MealRepository repository,
  MealApi api,
) async {
  stdout.write('Пошуковий запит (наприклад pasta): ');
  final query = stdin.readLineSync()?.trim() ?? '';
  if (query.isEmpty) {
    stdout.writeln('Запит не може бути порожнім.');
    return;
  }

  try {
    stdout.writeln('Завантаження…');
    final found = await api.search(query);
    if (found.isEmpty) {
      stdout.writeln('Нічого не знайдено.');
      return;
    }

    var added = 0;
    for (final Meal meal in found) {
      if (meals.any((m) => m.id == meal.id)) {
        continue;
      }
      meals.add(meal);
      added++;
    }

    await repository.save(meals);
    stdout.writeln('Знайдено: ${found.length}, додано нових: $added');
    _showList(found);
  } on FormatException catch (e) {
    stdout.writeln('Некоректна відповідь сервера: $e');
  } on SocketException catch (e) {
    stdout.writeln('Немає інтернету або сервер недоступний: $e');
  } catch (e) {
    stdout.writeln('Не вдалося отримати дані: $e');
  }
}

void _searchLocal(List<Meal> meals) {
  if (meals.isEmpty) {
    stdout.writeln('Список порожній.');
    return;
  }

  stdout.write('Що шукати (назва / категорія / кухня): ');
  final query = stdin.readLineSync()?.trim() ?? '';
  final found = searchMeals(meals, query);
  if (found.isEmpty) {
    stdout.writeln('Нічого не знайдено.');
    return;
  }
  _showList(found);
}

Future<void> _sortLocal(List<Meal> meals, MealRepository repository) async {
  if (meals.isEmpty) {
    stdout.writeln('Список порожній.');
    return;
  }

  stdout.writeln('Сортувати за:');
  stdout.writeln('1 — назвою');
  stdout.writeln('2 — категорією');
  stdout.writeln('3 — кухнею (area)');
  stdout.write('Оберіть: ');
  final choice = stdin.readLineSync()?.trim() ?? '';

  final SortBy? by = switch (choice) {
    '1' => SortBy.name,
    '2' => SortBy.category,
    '3' => SortBy.area,
    _ => null,
  };

  if (by == null) {
    stdout.writeln('Невірний вибір.');
    return;
  }

  sortMeals(meals, by);
  await repository.save(meals);
  stdout.writeln('Відсортовано за ${by.name}.');
  _showList(meals);
}
