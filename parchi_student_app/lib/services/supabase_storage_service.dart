import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'auth_service.dart'; // [Import Auth Service]
import 'package:flutter/foundation.dart'; // For debugPrint
class SupabaseStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Upload student ID image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadStudentIdImage(File imageFile, String userId) async {
    try {
      final String filePath = SupabaseConfig.getStudentIdPath(userId);
      
      // Upload file to Supabase Storage
      await _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ));

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload student ID image: $e');
    }
  }

  /// Upload student ID back image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadStudentIdBackImage(File imageFile, String userId) async {
    try {
      final String filePath = SupabaseConfig.getStudentIdBackPath(userId);
      
      // Upload file to Supabase Storage
      await _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ));

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload student ID back image: $e');
    }
  }

  /// Upload selfie image to Supabase Storage
  /// Returns the public URL of the uploaded image
  Future<String> uploadSelfieImage(File imageFile, String userId) async {
    try {
      final String filePath = SupabaseConfig.getSelfiePath(userId);
      
      // Upload file to Supabase Storage
      await _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .upload(filePath, imageFile, fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ));

      // Get public URL
      final String publicUrl = _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload selfie image: $e');
    }
  }

  /// Upload all KYC images and return their URLs
  /// Returns a map with 'studentIdUrl', 'studentIdBackUrl', and 'selfieUrl' keys
  Future<Map<String, String>> uploadKycImages({
    required File studentIdImage,
    required File studentIdBackImage,
    required File selfieImage,
    required String userId,
  }) async {
    try {
      // Upload all images concurrently
      final results = await Future.wait([
        uploadStudentIdImage(studentIdImage, userId),
        uploadStudentIdBackImage(studentIdBackImage, userId),
        uploadSelfieImage(selfieImage, userId),
      ]);

      return {
        'studentIdUrl': results[0],
        'studentIdBackUrl': results[1],
        'selfieUrl': results[2],
      };
    } catch (e) {
      throw Exception('Failed to upload KYC images: $e');
    }
  }

  // [FIXED] Upload Profile Picture
    Future<String> uploadProfilePicture(File imageFile, String userId) async {
      try {
        final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        final String filePath = '$userId/profile_$timestamp.jpg';
        
        // 1. Get the REFRESH token (Correct token for setSession)
        final refreshToken = await authService.getRefreshToken();
        
        if (refreshToken != null) {
          try {
            // This logs the Flutter Supabase client in so RLS policies pass
            await _supabase.auth.setSession(refreshToken);
          } catch (authError) {
            // If session sync fails, log it but don't crash the app.
            // The upload might still fail if RLS blocks it, but at least the app won't close.
            debugPrint("Supabase session sync warning: $authError");
          }
        } else {
          debugPrint("No refresh token found. Uploading as anonymous/current session.");
        }

        // 2. Upload to 'avatars' bucket
        await _supabase.storage.from('avatars').upload(
          filePath, 
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: true),
        );

        // 3. Get Public URL
        final String publicUrl = _supabase.storage.from('avatars').getPublicUrl(filePath);
        return publicUrl;
      } catch (e) {
        throw Exception('Failed to upload profile picture: $e');
      }
    }
  


  /// Delete an image from Supabase Storage
  Future<void> deleteImage(String filePath) async {
    try {
      await _supabase.storage
          .from(SupabaseConfig.studentKycBucket)
          .remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }
}

