class Ingredient {
  final String name;
  final num? quantity; // <- nullable
  final String? unit;  // <- sometimes null too

  Ingredient({
    required this.name,
    this.quantity,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      quantity: json['quantity'] as num?,      // don't cast null to num
      unit: json['unit'] as String?,           // may be null
    );
  }
}

class Recipe {
  final String title;
  final List<Ingredient> ingredients;
  final String servings;
  final List<String> instructions;
  final String nutrition;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.servings,
    required this.instructions,
    required this.nutrition,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final ingredientsJson = json['ingredients'] as List<dynamic>? ?? [];
    final instructionsJson = json['instructions'] as List<dynamic>? ?? [];

    return Recipe(
      title: json['title'] as String,
      ingredients: ingredientsJson
          .map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
          .toList(),
      servings: json['servings'] as String? ?? '',
      instructions: instructionsJson
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      nutrition: json['nutrition'] as String? ?? '',
    );
  }

  // convenience for your card UI
  // String get timeLabel => '45 MIN'; // you can’t get time from API, so hardcode or derive later
  // String get imageUrl =>
  //     'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&q=80&w=300';
}