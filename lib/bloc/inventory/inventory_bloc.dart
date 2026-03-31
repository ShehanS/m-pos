import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/inventory_repository.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _inventoryRepository;

  InventoryBloc(this._inventoryRepository) : super(const InventoryState()) {
    on<Started>(_onStarted);
    on<AddItem>(_onAddItem);
    on<EditStock>(_onEditStock);
    on<AddStock>(_onAddStock);
    on<Dispatch>(_onDispatch);
    on<DispatchByBarcode>(_onDispatchByBarcode);
    on<DispatchByItem>(_onDispatchByItem);
    on<DeleteItem>(_onDeleteItem);
    on<LoadItems>(_onLoadItems);
    on<LoadItemEvents>(_onLoadItemEvents);
    on<LoadActiveLots>(_onLoadActiveLots);
    on<ClearPendingDispatch>(_onClearPendingDispatch);
    on<EditItem>(_onEditItem);
    on<ScanItemForBill>(_onScanItemForBill);
    on<LoadLotsForItem>(_onLoadLotsForItem);
  }

  Future<void> _onClearPendingDispatch(
      ClearPendingDispatch event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(
      barcodeMatches: [],
      pendingDispatch: null,
      lastOperation: null,
    ));
  }

  Future<void> _onStarted(
      Started event,
      Emitter<InventoryState> emit,
      ) async {
    add(const LoadItems());
  }

  Future<void> _onAddItem(
      AddItem event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.addItem(event.item);
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (item) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: [...state.items, item],
            lastOperation: 'Item added successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            lastOperation: 'Item added successfully',
          )),
        );
      },
    );
  }

  Future<void> _onAddStock(
      AddStock event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.addStock(
      itemId: event.itemId,
      poNumber: event.poNumber,
      unitPrice: event.unitPrice,
      quantity: event.quantity,
      receivedDate: event.receivedDate,
      createdBy: event.createdBy,
      notes: event.notes,
      sellingPrice: event.sellingPrice,
      discount: event.discount
    );
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            lastOperation: 'Stock added successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            lastOperation: 'Stock added successfully',
          )),
        );
      },
    );
  }

  Future<void> _onEditStock(
      EditStock event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.editStock(
      itemId: event.itemId,
      lotId: event.lotId,
      unitPrice: event.unitPrice,
      sellingPrice: event.sellingPrice,
      quantity: event.quantity,
      discount: event.discount,
      notes: event.notes,
    );
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            lastOperation: 'Stock updated successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            lastOperation: 'Stock updated successfully',
          )),
        );
      },
    );
  }

  Future<void> _onDispatch(
      Dispatch event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.dispatch(
      itemId: event.itemId,
      quantity: event.quantity,
      createdBy: event.createdBy,
      dispatchedTo: event.dispatchedTo,
      notes: event.notes,
    );
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            lastOperation: 'Dispatched successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            lastOperation: 'Dispatched successfully',
          )),
        );
      },
    );
  }

  Future<void> _onDispatchByBarcode(
      DispatchByBarcode event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getItemsByBarcode(event.barcode);
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (matches) async {
        if (matches.length == 1) {
          final dispatchResult = await _inventoryRepository.dispatch(
            itemId: matches.first.itemId,
            quantity: event.quantity,
            createdBy: event.createdBy,
            dispatchedTo: event.dispatchedTo,
            notes: event.notes,
          );
          await dispatchResult.fold(
                (error) async => emit(state.copyWith(
              status: InventoryStatus.error,
              errorMessage: error,
            )),
                (_) async {
              final itemsResult = await _inventoryRepository.getAllItems();
              itemsResult.fold(
                    (error) => emit(state.copyWith(
                  status: InventoryStatus.loaded,
                  lastOperation: 'Dispatched successfully',
                )),
                    (items) => emit(state.copyWith(
                  status: InventoryStatus.loaded,
                  items: items,
                  barcodeMatches: [],
                  pendingDispatch: null,
                  lastOperation: 'Dispatched successfully',
                )),
              );
            },
          );
        } else {
          emit(state.copyWith(
            status: InventoryStatus.loaded,
            barcodeMatches: matches,
            pendingDispatch: PendingDispatch(
              quantity: event.quantity,
              createdBy: event.createdBy,
              dispatchedTo: event.dispatchedTo,
              notes: event.notes,
            ),
            lastOperation: null,
          ));
        }
      },
    );
  }

  Future<void> _onDispatchByItem(
      DispatchByItem event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.dispatch(
      itemId: event.itemId,
      quantity: event.quantity,
      createdBy: event.createdBy,
      dispatchedTo: event.dispatchedTo,
      notes: event.notes,
    );
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            barcodeMatches: [],
            pendingDispatch: null,
            lastOperation: 'Dispatched successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            barcodeMatches: [],
            pendingDispatch: null,
            lastOperation: 'Dispatched successfully',
          )),
        );
      },
    );
  }

  Future<void> _onDeleteItem(
      DeleteItem event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.deleteItem(event.itemId);
    await result.fold(
          (error) async => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: state.items
                .where((i) => i.itemId != event.itemId)
                .toList(),
            lastOperation: 'Item deleted successfully',
          )),
              (items) => emit(state.copyWith(
            status: InventoryStatus.loaded,
            items: items,
            lastOperation: 'Item deleted successfully',
          )),
        );
      },
    );
  }

  Future<void> _onLoadItems(
      LoadItems event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getAllItems();
    result.fold(
          (error) => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (items) => emit(state.copyWith(
        status: InventoryStatus.loaded,
        items: items,
        lastOperation: null,
      )),
    );
  }

  Future<void> _onLoadItemEvents(
      LoadItemEvents event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getItemEvents(event.itemId);
    result.fold(
          (error) => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (events) => emit(state.copyWith(
        status: InventoryStatus.loaded,
        events: events,
        lastOperation: null,
      )),
    );
  }

  Future<void> _onLoadActiveLots(
      LoadActiveLots event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getActiveLots(event.itemId);
    result.fold(
          (error) => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (lots) => emit(state.copyWith(
        status: InventoryStatus.loaded,
        activeLots: lots,
        lastOperation: null,
      )),
    );
  }
  Future<void> _onEditItem(
      EditItem event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.updateItem(event.item);
    await result.fold(
          (error) async =>
          emit(state.copyWith(
            status: InventoryStatus.error,
            errorMessage: error,
          )),
          (_) async {
        final itemsResult = await _inventoryRepository.getAllItems();
        itemsResult.fold(
              (error) =>
              emit(state.copyWith(
                status: InventoryStatus.loaded,
                items: state.items
                    .map((i) => i.itemId == event.item.itemId ? event.item : i)
                    .toList(),
                lastOperation: 'Item updated successfully',
              )),
              (items) =>
              emit(state.copyWith(
                status: InventoryStatus.loaded,
                items: items,
                lastOperation: 'Item updated successfully',
              )),
        );
      },
    );
  }
  Future<void> _onScanItemForBill(
      ScanItemForBill event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getItemsByBarcode(event.barcode);
    result.fold(
          (error) => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (items) => emit(state.copyWith(
        status: InventoryStatus.loaded,
        barcodeMatches: items,
        lastOperation: null,
      )),
    );
  }

  Future<void> _onLoadLotsForItem(
      LoadLotsForItem event,
      Emitter<InventoryState> emit,
      ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    final result = await _inventoryRepository.getActiveLots(event.itemId);
    result.fold(
          (error) => emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: error,
      )),
          (lots) => emit(state.copyWith(
        status: InventoryStatus.loaded,
        scannedItemLots: lots,
        lastOperation: null,
      )),
    );
  }
}