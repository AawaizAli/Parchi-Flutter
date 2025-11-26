import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // Base URL for the backend API
  static String get baseUrl {
    final url = dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';
    return url;
  }

  // Auth endpoints
  static String get signupEndpoint => '$baseUrl/auth/signup';
  static String get loginEndpoint => '$baseUrl/auth/login';
  static String get logoutEndpoint => '$baseUrl/auth/logout';
  static String get profileEndpoint => '$baseUrl/auth/me';
}

