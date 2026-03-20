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
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      contact: json['contact'] as String?,
      address: json['address'] as String?,
      isUpdateProfile: json['isUpdateProfile'] as bool? ?? false,
      emailVerified: json['emailVerified'] as bool? ?? false,
      business: (json['business'] as List<dynamic>?)
          ?.map((e) => Business.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      fcmToken: json['fcmToken'] as String?,
      activeBusiness: json['activeBusiness'] as String?,
    );

Map<String, dynamic> _$$UserEntityImplToJson(_$UserEntityImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'username': instance.username,
      'displayName': instance.displayName,
      'photoUrl': instance.photoUrl,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'contact': instance.contact,
      'address': instance.address,
      'isUpdateProfile': instance.isUpdateProfile,
      'emailVerified': instance.emailVerified,
      'business': instance.business,
      'createdAt': instance.createdAt?.toIso8601String(),
      'fcmToken': instance.fcmToken,
      'activeBusiness': instance.activeBusiness,
    };
