// lib/bloc/auth/auth_event.dart
import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckStatusEvent extends AuthEvent {}

class AuthLoginWithEmailEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginWithEmailEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterWithEmailEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  const AuthRegisterWithEmailEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object?> get props => [email, password, username];
}

class AuthLoginWithGoogleEvent extends AuthEvent {}

class AuthLogoutEvent extends AuthEvent {}

class AuthForgotPasswordEvent extends AuthEvent {
  final String email;

  const AuthForgotPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthUpdateProfileEvent extends AuthEvent {
  final String? displayName;
  final String? photoUrl;

  const AuthUpdateProfileEvent({this.displayName, this.photoUrl});

  @override
  List<Object?> get props => [displayName, photoUrl];
}
