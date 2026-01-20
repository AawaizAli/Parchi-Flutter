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

  // Get stored access token with auto-refresh check
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if token exists and is expired/about to expire
    final expiresAt = prefs.getInt(_tokenExpiresAtKey);
    if (expiresAt != null) {
      final expiryTime = expiresAt * 1000; // Convert to milliseconds
      // Check if expired or about to expire (within 5 minutes)
      if (DateTime.now().millisecondsSinceEpoch >= expiryTime - 300000) {
        try {
          print("Token expired or close to expiry. Refreshing...");
          await refreshToken();
          // If refresh succeeded, the new token is in SharedPreferences
          return prefs.getString(_accessTokenKey);
        } catch (e) {
          print("Auto-refresh in getToken failed: $e");
          // If refresh failed, we might still return the old token 
          // and let the API call fail with 401, or return null.
          // For now, return the old token. The API call will likely throw 'Unauthorized'.
        }
      }
    }
    
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
      // Check if expired or about to expire (within 5 minutes)
      if (DateTime.now().millisecondsSinceEpoch >= expiryTime - 300000) {
        // Attempt refresh
        try {
          await refreshToken();
          return true;
        } catch (e) {
          // Refresh failed, logout
          await removeToken();
          return false;
        }
      }
    }

    return true;
  }

  // Refresh Token
  Future<void> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      throw Exception('No refresh token available');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.refreshEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': refreshToken,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // The backend returns { data: { user: ..., session: ... }, ... }
        // We need to parse the inner session data based on how AuthResponse expects it
        // Or manually update tokens if the structure is different.
        // Based on backend implementation: return { user: ..., session: ... } wrapped in ApiResponse
        
        // Api Response wrapper: { data: { user: ..., session: ... }, message: ..., status: ... }
        final sessionData = responseData['data']['session'];
        if (sessionData != null) {
            // Update stored tokens
            if (sessionData['access_token'] != null) {
              await setToken(sessionData['access_token']);
            }
            if (sessionData['refresh_token'] != null) {
              await setRefreshToken(sessionData['refresh_token']);
            }
            if (sessionData['expires_at'] != null) {
               await setTokenExpiry(sessionData['expires_at']);
            } else if (sessionData['expires_in'] != null) {
               final expiresIn = sessionData['expires_in'] as int;
               final expiresAt = (DateTime.now().millisecondsSinceEpoch ~/ 1000) + expiresIn;
               await setTokenExpiry(expiresAt);
            }
        }
      } else {
        throw Exception('Refresh failed');
      }
    } catch (e) {
      throw Exception('Refresh token failed: ${e.toString()}');
    }
  }

  // Check if user is authenticated and has student role
  Future<bool> isStudentAuthenticated() async {
    final isAuth = await isAuthenticated();
    if (!isAuth) return false;

    // Reload user from local storage to be sure
    final user = await getUser();
    if (user == null) return false;

    // Only allow students to access the student app
    return user.role.toLowerCase() == 'student';
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

  // Student Signup with verification documents
  /// 
  /// Returns the signup response data on success
  /// Throws custom exceptions on error (ValidationException, ConflictException, etc.)
  Future<StudentSignupResponse> studentSignup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? phone,
    required String university,
    required String cnic,
    required String dateOfBirth,
    required String studentIdCardFrontUrl,
    required String studentIdCardBackUrl,
    required String cnicFrontImageUrl,
    required String cnicBackImageUrl,
    required String selfieImageUrl,
  }) async {
    try {
      // Prepare request body
      final requestBody = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'phone': phone,
        'university': university,
        'cnic': cnic,
        'dateOfBirth': dateOfBirth,
        'studentIdCardFrontUrl': studentIdCardFrontUrl,
        'studentIdCardBackUrl': studentIdCardBackUrl,
        'cnicFrontImageUrl': cnicFrontImageUrl,
        'cnicBackImageUrl': cnicBackImageUrl,
        'selfieImageUrl': selfieImageUrl,
      };

      // Make POST request
      final response = await http.post(
        Uri.parse(ApiConfig.studentSignupEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      // Parse response
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      // Check for success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return StudentSignupResponse.fromJson(responseData);
      } else {
        // Handle error response
        throw _handleStudentSignupError(response.statusCode, responseData);
      }
    } on http.ClientException {
      throw Exception('Network error. Please check your internet connection.');
    } catch (e) {
      if (e is ValidationException || 
          e is ConflictException || 
          e is UnprocessableEntityException || 
          e is ServerException) {
        rethrow;
      }
      throw Exception('Student signup failed: ${e.toString()}');
    }
  }

  /// Handle API error responses for student signup
  Exception _handleStudentSignupError(int statusCode, Map<String, dynamic> errorData) {
    final message = errorData['message'];
    String errorMessage;
    
    // Handle array of validation messages
    if (message is List) {
      errorMessage = message.join(', ');
    } else if (message is String) {
      errorMessage = message;
    } else {
      errorMessage = 'An error occurred';
    }
    
    switch (statusCode) {
      case 400:
        return ValidationException(errorMessage);
      case 409:
        return ConflictException(errorMessage);
      case 422:
        return UnprocessableEntityException(errorMessage);
      case 500:
        return ServerException(errorMessage);
      default:
        return Exception(errorMessage);
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

  // Forgot Password
  Future<void> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.forgotPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Success - password reset email sent
        // The API returns success even if email doesn't exist (for security)
        return;
      } else {
        // Handle error response
        String errorMessage = 'Failed to send password reset email';
        
        if (responseData.containsKey('message')) {
          final message = responseData['message'];
          if (message is List) {
            errorMessage = message.join(', ');
          } else if (message is String) {
            errorMessage = message;
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // [NEW] Update Profile Picture Endpoint
  Future<void> updateProfilePicture(String imageUrl) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found. Please login again.');
    }

    try {
      final response = await http.patch(
        // Ensure this matches your backend route
        Uri.parse('${ApiConfig.baseUrl}/auth/student/profile-picture'), 
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'imageUrl': imageUrl}),
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to update profile picture');
      }
      
      // Optionally force a profile refresh here
      await getProfile();
      
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }



  // Change Password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No token found. Please login again.');
    }

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.changePasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        // Password changed successfully
        // Note: The existing token remains valid, no need to update it
        return;
      } else {
        // Handle error responses
        String errorMessage = 'Failed to change password';
        
        if (responseData.containsKey('message')) {
          final message = responseData['message'];
          if (message is List) {
            errorMessage = message.join(', ');
          } else if (message is String) {
            errorMessage = message;
          }
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Change password failed: ${e.toString()}');
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

