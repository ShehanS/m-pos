// lib/bloc/locale/locale_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
