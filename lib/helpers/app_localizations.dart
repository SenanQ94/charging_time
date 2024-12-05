import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'title': 'Charging Time',
      'from': 'From',
      'to': 'To',
      'go': 'GO',
      'swap': 'Swap',
      'show_gas_stations': 'Show Gas Stations',
      'please_enter_addresses': 'Please enter both start and end addresses',
      'login': 'Login',
      'email': 'Email',
      'password': 'Password',
      'sign_up': 'Sign Up',
      'name': 'Name',
      'location': 'Location',
      'sign_up_button': 'Sign Up',
      'sign_up_error_message': 'Error signing up',
      'login_error_message': 'Error logging in',
      'sign_up_success_message': 'Sign up successful',
      'starting_location': 'Starting Location',
      'ending_location': 'Ending Location',
      'invalid_addresses': 'Invalid addresses',
      'error_fetching_addresses': 'Error fetching addresses',
      'nearby_places': 'Nearby Places',
      'no_nearby_places_found': 'No nearby places found',
      "dont_have_account": "Don't have an account? ",
      "register_here": "Register here",
      "already_have_account": "Already have an account?",
      "login_here": "Login here",
      'notification': 'notification'
    },
    'de': {
      'title': 'Charging Time',
      'from': 'Von',
      'to': 'Nach',
      'go': 'LOS',
      'swap': 'Tauschen',
      'show_gas_stations': 'Tankstellen anzeigen',
      'please_enter_addresses':
          'Bitte geben Sie sowohl Start- als auch Zieladressen ein',
      'login': 'Anmelden',
      'email': 'E-Mail',
      'password': 'Passwort',
      'sign_up': 'Registrieren',
      'name': 'Name',
      'location': 'Ort',
      'sign_up_button': 'Registrieren',
      'sign_up_error_message': 'Fehler bei der Registrierung',
      'login_error_message': 'Fehler beim Anmelden',
      'sign_up_success_message': 'Registrierung erfolgreich',
      'starting_location': 'Startort',
      'ending_location': 'Zielort',
      'invalid_addresses': 'Ungültige Adressen',
      'error_fetching_addresses': 'Fehler beim Abrufen der Adressen',
      'nearby_places': 'Nahegelegene Orte',
      'no_nearby_places_found': 'Keine nahegelegenen Orte gefunden',
      "dont_have_account": "Haben Sie kein Konto?",
      "register_here": "Registrieren Sie sich hier",
      "already_have_account": "Haben Sie bereits ein Konto?",
      "login_here": "Hier anmelden",
      'notification': ' Benachrichtigung'
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]![key]!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
