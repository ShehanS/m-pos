// profile_bloc.dart
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_app/bloc/profile/profile_event.dart';
import 'package:flutter_bloc_app/bloc/profile/profile_state.dart';
import 'package:flutter_bloc_app/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileState()) {
    on<ModifyProfile>(_updateProfile);
    on<GetProfile>(_getProfile);
  }

  Future<void> _updateProfile(
      ModifyProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));

    final result =
        await _profileRepository.updateProfile(event.uid, event.profile);

    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      )),
    );
  }

  Future<void> _getProfile(GetProfile event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _profileRepository.getProfile(event.uid);
    result.fold(
      (error) => emit(state.copyWith(
        status: ProfileStatus.error,
        errorMessage: error,
      )),
      (profile) => emit(state.copyWith(
        status: ProfileStatus.loaded,
        profile: profile,
      )),
    );
  }
}
