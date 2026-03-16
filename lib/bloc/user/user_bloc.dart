import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_event.dart';
import 'package:flutter_bloc_app/bloc/user/user_state.dart';
import 'package:flutter_bloc_app/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository;

  UserBloc(this._userRepository) : super(const UserState()) {
    on<UpdateUser>(_updateUser);
    on<GetUser>(_getUser);
  }

  Future<void> _updateUser(UpdateUser event, Emitter<UserState> emit) async {
    final result = await _userRepository.updateUser(event.uid, event.user);
    result.fold((error) {
      print('>>> error: $error');
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: error,
      ));
    }, (user) {
      emit(state.copyWith(
        status: UserStatus.loaded,
        user: user,
      ));
    });
  }

  Future<void> _getUser(GetUser event, Emitter<UserState> emit) async {
    final result = await _userRepository.getUser(event.uid);
    result.fold((error) {
      print('>>> error: $error');
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: error,
      ));
    }, (user) {
      emit(state.copyWith(
        status: UserStatus.loaded,
        user: user,
      ));
    });
  }
}
