import 'package:flutter/material.dart';

/// Global controller for managing App Language State (Sinhala / English)
class LanguageController extends ValueNotifier<String> {
  LanguageController._() : super('si'); // Default language is Sinhala ('si')

  static final LanguageController instance = LanguageController._();

  bool get isSinhala => value == 'si';
  bool get isEnglish => value == 'en';

  void toggleLanguage() {
    value = value == 'si' ? 'en' : 'si';
  }

  void setLanguage(String langCode) {
    if (value != langCode) {
      value = langCode;
    }
  }

  /// Translation helper dictionary for common UI strings
  String getText(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      'app_title': {
        'si': 'Govi Mithuru',
        'en': 'Govi Mithuru',
      },
      'home': {
        'si': 'මුල් පිටුව',
        'en': 'Home',
      },
      'about': {
        'si': 'අප ගැන',
        'en': 'About Us',
      },
      'contact': {
        'si': 'සම්බන්ධ කරගන්න',
        'en': 'Contact Us',
      },
      'my_crops': {
        'si': 'මගේ වගාවන්',
        'en': 'My Crops',
      },
      'my_crops_desc': {
        'si': 'වගාවන්හි වර්තමාන තත්ත්වය සහ වාර්තා',
        'en': 'Current status and logs of your crops',
      },
      'articles': {
        'si': 'ගොවි උපදෙස් සහ ලිපි',
        'en': 'Articles & Guides',
      },
      'articles_desc': {
        'si': 'නවීන කෘෂිකාර්මික උපදෙස් සහ දැනුම',
        'en': 'Modern agricultural tips and knowledge',
      },
      'chat': {
        'si': 'ගොවි AI සාකච්ඡාව',
        'en': 'Farm AI Chat',
      },
      'chat_desc': {
        'si': 'වගා ගැටලු සඳහා කෘත්‍රිම බුද්ධි සහයක',
        'en': 'AI assistant for your farming queries',
      },
      'settings': {
        'si': 'සැකසීම්',
        'en': 'Settings',
      },
      'welcome': {
        'si': 'ආයුබෝවන්, ගොවි මහතා!',
        'en': 'Hello, Welcome Back!',
      },
      'rain_chance': {
        'si': 'වැසි ලැබීමේ හැකියාව',
        'en': 'Rain Prediction',
      },
      'partly_cloudy': {
        'si': 'මඳ වශයෙන් වලාකුළු සහිතයි',
        'en': 'Partly Cloudy',
      },
      'notifications': {
        'si': 'දැනුම්දීම්',
        'en': 'Notifications',
      },
      'notifications_desc': {
        'si': 'කාලගුණ සහ වගා අවවාද',
        'en': 'Weather and farming alerts',
      },
    };

    return localizedValues[key]?[value] ?? key;
  }
}
