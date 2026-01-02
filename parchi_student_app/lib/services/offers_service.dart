import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Changed to match Auth Service
import '../config/api_config.dart';
import '../models/offer_model.dart';

class OffersService {
  // Same key as in AuthService to ensure we get the correct token
  static const String _accessTokenKey = 'access_token';

  // Helper to get the token exactly like AuthService does
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get Active Offers
  Future<List<OfferModel>> getActiveOffers() async {
    final token = await getToken();
    
    // If no token, return empty list or throw error depending on your preference
    if (token == null) {
      // Option 1: Return empty list (fails quietly)
      return []; 
      // Option 2: Throw exception (forces user to login)
      // throw Exception('No authentication token found.');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.activeOffersEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // NestJS response structure: { data: { data: [...], pagination: {...} }, ... }
        if (responseData['data'] != null && responseData['data']['items'] != null) {
          final List<dynamic> offersJson = responseData['data']['items'];
          return offersJson.map((json) => OfferModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch offers: ${e.toString()}');
    }
  }

  // Get Featured Offers
  Future<List<OfferModel>> getFeaturedOffers() async {
    final token = await getToken();
    if (token == null) return [];

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.featuredOffersEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['data'] != null) {
          final List<dynamic> offersJson = responseData['data'];
          return offersJson.map((json) => OfferModel.fromJson(json)).toList();
        }
        return [];
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch featured offers: ${e.toString()}');
    }
  }

  // Get Offer Details
  Future<OfferModel> getOfferDetails(String id) async {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token found.');

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.offerDetailsEndpoint(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // NestJS response for details might differ slightly, usually data inside data
        return OfferModel.fromJson(responseData['data']);
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Consistent Error Handling Helper (Matches AuthService logic)
  Exception _handleError(int statusCode, Map<String, dynamic> errorData) {
    final message = errorData['message'];
    String errorMessage;

    if (message is List) {
      errorMessage = message.join(', ');
    } else if (message is String) {
      errorMessage = message;
    } else {
      errorMessage = 'An error occurred';
    }

    switch (statusCode) {
      case 400:
        return Exception("Bad Request: $errorMessage");
      case 401:
        return Exception("Unauthorized: Please login again.");
      case 403:
        return Exception("Forbidden: You do not have access to this resource.");
      case 404:
        return Exception("Not Found: $errorMessage");
      case 500:
        return Exception("Server Error: $errorMessage");
      default:
        return Exception(errorMessage);
    }
  }
}

// Singleton instance
final offersService = OffersService();