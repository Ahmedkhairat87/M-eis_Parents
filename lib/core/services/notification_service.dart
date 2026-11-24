import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level background message handler for FCM.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized for background tasks if needed.
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  late final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static const String _fcmTokenKey = 'fcm_token';

  /// Initializes Firebase and Notification settings.
  Future<void> initialize() async {
    // 1. Initialize Firebase
    await Firebase.initializeApp();

    // Initialize FirebaseMessaging after Firebase is ready
    _messaging = FirebaseMessaging.instance;

    // 2. Setup Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. Initialize Local Notifications
    await _setupLocalNotifications();

    // 4. Set foreground presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false, // We will show our own local notification
      badge: true,
      sound: true,
    );

    // 5. Request Permissions
    await requestPermissions();

    // 6. Handle Listeners
    _setupMessageListeners();

    // 7. Get and Store Token
    await getAndStoreToken();
  }

  Future<void> _setupLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle tapping on a local notification
        _handleNotificationTap(response.payload);
      },
    );

    if (Platform.isAndroid) {
      // Create a high importance channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );

      await _localNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> requestPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional notification permission');
    } else {
      debugPrint('User declined or has not accepted notification permission');
    }
  }

  void _setupMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint('Message also contained a notification: ${message.notification}');
        _showLocalNotification(message);
      }
    });

    // When the app is in background but opened via notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('A new onMessageOpenedApp event was published!');
      _handleNotificationTap(message.data.toString());
    });

    // Handle initial message if app was terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('App opened from terminated state via notification');
        _handleNotificationTap(message.data.toString());
      }
    });

    // Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      debugPrint('FCM Token refreshed: $newToken');
      await _saveToken(newToken);
    });
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null && !kIsWeb) {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  void _handleNotificationTap(String? payload) {
    debugPrint('Notification tapped with payload: $payload');
    // Implement navigation or specific logic here if needed.
    // In this project, we can use a GlobalKey for navigation or similar.
  }

  Future<void> getAndStoreToken() async {
    try {
      if (Platform.isIOS) {
        // For iOS, it's safer to wait for APNS token first
        String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('APNS Token is null, waiting and retrying...');
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
        }
        debugPrint('APNS Token: $apnsToken');
      }

      String? token = await _messaging.getToken();
      if (token != null) {
        debugPrint('FCM Registration Token: $token');
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }
}
