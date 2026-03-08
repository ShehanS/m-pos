// lib/models/user_entity.dart
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
    @Default(false) bool emailVerified,
    DateTime? createdAt,
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
      createdAt: data['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
          : null,
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
      'createdAt': createdAt?.millisecondsSinceEpoch,
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