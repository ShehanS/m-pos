// lib/bloc/locale/locale_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/local_storage/local_storage_service.dart';

import 'app_locales.dart';
import 'locale_event.dart';
import 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  static const String _localeKey = 'app_locale';
  static const String _globalSettingsBox = 'global_settings';
  final _localStorageService = LocalStorageService.instance;

  LocaleBloc() : super(const LocaleState()) {
    on<LocaleLoadEvent>(_onLoad);
    on<LocaleChangeEvent>(_onChange);
  }

  Future<void> _onLoad(
    LocaleLoadEvent event,
    Emitter<LocaleState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final code = _localStorageService.getData(_globalSettingsBox, _localeKey);

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

    _localStorageService.saveData(
        _globalSettingsBox, _localeKey, event.locale.languageCode);

    emit(state.copyWith(locale: event.locale, isLoading: false));
  }
}
