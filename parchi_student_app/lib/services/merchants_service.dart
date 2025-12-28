import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/merchant_detail_model.dart';

class MerchantsService {
  static const String _accessTokenKey = 'access_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<MerchantDetailModel> getMerchantDetails(String merchantId) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('No authentication token found.');
    }

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.merchantDetailsEndpoint(merchantId)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // NestJS response structure: { data: {...}, ... }
        if (responseData['data'] != null) {
          return MerchantDetailModel.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format: missing data field');
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to fetch merchant details: ${e.toString()}');
    }
  }

  // Consistent Error Handling Helper
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
final merchantsService = MerchantsService();

