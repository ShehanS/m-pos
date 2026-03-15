import 'package:flutter_bloc_app/entities/form_field_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'global_setting_entity.freezed.dart';

part 'global_setting_entity.g.dart';

@freezed
class GlobalSettingEntity with _$GlobalSettingEntity {
  const GlobalSettingEntity._();

  const factory GlobalSettingEntity({
    required String appVersion,
    @Default(false) bool forceUpdate,
    bool? introEnabled,
    String? tcUrl,
    String? tncVersion,
    int? updatedAt,
    int? createdAt,
    String? locale,
    List<FormFieldEntity>? business,
    List<FormFieldEntity>? profile,
  }) = _GlobalSettingEntity;

  factory GlobalSettingEntity.fromJson(Map<String, dynamic> json) =>
      _$GlobalSettingEntityFromJson(json);

  factory GlobalSettingEntity.fromFirestore(Map<String, dynamic> data) {
    return GlobalSettingEntity(
      appVersion: data['appVersion'] as String? ?? '',
      forceUpdate: data['forceUpdate'] as bool? ?? false,
      introEnabled: data['introEnabled'] as bool?,
      tcUrl: data['tcUrl'] as String?,
      tncVersion: data['tncVersion'] as String?,
      updatedAt: data['updatedAt'] as int?,
      createdAt: data['createdAt'] as int?,
      locale: data['locale'] as String?,
      business: (data['business'] as List?)
          ?.map((e) => FormFieldEntity.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
      profile: (data['profile'] as List?)
          ?.map((e) => FormFieldEntity.fromMap(
                Map<String, dynamic>.from(e),
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appVersion': appVersion,
      'forceUpdate': forceUpdate,
      'introEnabled': introEnabled,
      'tcUrl': tcUrl,
      'tncVersion': tncVersion,
      'updatedAt': updatedAt,
      'createdAt': createdAt,
      'locale': locale,
      'business': business?.map((e) => e.toJson()).toList(),
      'profile': profile?.map((e) => e.toJson()).toList(),
    };
  }
}
