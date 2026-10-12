library;

/// Спільний toJson() для моделей (вимога методички).
abstract class Storable {
  Map<String, Object?> toJson();
}

/// За чим сортувати список страв у меню.
enum SortBy { name, category, area }

/// Інгредієнт: у API це пари strIngredientN + strMeasureN.
class Ingredient implements Storable {
  const Ingredient({required this.name, required this.measure});

  final String name;
  final String measure;

  static Ingredient fromJson(Map<String, Object?> json) {
    if (json case {
      'name': final String name,
      'measure': final String measure,
    }) {
      return Ingredient(name: name, measure: measure);
    }
    if (json case {'name': final String name}) {
      return Ingredient(name: name, measure: '');
    }
    throw FormatException('Не вдалося розібрати Ingredient з $json');
  }

  @override
  Map<String, Object?> toJson() => {'name': name, 'measure': measure};

  @override
  String toString() {
    if (measure.isEmpty) {
      return name;
    }
    return '$name ($measure)';
  }
}

/// Страва з TheMealDB.
class Meal implements Storable {
  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbUrl,
    required this.ingredients,
  });

  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbUrl;
  final List<Ingredient> ingredients;

  /// З відповіді API або з нашого data.json (після toJson).
  static Meal fromJson(Map<String, Object?> json) {
    final List<Ingredient> ingredients = [];

    if (json['ingredients'] case final List<Object?> list) {
      for (final Object? item in list) {
        if (item is! Map) {
          continue;
        }
        ingredients.add(Ingredient.fromJson(Map<String, Object?>.from(item)));
      }
    } else {
      for (var i = 1; i <= 20; i++) {
        final Object? rawName = json['strIngredient$i'];
        if (rawName is! String) {
          continue;
        }
        final String name = rawName.trim();
        if (name.isEmpty) {
          continue;
        }
        final Object? rawMeasure = json['strMeasure$i'];
        final String measure = rawMeasure is String ? rawMeasure.trim() : '';
        ingredients.add(Ingredient(name: name, measure: measure));
      }
    }

    final String id =
        (json['idMeal'] as String?) ?? (json['id'] as String?) ?? '';
    final String name =
        (json['strMeal'] as String?) ?? (json['name'] as String?) ?? '';

    if (id.isEmpty || name.isEmpty) {
      throw FormatException('Не вдалося розібрати Meal з $json');
    }

    return Meal(
      id: id,
      name: name,
      category:
          (json['strCategory'] as String?) ??
          (json['category'] as String?) ??
          '',
      area: (json['strArea'] as String?) ?? (json['area'] as String?) ?? '',
      instructions:
          (json['strInstructions'] as String?) ??
          (json['instructions'] as String?) ??
          '',
      thumbUrl:
          (json['strMealThumb'] as String?) ??
          (json['thumbUrl'] as String?) ??
          '',
      ingredients: ingredients,
    );
  }

  @override
  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'area': area,
    'instructions': instructions,
    'thumbUrl': thumbUrl,
    'ingredients': [for (final Ingredient item in ingredients) item.toJson()],
  };

  @override
  String toString() => '#$id $name ($category, $area)';
}

/// Відповідь search.php: { "meals": [ ... ] } або { "meals": null }.
class MealResponse {
  const MealResponse({required this.meals});

  final List<Meal> meals;

  static MealResponse fromJson(Map<String, Object?> json) {
    if (json case {'meals': final List<Object?> data}) {
      return MealResponse(
        meals: [
          for (final Object? item in data)
            if (item is Map) Meal.fromJson(Map<String, Object?>.from(item)),
        ],
      );
    }
    if (json case {'meals': null}) {
      return const MealResponse(meals: []);
    }
    throw FormatException('Відповідь не містить списку "meals": $json');
  }
}
