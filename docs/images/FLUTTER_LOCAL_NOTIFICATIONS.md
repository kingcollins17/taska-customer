# Flutter Local Notifications

A cross-platform plugin for displaying and scheduling local notifications for Flutter applications.

## 📱 Supported Platforms
- **Android**: API 16+ (Uses `NotificationCompat` APIs)
- **iOS**: iOS 10.0+ (Uses `UserNotification` APIs)
- **macOS**: 10.14+
- **Linux**: Uses Desktop Notifications Specification
- **Windows**: Uses C++/WinRT implementation of Toast Notifications
- **Web**: Uses Notifications API

---

## 🔧 Android Setup

### 1. Gradle Setup
Ensure your `compileSdk` is set to **35** or higher in your `android/app/build.gradle`:
```gradle
android {
    compileSdk 35
    // ...
}
```

For scheduled notifications (using Android Gradle plugin 8.11.1+), enable desugaring to support backwards compatibility on older versions of Android:
```gradle
android {
    compileOptions {
        coreLibraryDesugaringEnabled true
    }
}
dependencies {
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.3' 
}
```

### 2. AndroidManifest.xml Setup
For apps scheduling notifications, add the following to your `AndroidManifest.xml` inside `<manifest>`:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/> <!-- Or USE_EXACT_ALARM for Android 14+ -->
```

Inside the `<application>` block, add the following receivers so scheduled notifications and actions function correctly:

```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />
```

### 3. Requesting Permissions (Android 13+)
From Android 13 (API 33), apps must display a prompt for notification permissions:
```dart
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
```

---

## 🔧 iOS Setup

### 1. General Setup
Add the following to `application:didFinishLaunchingWithOptions:` in `AppDelegate.swift`:

```swift
import flutter_local_notifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Add this line
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## ❓ Usage Guide

### 1. Initialization
Create an instance and initialize settings for the target platforms (e.g., in `main.dart` or an initial startup routine).

```dart
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  // 'app_icon' must exist as a drawable resource in android/app/src/main/res/drawable
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  
  final DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );
  
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );
  
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
      // Handle when a notification is tapped
      if (notificationResponse.payload != null) {
        debugPrint('Notification payload: ${notificationResponse.payload}');
      }
    },
  );
}
```

### 2. Displaying a Notification
```dart
Future<void> showNotification() async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'your_channel_id', 
    'your_channel_name',
    channelDescription: 'your_channel_description',
    importance: Importance.max,
    priority: Priority.high,
    ticker: 'ticker',
  );
  
  const NotificationDetails notificationDetails = NotificationDetails(
    android: androidNotificationDetails
  );
  
  await flutterLocalNotificationsPlugin.show(
    0, // ID
    'Notification Title', 
    'Notification Body', 
    notificationDetails,
    payload: 'item x', // Optional data payload
  );
}
```

### 3. Scheduling a Notification
Uses `tz.TZDateTime` from the `timezone` package.

```dart
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification() async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Scheduled Title',
    'Scheduled Body',
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
    const NotificationDetails(
      android: AndroidNotificationDetails('your_channel_id', 'your_channel_name'),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

### 4. Periodic Notifications
```dart
Future<void> periodicallyShowNotification() async {
  const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
    'repeating_channel_id',
    'repeating_channel_name',
  );
  
  await flutterLocalNotificationsPlugin.periodicallyShow(
    0,
    'Repeating Title',
    'Repeating Body',
    RepeatInterval.everyMinute,
    const NotificationDetails(android: androidNotificationDetails),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}
```

### 5. Cancelling Notifications
```dart
// Cancel specific notification
await flutterLocalNotificationsPlugin.cancel(0);

// Cancel all notifications
await flutterLocalNotificationsPlugin.cancelAll();
```
