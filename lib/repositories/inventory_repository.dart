import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../entities/dispatch_event_entity.dart';
import '../entities/inventory_event_entity.dart';
import '../entities/item_entity.dart';
import '../entities/lot_entity.dart';

abstract class InventoryRepository {
  Future<Either<String, ItemEntity>> addItem(ItemEntity item);

  Future<Either<String, ItemEntity>> getItem(String itemId);

  Future<Either<String, List<ItemEntity>>> getAllItems();

  Future<Either<String, ItemEntity>> getItemByBarcode(String barcode);

  Future<Either<String, Unit>> addStock({
    required String itemId,
    required String poNumber,
    required double unitPrice,
    required int quantity,
    required double sellingPrice,
    double? discount,
    required DateTime receivedDate,
    required String createdBy,
    String? notes,
  });

  Future<Either<String, Unit>> editStock({
    required String itemId,
    required String lotId,
    required double unitPrice,
    required double sellingPrice,
    required int quantity,
    double? discount,
    String? notes,
  });

  Future<Either<String, Unit>> dispatch({
    required String itemId,
    required int quantity,
    required String createdBy,
    String? dispatchedTo,
    String? notes,
  });

  Future<Either<String, List<LotEntity>>> getActiveLots(String itemId);

  Future<Either<String, List<InventoryEventEntity>>> getItemEvents(
      String itemId);

  Future<Either<String, List<DispatchEventEntity>>> getItemDispatches(
      String itemId);

  Future<Either<String, List<InventoryEventEntity>>> getUserEvents(
      String userId);

  Future<Either<String, List<InventoryEventEntity>>> getUserEventsByItem({
    required String userId,
    required String itemId,
  });

  Future<Either<String, List<DispatchEventEntity>>> getUserDispatches(
      String userId);

  Future<Either<String, Unit>> deleteItem(String itemId);

  Future<Either<String, Map<String, int>>> getUserStockSummary(String userId);

  Stream<Either<String, ItemEntity>> watchItem(String itemId);

  Stream<Either<String, List<LotEntity>>> watchActiveLots(String itemId);

  Stream<Either<String, List<InventoryEventEntity>>> watchUserEvents(
      String userId);

  Future<Either<String, List<ItemEntity>>> getItemsByBarcode(String barcode);

  Future<Either<String, ItemEntity>> updateItem(ItemEntity item);
}

class InventoryRepositoryImpl implements InventoryRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _items => _firestore.collection('items');

  CollectionReference get _inventoryEvents =>
      _firestore.collection('inventoryEvents');

  CollectionReference get _dispatchEvents =>
      _firestore.collection('dispatchEvents');

  @override
  Future<Either<String, ItemEntity>> addItem(ItemEntity item) async {
    try {
      final ref = _items.doc();
      final newItem = item.copyWith(itemId: ref.id);
      await ref.set(newItem.toFirestore());
      return Right(newItem);
    } catch (e) {
      return Left('Item creation error: $e');
    }
  }

  @override
  Future<Either<String, ItemEntity>> getItem(String itemId) async {
    try {
      final doc = await _items.doc(itemId).get();
      if (!doc.exists || doc.data() == null) {
        return const Left('Item not found');
      }
      return Right(
        ItemEntity.fromFirestore(doc.id, doc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Left('Item fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<ItemEntity>>> getAllItems() async {
    try {
      final snapshot = await _items.orderBy('name').get();
      final items = snapshot.docs
          .map((doc) => ItemEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(items);
    } catch (e) {
      return Left('Items fetch error: $e');
    }
  }

  @override
  Future<Either<String, Unit>> addStock({
    required String itemId,
    required String poNumber,
    required double sellingPrice,
    double? discount,
    required double unitPrice,
    required int quantity,
    required DateTime receivedDate,
    required String createdBy,
    String? notes,
  }) async {
    try {
      final lotRef = _items.doc(itemId).collection('lots').doc();
      final eventRef = _inventoryEvents.doc();
      final itemRef = _items.doc(itemId);

      final lot = LotEntity(
        lotId: lotRef.id,
        itemId: itemId,
        poNumber: poNumber,
        discount: discount,
        unitPrice: unitPrice,
        quantityReceived: quantity,
        quantityRemaining: quantity,
        receivedDate: receivedDate,
        status: 'active',
        notes: notes,
        createdBy: createdBy,
        sellingPrice: sellingPrice,
        createdAt: DateTime.now(),
      );

      final event = InventoryEventEntity(
        eventId: eventRef.id,
        eventType: 'STOCK_IN',
        itemId: itemId,
        lotId: lotRef.id,
        poNumber: poNumber,
        quantity: quantity,
        unitPrice: unitPrice,
        sellingPrice: sellingPrice,
        discount: discount,
        timestamp: DateTime.now(),
        createdBy: createdBy,
        notes: notes,
      );

      final batch = _firestore.batch();
      batch.set(lotRef, lot.toFirestore());
      batch.set(eventRef, event.toFirestore());
      batch.update(itemRef, {
        'currentStock': FieldValue.increment(quantity),
      });
      await batch.commit();

      return const Right(unit);
    } catch (e) {
      return Left('Stock in error: $e');
    }
  }

  @override
  Future<Either<String, Unit>> dispatch({
    required String itemId,
    required int quantity,
    required String createdBy,
    String? dispatchedTo,
    String? notes,
  }) async {
    try {
      final lotsSnapshot = await _items
          .doc(itemId)
          .collection('lots')
          .where('status', isEqualTo: 'active')
          .where('quantityRemaining', isGreaterThan: 0)
          .orderBy('quantityRemaining')
          .orderBy('receivedDate')
          .get();

      final lots = lotsSnapshot.docs
          .map((doc) => LotEntity.fromFirestore(doc.id, doc.data()))
          .toList();

      final totalAvailable =
          lots.fold(0, (sum, lot) => sum + lot.quantityRemaining);

      if (totalAvailable < quantity) {
        return Left(
            'Insufficient stock. Available: $totalAvailable, Requested: $quantity');
      }

      final lotsConsumed = <LotConsumed>[];
      double totalCost = 0;
      int remaining = quantity;

      final batch = _firestore.batch();

      for (final lot in lots) {
        if (remaining == 0) break;

        final consumed = remaining <= lot.quantityRemaining
            ? remaining
            : lot.quantityRemaining;
        final newRemaining = lot.quantityRemaining - consumed;
        final lotRef = _items.doc(itemId).collection('lots').doc(lot.lotId);

        batch.update(lotRef, {
          'quantityRemaining': newRemaining,
          'status': newRemaining == 0 ? 'exhausted' : 'active',
        });

        lotsConsumed.add(LotConsumed(
          lotId: lot.lotId,
          quantity: consumed,
          unitPrice: lot.unitPrice,
        ));

        totalCost += consumed * lot.unitPrice;
        remaining -= consumed;
      }

      final dispatchRef = _dispatchEvents.doc();
      final eventRef = _inventoryEvents.doc();
      final itemRef = _items.doc(itemId);

      final dispatchEvent = DispatchEventEntity(
        dispatchId: dispatchRef.id,
        itemId: itemId,
        totalQuantity: quantity,
        totalCost: totalCost,
        lotsConsumed: lotsConsumed,
        timestamp: DateTime.now(),
        dispatchedTo: dispatchedTo,
        createdBy: createdBy,
        notes: notes,
      );

      final inventoryEvent = InventoryEventEntity(
        eventId: eventRef.id,
        eventType: 'DISPATCH',
        itemId: itemId,
        quantity: quantity,
        sellingPrice: 0,
        discount: null,
        timestamp: DateTime.now(),
        createdBy: createdBy,
        notes: notes,
      );

      batch.set(dispatchRef, dispatchEvent.toFirestore());
      batch.set(eventRef, inventoryEvent.toFirestore());
      batch.update(itemRef, {
        'currentStock': FieldValue.increment(-quantity),
      });
      await batch.commit();

      return const Right(unit);
    } catch (e) {
      return Left('Dispatch error: $e');
    }
  }

  @override
  Future<Either<String, List<LotEntity>>> getActiveLots(String itemId) async {
    try {
      final snapshot = await _items
          .doc(itemId)
          .collection('lots')
          .where('status', isEqualTo: 'active')
          .where('quantityRemaining', isGreaterThan: 0)
          .orderBy('quantityRemaining')
          .orderBy('receivedDate')
          .get();

      final lots = snapshot.docs
          .map((doc) => LotEntity.fromFirestore(doc.id, doc.data()))
          .toList();
      return Right(lots);
    } catch (e) {
      return Left('Lots fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<InventoryEventEntity>>> getItemEvents(
      String itemId) async {
    try {
      final snapshot = await _inventoryEvents
          .where('itemId', isEqualTo: itemId)
          .orderBy('timestamp', descending: true)
          .get();

      final events = snapshot.docs
          .map((doc) => InventoryEventEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(events);
    } catch (e) {
      return Left('Events fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<DispatchEventEntity>>> getItemDispatches(
      String itemId) async {
    try {
      final snapshot = await _dispatchEvents
          .where('itemId', isEqualTo: itemId)
          .orderBy('timestamp', descending: true)
          .get();

      final dispatches = snapshot.docs
          .map((doc) => DispatchEventEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(dispatches);
    } catch (e) {
      return Left('Dispatches fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<InventoryEventEntity>>> getUserEvents(
      String userId) async {
    try {
      final snapshot = await _inventoryEvents
          .where('createdBy', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final events = snapshot.docs
          .map((doc) => InventoryEventEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(events);
    } catch (e) {
      return Left('User events fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<InventoryEventEntity>>> getUserEventsByItem({
    required String userId,
    required String itemId,
  }) async {
    try {
      final snapshot = await _inventoryEvents
          .where('createdBy', isEqualTo: userId)
          .where('itemId', isEqualTo: itemId)
          .orderBy('timestamp', descending: true)
          .get();

      final events = snapshot.docs
          .map((doc) => InventoryEventEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(events);
    } catch (e) {
      return Left('User item events fetch error: $e');
    }
  }

  @override
  Future<Either<String, List<DispatchEventEntity>>> getUserDispatches(
      String userId) async {
    try {
      final snapshot = await _dispatchEvents
          .where('createdBy', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      final dispatches = snapshot.docs
          .map((doc) => DispatchEventEntity.fromFirestore(
                doc.id,
                doc.data() as Map<String, dynamic>,
              ))
          .toList();
      return Right(dispatches);
    } catch (e) {
      return Left('User dispatches fetch error: $e');
    }
  }

  @override
  Future<Either<String, Map<String, int>>> getUserStockSummary(
      String userId) async {
    try {
      final snapshot =
          await _inventoryEvents.where('createdBy', isEqualTo: userId).get();

      final summary = <String, int>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final itemId = data['itemId'] as String? ?? '';
        final qty = data['quantity'] as int? ?? 0;
        final type = data['eventType'] as String? ?? '';

        if (type == 'STOCK_IN') {
          summary[itemId] = (summary[itemId] ?? 0) + qty;
        } else if (type == 'DISPATCH') {
          summary[itemId] = (summary[itemId] ?? 0) - qty;
        }
      }
      return Right(summary);
    } catch (e) {
      return Left('User stock summary error: $e');
    }
  }

  @override
  Stream<Either<String, ItemEntity>> watchItem(String itemId) {
    return _items.doc(itemId).snapshots().map((doc) {
      try {
        if (!doc.exists || doc.data() == null) {
          return const Left('Item not found');
        }
        return Right<String, ItemEntity>(
          ItemEntity.fromFirestore(doc.id, doc.data() as Map<String, dynamic>),
        );
      } catch (e) {
        return Left<String, ItemEntity>('Item stream error: $e');
      }
    });
  }

  @override
  Stream<Either<String, List<LotEntity>>> watchActiveLots(String itemId) {
    return _items
        .doc(itemId)
        .collection('lots')
        .where('status', isEqualTo: 'active')
        .where('quantityRemaining', isGreaterThan: 0)
        .orderBy('quantityRemaining')
        .orderBy('receivedDate')
        .snapshots()
        .map((snapshot) {
      try {
        final lots = snapshot.docs
            .map((doc) => LotEntity.fromFirestore(doc.id, doc.data()))
            .toList();
        return Right<String, List<LotEntity>>(lots);
      } catch (e) {
        return Left<String, List<LotEntity>>('Lots stream error: $e');
      }
    });
  }

  @override
  Stream<Either<String, List<InventoryEventEntity>>> watchUserEvents(
      String userId) {
    return _inventoryEvents
        .where('createdBy', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      try {
        final events = snapshot.docs
            .map((doc) => InventoryEventEntity.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList();
        return Right<String, List<InventoryEventEntity>>(events);
      } catch (e) {
        return Left<String, List<InventoryEventEntity>>(
            'User events stream error: $e');
      }
    });
  }

  @override
  Future<Either<String, ItemEntity>> getItemByBarcode(String barcode) async {
    try {
      final snapshot =
          await _items.where('barcode', isEqualTo: barcode).limit(1).get();

      if (snapshot.docs.isEmpty) {
        return const Left('No item found for this barcode');
      }

      final doc = snapshot.docs.first;
      return Right(
        ItemEntity.fromFirestore(doc.id, doc.data() as Map<String, dynamic>),
      );
    } catch (e) {
      return Left('Barcode lookup error: $e');
    }
  }

  @override
  Future<Either<String, List<ItemEntity>>> getItemsByBarcode(
      String barcode) async {
    try {
      final snapshot = await _items.where('barcode', isEqualTo: barcode).get();

      if (snapshot.docs.isEmpty) {
        return const Left('No item found for this barcode');
      }

      final items = snapshot.docs
          .map((doc) => ItemEntity.fromFirestore(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      return Right(items);
    } catch (e) {
      return Left('Barcode lookup error: $e');
    }
  }

  @override
  Future<Either<String, Unit>> deleteItem(String itemId) async {
    try {
      Future<void> commitInBatches(List<DocumentReference> refs) async {
        const batchSize = 400;
        for (var i = 0; i < refs.length; i += batchSize) {
          final batch = _firestore.batch();
          final chunk = refs.sublist(
              i, i + batchSize > refs.length ? refs.length : i + batchSize);
          for (final ref in chunk) {
            batch.delete(ref);
          }
          await batch.commit();
        }
      }

      final lotsRefs = (await _items.doc(itemId).collection('lots').get())
          .docs
          .map((d) => d.reference)
          .toList();

      final eventsRefs =
          (await _inventoryEvents.where('itemId', isEqualTo: itemId).get())
              .docs
              .map((d) => d.reference)
              .toList();

      final dispatchRefs =
          (await _dispatchEvents.where('itemId', isEqualTo: itemId).get())
              .docs
              .map((d) => d.reference)
              .toList();

      await commitInBatches([
        ...lotsRefs,
        ...eventsRefs,
        ...dispatchRefs,
        _items.doc(itemId),
      ]);

      return const Right(unit);
    } catch (e) {
      return Left('Delete error: $e');
    }
  }

  @override
  Future<Either<String, ItemEntity>> updateItem(ItemEntity item) async {
    try {
      await _items.doc(item.itemId).update(item.toFirestore());
      return Right(item);
    } catch (e) {
      return Left('Item update error: $e');
    }
  }

  @override
  Future<Either<String, Unit>> editStock({
    required String itemId,
    required String lotId,
    required double unitPrice,
    required double sellingPrice,
    required int quantity,
    double? discount,
    String? notes,
  }) async {
    try {
      final lotRef = _items.doc(itemId).collection('lots').doc(lotId);
      final itemRef = _items.doc(itemId);
      final lotDoc = await lotRef.get();
      if (!lotDoc.exists) return const Left('Lot not found');

      final currentLot = LotEntity.fromFirestore(
          lotDoc.id, lotDoc.data() as Map<String, dynamic>);

      final stockDiff = quantity - currentLot.quantityRemaining;

      final batch = _firestore.batch();

      batch.update(lotRef, {
        'unitPrice': unitPrice,
        'sellingPrice': sellingPrice,
        'quantityRemaining': quantity,
        'quantityReceived': currentLot.quantityReceived + stockDiff,
        'status': quantity == 0 ? 'exhausted' : 'active',
        if (discount != null && discount > 0) 'discount': discount,
        if (discount == null || discount == 0) 'discount': FieldValue.delete(),
        if (notes != null) 'notes': notes,
      });
      if (stockDiff != 0) {
        batch.update(itemRef, {
          'currentStock': FieldValue.increment(stockDiff),
        });
      }

      await batch.commit();
      return const Right(unit);
    } catch (e) {
      return Left('Edit stock error: $e');
    }
  }
}
