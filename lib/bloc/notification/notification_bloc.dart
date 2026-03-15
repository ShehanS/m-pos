// lib/bloc/notification/notification_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/notification_service.dart';
import 'notification_event.dart';
import 'notification_state.dart';

export 'notification_event.dart';
export 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationService notificationService;

  NotificationBloc({required this.notificationService})
      : super(const NotificationState()) {
    on<NotificationInitializeEvent>(_onInitialize);
    on<NotificationPermissionRequestEvent>(_onRequestPermission);
    on<NotificationReceivedEvent>(_onReceived);
    on<NotificationClearEvent>(_onClear);
  }

  Future<void> _onInitialize(
    NotificationInitializeEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final granted = await notificationService.requestPermission();
      final token = granted ? await notificationService.getToken() : null;

      emit(state.copyWith(
        permissionStatus: granted
            ? NotificationPermissionStatus.granted
            : NotificationPermissionStatus.denied,
        fcmToken: token,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        clearError: false,
      ));
    }
  }

  Future<void> _onRequestPermission(
    NotificationPermissionRequestEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final granted = await notificationService.requestPermission();
    final token = granted ? await notificationService.getToken() : null;

    emit(state.copyWith(
      permissionStatus: granted
          ? NotificationPermissionStatus.granted
          : NotificationPermissionStatus.denied,
      fcmToken: token,
      isLoading: false,
    ));
  }

  Future<void> _onReceived(
    NotificationReceivedEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(
      lastTitle: event.title,
      lastBody: event.body,
      lastData: event.data,
      hasNewNotification: true,
    ));
  }

  Future<void> _onClear(
    NotificationClearEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(state.copyWith(clearNotification: true));
  }
}
