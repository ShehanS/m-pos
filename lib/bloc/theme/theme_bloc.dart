// lib/bloc/theme/theme_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
  @override
  List<Object?> get props => [];
}

class ThemeLoadEvent extends ThemeEvent {}

class ThemeToggleEvent extends ThemeEvent {}

class ThemeSetEvent extends ThemeEvent {
  final ThemeMode mode;
  const ThemeSetEvent(this.mode);
  @override
  List<Object?> get props => [mode];
}

// ─── State ────────────────────────────────────────────────────────────────────

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeState({
    this.themeMode = ThemeMode.light,
    this.isLoading = false,
  });

  ThemeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  bool get isDark => themeMode == ThemeMode.dark;
  bool get isLight => themeMode == ThemeMode.light;

  @override
  List<Object?> get props => [themeMode, isLoading];

  @override
  String toString() => 'ThemeState(mode: $themeMode, loading: $isLoading)';
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeToggleEvent>(_onToggle);
    on<ThemeSetEvent>(_onSet);
  }

  Future<void> _onLoad(ThemeLoadEvent event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(isLoading: true));

    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;

    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isLoading: false,
    ));
  }

  Future<void> _onToggle(ThemeToggleEvent event, Emitter<ThemeState> emit) async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;

    emit(state.copyWith(isLoading: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);

    emit(state.copyWith(themeMode: newMode, isLoading: false));
  }

  Future<void> _onSet(ThemeSetEvent event, Emitter<ThemeState> emit) async {
    emit(state.copyWith(isLoading: true));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, event.mode == ThemeMode.dark);

    emit(state.copyWith(themeMode: event.mode, isLoading: false));
  }
}
