import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConfig {
  // Load Supabase configuration from environment variables
  static String get supabaseUrl {
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL is not set in .env file');
    }
    return url;
  }

  static String get supabaseAnonKey {
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY is not set in .env file');
    }
    return key;
  }

  // Storage bucket name for student KYC documents
  static String get studentKycBucket {
    return dotenv.env['STUDENT_KYC_BUCKET'] ?? 'student-kyc';
  }

  // Storage paths
  static String getStudentIdPath(String userId) =>
      'student-id/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
  static String getSelfiePath(String userId) =>
      'selfie/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
}

