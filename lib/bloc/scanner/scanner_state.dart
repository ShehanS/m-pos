import 'package:freezed_annotation/freezed_annotation.dart';

part 'scanner_state.freezed.dart';

enum ScannerStatus { initial, loading, loaded, error }

@freezed
class ScannerState with _$ScannerState {
  const factory ScannerState({
    @Default(ScannerStatus.initial) ScannerStatus status,
    String? code,
    String? errorMessage,
  }) = _ScannerState;
}