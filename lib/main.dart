import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/recipe.dart';
import 'services/recipe_api.dart';
import 'services/bookmark_service.dart';
import 'services/supabase_service.dart';

import 'login_page.dart';
import 'recipe_detail_screen.dart';
import 'bookmark_screen.dart';
import 'profile_screen.dart';
import 'splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.init();
  runApp(const GoodMealsApp());
}

class GoodMealsApp extends StatelessWidget {
  const GoodMealsApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF246E00);
    const textDark = Color(0xFF163A1B);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoodMeals',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEBFFE6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          headlineLarge: GoogleFonts.poppins(
            fontSize: 34,
            fontWeight: FontWeight.w800,
            color: textDark,
            height: 1.15,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3F5143),
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF66756A),
          ),
          labelLarge: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      home: const SplashScreen(),
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
        return GoodMealsHome(
          key: ValueKey(user?.id ?? 'guest'),
        );
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
  late Future<PaginatedRecipeResult> _futureRecipes;

  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  int _pageSize = 6;

  String _selectedCategory = '';
  String _searchQuery = '';

  final BookmarkService _bookmarkService = BookmarkService();
  Set<String> _bookmarkedIds = {};

  bool get _isLoggedIn => SupabaseService.currentUser != null;

  User? get _user => SupabaseService.currentUser;
  Map<String, dynamic> get _metadata => _user?.userMetadata ?? {};

  String get _username {
    return _metadata['username']?.toString() ??
        _user?.email?.split('@').first ??
        'Guest';
  }

  String get _avatarUrl {
    return _metadata['avatar_url']?.toString() ?? '';
  }

  @override
  void initState() {
    super.initState();
    _futureRecipes = _loadRecipes();
    _loadBookmarkedIds();
  }

  Future<PaginatedRecipeResult> _loadRecipes() {
    return _api.getRecipes(
      query: _searchQuery.isEmpty ? null : _searchQuery,
      category: _selectedCategory.isEmpty ? null : _selectedCategory,
      page: _currentPage,
      pageSize: _pageSize,
    );
  }

  Future<void> _loadBookmarkedIds() async {
    if (!_isLoggedIn) {
      setState(() {
        _bookmarkedIds = {};
      });
      return;
    }

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

    setState(() {
      _searchQuery = query;
      _currentPage = 1;
      _futureRecipes = _loadRecipes();
    });
  }

  void _filterCategory(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? '' : category;
      _currentPage = 1;
      _futureRecipes = _loadRecipes();
    });
  }

  Widget _buildProfileAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryGreen.withOpacity(0.18),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: _avatarUrl.isNotEmpty
            ? Image.network(
          _avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.person, color: primaryGreen);
          },
        )
            : Icon(Icons.person, color: primaryGreen),
      ),
    );
  }

  Future<bool?> _showActionDialog({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String message,
    required String primaryText,
    required VoidCallback onPrimaryPressed,
    String secondaryText = 'Cancel',
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBg,
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    height: 1.65,
                    color: const Color(0xFF6B7A70),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          side: BorderSide(
                            color: primaryGreen.withOpacity(0.20),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          secondaryText,
                          style:
                          Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                          onPrimaryPressed();
                        },
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: primaryGreen,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          primaryText,
                          style:
                          Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmLogout() async {
    await _showActionDialog(
      icon: Icons.logout_rounded,
      iconBg: const Color(0xFFE8F7E1),
      title: 'Logout from GoodMeals?',
      message:
      'You can always come back and continue discovering delicious recipes anytime.',
      primaryText: 'Logout',
      onPrimaryPressed: () async {
        await SupabaseService.signOut();
        if (mounted) {
          setState(() {
            _bookmarkedIds = {};
          });
        }
      },
    );
  }

  Future<void> _showLoginRequiredDialog() async {
    await _showActionDialog(
      icon: Icons.lock_rounded,
      iconBg: const Color(0xFFE8F7E1),
      title: 'Login Required',
      message:
      'Please login first to save bookmarks and manage your personal profile.',
      primaryText: 'Login',
      onPrimaryPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
        ).then((_) {
          _loadBookmarkedIds();
          setState(() {});
        });
      },
    );
  }

  Widget _buildTopAppBar() {
    return Row(
      children: [
        _buildProfileAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Hi, $_username!',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              color: primaryGreen,
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none, color: Colors.grey),
          onPressed: () {},
        ),
        _isLoggedIn
            ? IconButton(
          icon: Icon(Icons.logout, color: primaryGreen),
          onPressed: _confirmLogout,
        )
            : IconButton(
          icon: Icon(Icons.login, color: primaryGreen),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoginPage(),
              ),
            ).then((_) {
              _loadBookmarkedIds();
              setState(() {});
            });
          },
        ),
      ],
    );
  }

  Widget _buildHeroText() {
    return Text(
      'What do you want\ncooking today!',
      style: Theme.of(context).textTheme.headlineLarge,
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
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search recipe...',
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade400,
          ),
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
            color: primaryGreen.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ]
            : [],
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isSelected ? Colors.white : textDark.withOpacity(0.75),
          fontSize: 14,
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
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontSize: 22,
          ),
        ),
      ],
    );
  }

  Widget _buildPageSizeSelector() {
    final options = [4, 6, 8, 10];

    return Row(
      children: [
        Text(
          'Show:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(width: 12),
        ...options.map((size) {
          final isSelected = _pageSize == size;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _pageSize = size;
                  _currentPage = 1;
                  _futureRecipes = _loadRecipes();
                });
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryGreen : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$size',
                  style: TextStyle(
                    color: isSelected ? Colors.white : textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
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
                        children: [
                          Text(
                            'Recipe',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
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

  Widget _buildRecipeCardsFromApi(BuildContext context) {
    return FutureBuilder<PaginatedRecipeResult>(
      future: _futureRecipes,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load recipes: ${snapshot.error}',
            ),
          );
        }

        final pageData = snapshot.data;
        final recipes = pageData?.recipes ?? [];

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
                  isBookmarked: _bookmarkedIds.contains(recipes[i].id),
                  onBookmarkTap: () async {
                    if (!_isLoggedIn) {
                      _showLoginRequiredDialog();
                      return;
                    }

                    final added =
                    await _bookmarkService.toggleBookmark(recipes[i]);
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
  }

  Widget _buildPagination() {
    return FutureBuilder<PaginatedRecipeResult>(
      future: _futureRecipes,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final totalPages = snapshot.data!.totalPages;

        if (totalPages <= 1) {
          return const SizedBox.shrink();
        }

        const int visiblePages = 5;

        int startPage = 1;
        int endPage = totalPages;

        if (totalPages > visiblePages) {
          startPage = _currentPage - 2;
          endPage = _currentPage + 2;

          if (startPage < 1) {
            startPage = 1;
            endPage = visiblePages;
          }

          if (endPage > totalPages) {
            endPage = totalPages;
            startPage = totalPages - visiblePages + 1;
          }
        }

        final pages = List.generate(
          endPage - startPage + 1,
              (index) => startPage + index,
        );

        Widget buildButton({
          required VoidCallback? onTap,
          required Widget child,
          bool isActive = false,
          EdgeInsets padding =
          const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        }) {
          final isDisabled = onTap == null;

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: onTap,
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: isActive
                      ? primaryGreen
                      : isDisabled
                      ? Colors.grey.shade100
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isActive ? primaryGreen : Colors.grey.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isActive
                          ? primaryGreen.withOpacity(0.18)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          );
        }

        final List<Widget> items = [];

        items.add(
          buildButton(
            onTap: _currentPage > 1
                ? () {
              setState(() {
                _currentPage = 1;
                _futureRecipes = _loadRecipes();
              });
            }
                : null,
            child: Text(
              'First',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _currentPage > 1 ? textDark : Colors.grey.shade400,
              ),
            ),
          ),
        );

        items.add(
          buildButton(
            onTap: _currentPage > 1
                ? () {
              setState(() {
                _currentPage--;
                _futureRecipes = _loadRecipes();
              });
            }
                : null,
            child: Text(
              'Prev',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _currentPage > 1 ? textDark : Colors.grey.shade400,
              ),
            ),
          ),
        );

        if (startPage > 1) {
          items.add(
            buildButton(
              onTap: () {
                setState(() {
                  _currentPage = 1;
                  _futureRecipes = _loadRecipes();
                });
              },
              child: Text(
                '1',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ),
          );

          items.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        }

        for (final page in pages) {
          final isActive = page == _currentPage;

          items.add(
            buildButton(
              isActive: isActive,
              onTap: () {
                setState(() {
                  _currentPage = page;
                  _futureRecipes = _loadRecipes();
                });
              },
              child: Text(
                '$page',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isActive ? Colors.white : textDark,
                ),
              ),
            ),
          );
        }

        if (endPage < totalPages) {
          items.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                '...',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );

          items.add(
            buildButton(
              onTap: () {
                setState(() {
                  _currentPage = totalPages;
                  _futureRecipes = _loadRecipes();
                });
              },
              child: Text(
                '$totalPages',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
            ),
          );
        }

        items.add(
          buildButton(
            onTap: _currentPage < totalPages
                ? () {
              setState(() {
                _currentPage++;
                _futureRecipes = _loadRecipes();
              });
            }
                : null,
            child: Text(
              'Next',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _currentPage < totalPages
                    ? textDark
                    : Colors.grey.shade400,
              ),
            ),
          ),
        );

        items.add(
          buildButton(
            onTap: _currentPage < totalPages
                ? () {
              setState(() {
                _currentPage = totalPages;
                _futureRecipes = _loadRecipes();
              });
            }
                : null,
            child: Text(
              'Last',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _currentPage < totalPages
                    ? textDark
                    : Colors.grey.shade400,
              ),
            ),
          ),
        );

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              runAlignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 10,
              children: items,
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
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
          _buildNavIcon(Icons.home, isActive: true),
          GestureDetector(
            onTap: () async {
              if (!_isLoggedIn) {
                _showLoginRequiredDialog();
                return;
              }

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

              _loadBookmarkedIds();
            },
            child: _buildNavIcon(Icons.bookmark_outline, isActive: false),
          ),
          GestureDetector(
            onTap: () async {
              if (!_isLoggedIn) {
                _showLoginRequiredDialog();
                return;
              }

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );

              if (mounted) {
                setState(() {});
                _loadBookmarkedIds();
              }
            },
            child: _buildNavIcon(Icons.person_outline, isActive: false),
          ),
        ],
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, {required bool isActive}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
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
                    const SizedBox(height: 16),
                    _buildPageSizeSelector(),
                    const SizedBox(height: 24),
                    _buildRecipeCardsFromApi(context),
                    const SizedBox(height: 28),
                    _buildPagination(),
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
}