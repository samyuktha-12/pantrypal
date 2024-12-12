import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'google_sign_in.dart';  // The file where Google Sign-In logic is handled
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Initialize Firebase

  // Request notification permissions (important for iOS)
  await FirebaseMessaging.instance.requestPermission();

  // Listen for background messages
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Subscribe to a topic for push notifications
  FirebaseMessaging.instance.subscribeToTopic('hydration_reminders');

  // Listen for foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Received a message while in foreground: ${message.notification?.title}');
    if (message.notification != null) {
      print('Message contains a notification: ${message.notification?.body}');
      // Automatically show notification here in the foreground if needed
      _showSystemNotification(message);  // Show a system-like notification
    }
  });

  // Run the app
  runApp(const MyApp());
}

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.title}");
  // You can handle background message logic here if needed
}

void _showSystemNotification(RemoteMessage message) {
  // This method will show system-like notifications in the foreground (no local notifications)
  // You just need to let Firebase handle the notification in the system UI.
  // No need for local notifications since Firebase manages it in the system UI.
  if (message.notification != null) {
    // Firebase handles this automatically when your app is in the background or terminated
    print('Received Notification: ${message.notification?.title}, ${message.notification?.body}');
    // The system will show this notification in the notification tray.
    // Just make sure Firebase is configured correctly for push notifications.
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PantryPal',
      theme: ThemeData.dark(),
      home: const GoogleSignInPage(),  // Starts with GoogleSignInPage
    );
  }
}


