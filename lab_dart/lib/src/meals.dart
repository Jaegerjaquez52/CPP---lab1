import 'models.dart';

/// Пошук у локальному списку (назва, категорія, кухня).
List<Meal> searchMeals(List<Meal> meals, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) {
    return List<Meal>.from(meals);
  }

  return meals
      .where(
        (meal) =>
            meal.name.toLowerCase().contains(q) ||
            meal.category.toLowerCase().contains(q) ||
            meal.area.toLowerCase().contains(q),
      )
      .toList();
}

/// Сортування списку на місці за [SortBy].
void sortMeals(List<Meal> meals, SortBy by) {
  meals.sort((a, b) {
    switch (by) {
      case SortBy.name:
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      case SortBy.category:
        return a.category.toLowerCase().compareTo(b.category.toLowerCase());
      case SortBy.area:
        return a.area.toLowerCase().compareTo(b.area.toLowerCase());
    }
  });
}
