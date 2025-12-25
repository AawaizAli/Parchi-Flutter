import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/redemption_model.dart';

class RedemptionService {
  static const String _accessTokenKey = 'access_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get Redemption History
  Future<List<RedemptionModel>> getRedemptions(
      {int page = 1, String? status}) async {
    final token = await getToken();
    if (token == null) return [];

    try {
      final queryParams = {
        'page': page.toString(),
        if (status != null) 'status': status,
      };

      final uri = Uri.parse(ApiConfig.redemptionHistoryEndpoint)
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (responseData['data'] != null &&
            responseData['data']['items'] != null) {
          final List<dynamic> listJson = responseData['data']['items'];
          return listJson
              .map((json) => RedemptionModel.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to fetch redemptions: ${e.toString()}');
    }
  }

  // Get Redemption Stats
  Future<RedemptionStats> getStats() async {
    final token = await getToken();
    if (token == null)
      return RedemptionStats(totalRedemptions: 0, totalSavings: 0);

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.redemptionStatsEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return RedemptionStats.fromJson(responseData['data'] ?? {});
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      // Return zero stats on error rather than breaking UI
      return RedemptionStats(totalRedemptions: 0, totalSavings: 0);
    }
  }

  // Get Redemption Details
  Future<RedemptionModel> getRedemptionDetails(String id) async {
    final token = await getToken();
    if (token == null) throw Exception('No authentication token found.');

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.redemptionDetailsEndpoint(id)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return RedemptionModel.fromJson(responseData['data']);
      } else {
        throw _handleError(response.statusCode, responseData);
      }
    } catch (e) {
      rethrow;
    }
  }

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

final redemptionService = RedemptionService();
