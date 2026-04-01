class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final String category;
  final String area;
  final List<String> instructions;
  final List<String> ingredients;
  final String youtubeUrl;

  final String calories;
  final String protein;
  final String fat;
  final String carbs;

  Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.category,
    required this.area,
    required this.instructions,
    required this.ingredients,
    required this.youtubeUrl,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  factory Recipe.fromSpoonacular(Map<String, dynamic> json) {
    List<String> instructions = [];
    if (json['savedInstructions'] != null) {
      instructions = List<String>.from(json['savedInstructions'] as List);
    } else {
      final analyzedInstructions =
          json['analyzedInstructions'] as List<dynamic>? ?? [];
      if (analyzedInstructions.isNotEmpty) {
        final firstInstruction =
        analyzedInstructions.first as Map<String, dynamic>;
        final steps = firstInstruction['steps'] as List<dynamic>? ?? [];
        instructions = steps.map((e) {
          final step = e as Map<String, dynamic>;
          return step['step']?.toString() ?? '';
        }).where((e) => e.isNotEmpty).toList();
      }
    }

    List<String> ingredients = [];
    if (json['savedIngredients'] != null) {
      ingredients = List<String>.from(json['savedIngredients'] as List);
    } else {
      final extendedIngredients =
          json['extendedIngredients'] as List<dynamic>? ?? [];
      ingredients = extendedIngredients.map((e) {
        final item = e as Map<String, dynamic>;
        return item['original']?.toString() ?? '';
      }).where((e) => e.isNotEmpty).toList();
    }

    final nutrients =
        ((json['nutrition'] as Map<String, dynamic>?)?['nutrients']
        as List<dynamic>?) ??
            [];

    String findNutrient(String name) {
      try {
        final item = nutrients.firstWhere(
              (e) => (e as Map<String, dynamic>)['name'] == name,
        ) as Map<String, dynamic>;
        return '${item['amount']} ${item['unit']}';
      } catch (_) {
        return json[name.toLowerCase()] as String? ?? '-';
      }
    }

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image']?.toString() ?? '',
      category:
      json['dishTypes'] != null && (json['dishTypes'] as List).isNotEmpty
          ? (json['dishTypes'] as List).first.toString()
          : '',
      area: json['cuisines'] != null && (json['cuisines'] as List).isNotEmpty
          ? (json['cuisines'] as List).first.toString()
          : '',
      instructions: instructions,
      ingredients: ingredients,
      youtubeUrl: json['youtubeUrl']?.toString() ?? '',
      calories: findNutrient('Calories'),
      protein: findNutrient('Protein'),
      fat: findNutrient('Fat'),
      carbs: findNutrient('Carbohydrates'),
    );
  }

  factory Recipe.fromBookmark(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipe_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      area: json['area']?.toString() ?? '',
      instructions: List<String>.from(json['instructions'] ?? []),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      youtubeUrl: json['youtube_url']?.toString() ?? '',
      calories: json['calories']?.toString() ?? '-',
      protein: json['protein']?.toString() ?? '-',
      fat: json['fat']?.toString() ?? '-',
      carbs: json['carbs']?.toString() ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': imageUrl,
      'dishTypes': [category],
      'cuisines': [area],
      'youtubeUrl': youtubeUrl,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
      'savedInstructions': instructions,
      'savedIngredients': ingredients,
    };
  }
}
