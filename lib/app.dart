import 'package:chargingtime/pages/home_page.dart';
import 'package:chargingtime/pages/login_screen.dart';
import 'package:chargingtime/pages/signup_screen.dart';
import 'package:chargingtime/providers/language_provider.dart';
import 'package:chargingtime/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'helpers/app_localizations.dart';
import 'pages/notification_dialog.dart';
import 'providers/auth_service.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageProvider>(
      builder: (context, themeProvider, languageProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Charging Time',
          theme:
          themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(),
          locale: languageProvider.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          navigatorKey: navigatorKey,
          initialRoute: '/',
          routes: {
            '/':  (context) => const AuthWrapper(),
            '/home': (context) => const HomePage(),
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/notificationDialog': (context) => const NotificationDialog(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        } else if (snapshot.hasData) {
          final user = snapshot.data;
          if (user != null) {
            // Navigate to HomePage using named routes
            Future.microtask(() {
              navigatorKey.currentState?.pushReplacementNamed('/home');
            });
            return Container(); // Return an empty container since the navigation will handle the screen
          } else {
            // Navigate to LoginScreen using named routes
            Future.microtask(() {
              navigatorKey.currentState?.pushReplacementNamed('/login');
            });
            return Container();
          }
        } else {
          // Navigate to LoginScreen using named routes
          Future.microtask(() {
            navigatorKey.currentState?.pushReplacementNamed('/login');
          });
          return Container();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Image.asset(
              'assets/images/loading.gif',
              width: 200,
              height: 200,
            ),
          ),
        ),
      ),
    );
  }
}
