import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe.dart';

class RecipeApiNinjas {
  static const _baseUrl = 'https://api.api-ninjas.com/v3/recipe';
  static const _apiKey = 'fA4rxinOU0z9VTWYrjhTKntFQ79xbvTImUQWoizw';

  Future<List<Recipe>> searchRecipes(String title) async {
    final uri = Uri.parse('$_baseUrl?title=${Uri.encodeQueryComponent(title)}');

    final response = await http.get(
      uri,
      headers: {
        'X-Api-Key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body) as List;
      return data
          .map((e) => Recipe.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed: ${response.statusCode} ${response.body}');
    }
  }
}