
import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';

enum DiscountType { flat, percentage }

class BillItem {
  final ItemEntity item;
  final List<LotEntity> lots;
  double quantity;
  double sellingPrice;
  double discount;
  DiscountType discountType;

  BillItem({
    required this.item,
    required this.lots,
    required this.quantity,
    required this.sellingPrice,
    this.discount = 0,
    this.discountType = DiscountType.flat,
  });

  double get subtotal => quantity * sellingPrice;

  double get discountAmount {
    if (discount <= 0) return 0;
    if (discountType == DiscountType.percentage) {
      return subtotal * (discount / 100);
    }
    return discount;
  }

  double get total => subtotal - discountAmount;

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
    item: ItemEntity.fromJson(json['item'] as Map<String, dynamic>),
    lots: (json['lots'] as List<dynamic>)
        .map((e) => LotEntity.fromJson(e as Map<String, dynamic>))
        .toList(),
    quantity: (json['quantity'] as num).toDouble(),
    sellingPrice: (json['sellingPrice'] as num).toDouble(),
    discount: (json['discount'] as num).toDouble(),
    discountType: DiscountType.values.firstWhere(
            (e) => e.name == json['discountType'],
        orElse: () => DiscountType.flat),
  );

  Map<String, dynamic> toJson() => {
    'item': item.toJson(),
    'lots': lots.map((e) => e.toJson()).toList(),
    'quantity': quantity,
    'sellingPrice': sellingPrice,
    'discount': discount,
    'discountType': discountType.name,
  };
}