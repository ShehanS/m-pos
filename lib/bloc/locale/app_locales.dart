// lib/bloc/locale/app_locales.dart
import 'package:flutter/material.dart';

class AppLocales {
  static const Locale english = Locale('en', 'US');
  static const Locale sinhala = Locale('si', 'LK');
  static const Locale tamil = Locale('ta', 'LK');

  static const List<Locale> supported = [english, sinhala, tamil];

  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return 'English';
    }
  }

  static String getFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'si':
      case 'ta':
        return '🇱🇰';
      default:
        return '🇬🇧';
    }
  }
}
