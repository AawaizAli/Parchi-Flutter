import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/colours.dart';
import '../../../services/supabase_storage_service.dart';
import '../../../services/auth_service.dart';
import '../../../providers/user_provider.dart';

class ProfilePictureUploadSheet extends ConsumerStatefulWidget {
  final VoidCallback onClose; // Callback to handle closing animation

  const ProfilePictureUploadSheet({super.key, required this.onClose});

  @override
  ConsumerState<ProfilePictureUploadSheet> createState() => _ProfilePictureUploadSheetState();
}

class _ProfilePictureUploadSheetState extends ConsumerState<ProfilePictureUploadSheet> {
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
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _handleUpload() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);
    try {
      final user = ref.read(userProfileProvider).value;
      if (user == null) throw Exception("User not found");

      final String publicUrl = await _storageService.uploadProfilePicture(_selectedImage!, user.id);
      await authService.updateProfilePicture(publicUrl);
      await ref.refresh(userProfileProvider.future);

      if (mounted) {
        // Trigger the close animation via callback
        widget.onClose(); 
        
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Profile updated!"), 
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Upload failed: $e"), 
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),

            const Text(
              "Change Profile Photo",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOptionButton(Icons.camera_alt_rounded, "Camera", () => _pickImage(ImageSource.camera)),
                _buildOptionButton(Icons.photo_library_rounded, "Gallery", () => _pickImage(ImageSource.gallery)),
              ],
            ),

            if (_selectedImage != null) ...[
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _handleUpload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  child: _isUploading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) 
                      : const Text("Save Photo"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: _isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: [Icon(icon, size: 28), const SizedBox(height: 8), Text(label)]),
      ),
    );
  }
}