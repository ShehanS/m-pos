import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_event.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_state.dart';
class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {


  ScannerBloc() : super(const ScannerState()) {
    on<Scanning>(_scanning);
    on<ScannerReset>(_reset);
  }

  Future<void> _scanning(Scanning event, Emitter<ScannerState> emit) async {
    emit(state.copyWith(status: ScannerStatus.loading));
    emit(state.copyWith(code: event.code, status: ScannerStatus.loaded));
  }

  Future<void> _reset(ScannerReset event, Emitter<ScannerState> emit) async {
    emit(const ScannerState());
  }
}
