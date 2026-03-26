import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  final Color primaryGreen = const Color(0xFF7ED957);
  final Color textDark = const Color(0xFF163A1B);
  final Color textGrey = const Color(0xFFA0A0A0);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Background Hero Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45,
            child: Image.network(
              'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&q=80&w=800',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Top Navigation Buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 24,
            child: _buildNavButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 24,
            child: _buildNavButton(
              icon: Icons.more_horiz,
              onTap: () {},
            ),
          ),

          // 3. Bottom Sheet Content
          Positioned(
            top: size.height * 0.35,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                    left: 24, right: 24, top: 16, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title and Time Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            'Chicken Steak With\nLemon',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            '45 MIN',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Nutritions Section
                    Text(
                      'Nutritions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildNutritionItem('Protein', '🍗', '250g'),
                        _buildNutritionItem('Fat', '🥩', '25g'),
                        _buildNutritionItem('Carbo', '🧅', '80g'),
                        _buildNutritionItem('Calories', '🔥', '150g'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Recipe Steps Section
                    Text(
                      'Recipe',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildRecipeStep(
                      stepNumber: '1',
                      title: '1 Step',
                      description:
                      'Wipe the chicken breasts and beat with a mallet or a knife to flatten. Cut each into two pieces.',
                      isActive: true,
                      isLast: false,
                    ),
                    _buildRecipeStep(
                      stepNumber: '2',
                      title: '2 Step',
                      description:
                      'Mix the chicken with the other ingredients, except oil.',
                      isActive: false,
                      isLast: false,
                    ),
                    _buildRecipeStep(
                      stepNumber: '3',
                      title: '3 Step',
                      description: 'Put aside to marinate for 2 hours or so.',
                      isActive: false,
                      isLast: false,
                    ),
                    _buildRecipeStep(
                      stepNumber: '4',
                      title: '4 Step',
                      description:
                      'Heat a non-stick pan or grill with a thin layer of oil.',
                      isActive: false,
                      isLast: false,
                    ),
                    _buildRecipeStep(
                      stepNumber: '5',
                      title: '5 Step',
                      description:
                      'When hot, put the pieces of chicken without them touching each other, turning over at once.',
                      isActive: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Floating Video Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.play_circle_outline, color: Colors.white),
                label: const Text(
                  'Video',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: primaryGreen.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: textDark, size: 20),
      ),
    );
  }

  Widget _buildNutritionItem(String title, String emoji, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: textDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecipeStep({
    required String stepNumber,
    required String title,
    required String description,
    required bool isActive,
    required bool isLast,
  }) {
    Color itemColor = isActive ? primaryGreen : textGrey.withOpacity(0.5);
    Color textColor = isActive ? textDark : textGrey;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: itemColor,
                      width: 2,
                    ),
                    color: Colors.white,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: CustomPaint(
                      painter: DashedLinePainter(color: itemColor),
                      size: const Size(1, double.infinity),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Step Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isActive ? textGrey : textGrey.withOpacity(0.7),
                      height: 1.5,
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

// Custom Painter to draw the dashed line for the recipe steps
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 4, dashSpace = 4, startY = 4;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;

    while (startY < size.height) {
      canvas.drawLine(Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}