import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeMealDb {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Recipe>> searchRecipes(String query) async {
    final uri = Uri.parse('$_base/search.php?s=${Uri.encodeQueryComponent(query)}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = json['meals'] as List<dynamic>?;
      if (meals == null) return []; // no results
      return meals
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  Future<List<Recipe>> filterByCategory(String category) async {
    final uri = Uri.parse('$_base/filter.php?c=${Uri.encodeQueryComponent(category)}');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = json['meals'] as List<dynamic>?;
      if (meals == null) return [];
      return meals
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  Future<Recipe?> getById(String id) async {
    final uri = Uri.parse('$_base/lookup.php?i=$id');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = json['meals'] as List<dynamic>?;
      if (meals == null || meals.isEmpty) return null;
      return Recipe.fromJson(meals[0] as Map<String, dynamic>);
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }

  Future<Recipe> getRandom() async {
    final uri = Uri.parse('$_base/random.php');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final meals = json['meals'] as List<dynamic>;
      return Recipe.fromJson(meals[0] as Map<String, dynamic>);
    } else {
      throw Exception('Failed: ${response.statusCode}');
    }
  }
}