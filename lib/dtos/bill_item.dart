import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';

class BillItem {
  final ItemEntity item;
  final List<LotEntity> lots;
  int quantity;
  double sellingPrice;
  double discount;

  BillItem({
    required this.item,
    required this.lots,
    required this.quantity,
    required this.sellingPrice,
    this.discount = 0,
  });

  double get unitCost {
    if (lots.isEmpty) return 0;
    double total = 0;
    int remaining = quantity;
    for (final lot in lots) {
      if (remaining <= 0) break;
      final take = remaining <= lot.quantityRemaining
          ? remaining
          : lot.quantityRemaining;
      total += take * lot.unitPrice;
      remaining -= take;
    }
    return total;
  }

  double get subtotal => quantity * sellingPrice;
  double get discountAmount => discount;
  double get total => subtotal - discountAmount;
}