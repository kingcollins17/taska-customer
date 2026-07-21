import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/debug_log.dart';

/// A singleton class that wraps the `flutter_local_notifications` plugin
/// and provides a clean API for initializing, requesting permissions, and showing notifications.
class DeviceTray {
  DeviceTray._privateConstructor();

  /// The singleton instance of [DeviceTray].
  static final DeviceTray instance = DeviceTray._privateConstructor();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Initializes the notification plugin for Android and iOS.
  Future<void> initialize() async {
    // '@mipmap/ic_launcher' must exist in android/app/src/main/res/mipmap-*
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // We disable requesting permissions at initialization to request them later via [requestPermission]
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    'DeviceTray initialized'.debugLog();
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    'Notification tapped with payload: ${response.payload}'.debugLog();
    // Handle notification tap logic here
  }

  /// Requests notification permissions for the current platform.
  ///
  /// Returns `true` if permissions were granted, or `null` if the request is not applicable.
  Future<bool?> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();

        final bool? granted = await androidImplementation
            ?.requestNotificationsPermission();
        'Android notification permission granted: $granted'.debugLog();
        return granted;
      } else if (Platform.isIOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation = _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >();

        final bool? granted = await iosImplementation?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        'iOS notification permission granted: $granted'.debugLog();
        return granted;
      }
    } catch (e) {
      'Error requesting notification permissions: $e'.debugLog();
    }
    return false;
  }

  /// Displays an immediate notification.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'default_channel_id',
          'Default Notifications',
          channelDescription: 'Standard notification channel',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    try {
      await _plugin.show(
        id: id,
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );
      'Showing notification [id: $id, title: $title]'.debugLog();
    } catch (e) {
      'Failed to show notification: $e'.debugLog();
    }
  }
}
