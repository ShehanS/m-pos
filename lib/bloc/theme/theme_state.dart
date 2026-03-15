// lib/bloc/theme/theme_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
