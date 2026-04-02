import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/supabase_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final Color primaryGreen = const Color(0xFF246E00);
  final Color textDark = const Color(0xFF163A1B);

  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();

  bool _isLoading = false;
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();

    final user = SupabaseService.currentUser;
    final metadata = user?.userMetadata ?? {};

    _usernameController.text = metadata['username']?.toString() ?? '';
    _fullNameController.text = metadata['full_name']?.toString() ?? '';
    _avatarUrl = metadata['avatar_url']?.toString() ?? '';
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(
        color: Colors.grey.shade700,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 18,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryGreen, width: 1.4),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  Future<void> _pickAndUploadAvatar() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    final picker = ImagePicker();
    final imageFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (imageFile == null) return;

    try {
      setState(() => _isLoading = true);

      final Uint8List bytes = await imageFile.readAsBytes();
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      final filePath = '${user.id}/avatar.$fileExt';

      await SupabaseService.client.storage.from('profile').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: imageFile.mimeType ?? 'image/$fileExt',
        ),
      );

      final imageUrl = SupabaseService.client.storage
          .from('profile')
          .getPublicUrl(filePath);

      await SupabaseService.client.auth.updateUser(
        UserAttributes(
          data: {
            'username': _usernameController.text.trim(),
            'full_name': _fullNameController.text.trim(),
            'avatar_url': imageUrl,
          },
        ),
      );

      setState(() {
        _avatarUrl = imageUrl;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avatar uploaded successfully')),
      );
    } on StorageException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    final fullName = _fullNameController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username is required')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      await SupabaseService.client.auth.updateUser(
        UserAttributes(
          data: {
            'username': username,
            'full_name': fullName,
            'avatar_url': _avatarUrl,
          },
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context, true);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEBFFE6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEBFFE6),
        elevation: 0,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: IconThemeData(color: textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryGreen.withOpacity(0.18),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.grey.shade100,
                  backgroundImage:
                  _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
                  child: _avatarUrl.isEmpty
                      ? Icon(Icons.person, size: 50, color: primaryGreen)
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _isLoading ? null : _pickAndUploadAvatar,
                child: Text(
                  'Change Avatar',
                  style: GoogleFonts.poppins(
                    color: primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: textDark,
                ),
                decoration: _inputDecoration('Username'),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _fullNameController,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: textDark,
                ),
                decoration: _inputDecoration('Full Name'),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    'Save Changes',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}