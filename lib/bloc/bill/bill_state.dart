import 'package:flutter_bloc_app/entities/bill_entity.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill_state.freezed.dart';

enum CustomerBillStatus { initial, loading, loaded, error }

@freezed
class BillState with _$BillState {
  const factory BillState({
    @Default(CustomerBillStatus.initial) CustomerBillStatus status,
    String? message,
    BillEntity? bill,
    List<BillEntity>? bills,
    String? errorMessage,
  }) = _BillState;
}
