// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDYe8RpZCptqzeMsUhy9Jnlyr9FYEmclak',
    appId: '1:101435210373:web:06835971216f96cd9f07ec',
    messagingSenderId: '101435210373',
    projectId: 'chargingtime-3767b',
    authDomain: 'chargingtime-3767b.firebaseapp.com',
    databaseURL: 'https://chargingtime-3767b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chargingtime-3767b.appspot.com',
    measurementId: 'G-ESH322ZDG2',
  );

  static const FirebaseOptions android = FirebaseOptions(
      apiKey: "AIzaSyDc6CSFgJZzgEbQrqhQ5cuwsSoUITlKYVI",
      authDomain: "chargingtime-3767b.firebaseapp.com",
      databaseURL: "https://chargingtime-3767b-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "chargingtime-3767b",
      storageBucket: "chargingtime-3767b.firebasestorage.app",
      messagingSenderId: "101435210373",
      appId: "1:101435210373:web:a6352361b09c27999f07ec",
      measurementId: "G-19F83R47H1"
  );

  static const FirebaseOptions ios = FirebaseOptions(
      apiKey: "AIzaSyDc6CSFgJZzgEbQrqhQ5cuwsSoUITlKYVI",
      authDomain: "chargingtime-3767b.firebaseapp.com",
      databaseURL: "https://chargingtime-3767b-default-rtdb.europe-west1.firebasedatabase.app",
      projectId: "chargingtime-3767b",
      storageBucket: "chargingtime-3767b.firebasestorage.app",
      messagingSenderId: "101435210373",
      appId: "1:101435210373:web:a6352361b09c27999f07ec",
      measurementId: "G-19F83R47H1"
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAWMApzOaSq4X-lMkVLMSuTC091lcpDq0Q',
    appId: '1:101435210373:ios:df8484c6ab654b089f07ec',
    messagingSenderId: '101435210373',
    projectId: 'chargingtime-3767b',
    databaseURL: 'https://chargingtime-3767b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chargingtime-3767b.appspot.com',
    iosBundleId: 'com.example.chargingtime',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDYe8RpZCptqzeMsUhy9Jnlyr9FYEmclak',
    appId: '1:101435210373:web:a6352361b09c27999f07ec',
    messagingSenderId: '101435210373',
    projectId: 'chargingtime-3767b',
    authDomain: 'chargingtime-3767b.firebaseapp.com',
    databaseURL: 'https://chargingtime-3767b-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'chargingtime-3767b.appspot.com',
    measurementId: 'G-19F83R47H1',
  );
}
