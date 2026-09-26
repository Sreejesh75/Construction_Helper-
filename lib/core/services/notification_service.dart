import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();

  factory NotificationService() => instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize local notifications
  Future<void> init() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint("Notification clicked: ${details.payload}");
        },
      );
      _isInitialized = true;
      await requestPermission();
      debugPrint("NotificationService: Initialized successfully");
    } catch (e) {
      debugPrint("NotificationService Initialization Error: $e");
    }
  }

  /// Request runtime notification permission on Android 13+ & iOS
  Future<bool> requestPermission() async {
    try {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation
            .requestNotificationsPermission();
        debugPrint("Android Notification Permission Granted: $granted");
        return granted ?? false;
      }
    } catch (e) {
      debugPrint("Error requesting notification permission: $e");
    }
    return true;
  }

  /// Trigger top banner notification for OTP
  Future<void> showOtpNotification({
    required String otp,
    required String phone,
  }) async {
    try {
      await init();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
            'otp_channel',
            'OTP Notifications',
            channelDescription: 'Notifications for login OTP codes',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      );

      await _notificationsPlugin.show(
        888, // Notification ID
        '🔑 Login OTP: $otp',
        'Your Construction App login code is $otp. Valid for 2 minutes.',
        notificationDetails,
        payload: otp,
      );
      debugPrint("NotificationService: Displayed OTP notification ($otp)");
    } catch (e) {
      debugPrint("NotificationService Error showing notification: $e");
    }
  }
}
