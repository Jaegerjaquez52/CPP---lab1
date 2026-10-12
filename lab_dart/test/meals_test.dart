import 'package:lab_dart/lab_dart.dart';
import 'package:test/test.dart';

Meal _meal({
  required String id,
  required String name,
  String category = '',
  String area = '',
}) {
  return Meal(
    id: id,
    name: name,
    category: category,
    area: area,
    instructions: '',
    thumbUrl: '',
    ingredients: const [],
  );
}

void main() {
  final meals = [
    _meal(id: '1', name: 'Pasta Salad', category: 'Seafood', area: 'Italian'),
    _meal(id: '2', name: 'Beef Stew', category: 'Beef', area: 'British'),
    _meal(id: '3', name: 'Sushi', category: 'Seafood', area: 'Japanese'),
  ];

  test('працює пошук / фільтрація', () {
    final seafood = searchMeals(meals, 'seafood');
    expect(seafood, hasLength(2));
    expect(seafood.map((m) => m.id), containsAll(['1', '3']));

    final pasta = searchMeals(meals, 'pasta');
    expect(pasta, hasLength(1));
    expect(pasta.first.name, equals('Pasta Salad'));
  });

  test('працює сортування', () {
    final copy = List<Meal>.from(meals);
    sortMeals(copy, SortBy.name);
    expect(copy.map((m) => m.name).toList(), [
      'Beef Stew',
      'Pasta Salad',
      'Sushi',
    ]);

    sortMeals(copy, SortBy.area);
    expect(copy.map((m) => m.area).toList(), [
      'British',
      'Italian',
      'Japanese',
    ]);
  });
}
