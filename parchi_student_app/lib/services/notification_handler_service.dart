import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHandlerService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static final NotificationHandlerService _instance = NotificationHandlerService._internal();

  factory NotificationHandlerService() {
    return _instance;
  }

  NotificationHandlerService._internal();

  // 1. Initialize Everything
  Future<void> initialize() async {
    // Request Permission (Critical for iOS)
    try {
      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // Subscribe to the Broadcast Topic
      // This connects this device to your "students_all" blasts
      // Wrapped in try-catch for iOS Simulator which fails to get APNS token
      await _fcm.subscribeToTopic('students_all');
      print("Subscribed to student broadcasts!");
    } catch (e) {
      print("FCM Subscription failed (Known issue on Simulator): $e");
    }

    // Setup Local Notifications (for foreground display)
    // Make sure 'ic_launcher' exists in android/app/src/main/res/drawable or mipmap
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher'); 
    
    // For iOS (Darwin)
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings initSettings = 
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(initSettings);

    // 2. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // When app is OPEN, FCM doesn't show a popup automatically.
      // We manually trigger a Local Notification.
      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // Handle Background Message Open
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('Message clicked!');
    });
  }

  // 3. Trigger the Local Notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'broadcast_channel', // id
      'Student Broadcasts', // name
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = 
        NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      // Pass the DB ID so we can mark it read later if needed
      payload: message.data['notification_id'], 
    );
  }
  
  // 4. Get FCM Token (Optional: send this to your backend if you want user-specific notifs later)
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
