// lib/bloc/auth/auth_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

class _AuthFirebaseChangedEvent extends AuthEvent {
  final bool isAuthenticated;
  const _AuthFirebaseChangedEvent({required this.isAuthenticated});
  @override
  List<Object?> get props => [isAuthenticated];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService authService;
  StreamSubscription? _authSubscription;

  AuthBloc({required this.authService}) : super(const AuthState.initial()) {
    on<AuthCheckStatusEvent>(_onCheckStatus);
    on<_AuthFirebaseChangedEvent>(_onFirebaseChanged);
    on<AuthLoginWithEmailEvent>(_onLoginWithEmail);
    on<AuthRegisterWithEmailEvent>(_onRegisterWithEmail);
    on<AuthLoginWithGoogleEvent>(_onLoginWithGoogle);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthForgotPasswordEvent>(_onForgotPassword);
    on<AuthUpdateProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    _authSubscription?.cancel();
    _authSubscription = authService.authStateChanges.listen((firebaseUser) {
      add(_AuthFirebaseChangedEvent(isAuthenticated: firebaseUser != null));
    });

    final user = authService.currentUser;
    if (user != null) {
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
    }
  }

  Future<void> _onFirebaseChanged(
    _AuthFirebaseChangedEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (!event.isAuthenticated) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
    } else {
      final user = authService.currentUser;
      if (user != null) {
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      }
    }
  }

  Future<void> _onLoginWithEmail(
    AuthLoginWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await authService.signInWithEmail(
      email: event.email,
      password: event.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> _onRegisterWithEmail(
    AuthRegisterWithEmailEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await authService.registerWithEmail(
      email: event.email,
      password: event.password,
      username: event.username,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.registrationSuccess,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> _onLoginWithGoogle(
    AuthLoginWithGoogleEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await authService.signInWithGoogle();

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      )),
    );
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    await authService.signOut();
    emit(state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUser: true,
      clearError: true,
    ));
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearError: true));

    final result = await authService.sendPasswordResetEmail(email: event.email);

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.passwordResetSent,
        resetEmail: event.email,
        clearError: true,
      )),
    );
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfileEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (!state.isAuthenticated) return;

    emit(state.copyWith(status: AuthStatus.loading));

    final result = await authService.updateProfile(
      displayName: event.displayName,
      photoUrl: event.photoUrl,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        clearError: true,
      )),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
