import 'package:freezed_annotation/freezed_annotation.dart';

part 'dispatch_event_entity.freezed.dart';
part 'dispatch_event_entity.g.dart';

@freezed
class LotConsumed with _$LotConsumed {
  const LotConsumed._();

  const factory LotConsumed({
    required String lotId,
    required int quantity,
    required double unitPrice,
  }) = _LotConsumed;

  factory LotConsumed.fromJson(Map<String, dynamic> json) =>
      _$LotConsumedFromJson(json);

  static LotConsumed fromMap(Map<String, dynamic> data) {
    return LotConsumed(
      lotId: data['lotId'] as String? ?? '',
      quantity: data['quantity'] as int? ?? 0,
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

extension LotConsumedX on LotConsumed {
  double get lineTotal => quantity * unitPrice;

  Map<String, dynamic> toMap() => {
    'lotId': lotId,
    'quantity': quantity,
    'unitPrice': unitPrice,
  };
}

@freezed
class DispatchEventEntity with _$DispatchEventEntity {
  const DispatchEventEntity._();

  const factory DispatchEventEntity({
    required String dispatchId,
    required String itemId,
    required int totalQuantity,
    required double totalCost,
    required List<LotConsumed> lotsConsumed,
    required DateTime timestamp,
    String? dispatchedTo,
    String? createdBy,
    String? notes,
  }) = _DispatchEventEntity;

  factory DispatchEventEntity.fromFirestore(
      String id, Map<String, dynamic> data) {
    return DispatchEventEntity(
      dispatchId: id,
      itemId: data['itemId'] as String? ?? '',
      totalQuantity: data['totalQuantity'] as int? ?? 0,
      totalCost: (data['totalCost'] as num?)?.toDouble() ?? 0.0,
      lotsConsumed: (data['lotsConsumed'] as List?)
          ?.map((e) => LotConsumed.fromMap(Map<String, dynamic>.from(e)))
          .toList() ??
          [],
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as dynamic).toDate()
          : DateTime.now(),
      dispatchedTo: data['dispatchedTo'] as String?,
      createdBy: data['createdBy'] as String?,
      notes: data['notes'] as String?,
    );
  }

  factory DispatchEventEntity.fromJson(Map<String, dynamic> json) =>
      _$DispatchEventEntityFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'totalQuantity': totalQuantity,
      'totalCost': totalCost,
      'lotsConsumed': lotsConsumed.map((e) => e.toMap()).toList(),
      'timestamp': timestamp,
      if (dispatchedTo != null) 'dispatchedTo': dispatchedTo,
      if (createdBy != null) 'createdBy': createdBy,
      if (notes != null) 'notes': notes,
    };
  }

  double get weightedAverageUnitPrice =>
      totalQuantity == 0 ? 0.0 : totalCost / totalQuantity;

  int get lotCount => lotsConsumed.length;
  bool get isMultiLot => lotsConsumed.length > 1;
}