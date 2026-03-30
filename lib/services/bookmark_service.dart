import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recipe.dart';

class BookmarkService {
  static const _key = 'bookmarked_recipes';

  // Get all bookmarked recipes
  Future<List<Recipe>> getBookmarks() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> raw = prefs.getStringList(_key) ?? [];

  final validRaw = raw.where((e) {
    final map = jsonDecode(e) as Map<String, dynamic>;
    final id = map['id']?.toString() ?? '';
    final title = map['title']?.toString() ?? '';
    return id.isNotEmpty && title.isNotEmpty; // skip corrupt entries
  }).toList();

  // Save back only the valid ones, removing corrupt ones permanently
  await prefs.setStringList(_key, validRaw);

  return validRaw
      .map((e) => Recipe.fromSpoonacular(jsonDecode(e) as Map<String, dynamic>))
      .toList();
}

  // Check if a recipe is bookmarked
  Future<bool> isBookmarked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    return raw.any((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return map['id'] == id;
    });
  }

  // Add bookmark
  Future<void> addBookmark(Recipe recipe) async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> raw = prefs.getStringList(_key) ?? [];
  
  final encoded = jsonEncode(recipe.toJson());
  
  // DEBUG: print what's being saved
  print('=== SAVING BOOKMARK ===');
  print('Encoded: $encoded');
  print('=======================');
  
  raw.add(encoded);
  await prefs.setStringList(_key, raw);
}

  // Remove bookmark
  Future<void> removeBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> raw = prefs.getStringList(_key) ?? [];
    raw.removeWhere((e) {
      final map = jsonDecode(e) as Map<String, dynamic>;
      return map['id'] == id;
    });
    await prefs.setStringList(_key, raw);
  }

  // Toggle bookmark
  Future<bool> toggleBookmark(Recipe recipe) async {
    final bookmarked = await isBookmarked(recipe.id);
    if (bookmarked) {
      await removeBookmark(recipe.id);
      return false; // now removed
    } else {
      await addBookmark(recipe);
      return true; // now added
    }
  }
}