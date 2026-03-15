// lib/bloc/locale/locale_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LocaleState extends Equatable {
  final Locale locale;
  final bool isLoading;

  const LocaleState({
    this.locale = const Locale('en', 'US'),
    this.isLoading = false,
  });

  LocaleState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  String get languageCode => locale.languageCode;
  bool get isSinhala => locale.languageCode == 'si';
  bool get isTamil => locale.languageCode == 'ta';
  bool get isEnglish => locale.languageCode == 'en';

  @override
  List<Object?> get props => [locale, isLoading];

  @override
  String toString() =>
      'LocaleState(locale: ${locale.languageCode}, loading: $isLoading)';
}
