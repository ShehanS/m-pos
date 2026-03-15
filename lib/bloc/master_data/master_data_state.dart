import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bloc_app/entities/global_setting_entity.dart';

part 'master_data_state.freezed.dart';
enum MasterDataStatus { initial, loading, loaded, error }

@freezed
class MasterDataState with _$MasterDataState {
  const factory MasterDataState({
    @Default(MasterDataStatus.initial) MasterDataStatus status,
    @Default('') String errorMessage,
    GlobalSettingEntity? setting,
  }) = _MasterDataState;
}