import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_event.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_state.dart';
import 'package:flutter_bloc_app/local_storage/local_storage_service.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final localStorageService = LocalStorageService.instance;
  static const String _globalSettingsBox = 'global_settings';
  static const String _deviceAddressKey = 'device_address';
  static const String _deviceNameKey = 'device_name';

  ScannerBloc() : super(const ScannerState()) {
    on<Scanning>(_scanning);
    on<ScannerReset>(_reset);
    on<SelectDevice>(_selectDevice);
    on<LoadDevice>(_loadDevice);
    on<DeviceAutoConnect>(_autoConnect);
  }

  Future<void> _loadDevice(LoadDevice event, Emitter<ScannerState> emit) async {
    try {
      final address =
          localStorageService.getData(_globalSettingsBox, _deviceAddressKey);
      final name =
          localStorageService.getData(_globalSettingsBox, _deviceNameKey);

      if (address != null && address is String) {
        final device = BluetoothDevice(
          address: address,
          name: name is String ? name : null,
        );
        emit(state.copyWith(selectedDevice: device));
      }
    } catch (_) {}
  }

  Future<void> _selectDevice(
      SelectDevice event, Emitter<ScannerState> emit) async {
    try {
      await localStorageService.saveData(
          _globalSettingsBox, _deviceAddressKey, event.device.address);
      await localStorageService.saveData(
          _globalSettingsBox, _deviceNameKey, event.device.name ?? '');
      emit(state.copyWith(selectedDevice: event.device));
    } catch (_) {}
  }

  Future<void> _scanning(Scanning event, Emitter<ScannerState> emit) async {
    emit(state.copyWith(status: ScannerStatus.loading));
    emit(state.copyWith(code: event.code, status: ScannerStatus.loaded));
  }

  Future<void> _reset(ScannerReset event, Emitter<ScannerState> emit) async {
    emit(const ScannerState());
  }

  Future<void> _autoConnect(
      DeviceAutoConnect event, Emitter<ScannerState> emit) async {
    final address =
        localStorageService.getData(_globalSettingsBox, _deviceAddressKey);
    final name =
        localStorageService.getData(_globalSettingsBox, _deviceNameKey);

    if (address == null || address is! String || address.isEmpty) {
      emit(state.copyWith(connectionStatus: DeviceConnectionStatus.none));
      return;
    }

    final device = BluetoothDevice(
      address: address,
      name: name is String && name.isNotEmpty ? name : null,
    );

    emit(state.copyWith(
      connectionStatus: DeviceConnectionStatus.connecting,
      selectedDevice: device,
    ));

    try {
      await FlutterBluetoothPrinter.connect(device.address)
          .timeout(const Duration(seconds: 8));
      emit(state.copyWith(
        connectionStatus: DeviceConnectionStatus.connected,
        selectedDevice: device,
      ));
      print("device auto connected....");
    } on TimeoutException {
      emit(state.copyWith(
        connectionStatus: DeviceConnectionStatus.failed,
        selectedDevice: device,
      ));
      print("device auto connect timeout — device unreachable");
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: DeviceConnectionStatus.failed,
        selectedDevice: device,
      ));
      print("device auto failed....$e");
    }
  }
}
