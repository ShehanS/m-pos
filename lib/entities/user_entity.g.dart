// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserEntityImpl _$$UserEntityImplFromJson(Map<String, dynamic> json) =>
    _$UserEntityImpl(
      uid: json['uid'] as String,
      email: json['email'] as String,
      username: json['username'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      isUpdateProfile: json['isUpdateProfile'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      profile: (json['profile'] as List<dynamic>?)
          ?.map((e) => FormFieldEntity.fromJson(e as String))
          .toList(),
      business: (json['business'] as List<dynamic>?)
          ?.map((e) => (e as Map<String, dynamic>).map(
                (k, e) => MapEntry(
                    k,
                    (e as List<dynamic>)
                        .map((e) => FormFieldEntity.fromJson(e as String))
                        .toList()),
              ))
          .toList(),
      fcmToken: json['fcmToken'] as String?,
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'isUpdateProfile': instance.isUpdateProfile,
      'emailVerified': instance.emailVerified,
      'createdAt': instance.createdAt?.toIso8601String(),
      'profile': instance.profile,
      'business': instance.business,
      'fcmToken': instance.fcmToken,
    };
