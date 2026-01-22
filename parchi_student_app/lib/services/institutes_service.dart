import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/institute_model.dart';

class InstitutesService {
  Future<List<Institute>> fetchInstitutes() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.institutesEndpoint));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Institute.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load institutes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch institutes: $e');
    }
  }
}
