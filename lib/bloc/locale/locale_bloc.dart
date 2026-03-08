// lib/bloc/locale/locale_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class LocaleEvent extends Equatable {
  const LocaleEvent();
  @override
  List<Object?> get props => [];
}

class LocaleLoadEvent extends LocaleEvent {}

class LocaleChangeEvent extends LocaleEvent {
  final Locale locale;
  const LocaleChangeEvent(this.locale);
  @override
  List<Object?> get props => [locale];
}

// ─── State ────────────────────────────────────────────────────────────────────

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
  String toString() => 'LocaleState(locale: ${locale.languageCode}, loading: $isLoading)';
}

// ─── Supported Locales ────────────────────────────────────────────────────────

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

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'app_locale';

  LocaleBloc() : super(const LocaleState()) {
    on<LocaleLoadEvent>(_onLoad);
    on<LocaleChangeEvent>(_onChange);
  }

  Future<void> _onLoad(LocaleLoadEvent event, Emitter<LocaleState> emit) async {
    emit(state.copyWith(isLoading: true));

    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);

    if (code != null) {
      final locale = AppLocales.supported.firstWhere(
        (l) => l.languageCode == code,
        orElse: () => AppLocales.english,
      );
      emit(state.copyWith(locale: locale, isLoading: false));
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onChange(
    LocaleChangeEvent event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, event.locale.languageCode);

    emit(state.copyWith(locale: event.locale, isLoading: false));
  }
}
