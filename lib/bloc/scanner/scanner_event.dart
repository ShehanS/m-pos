import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
part 'scanner_event.freezed.dart';

@freezed
class ScannerEvent with _$ScannerEvent {
  const factory ScannerEvent.started() = Started;
  const factory ScannerEvent.scanning({required String code}) = Scanning;
  const factory ScannerEvent.reset() = ScannerReset;
  const factory ScannerEvent.selectDevice({required BluetoothDevice device}) = SelectDevice;
  const factory ScannerEvent.loadDevice() = LoadDevice;
  const factory ScannerEvent.deviceAutoConnect() = DeviceAutoConnect;
}