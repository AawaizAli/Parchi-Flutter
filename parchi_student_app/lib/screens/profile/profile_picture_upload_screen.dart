import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/colours.dart';
import '../../services/supabase_storage_service.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';

class ProfilePictureUploadScreen extends ConsumerStatefulWidget {
  const ProfilePictureUploadScreen({super.key});

  @override
  ConsumerState<ProfilePictureUploadScreen> createState() => _ProfilePictureUploadScreenState();
}

class _ProfilePictureUploadScreenState extends ConsumerState<ProfilePictureUploadScreen> {
  File? _selectedImage;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();
  final SupabaseStorageService _storageService = SupabaseStorageService();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 70);
      if (picked != null) {
        setState(() => _selectedImage = File(picked.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking image: $e")));
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);
    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null) throw Exception("User not found");

      // 1. Upload to Supabase
      final String publicUrl = await _storageService.uploadProfilePicture(_selectedImage!, user.id);

      // 2. Update Backend
      await authService.updateProfilePicture(publicUrl);

      // 3. Refresh App State
      // This forces the UserProvider to fetch fresh data (including the new image URL)
      await ref.refresh(userProfileProvider.future);

      if (mounted) {
        Navigator.pop(context); // Go back to Profile Screen
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!"), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Upload failed: $e"), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Profile Picture")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Preview
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _selectedImage != null ? FileImage(_selectedImage!) : null,
              child: _selectedImage == null 
                  ? const Icon(Icons.person, size: 80, color: Colors.grey) 
                  : null,
            ),
            const SizedBox(height: 30),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Camera"),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text("Gallery"),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            if (_selectedImage != null)
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                      : const Text("Save & Update"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}