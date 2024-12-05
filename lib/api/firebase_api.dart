import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../app.dart'; // Assuming this contains the navigatorKey

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  // Request notification permissions and initialize push notification handling
  Future<void> initNotification() async {
    // Request permissions for notifications
    await _firebaseMessaging.requestPermission();

    // Get the Firebase Cloud Messaging (FCM) token
    final fCMToken = await _firebaseMessaging.getToken();
    print('FCM Token: $fCMToken');

    // Register handlers for push notifications
    await initPushNotification();
  }

  // Handles notifications when app is in the background or terminated
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushReplacementNamed('/home', arguments: message);
  }

  // Initialize push notification handlers for background/terminated states
  Future<void> initPushNotification() async {
    // Handle notifications if the app was terminated
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    // Handle notifications when app is opened by tapping on a notification
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      handleForegroundMessage(message);
    });
  }

  // Method to handle foreground notification
  void handleForegroundMessage(RemoteMessage message) {
    // Show an in-app dialog for foreground messages
    navigatorKey.currentState?.pushNamed('/notificationDialog', arguments: message);
  }
}