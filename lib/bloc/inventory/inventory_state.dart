import 'package:freezed_annotation/freezed_annotation.dart';

import '../../entities/inventory_event_entity.dart';
import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';

part 'inventory_state.freezed.dart';

enum InventoryStatus { initial, loading, loaded, error }

class PendingDispatch {
  final int quantity;
  final String createdBy;
  final String? dispatchedTo;
  final String? notes;

  const PendingDispatch({
    required this.quantity,
    required this.createdBy,
    this.dispatchedTo,
    this.notes,
  });
}

@freezed
class InventoryState with _$InventoryState {
  const factory InventoryState({
    @Default(InventoryStatus.initial) InventoryStatus status,
    @Default([]) List<ItemEntity> items,
    @Default([]) List<LotEntity> activeLots,
    @Default([]) List<InventoryEventEntity> events,
    @Default([]) List<ItemEntity> barcodeMatches,
    @Default([]) List<LotEntity> scannedItemLots,
    ItemEntity? scannedItem,
    ItemEntity? scannedBillItem,
    PendingDispatch? pendingDispatch,
    String? lastOperation,
    String? errorMessage,
  }) = _InventoryState;
}