import 'package:chargingtime/firebase_options.dart';
import 'package:chargingtime/providers/auth_service.dart';
import 'package:chargingtime/providers/language_provider.dart';
import 'package:chargingtime/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'api/firebase_api.dart';
import 'app.dart';

import 'helpers/config.dart';

import 'providers/location_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: Config.firebaseOptions);
  await FirebaseApi().initNotification();
  final LanguageProvider languageProvider = LanguageProvider();
  await languageProvider.setDefaultLanguage();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider(create: (_) => MapProvider(Config.routeKey)),
      ],
      child: const App(),
    ),
  );
}
