import 'package:freezed_annotation/freezed_annotation.dart';

import '../../entities/item_entity.dart';

part 'inventory_event.freezed.dart';

@freezed
class InventoryEvent with _$InventoryEvent {
  const factory InventoryEvent.started() = Started;

  const factory InventoryEvent.addItem({
    required ItemEntity item,
  }) = AddItem;

  const factory InventoryEvent.addStock({
    required String itemId,
    required String poNumber,
    required double unitPrice,
    required double sellingPrice,
    @Default(0.00) double discount,
    required int quantity,
    required DateTime receivedDate,
    required String createdBy,
    String? notes,
  }) = AddStock;

  const factory InventoryEvent.dispatch({
    required String itemId,
    required int quantity,
    required String createdBy,
    String? dispatchedTo,
    String? notes,
  }) = Dispatch;

  const factory InventoryEvent.dispatchByBarcode({
    required String barcode,
    required int quantity,
    required String createdBy,
    String? dispatchedTo,
    String? notes,
  }) = DispatchByBarcode;

  const factory InventoryEvent.loadItems() = LoadItems;

  const factory InventoryEvent.loadItemEvents({
    required String itemId,
  }) = LoadItemEvents;

  const factory InventoryEvent.loadActiveLots({
    required String itemId,
  }) = LoadActiveLots;

  const factory InventoryEvent.dispatchByItem({
    required String itemId,
    required int quantity,
    required String createdBy,
    String? dispatchedTo,
    String? notes,
  }) = DispatchByItem;
  const factory InventoryEvent.deleteItem({
    required String itemId,
  }) = DeleteItem;

  const factory InventoryEvent.clearPendingDispatch() = ClearPendingDispatch;

  const factory InventoryEvent.editItem({
    required ItemEntity item,
  }) = EditItem;
  const factory InventoryEvent.scanItemForBill({
    required String barcode,
  }) = ScanItemForBill;

  const factory InventoryEvent.loadLotsForItem({
    required String itemId,
  }) = LoadLotsForItem;
}
