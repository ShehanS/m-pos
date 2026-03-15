// profile_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_state.freezed.dart';

enum ProfileStatus { initial, loading, loaded, error }

@freezed
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(ProfileStatus.initial) ProfileStatus status,
    @Default('') String errorMessage,
    Map<String, dynamic>? profile,
  }) = _ProfileState;
}