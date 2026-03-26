import 'package:flutter/material.dart';
import 'recipe_detail_screen.dart';

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
        scaffoldBackgroundColor: const Color(0xFFEBFFE6), // Light green background
        fontFamily: 'Inter', // Pastikan Anda menambahkan font di pubspec.yaml jika ingin sama persis
      ),
      home: const GoodMealsHome(),
    );
  }
}

class GoodMealsHome extends StatelessWidget {
  const GoodMealsHome({super.key});

  // Warna-warna utama dari desain
  final Color primaryGreen = const Color(0xFF246E00);
  final Color textDark = const Color(0xFF163A1B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Konten Utama yang bisa di-scroll
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 100),
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
                  _buildRecipeCards(context),
                ],
              ),
            ),
          ),

          // Floating Bottom Navigation
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
              image: NetworkImage('https://i.pravatar.cc/150?img=5'), // Placeholder foto profil
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
        decoration: InputDecoration(
          hintText: 'Search recipe...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(Icons.search, color: primaryGreen),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: primaryGreen.withOpacity(0.1),
              child: Icon(Icons.mic, color: primaryGreen, size: 20),
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
            ? [BoxShadow(color: primaryGreen.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
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

  // 1. Update this method to accept BuildContext for navigation
  Widget _buildRecipeCards(BuildContext context) {
    return Column(
      children: [
        _buildCustomCard(
          bgColor: const Color(0xFFFDF7CC),
          textColor: const Color(0xFF4E3D00),
          time: '45 MIN',
          title: 'Chicken Steak\nwith Lemon',
          imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&q=80&w=300',
          // Add the navigation logic here
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeDetailScreen(),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        _buildCustomCard(
          bgColor: const Color(0xFFD1FAE5),
          textColor: const Color(0xFF00443D),
          time: '35 MIN',
          title: 'Spaghetti Original\nSeafood',
          imageUrl: 'https://images.unsplash.com/photo-1563379926898-05f4575a45d8?auto=format&fit=crop&q=80&w=300',
          // Add the navigation logic here as well
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RecipeDetailScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  // 2. Update the card builder to accept an onTap callback
  Widget _buildCustomCard({
    required Color bgColor,
    required Color textColor,
    required String time,
    required String title,
    required String imageUrl,
    required VoidCallback onTap, // <--- New parameter
  }) {
    // Wrap the entire Stack in a GestureDetector
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
                    Icon(Icons.schedule, size: 16, color: textColor.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: textColor.withOpacity(0.7),
                      ),
                    ),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Text('Recipe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
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
}