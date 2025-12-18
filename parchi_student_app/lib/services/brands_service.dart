import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/brand_model.dart';

class BrandsService {
  static const String _accessTokenKey = 'access_token';

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  Future<List<BrandModel>> getAllBrands() async {
    final token = await getToken();
    
    // Allow public access if token is missing, or handle as needed. 
    // Assuming protected endpoint based on plan, but handle null safe.
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(
        Uri.parse(ApiConfig.allBrandsEndpoint),
        headers: headers,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // Expecting { data: [...] } or just [...] depending on standard. 
        // Based on offers_service, it might be nested. 
        // Let's assume standard array in 'data' field or root array.
        
        // Debugging hint: print(responseData);
        
        List<dynamic> list = [];
         if (responseData['data'] is List) {
          list = responseData['data'];
        } else if (responseData is List) {
          list = responseData as List;
        }

        return list.map((json) => BrandModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load brands: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching brands: $e');
    }
  }
}

final brandsService = BrandsService();
