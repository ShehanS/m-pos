// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_setting_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GlobalSettingEntityImpl _$$GlobalSettingEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$GlobalSettingEntityImpl(
      appVersion: json['appVersion'] as String,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      introEnabled: json['introEnabled'] as bool?,
      tcUrl: json['tcUrl'] as String?,
      tncVersion: json['tncVersion'] as String?,
      updatedAt: (json['updatedAt'] as num?)?.toInt(),
      createdAt: (json['createdAt'] as num?)?.toInt(),
      locale: json['locale'] as String?,
      business: (json['business'] as List<dynamic>?)
          ?.map((e) => FormFieldEntity.fromJson(e as String))
          .toList(),
      profile: (json['profile'] as List<dynamic>?)
          ?.map((e) => FormFieldEntity.fromJson(e as String))
          .toList(),
    );

Map<String, dynamic> _$$GlobalSettingEntityImplToJson(
        _$GlobalSettingEntityImpl instance) =>
    <String, dynamic>{
      'appVersion': instance.appVersion,
      'forceUpdate': instance.forceUpdate,
      'introEnabled': instance.introEnabled,
      'tcUrl': instance.tcUrl,
      'tncVersion': instance.tncVersion,
      'updatedAt': instance.updatedAt,
      'createdAt': instance.createdAt,
      'locale': instance.locale,
      'business': instance.business,
      'profile': instance.profile,
    };
