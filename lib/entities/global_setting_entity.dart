import 'package:freezed_annotation/freezed_annotation.dart';
import '../dtos/business_type.dart';

part 'global_setting_entity.freezed.dart';
part 'global_setting_entity.g.dart';

List<BusinessType>? _businessTypeListFromJson(List<dynamic>? json) =>
    json?.map((e) => BusinessType.fromJson(Map<String, dynamic>.from(e))).toList();

List<Map<String, dynamic>>? _businessTypeListToJson(List<BusinessType>? list) =>
    list?.map((e) => e.toJson()).toList();

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
    @JsonKey(fromJson: _businessTypeListFromJson, toJson: _businessTypeListToJson)
    List<BusinessType>? business,
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
          ?.map((e) => BusinessType.fromJson(Map<String, dynamic>.from(e)))
          .toList()
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appVersion': appVersion,
      'forceUpdate': forceUpdate,
      if (introEnabled != null) 'introEnabled': introEnabled,
      if (tcUrl != null) 'tcUrl': tcUrl,
      if (tncVersion != null) 'tncVersion': tncVersion,
      if (updatedAt != null) 'updatedAt': updatedAt,
      if (createdAt != null) 'createdAt': createdAt,
      if (locale != null) 'locale': locale,
      if (business != null) 'business': business!.map((e) => e.toJson()).toList(),
    };
  }
}