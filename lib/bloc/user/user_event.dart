import 'package:freezed_annotation/freezed_annotation.dart';

import '../../entities/user_entity.dart';
part 'user_event.freezed.dart';

@freezed
class UserEvent with _$UserEvent{
  const factory UserEvent.updateUser({required String uid, required UserEntity user}) = UpdateUser;
  const factory UserEvent.getUser({required String uid}) = GetUser;
}
