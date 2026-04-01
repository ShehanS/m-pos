import 'package:freezed_annotation/freezed_annotation.dart';
import '../../entities/bill_entity.dart';
part 'bill_event.freezed.dart';

@freezed
class BillEvent with _$BillEvent {
  const factory BillEvent.started() = Started;
  const factory BillEvent.addBill({required BillEntity bill, required String userId}) = AddBill;
  const factory BillEvent.getBill({required String userId, required String billId}) = GetBill;
  const factory BillEvent.updateBill({required BillEntity bill}) = UpdateBill;
  const factory BillEvent.getBills({
    required String userId,
    DateTime? startDate,
    DateTime? endDate
  }) = GetBills;
}