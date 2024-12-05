import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatelessWidget {
  const NotificationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the notification message passed via arguments
    final RemoteMessage message = ModalRoute.of(context)?.settings.arguments as RemoteMessage;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AlertDialog(
        title: const Text('Notification'),
        content: Text(message.notification?.body ?? 'No message content'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

