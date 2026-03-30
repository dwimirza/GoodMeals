import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeMealDb {
  static const String _base =
      'https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com';

  static const Map<String, String> _headers = {
    'x-rapidapi-key': '365e82efffmsha7d6faa2248dc72p13938fjsnafd3658e78e3',
    'x-rapidapi-host': 'spoonacular-recipe-food-nutrition-v1.p.rapidapi.com',
  };

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse(
      '$_base/recipes/complexSearch?query=${Uri.encodeQueryComponent(query)}&number=10&addRecipeInformation=true&fillIngredients=true',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;

      if (results == null) return [];

      return results
          .map((e) => Recipe.fromSpoonacular(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Recipe>> filterByCategory(String category) async {
    final uri = Uri.parse(
      '$_base/recipes/complexSearch?type=${Uri.encodeQueryComponent(category.toLowerCase())}&number=10&addRecipeInformation=true&fillIngredients=true',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>?;

      if (results == null) return [];

      return results
          .map((e) => Recipe.fromSpoonacular(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Recipe?> getById(String id) async {
    final uri = Uri.parse(
      '$_base/recipes/$id/information?includeNutrition=true',
    );

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return Recipe.fromSpoonacular(json);
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Recipe> getRandom() async {
    final uri = Uri.parse('$_base/recipes/random?number=1');

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final recipes = json['recipes'] as List<dynamic>;

      return Recipe.fromSpoonacular(recipes.first as Map<String, dynamic>);
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }
}