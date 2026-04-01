import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dtos/bill_item.dart';

part 'bill_entity.freezed.dart';
part 'bill_entity.g.dart';

enum BillStatus { pending, hold, competed }

@freezed
class BillEntity with _$BillEntity {
  const BillEntity._();

  const factory BillEntity({
    String? billId,
    String? customerName,
    String? customerContact,
    required List<BillItem> billItems,
    required double subtotal,
    required double totalDiscount,
    required double grandTotal,
    required DateTime createdAt,
    String? createdBy,
    required BillStatus status,
  }) = _BillEntity;

  factory BillEntity.fromJson(Map<String, dynamic> json) =>
      _$BillEntityFromJson(json);

  factory BillEntity.fromFirestore(String id, Map<String, dynamic> data) {
    return BillEntity(
      billId: id,
      customerName: data['customerName'] as String?,
      customerContact: data['customerContact'] as String?,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (data['totalDiscount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (data['grandTotal'] as num?)?.toDouble() ?? 0.0,
      createdBy: data['createdBy'] as String?,
      status: BillStatus.values.firstWhere(
            (e) => e.name == (data['status'] as String?),
        orElse: () => BillStatus.pending,
      ),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      billItems: (data['billItems'] as List<dynamic>?)
          ?.map((e) => BillItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (billId != null) 'billId': billId,
      'customerName': customerName,
      'customerContact': customerContact,
      'subtotal': subtotal,
      'totalDiscount': totalDiscount,
      'grandTotal': grandTotal,
      'createdBy': createdBy,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'billItems': billItems.map((e) => e.toJson()).toList(),
    };
  }
}