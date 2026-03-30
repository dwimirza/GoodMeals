import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'services/bookmark_service.dart';
import 'recipe_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  final void Function(String id, bool isAdded)? onBookmarkChanged; // new

  const BookmarkScreen({super.key, this.onBookmarkChanged});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final Color primaryGreen = const Color(0xFF246E00);
  final Color textDark = const Color(0xFF163A1B);
  final BookmarkService _bookmarkService = BookmarkService();

  late Future<List<Recipe>> _futureBookmarks;

  @override
  void initState() {
    super.initState();
    _futureBookmarks = _bookmarkService.getBookmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFFE6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bookmarks',
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: FutureBuilder<List<Recipe>>(
        future: _futureBookmarks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_outline,
                      size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No bookmarks yet',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RecipeDetailScreen(recipeId: recipe.id),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          recipe.imageUrl.isNotEmpty
                              ? recipe.imageUrl
                              : 'https://via.placeholder.com/80x80.png?text=No+Image',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.image_not_supported,
                                color: Colors.grey,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title + category
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recipe.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              recipe.category,
                              style: TextStyle(
                                fontSize: 13,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remove bookmark
                      IconButton(
          icon: Icon(Icons.bookmark, color: primaryGreen),
              onPressed: () async {
              await _bookmarkService.removeBookmark(recipe.id);
              widget.onBookmarkChanged?.call(recipe.id, false); // notify home
                  setState(() {
                      _futureBookmarks = _bookmarkService.getBookmarks();
                    });
                  },
                ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}