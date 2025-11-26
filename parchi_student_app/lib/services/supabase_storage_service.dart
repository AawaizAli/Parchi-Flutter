import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

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

  /// Upload both images and return their URLs
  /// Returns a map with 'studentIdUrl' and 'selfieUrl' keys
  Future<Map<String, String>> uploadKycImages({
    required File studentIdImage,
    required File selfieImage,
    required String userId,
  }) async {
    try {
      // Upload both images concurrently
      final results = await Future.wait([
        uploadStudentIdImage(studentIdImage, userId),
        uploadSelfieImage(selfieImage, userId),
      ]);

      return {
        'studentIdUrl': results[0],
        'selfieUrl': results[1],
      };
    } catch (e) {
      throw Exception('Failed to upload KYC images: $e');
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

