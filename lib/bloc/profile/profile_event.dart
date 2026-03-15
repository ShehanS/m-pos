import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_event.freezed.dart';

@freezed
class ProfileEvent with _$ProfileEvent {
  const factory ProfileEvent.updateProfile({
    required Map<String, dynamic> profile,
    required String uid,
  }) = ModifyProfile;

  const factory ProfileEvent.getProfile({
    required String uid,
  }) = GetProfile;
}
