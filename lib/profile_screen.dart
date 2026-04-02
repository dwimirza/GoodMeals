import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/supabase_service.dart';
import 'edit_profile_screen.dart';
import 'bookmark_screen.dart';
import 'main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Color primaryGreen = const Color(0xFF246E00);
  final Color textDark = const Color(0xFF163A1B);

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SupabaseService.currentUser;
    final metadata = user?.userMetadata ?? {};

    final username = metadata['username']?.toString() ??
        user?.email?.split('@').first ??
        'Guest';

    final fullName = metadata['full_name']?.toString() ?? '';
    final avatarUrl = metadata['avatar_url']?.toString() ?? '';
    final email = user?.email ?? '-';

    return Scaffold(
      backgroundColor: const Color(0xFFEBFFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFFE6),
        elevation: 0,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: textDark),
        actions: [
          IconButton(
            onPressed: _openEditProfile,
            icon: Icon(Icons.settings, color: primaryGreen),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              child: avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 50, color: primaryGreen)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              fullName.isNotEmpty ? fullName : username,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '@$username',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style: GoogleFonts.poppins(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(
                  'Edit Profile',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: _buildBottomNav(),
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
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const GoodMealsHome(),
                ),
                    (route) => false,
              );
            },
            child: _buildNavIcon(Icons.home, isActive: false),
          ),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BookmarkScreen(
                    onBookmarkChanged: (id, isAdded) {},
                  ),
                ),
              );
              if (mounted) setState(() {});
            },
            child: _buildNavIcon(Icons.bookmark_outline, isActive: false),
          ),
          _buildNavIcon(Icons.person_outline, isActive: true),
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