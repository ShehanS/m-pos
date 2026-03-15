import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_app/repositories/master_data_repository.dart';

import 'master_data_event.dart';
import 'master_data_state.dart';

class MasterDataBloc extends Bloc<MasterDataEvent, MasterDataState> {
  final MasterDataRepository _masterDataRepository;


  MasterDataBloc(this._masterDataRepository) : super(const MasterDataState()) {
    on<MasterDataEvent>(_loadMasterData);
  }

  Future<void> _loadMasterData(
      MasterDataEvent event, Emitter<MasterDataState> emit) async {
    emit(state.copyWith(status: MasterDataStatus.loading));
    final result = await _masterDataRepository.loadMasterData();
    result.fold(
      (error) {
        print('>>> error: $error');
        emit(state.copyWith(
          status: MasterDataStatus.error,
          errorMessage: error,
        ));
      },
      (setting) {
        emit(state.copyWith(
          status: MasterDataStatus.loaded,
          setting: setting,
        ));
      },
    );
  }
}
