import 'package:flutter/material.dart';
import 'package:goodmeals/services/bookmark_service.dart';
import 'services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/recipe.dart';
import 'login_page.dart';
import 'recipe_detail_screen.dart';
import 'services/recipe_api.dart';
import 'bookmark_screen.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const GoodMealsApp());
}

class GoodMealsApp extends StatelessWidget {
  const GoodMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoodMeals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEBFFE6),
        fontFamily: 'Inter',
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseService.authStateChanges,
      builder: (context, snapshot) {
        final user = SupabaseService.currentUser;

        if (user != null) {
          return const GoodMealsHome();
        }

        return const LoginPage();
      },
    );
  }
}

class GoodMealsHome extends StatefulWidget {
  const GoodMealsHome({super.key});

  @override
  State<GoodMealsHome> createState() => _GoodMealsHomeState();
}

class _GoodMealsHomeState extends State<GoodMealsHome> {
  final Color primaryGreen = const Color(0xFF246E00);
  final Color textDark = const Color(0xFF163A1B);

  final RecipeMealDb _api = RecipeMealDb();
  late Future<List<Recipe>> _futureRecipes;
  final TextEditingController _searchController = TextEditingController();

  final BookmarkService _bookmarkService = BookmarkService();
  Set<String> _bookmarkedIds = {};


  String _selectedCategory = 'main course';

@override
void initState() {
  super.initState();
  _futureRecipes = _api.searchRecipes('chicken');
  _loadBookmarkedIds();
}

Future<void> _loadBookmarkedIds() async {
  final bookmarks = await _bookmarkService.getBookmarks();
  setState(() {
    _bookmarkedIds = bookmarks.map((r) => r.id).toSet();
  });
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _futureRecipes = _api.searchRecipes(query);
    });
  }

  void _filterCategory(String category) {
    setState(() {
      _selectedCategory = category;
      _futureRecipes = _api.filterByCategory(category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 20,
                  bottom: 120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopAppBar(),
                    const SizedBox(height: 32),
                    _buildHeroText(),
                    const SizedBox(height: 24),
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildCategories(),
                    const SizedBox(height: 36),
                    _buildPopularRecipeHeader(),
                    const SizedBox(height: 24),
                    _buildRecipeCardsFromApi(context),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: _buildBottomNav(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryGreen.withOpacity(0.2), width: 2),
          ),
          child: Icon(Icons.person, color: primaryGreen),
        ),
        const SizedBox(width: 16),
        Text(
          'Hi, Angelia!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: primaryGreen,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.grey),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(Icons.logout, color: primaryGreen),
          onPressed: () async {
            await SupabaseService.signOut();
          },
        ),
      ],
    );
  }

  Widget _buildHeroText() {
    return Text(
      'What do you want\ncooking today!',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        color: textDark,
        height: 1.2,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(
          hintText: 'Search recipe...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search, color: primaryGreen),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _search,
              child: CircleAvatar(
                backgroundColor: primaryGreen.withOpacity(0.1),
                child: Icon(Icons.search, color: primaryGreen, size: 20),
              ),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    final categories = [
      'main course',
      'side dish',
      'dessert',
      'appetizer',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: categories.map((category) {
          return GestureDetector(
            onTap: () => _filterCategory(category),
            child: _buildCategoryChip(
              category,
              isSelected: _selectedCategory == category,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, {required bool isSelected}) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? primaryGreen : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: primaryGreen.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textDark.withOpacity(0.6),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPopularRecipeHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Popular Recipe',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
        Text(
          'See All',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCard({
  required Color bgColor,
  required Color textColor,
  required String imageUrl,
  required String title,
  required VoidCallback onTap,
  required bool isBookmarked,
  required Future<void> Function() onBookmarkTap,
}) {
  final safeImageUrl = imageUrl.isNotEmpty
      ? imageUrl
      : 'https://via.placeholder.com/300x300.png?text=No+Image';

  return GestureDetector(
    onTap: onTap,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(    
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 16,
                color: textColor.withOpacity(0.7),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 160,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Recipe button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          'Recipe',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Bookmark button - fixed
                  GestureDetector(
                    onTap: () => onBookmarkTap(),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                      color: isBookmarked
                          ? textColor
                          : textColor.withOpacity(0.4),
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Food image
        Positioned(
          right: -10,
          top: -20,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.network(
                safeImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
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
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBottomNav() {
  return Container(
    height: 70,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(35),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Home - already on home screen, no navigation needed
        _buildNavIcon(Icons.home, isActive: true),

        // Search
        _buildNavIcon(Icons.search, isActive: false),

        // Bookmarks - navigate to BookmarkScreen
        GestureDetector(
  onTap: () async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookmarkScreen(
          onBookmarkChanged: (id, isAdded) {
            setState(() {
              if (isAdded) {
                _bookmarkedIds.add(id);
              } else {
                _bookmarkedIds.remove(id);
              }
            });
          },
        ),
      ),
    );
    // Reload all bookmark ids when returning to home
    _loadBookmarkedIds();
  },
  child: _buildNavIcon(Icons.bookmark_outline, isActive: false),
),

        // Profile - stub for now
        _buildNavIcon(Icons.person_outline, isActive: false),
      ],
    ),
  );
}

  Widget _buildNavIcon(IconData icon, {required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? primaryGreen : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isActive ? Colors.white : Colors.grey.shade400,
        size: 26,
      ),
    );
  }

  Widget _buildRecipeCardsFromApi(BuildContext context) {
  return FutureBuilder<List<Recipe>>(
    future: _futureRecipes,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(
          child: Text(
            'Failed to load recipes: ${snapshot.error}',
            style: TextStyle(color: Colors.red.shade700),
          ),
        );
      }

      final recipes = snapshot.data ?? [];

      if (recipes.isEmpty) {
        return const Text('No recipes found');
      }

      return Column(
        children: [
          for (int i = 0; i < recipes.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == recipes.length - 1 ? 0 : 40.0,
              ),
              child: _buildCustomCard(
                bgColor: i.isEven
                    ? const Color(0xFFFDF7CC)
                    : const Color(0xFFD1FAE5),
                textColor: i.isEven
                    ? const Color(0xFF4E3D00)
                    : const Color(0xFF00443D),
                title: recipes[i].title,
                imageUrl: recipes[i].imageUrl,
                isBookmarked: _bookmarkedIds.contains(recipes[i].id), // new
                onBookmarkTap: () async {                              // new
                  final added = await _bookmarkService.toggleBookmark(recipes[i]);
                  setState(() {
                    if (added) {
                      _bookmarkedIds.add(recipes[i].id);
                    } else {
                      _bookmarkedIds.remove(recipes[i].id);
                    }
                  });
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecipeDetailScreen(
                        recipeId: recipes[i].id,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    },
  );
}}  