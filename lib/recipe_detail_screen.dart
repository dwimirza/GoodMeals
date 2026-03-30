import 'package:flutter/material.dart';
import 'models/recipe.dart';
import 'services/recipe_api.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context) {
    final api = RecipeMealDb();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: FutureBuilder<Recipe?>(
        future: api.getById(recipeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load recipe: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final recipe = snapshot.data;
          if (recipe == null) {
            return const Center(child: Text('Recipe not found'));
          }

          return _RecipeDetailContent(recipe: recipe);
        },
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  final Recipe recipe;

  const _RecipeDetailContent({required this.recipe});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF7ED957);
    const Color textDark = Color(0xFF163A1B);
    const Color textGrey = Color(0xFFA0A0A0);

    final imageUrl = recipe.imageUrl.isNotEmpty
        ? recipe.imageUrl
        : 'https://via.placeholder.com/800x600.png?text=No+Image';

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 330,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 24,
          child: _buildTopButton(
            icon: Icons.arrow_back_ios_new,
            onTap: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          right: 24,
          child: _buildTopButton(
            icon: Icons.more_horiz,
            onTap: () {},
          ),
        ),
        Positioned.fill(
          top: 280,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(40),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (recipe.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            recipe.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (recipe.area.isNotEmpty) const SizedBox(width: 10),
                      if (recipe.area.isNotEmpty)
                        Text(
                          recipe.area,
                          style: const TextStyle(
                            color: textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Nutrition',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _nutritionCard('Calories', recipe.calories, '🔥'),
                      _nutritionCard('Protein', recipe.protein, '🥩'),
                      _nutritionCard('Fat', recipe.fat, '🥑'),
                      _nutritionCard('Carbs', recipe.carbs, '🍞'),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (recipe.ingredients.isEmpty)
                    const Text(
                      'No ingredients available',
                      style: TextStyle(color: textGrey),
                    )
                  else
                    Column(
                      children: recipe.ingredients.map((ingredient) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: primaryGreen,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  ingredient,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: textDark,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 28),
                  const Text(
                    'Recipe',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (recipe.instructions.isEmpty)
                    const Text(
                      'No steps available',
                      style: TextStyle(color: textGrey),
                    )
                  else
                    Column(
                      children: List.generate(
                        recipe.instructions.length,
                            (index) {
                          return _buildRecipeStep(
                            stepNumber: '${index + 1}',
                            title: '${index + 1} Step',
                            description: recipe.instructions[index],
                            isActive: index == 0,
                            isLast: index == recipe.instructions.length - 1,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 24,
          child: Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Start Cooking screen belum dibuat'),
                  ),
                );
              },
              icon: const Icon(Icons.play_circle_outline, color: Colors.white),
              label: const Text(
                'Start Cooking',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget _buildTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF163A1B)),
      ),
    );
  }

  static Widget _nutritionCard(String title, String value, String emoji) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF6FFF2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF163A1B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFFA0A0A0),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildRecipeStep({
    required String stepNumber,
    required String title,
    required String description,
    required bool isActive,
    required bool isLast,
  }) {
    const Color primaryGreen = Color(0xFF7ED957);
    const Color textGrey = Color(0xFFA0A0A0);
    const Color textDark = Color(0xFF163A1B);

    final itemColor = isActive ? primaryGreen : textGrey.withOpacity(0.5);
    final textColor = isActive ? textDark : textGrey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: itemColor, width: 2),
                    color: Colors.white,
                  ),
                  child: Text(
                    stepNumber,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: itemColor,
                    ),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: itemColor.withOpacity(0.4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 15,
                      color: isActive
                          ? textGrey
                          : textGrey.withOpacity(0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}