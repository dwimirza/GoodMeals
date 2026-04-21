import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class PaginatedRecipeResult {
  final List<Recipe> recipes;
  final int totalResults;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginatedRecipeResult({
    required this.recipes,
    required this.totalResults,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

class RecipeMealDb {
  static const String _base =
      'https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com';

  static const Map<String, String> _headers = {
    'x-rapidapi-key': 'spoonacular-api-key',
    'x-rapidapi-host': 'spoonaculra-api-host',
  };

  Future<PaginatedRecipeResult> getRecipes({
    String? query,
    String? category,
    int page = 1,
    int pageSize = 6,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safePageSize = pageSize < 1 ? 6 : pageSize;
    final offset = (safePage - 1) * safePageSize;

    final queryParams = <String, String>{
      'number': safePageSize.toString(),
      'offset': offset.toString(),
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
    };

    if (query != null && query.trim().isNotEmpty) {
      queryParams['query'] = query.trim();
    }

    if (category != null && category.trim().isNotEmpty) {
      queryParams['type'] = category.trim().toLowerCase();
    }

    final uri = Uri.parse('$_base/recipes/complexSearch')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final results = json['results'] as List<dynamic>? ?? [];
      final totalResults = (json['totalResults'] as num?)?.toInt() ?? 0;

      final recipes = results
          .map((e) => Recipe.fromSpoonacular(e as Map<String, dynamic>))
          .toList();

      final totalPages = totalResults == 0
          ? 1
          : max(1, (totalResults / safePageSize).ceil());

      return PaginatedRecipeResult(
        recipes: recipes,
        totalResults: totalResults,
        page: safePage,
        pageSize: safePageSize,
        totalPages: totalPages,
      );
    } else {
      throw Exception('Failed: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Recipe>> searchRecipes(
      String query, {
        int page = 1,
        int pageSize = 10,
      }) async {
    final result = await getRecipes(
      query: query,
      page: page,
      pageSize: pageSize,
    );
    return result.recipes;
  }

  Future<List<Recipe>> filterByCategory(
      String category, {
        int page = 1,
        int pageSize = 10,
      }) async {
    final result = await getRecipes(
      category: category,
      page: page,
      pageSize: pageSize,
    );
    return result.recipes;
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