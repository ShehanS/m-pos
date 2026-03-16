import 'package:freezed_annotation/freezed_annotation.dart';

import '../../entities/user_entity.dart';

part 'user_state.freezed.dart';

enum UserStatus { initial, loading, loaded, error }

@freezed
class UserState with _$UserState {
  const factory UserState({
    @Default(UserStatus.initial) UserStatus status,
    @Default('') String errorMessage,
    UserEntity? user
  })= _UserState;
}
