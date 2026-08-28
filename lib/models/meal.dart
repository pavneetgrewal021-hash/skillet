/// Data models for TheMealDB API responses.
///
/// TheMealDB returns everything as JSON maps of strings. These classes turn
/// that loosely-typed data into something the UI can rely on.
library;

/// A lightweight meal entry as returned by the "filter by category" and
/// "search" list endpoints — just enough to render a card in a list.
class MealSummary {
  final String id;
  final String name;
  final String thumbnail;

  const MealSummary({
    required this.id,
    required this.name,
    required this.thumbnail,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      thumbnail: json['strMealThumb'] as String? ?? '',
    );
  }
}

/// One line of a recipe: e.g. measure "2 cloves", name "Garlic".
class Ingredient {
  final String name;
  final String measure;

  const Ingredient({required this.name, required this.measure});
}

/// The full meal detail returned by the "lookup by id" endpoint.
class Meal {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnail;
  final String? youtubeUrl;
  final String? sourceUrl;
  final List<Ingredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnail,
    required this.youtubeUrl,
    required this.sourceUrl,
    required this.ingredients,
  });

  /// Reduce to the fields we store in the favorites list.
  MealSummary toSummary() =>
      MealSummary(id: id, name: name, thumbnail: thumbnail);

  factory Meal.fromJson(Map<String, dynamic> json) {
    // TheMealDB stores ingredients as 20 flat pairs: strIngredient1..20 and
    // strMeasure1..20, with unused slots left blank or null. Collapse them
    // into a clean list and drop the empties.
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] as String?)?.trim() ?? '';
      final measure = (json['strMeasure$i'] as String?)?.trim() ?? '';
      if (name.isNotEmpty) {
        ingredients.add(Ingredient(name: name, measure: measure));
      }
    }

    String? nonEmpty(String? value) =>
        (value == null || value.trim().isEmpty) ? null : value.trim();

    return Meal(
      id: json['idMeal'] as String,
      name: json['strMeal'] as String,
      category: json['strCategory'] as String? ?? 'Unknown',
      area: json['strArea'] as String? ?? 'Unknown',
      instructions: json['strInstructions'] as String? ?? '',
      thumbnail: json['strMealThumb'] as String? ?? '',
      youtubeUrl: nonEmpty(json['strYoutube'] as String?),
      sourceUrl: nonEmpty(json['strSource'] as String?),
      ingredients: ingredients,
    );
  }
}

/// A recipe category, e.g. "Seafood", "Dessert".
class Category {
  final String name;
  final String thumbnail;
  final String description;

  const Category({
    required this.name,
    required this.thumbnail,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['strCategory'] as String,
      thumbnail: json['strCategoryThumb'] as String? ?? '',
      description: json['strCategoryDescription'] as String? ?? '',
    );
  }
}
