import 'package:freezed_annotation/freezed_annotation.dart';

part 'lot_entity.freezed.dart';
part 'lot_entity.g.dart';

@freezed
class LotEntity with _$LotEntity {
  const LotEntity._();

  const factory LotEntity({
    required String lotId,
    required String itemId,
    required String poNumber,
    required double unitPrice,
    required double sellingPrice,
    required int quantityReceived,
    required int quantityRemaining,
    required DateTime receivedDate,
    @Default('active') String status,
    double? discount,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) = _LotEntity;

  factory LotEntity.fromFirestore(String id, Map<String, dynamic> data) {
    return LotEntity(
      lotId: id,
      itemId: data['itemId'] as String? ?? '',
      poNumber: data['poNumber'] as String? ?? '',
      unitPrice: (data['unitPrice'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (data['sellingPrice'] as num?)?.toDouble() ?? 0.0,
      quantityReceived: data['quantityReceived'] as int? ?? 0,
      quantityRemaining: data['quantityRemaining'] as int? ?? 0,
      receivedDate: data['receivedDate'] != null
          ? (data['receivedDate'] as dynamic).toDate()
          : DateTime.now(),
      status: data['status'] as String? ?? 'active',
      discount: (data['discount'] as num?)?.toDouble(),
      notes: data['notes'] as String?,
      createdBy: data['createdBy'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  factory LotEntity.fromJson(Map<String, dynamic> json) =>
      _$LotEntityFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'itemId': itemId,
      'poNumber': poNumber,
      'unitPrice': unitPrice,
      'sellingPrice': sellingPrice,
      'quantityReceived': quantityReceived,
      'quantityRemaining': quantityRemaining,
      'receivedDate': receivedDate,
      'status': status,
      if (discount != null) 'discount': discount,
      if (notes != null) 'notes': notes,
      if (createdBy != null) 'createdBy': createdBy,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }

  bool get isExhausted => quantityRemaining == 0;
  bool get isPartial =>
      quantityRemaining > 0 && quantityRemaining < quantityReceived;

  double get effectiveSellingPrice {
    if (discount == null || discount == 0) return sellingPrice;
    return sellingPrice - discount!;
  }
}