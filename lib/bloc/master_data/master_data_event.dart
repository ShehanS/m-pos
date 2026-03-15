import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_data_event.freezed.dart';

@freezed
class MasterDataEvent with _$MasterDataEvent {
  const factory MasterDataEvent.loadMasterData() = LoadMasterData;
}