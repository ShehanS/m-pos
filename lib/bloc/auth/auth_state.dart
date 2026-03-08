// lib/bloc/auth/auth_state.dart
import 'package:equatable/equatable.dart';
import '../../models/user_model.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  registrationSuccess,
  passwordResetSent,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? resetEmail;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.resetEmail,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
  bool get isRegistrationSuccess => status == AuthStatus.registrationSuccess;
  bool get isPasswordResetSent => status == AuthStatus.passwordResetSent;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? resetEmail,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      resetEmail: resetEmail ?? this.resetEmail,
    );
  }

  // Named constructors for convenience
  const AuthState.initial() : this(status: AuthStatus.initial);

  const AuthState.loading() : this(status: AuthStatus.loading);

  AuthState.authenticated(UserModel user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
      : this(status: AuthStatus.unauthenticated);

  AuthState.error(String message)
      : this(status: AuthStatus.error, errorMessage: message);

  AuthState.registrationSuccess(UserModel user)
      : this(status: AuthStatus.registrationSuccess, user: user);

  AuthState.passwordResetSent(String email)
      : this(status: AuthStatus.passwordResetSent, resetEmail: email);

  @override
  List<Object?> get props => [status, user, errorMessage, resetEmail];

  @override
  String toString() =>
      'AuthState(status: $status, user: ${user?.email}, error: $errorMessage)';
}
