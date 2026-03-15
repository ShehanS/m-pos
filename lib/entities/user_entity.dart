import 'package:flutter_bloc_app/entities/form_field_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const UserEntity._();

  const factory UserEntity({
    required String uid,
    required String email,
    String? username,
    String? displayName,
    String? photoUrl,
    @Default(false) bool isUpdateProfile,
    @Default(false) bool emailVerified,
    DateTime? createdAt,
    List<FormFieldEntity>? profile,
    List<Map<String, List<FormFieldEntity>>>? business,
    String? fcmToken,
  }) = _UserEntity;

  factory UserEntity.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserEntity(
      uid: uid,
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      emailVerified: data['emailVerified'] as bool? ?? false,
      createdAt: data['createdAt'] as DateTime?,
      profile: (data['profile'] as List?)
          ?.map((e) => FormFieldEntity.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      business: (data['business'] as List?)
          ?.map((e) => (e as Map<String, dynamic>).map(
            (key, value) => MapEntry(
          key,
          (value as List)
              .map((f) => FormFieldEntity.fromMap(
            Map<String, dynamic>.from(f),
          ))
              .toList(),
        ),
      ))
          .toList(),
      fcmToken: data['fcmToken'] as String?,
    );
  }

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'createdAt': createdAt,
      'profile': profile?.map((e) => e.toMap()).toList(),
      'business': business
          ?.map((section) => section.map(
            (key, value) =>
            MapEntry(key, value.map((e) => e.toMap()).toList()),
      ))
          .toList(),
      'fcmToken': fcmToken,
    };
  }

  String get initials {
    final name = displayName ?? username ?? email;
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}