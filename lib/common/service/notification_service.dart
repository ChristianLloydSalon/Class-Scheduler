import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Channel IDs
  static const String _highImportanceChannelId = 'high_importance_channel';
  static const String _defaultChannelId = 'default_channel';

  Future<void> initialize() async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Create notification channels
    await _createNotificationChannels();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        _showForegroundNotification(message);
      }
    });

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  Future<void> _createNotificationChannels() async {
    final android =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (android != null) {
      // High importance channel
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _highImportanceChannelId,
          'High Importance Notifications',
          description: 'This channel is used for important notifications.',
          importance: Importance.high,
          enableVibration: true,
          enableLights: true,
          playSound: true,
        ),
      );

      // Default channel
      await android.createNotificationChannel(
        const AndroidNotificationChannel(
          _defaultChannelId,
          'Default Notifications',
          description: 'This channel is used for default notifications.',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;
    final apple = message.notification?.apple;

    if (notification == null) return;

    // For Android
    final androidDetails =
        android != null
            ? AndroidNotificationDetails(
              _highImportanceChannelId,
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@drawable/ic_notification',
              enableVibration: true,
              enableLights: true,
              playSound: true,
              styleInformation:
                  android.imageUrl != null
                      ? BigPictureStyleInformation(
                        FilePathAndroidBitmap(android.imageUrl!),
                        hideExpandedLargeIcon: true,
                      )
                      : null,
            )
            : null;

    // For iOS
    final iosDetails =
        apple != null
            ? const DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            )
            : null;

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationResponse(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      debugPrint('Notification payload: $payload');
      // Navigate or perform action based on payload
      // You can use a navigation service or context to navigate to specific screens
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped in background state');
    debugPrint('Message data: ${message.data}');
    // Handle notification tap when app is in background/terminated
    // Navigate or perform action based on message.data
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // Initialize Firebase if needed (for background messages)
  // await Firebase.initializeApp();

  // You can also show a notification here if needed
  await NotificationService()._showForegroundNotification(message);
}
