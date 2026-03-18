import 'package:freezed_annotation/freezed_annotation.dart';
import '../dtos/business.dart';

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
    String? firstName,
    String? lastName,
    String? contact,
    String? address,
    @Default(false) bool isUpdateProfile,
    @Default(false) bool emailVerified,
    List<Business>? business,
    DateTime? createdAt,
    String? fcmToken,
  }) = _UserEntity;

  factory UserEntity.fromFirestore(Map<String, dynamic> data) {
    return UserEntity(
      uid: data['uid'] as String? ?? '',
      email: data['email'] as String? ?? '',
      username: data['username'] as String?,
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      firstName: data['firstName'] as String?,
      lastName: data['lastName'] as String?,
      contact: data['contact'] as String?,
      address: data['address'] as String?,
      isUpdateProfile: data['isUpdateProfile'] as bool? ?? false,
      emailVerified: data['emailVerified'] as bool? ?? false,
      business: (data['business'] as List?)
          ?.map((e) => Business.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
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
      'isUpdateProfile': isUpdateProfile,
      'emailVerified': emailVerified,
      if (username != null) 'username': username,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (contact != null) 'contact': contact,
      if (address != null) 'address': address,
      if (business != null) 'business': business!.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'createdAt': createdAt,
      if (fcmToken != null) 'fcmToken': fcmToken,
    };
  }

  String get initials {
    final name = displayName ?? username ?? email;
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }
}