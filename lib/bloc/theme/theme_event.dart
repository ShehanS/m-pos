// lib/bloc/theme/theme_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
