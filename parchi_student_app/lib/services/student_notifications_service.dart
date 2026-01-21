import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';
import '../models/notification_model.dart';

class StudentNotificationsService {
  static final StudentNotificationsService _instance = StudentNotificationsService._internal();

  factory StudentNotificationsService() {
    return _instance;
  }

  StudentNotificationsService._internal();

  // Fetch Notifications
  Future<StudentNotificationsResponse> getNotifications({int page = 1, int limit = 10}) async {
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    final uri = Uri.parse(ApiConfig.studentNotificationsEndpoint).replace(queryParameters: queryParams);
    
    try {
      final response = await authService.authenticatedGet(uri.toString());

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return StudentNotificationsResponse.fromJson(json);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
       if (e.toString().contains("Unauthorized")) {
          throw Exception("Unauthorized");
       }
       rethrow;
    }
  }

  // Mark as Read
  Future<void> markAsRead(String notificationId) async {
    try {
      await authService.authenticatedPost(
        ApiConfig.markNotificationReadEndpoint(notificationId),
      );
    } catch (e) {
      print('Failed to mark notification as read: $e');
      // We often swallow this error in UI to not block the user, 
      // but logging it is good.
    }
  }
}
