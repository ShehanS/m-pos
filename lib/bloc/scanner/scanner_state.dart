import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
part 'scanner_state.freezed.dart';

enum ScannerStatus { initial, loading, loaded, error }
enum DeviceConnectionStatus { none, connecting, connected, failed }

@freezed
class ScannerState with _$ScannerState {
  const factory ScannerState({
    @Default(ScannerStatus.initial) ScannerStatus status,
    BluetoothDevice? selectedDevice,
    @Default(DeviceConnectionStatus.none) DeviceConnectionStatus connectionStatus,
    String? code,
    String? errorMessage,
  }) = _ScannerState;
}