import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc_app/repositories/bill_repository.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final BillRepository _billRepository;

  BillBloc(this._billRepository) : super(const BillState()) {
    on<AddBill>(_onAddBill);
    on<GetBills>(_onGetBills);
    on<UpdateBill>(_onUpdateBill);
  }

  Future<void> _onAddBill(AddBill event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: CustomerBillStatus.loading));
    final result = await _billRepository.addBill(event.userId, event.bill);
    result.fold(
      (error) => emit(state.copyWith(
        status: CustomerBillStatus.error,
        errorMessage: error,
      )),
      (bill) => emit(state.copyWith(
        status: CustomerBillStatus.loaded,
        bill: bill,
      )),
    );
  }

  Future<void> _onGetBills(GetBills event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: CustomerBillStatus.loading));

    final result = await _billRepository.getBillsByUserId(
      event.userId,
      startDate: event.startDate,
      endDate: event.endDate,
    );

    result.fold(
      (error) => emit(state.copyWith(
          status: CustomerBillStatus.error, errorMessage: error)),
      (bills) =>
          emit(state.copyWith(status: CustomerBillStatus.loaded, bills: bills)),
    );
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillState> emit) async {
    emit(state.copyWith(status: CustomerBillStatus.loading));
    final result = await _billRepository.updateBill(event.bill);
    result.fold(
        (error) => emit(state.copyWith(
            status: CustomerBillStatus.error, errorMessage: error)),
        (update) => emit(state.copyWith(
            status: CustomerBillStatus.loaded, message: update)));
  }
}
