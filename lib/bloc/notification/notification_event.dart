// lib/bloc/notification/notification_event.dart
import 'package:equatable/equatable.dart';

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
