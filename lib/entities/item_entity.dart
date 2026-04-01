import 'package:freezed_annotation/freezed_annotation.dart';

part 'item_entity.freezed.dart';
part 'item_entity.g.dart';

@freezed
class ItemEntity with _$ItemEntity {
  const ItemEntity._();

  const factory ItemEntity({
    required String itemId,
    required String name,
    required String unit,
    String? category,
    String? description,
    String? barcode,
    @Default(0) int currentStock,
    DateTime? createdAt,
    String? createdBy,
    String? variant,
    @Default(true) bool ? isScanning,
  }) = _ItemEntity;

  factory ItemEntity.fromFirestore(String id, Map<String, dynamic> data) {
    return ItemEntity(
      itemId: id,
      isScanning: data['isScanning'] as bool,
      name: data['name'] as String? ?? '',
      unit: data['unit'] as String? ?? '',
      category: data['category'] as String?,
      description: data['description'] as String?,
      barcode: data['barcode'] as String?,
      variant: data['variant'] as String?,
      currentStock: data['currentStock'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : null,
      createdBy: data['createdBy'] as String?,
    );
  }

  factory ItemEntity.fromJson(Map<String, dynamic> json) =>
      _$ItemEntityFromJson(json);

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unit': unit,
      'currentStock': currentStock,
      'isScanning': isScanning,
      if (variant != null) 'variant': variant,
      if (category != null) 'category': category,
      if (description != null) 'description': description,
      if (barcode != null) 'barcode': barcode,
      if (createdAt != null) 'createdAt': createdAt,
      if (createdBy != null) 'createdBy': createdBy,
    };
  }
}