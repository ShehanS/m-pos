// lib/bloc/theme/theme_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_app/local_storage/local_storage_service.dart';

import 'theme_event.dart';
import 'theme_state.dart';

export 'theme_event.dart';
export 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  static const String _themeKey = 'app_theme';
  static const String _globalSettingsBox = 'global_settings';
  final _localStorageService = LocalStorageService.instance;

  ThemeBloc() : super(const ThemeState()) {
    on<ThemeLoadEvent>(_onLoad);
    on<ThemeToggleEvent>(_onToggle);
    on<ThemeSetEvent>(_onSet);
  }

  Future<void> _onLoad(
    ThemeLoadEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final isDark =
        _localStorageService.getData(_globalSettingsBox, _themeKey) ?? false;

    emit(state.copyWith(
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      isLoading: false,
    ));
  }

  Future<void> _onToggle(
    ThemeToggleEvent event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode = state.isDark ? ThemeMode.light : ThemeMode.dark;

    emit(state.copyWith(isLoading: true));

    _localStorageService.saveData(
        _globalSettingsBox, _themeKey, newMode == ThemeMode.dark);

    emit(state.copyWith(themeMode: newMode, isLoading: false));
  }

  Future<void> _onSet(
    ThemeSetEvent event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    _localStorageService.saveData(
        _globalSettingsBox, _themeKey, event.mode == ThemeMode.dark);

    emit(state.copyWith(themeMode: event.mode, isLoading: false));
  }
}
