import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiresAtKey = 'token_expires_at';
  static const String _userKey = 'user';

  // Get stored access token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Set access token
  Future<void> setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }

  // Get stored refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Set refresh token
  Future<void> setRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  // Set token expiry
  Future<void> setTokenExpiry(int expiresAt) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_tokenExpiresAtKey, expiresAt);
  }

  // Get token expiry
  Future<int?> getTokenExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_tokenExpiresAtKey);
  }

  // Store user data
  Future<void> setUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // Get stored user data
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  // Remove all stored tokens and user data
  Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_tokenExpiresAtKey);
    await prefs.remove(_userKey);
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    if (token == null) return false;

    // Check if token is expired
    final expiresAt = await getTokenExpiry();
    if (expiresAt != null) {
      final expiryTime = expiresAt * 1000; // Convert to milliseconds
      if (DateTime.now().millisecondsSinceEpoch >= expiryTime) {
        await removeToken();
        return false;
      }
    }

    return true;
  }

  // Signup
  Future<AuthResponse> signup({
    required String email,
    required String password,
    required String role,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.signupEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final authResponse = AuthResponse.fromJson(responseData);

        // Store tokens and user data
        await setToken(authResponse.session.accessToken);
        await setRefreshToken(authResponse.session.refreshToken);
        await setTokenExpiry(authResponse.session.expiresAt);
        await setUser(authResponse.user);

        return authResponse;
      } else {
        final error = ApiError.fromJson(responseData);
        throw Exception(error.message);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  // Login
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final authResponse = AuthResponse.fromJson(responseData);

        // Store tokens and user data
        await setToken(authResponse.session.accessToken);
        await setRefreshToken(authResponse.session.refreshToken);
        await setTokenExpiry(authResponse.session.expiresAt);
        await setUser(authResponse.user);

        return authResponse;
      } else {
        final error = ApiError.fromJson(responseData);
        throw Exception(error.message);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // Get current user profile
  Future<ProfileResponse> getProfile() async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found. Please login again.');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.profileEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final profileResponse = ProfileResponse.fromJson(responseData);
        
        // Update stored user data
        await setUser(profileResponse.user);

        return profileResponse;
      } else {
        final error = ApiError.fromJson(responseData);
        throw Exception(error.message);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to get profile: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    final token = await getToken();
    
    if (token != null) {
      try {
        await http.post(
          Uri.parse(ApiConfig.logoutEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
      } catch (e) {
        // Even if logout request fails, clear local tokens
        // Log error silently - user will be logged out locally anyway
      }
    }

    // Always remove tokens locally
    await removeToken();
  }
}

// Singleton instance
final authService = AuthService();

