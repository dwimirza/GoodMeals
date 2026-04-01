import '../models/recipe.dart';
import 'supabase_service.dart';

class BookmarkService {
  static const String tableName = 'bookmarks';

  Future<List<Recipe>> getBookmarks() async {
    final user = SupabaseService.currentUser;
    if (user == null) return [];

    final data = await SupabaseService.client
        .from(tableName)
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => Recipe.fromBookmark(item))
        .toList();
  }

  Future<bool> isBookmarked(String id) async {
    final user = SupabaseService.currentUser;
    if (user == null) return false;

    final data = await SupabaseService.client
        .from(tableName)
        .select('recipe_id')
        .eq('user_id', user.id)
        .eq('recipe_id', id);

    return (data as List).isNotEmpty;
  }

  Future<void> addBookmark(Recipe recipe) async {
    final user = SupabaseService.currentUser;
    if (user == null) throw Exception('User belum login');

    await SupabaseService.client.from(tableName).insert({
      'user_id': user.id,
      'recipe_id': recipe.id,
      'title': recipe.title,
      'image_url': recipe.imageUrl,
      'category': recipe.category,
      'area': recipe.area,
      'instructions': recipe.instructions,
      'ingredients': recipe.ingredients,
      'youtube_url': recipe.youtubeUrl,
      'calories': recipe.calories,
      'protein': recipe.protein,
      'fat': recipe.fat,
      'carbs': recipe.carbs,
    });
  }

  Future<void> removeBookmark(String id) async {
    final user = SupabaseService.currentUser;
    if (user == null) throw Exception('User belum login');

    await SupabaseService.client
        .from(tableName)
        .delete()
        .eq('user_id', user.id)
        .eq('recipe_id', id);
  }

  Future<bool> toggleBookmark(Recipe recipe) async {
    final bookmarked = await isBookmarked(recipe.id);

    if (bookmarked) {
      await removeBookmark(recipe.id);
      return false;
    } else {
      await addBookmark(recipe);
      return true;
    }
  }
}
