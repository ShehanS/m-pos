import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';

enum DiscountType { flat, percentage }

class BillItem {
  final ItemEntity item;
  final List<LotEntity> lots;
  int quantity;
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

  double get flatDiscountValue =>
      discountType == DiscountType.percentage
          ? subtotal * (discount / 100)
          : discount;
}