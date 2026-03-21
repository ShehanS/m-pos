import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
part 'printer_event.freezed.dart';

@freezed
class PrinterEvent with _$PrinterEvent {
  const factory PrinterEvent.selectDevice(
      {required BluetoothDevice device}) = SelectDevice;
  const factory PrinterEvent.loadDevice() = LoadDevice;
  const factory PrinterEvent.deviceAutoConnect() = DeviceAutoConnect;
}