import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

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
    debugPrint('🚀 Initializing NotificationService');

    try {
      // Request permission
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      debugPrint('📱 Permission status: ${settings.authorizationStatus}');

      // Set foreground notification presentation options
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('✅ Foreground notification options set');

      // Get initial token
      final token = await getToken();
      if (token != null) {
        debugPrint('✅ Initial FCM token obtained');
      }

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
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
        onDidReceiveNotificationResponse: _handleNotificationResponse,
      );

      // Create notification channels
      await _createNotificationChannels();

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');
        debugPrint(
          'Message notification title: ${message.notification?.title}',
        );
        debugPrint('Message notification body: ${message.notification?.body}');

        if (message.notification != null) {
          _showForegroundNotification(message);
        }
      });

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      debugPrint('✅ NotificationService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing NotificationService: $e');
    }
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

    if (notification == null) {
      debugPrint('❌ No notification in message');
      return;
    }

    debugPrint('📬 Showing notification:');
    debugPrint('- Title: ${notification.title}');
    debugPrint('- Body: ${notification.body}');
    debugPrint('- Data: ${message.data}');

    try {
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
                channelShowBadge: true,
                styleInformation:
                    android.imageUrl != null
                        ? BigPictureStyleInformation(
                          FilePathAndroidBitmap(android.imageUrl!),
                          hideExpandedLargeIcon: true,
                        )
                        : null,
              )
              : null;

      debugPrint('📱 Android notification details configured');

      // For iOS
      final iosDetails =
          apple != null
              ? const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
                interruptionLevel: InterruptionLevel.active,
              )
              : null;

      debugPrint('📱 iOS notification details configured');

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

      debugPrint('✅ Notification shown successfully');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
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
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        debugPrint('✅ FCM Token obtained successfully');
        debugPrint(
          'Token: ${token.substring(0, 6)}...${token.substring(token.length - 6)}',
        );
      } else {
        debugPrint('❌ Failed to get FCM token');
      }
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  Future<bool> checkPermissions() async {
    final settings = await _messaging.getNotificationSettings();
    debugPrint('Current permission status: ${settings.authorizationStatus}');
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  // Add this method to NotificationService
  Future<void> testNotification() async {
    await _localNotifications.show(
      0,
      'Test Notification',
      'This is a test notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _highImportanceChannelId,
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

// Handle background messages
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');

  // Initialize Firebase for background messages
  await Firebase.initializeApp();

  debugPrint('Firebase initialized in background');
  debugPrint('Message data: ${message.data}');
  debugPrint('Message notification: ${message.notification?.title}');

  // Show the notification
  await NotificationService()._showForegroundNotification(message);
}
