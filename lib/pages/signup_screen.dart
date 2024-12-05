import 'package:chargingtime/pages/login_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app.dart';
import '../helpers/app_localizations.dart';
import '../providers/auth_service.dart';
import '../providers/language_provider.dart';
import '../providers/theme_provider.dart';
import 'home_page.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSignupEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _passwordController.addListener(_updateButtonState);
    _nameController.addListener(_updateButtonState);
    _locationController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isSignupEnabled = _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _locationController.text.isNotEmpty;
    });
  }

  Future<void> _signup() async {

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      final error =
          await authService.signupUser(email, password, name, location);

      if (!mounted) return;
      if (error == null) {
        navigatorKey.currentState?.pushNamed('/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }finally{
      setState(() {
        _isLoading = false;
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final size = MediaQuery.of(context).size;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context);

    String logoPath = themeProvider.isDarkMode
        ? 'assets/images/logo_dark.png'
        : 'assets/images/logo_light.png';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate('sign_up')),
        actions: [
          DropdownButton<String>(
            icon: Icon(Icons.language,
                color:
                    themeProvider.isDarkMode ? Colors.white : Colors.grey[800]),
            value: languageProvider.locale.languageCode,
            dropdownColor:
                themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
            items: <String>['en', 'de'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value.toUpperCase(),
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.grey[800])),
              );
            }).toList(),
            onChanged: (String? newLanguage) {
              if (newLanguage != null) {
                languageProvider.setLanguage(newLanguage);
              }
            },
          ),
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                logoPath,
                width: size.width,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: localizations.translate('name'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: localizations.translate('location'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: localizations.translate('email'),
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: localizations.translate('password'),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSignupEnabled ? _signup : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      :   Text(localizations.translate('sign_up')),
                ),
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: localizations.translate('already_have_account'),
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    TextSpan(
                      text: ' ${localizations.translate('login_here')}',
                      style: TextStyle(
                        fontSize: 16,
                        color: themeProvider.isDarkMode
                            ? Colors.blueAccent
                            : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          navigatorKey.currentState?.pushNamed('/login');
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
