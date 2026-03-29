import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';
import 'services/recipe_api.dart'; // contains RecipeApiNinjas
import 'models/recipe.dart';

void main() {
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
      home: const GoodMealsHome(),
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

  @override
  void initState() {
    super.initState();
    // default query to show something on first load
    _futureRecipes = _api.searchRecipes('chicken');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 20,
                bottom: 100,
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
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _buildTopAppBar() {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryGreen.withOpacity(0.2), width: 2),
            image: const DecorationImage(
              image: NetworkImage('https://i.pravatar.cc/150?img=5'),
              fit: BoxFit.cover,
            ),
          ),
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
                child: Icon(Icons.mic, color: primaryGreen, size: 20),
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          _buildCategoryChip('All', isSelected: true),
          _buildCategoryChip('Meat', isSelected: false),
          _buildCategoryChip('Noodles', isSelected: false),
          _buildCategoryChip('Vegetable', isSelected: false),
        ],
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Card
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
                Row(
                  children: [
                    Icon(Icons.schedule,
                        size: 16, color: textColor.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    // Text(
                    //    time,
                    //   style: TextStyle(
                    //     fontSize: 12,
                    //     fontWeight: FontWeight.bold,
                    //     color: textColor.withOpacity(0.7),
                    //   ),
                    // ),
                  ],
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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
                          Icon(Icons.arrow_forward,
                              color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.bookmark, color: textColor.withOpacity(0.5)),
                  ],
                )
              ],
            ),
          ),
          // Food Image
          Positioned(
            right: -10,
            top: -20,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
                image: DecorationImage(
                  image: NetworkImage(imageUrl),
                  fit: BoxFit.cover,
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
          _buildNavIcon(Icons.home, isActive: true),
          _buildNavIcon(Icons.search, isActive: false),
          _buildNavIcon(Icons.bookmark_outline, isActive: false),
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

  // ---------- API cards ----------

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecipeDetailScreen(),
                        // later: pass recipe
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
}