import 'package:freezed_annotation/freezed_annotation.dart';

part 'inventory_event_entity.freezed.dart';
part 'inventory_event_entity.g.dart';

@freezed
class InventoryEventEntity with _$InventoryEventEntity {
  const InventoryEventEntity._();

  const factory InventoryEventEntity({
    required String eventId,
    required String eventType,
    required String itemId,
    required int quantity,
    required DateTime timestamp,
    String? lotId,
    String? poNumber,
    double? unitPrice,
    required double sellingPrice,
    double? discount,
    String? createdBy,
    String? notes,
  }) = _InventoryEventEntity;

  factory InventoryEventEntity.fromFirestore(
      String id, Map<String, dynamic> data) {
    return InventoryEventEntity(
      eventId: id,
      eventType: data['eventType'] as String? ?? '',
      itemId: data['itemId'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      discount: (data['discount'] as num?)?.toDouble(),
      sellingPrice:
      (data['sellingPrice'] as num?)?.toDouble() ?? 0,
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      lotId: data['lotId'] as String?,
      poNumber: data['poNumber'] as String?,
      unitPrice: (data['unitPrice'] as num?)?.toDouble(),
      createdBy: data['createdBy'] as String?,
      notes: data['notes'] as String?,
    );
  }

  factory InventoryEventEntity.fromJson(Map<String, dynamic> json) =>
      _$InventoryEventEntityFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'eventType': eventType,
      'itemId': itemId,
      'quantity': quantity,
      'timestamp': timestamp,
      if (lotId != null) 'lotId': lotId,
      if (poNumber != null) 'poNumber': poNumber,
      if (unitPrice != null) 'unitPrice': unitPrice,
      'sellingPrice': sellingPrice,
      if (discount != null) 'discount': discount,
      if (createdBy != null) 'createdBy': createdBy,
      if (notes != null) 'notes': notes,
    };
  }

  bool get isStockIn => eventType == 'STOCK_IN';
  bool get isDispatch => eventType == 'DISPATCH';
  bool get isAdjust => eventType == 'STOCK_ADJUST';
  bool get isReturn => eventType == 'RETURN';
  bool get isWriteOff => eventType == 'WRITE_OFF';
}