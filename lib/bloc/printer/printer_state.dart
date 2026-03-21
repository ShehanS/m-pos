import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'printer_state.freezed.dart';

enum DeviceConnectionStatus { none, connecting, connected, failed }

@freezed
class PrinterState with _$PrinterState {
  const factory PrinterState({
    BluetoothDevice? selectedDevice,
    @Default(
        DeviceConnectionStatus.none) DeviceConnectionStatus connectionStatus
  }) = _PrinterState;
}
