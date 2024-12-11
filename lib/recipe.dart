// recipe.dart
class Recipe {
  final String name;
  final List<String> ingredients;
  final int totalTimeInMins;
  final String cuisine;
  final String instructions;
  final String url;
  final String imageUrl;
  final int ingredientCount;

  Recipe({
    required this.name,
    required this.ingredients,
    required this.totalTimeInMins,
    required this.cuisine,
    required this.instructions,
    required this.url,
    required this.imageUrl,
    required this.ingredientCount,
  });
}
