// lib/bloc/notification/notification_state.dart
import 'package:equatable/equatable.dart';

enum NotificationPermissionStatus { unknown, granted, denied }

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
