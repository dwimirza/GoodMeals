class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String area;
  final List<String> instructions;
  final List<String> ingredients;
  final String youtubeUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.area,
    required this.instructions,
    required this.ingredients,
    required this.youtubeUrl,
  });

  // String get timeLabel => '45 MIN'; // API doesn't provide time

  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Split instructions string into list
    final raw = json['strInstructions'] as String? ?? '';
    final steps = raw
        .split('\r\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Build ingredients list from strIngredient1..20
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ingredient != null && ingredient.trim().isNotEmpty) {
        ingredients.add('${measure?.trim() ?? ''} ${ingredient.trim()}'.trim());
      }
    }

    return Recipe(
      id: json['idMeal'] as String? ?? '',
      title: json['strMeal'] as String? ?? '',
      imageUrl: json['strMealThumb'] as String? ?? '',
      category: json['strCategory'] as String? ?? '',
      area: json['strArea'] as String? ?? '',
      instructions: steps,
      ingredients: ingredients,
      youtubeUrl: json['strYoutube'] as String? ?? '',
    );
  }
}