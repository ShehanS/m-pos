import 'package:freezed_annotation/freezed_annotation.dart';
part 'scanner_event.freezed.dart';

@freezed
class ScannerEvent with _$ScannerEvent {
  const factory ScannerEvent.started() = Started;
  const factory ScannerEvent.scanning({required String code}) = Scanning;
  const factory ScannerEvent.reset() = ScannerReset;
}