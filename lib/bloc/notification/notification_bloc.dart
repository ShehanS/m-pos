// lib/bloc/notification/notification_bloc.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/notification_service.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class NotificationInitializeEvent extends NotificationEvent {}

class NotificationPermissionRequestEvent extends NotificationEvent {}

class NotificationReceivedEvent extends NotificationEvent {
  final String title;
  final String body;
  final Map<String, dynamic>? data;

  const NotificationReceivedEvent({
    required this.title,
    required this.body,
    this.data,
  });

  @override
  List<Object?> get props => [title, body, data];
}

class NotificationClearEvent extends NotificationEvent {}

// ─── Permission Status ────────────────────────────────────────────────────────

enum NotificationPermissionStatus { unknown, granted, denied }

// ─── State ────────────────────────────────────────────────────────────────────

class NotificationState extends Equatable {
  final NotificationPermissionStatus permissionStatus;
  final bool isLoading;
  final String? fcmToken;
  final String? lastTitle;
  final String? lastBody;
  final Map<String, dynamic>? lastData;
  final String? errorMessage;
  final bool hasNewNotification;

  const NotificationState({
    this.permissionStatus = NotificationPermissionStatus.unknown,
    this.isLoading = false,
    this.fcmToken,
    this.lastTitle,
    this.lastBody,
    this.lastData,
    this.errorMessage,
    this.hasNewNotification = false,
  });

  NotificationState copyWith({
    NotificationPermissionStatus? permissionStatus,
    bool? isLoading,
    String? fcmToken,
    String? lastTitle,
    String? lastBody,
    Map<String, dynamic>? lastData,
    String? errorMessage,
    bool? hasNewNotification,
    bool clearNotification = false,
    bool clearError = false,
  }) {
    return NotificationState(
      permissionStatus: permissionStatus ?? this.permissionStatus,
      isLoading: isLoading ?? this.isLoading,
      fcmToken: fcmToken ?? this.fcmToken,
      lastTitle: clearNotification ? null : (lastTitle ?? this.lastTitle),
      lastBody: clearNotification ? null : (lastBody ?? this.lastBody),
      lastData: clearNotification ? null : (lastData ?? this.lastData),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasNewNotification: clearNotification
          ? false
          : (hasNewNotification ?? this.hasNewNotification),
    );
  }

  bool get isGranted =>
      permissionStatus == NotificationPermissionStatus.granted;
  bool get isDenied =>
      permissionStatus == NotificationPermissionStatus.denied;

  @override
  List<Object?> get props => [
        permissionStatus,
        isLoading,
        fcmToken,
        lastTitle,
        lastBody,
        lastData,
        errorMessage,
        hasNewNotification,
      ];

  @override
  String toString() =>
      'NotificationState(permission: $permissionStatus, token: ${fcmToken?.substring(0, 10)}..., hasNew: $hasNewNotification)';
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

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
