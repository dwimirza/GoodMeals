import 'dart:typed_data';
import 'package:flutter/material.dart';
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
      final fileExt = imageFile.path.split('.').last;
      final filePath = '${user.id}/avatar.$fileExt';

      await SupabaseService.client.storage.from('profile').uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(
          upsert: true,
          contentType: imageFile.mimeType,
        ),
      );

      final imageUrl = SupabaseService.client.storage
          .from('profile')
          .getPublicUrl(filePath);

      setState(() {
        _avatarUrl = imageUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar uploaded successfully')),
        );
      }
    } on StorageException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Color(0xFF163A1B)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF163A1B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white,
              backgroundImage:
              _avatarUrl.isNotEmpty ? NetworkImage(_avatarUrl) : null,
              child: _avatarUrl.isEmpty
                  ? Icon(Icons.person, size: 50, color: primaryGreen)
                  : null,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _isLoading ? null : _pickAndUploadAvatar,
              child: Text(
                'Change Avatar',
                style: TextStyle(color: primaryGreen),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  _isLoading ? 'Saving...' : 'Save Changes',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}