import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/blocs.dart';
import 'package:flutter_bloc_app/widgets/print_template.dart';

import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/scanner/scanner_bloc.dart';
import '../../bloc/scanner/scanner_event.dart';
import '../../bloc/scanner/scanner_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../dtos/bill_item.dart';
import '../../dtos/business.dart';
import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scanner.dart';

class ScanDispatchScreen extends StatefulWidget {
  const ScanDispatchScreen({super.key});

  @override
  State<ScanDispatchScreen> createState() => _ScanDispatchScreenState();
}

class _ScanDispatchScreenState extends State<ScanDispatchScreen> {
  final List<BillItem> _billItems = [];
  final _dispatchedToController = TextEditingController();
  final _notesController = TextEditingController();

  bool _variantPickerShowing = false;
  bool _itemDetailShowing = false;
  bool _isScanning = false;
  InventoryStatus? _lastStatus;
  Business? _selectedBusiness;

  List<ItemEntity> _pendingMatches = [];
  List<LotEntity> _pendingLots = [];
  ItemEntity? _pendingItem;

  @override
  void dispose() {
    _dispatchedToController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _grandTotal => _billItems.fold(0.0, (sum, i) => sum + i.total);

  double get _totalDiscount =>
      _billItems.fold(0.0, (sum, i) => sum + i.discountAmount);

  double get _subtotalBeforeDiscount =>
      _billItems.fold(0.0, (sum, i) => sum + i.subtotal);

  void _startScan(BuildContext context) {
    if (_isScanning) return;
    setState(() => _isScanning = true);
    context.read<ScannerBloc>().add(const ScannerReset());
    Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _BarcodeCaptureScreen()),
    ).then((scanned) {
      setState(() => _isScanning = false);
      if (scanned != null && scanned.isNotEmpty && mounted) {
        context.read<InventoryBloc>().add(ScanItemForBill(barcode: scanned));
      }
    });
  }

  void _continueScan(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startScan(context);
    });
  }

  void _autoAddToBill(
      BuildContext context, ItemEntity item, List<LotEntity> lots) {
    setState(() {
      final existingIndex =
      _billItems.indexWhere((b) => b.item.itemId == item.itemId);
      if (existingIndex >= 0) {
        _billItems[existingIndex].quantity += 1;
      } else {
        final defaultLot = lots.isNotEmpty ? lots.first : null;
        double displayDisc = 0;
        if (defaultLot != null && defaultLot.sellingPrice > 0) {
          displayDisc = ((defaultLot.discount ?? 0) / defaultLot.sellingPrice) * 100;
        }
        _billItems.add(BillItem(
          item: item,
          lots: lots,
          quantity: 1,
          sellingPrice: defaultLot?.sellingPrice ?? 0,
          discount: displayDisc,
          discountType: DiscountType.percentage,
        ));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              item.variant != null
                  ? '${item.name} — ${item.variant} added'
                  : '${item.name} added',
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserBloc>().state.user;
    _selectedBusiness = user?.business?.firstWhere(
            (b) => b.businessName == user.activeBusiness,
        orElse: () => user.business!.first);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Bill'),
        actions: [
          if (_billItems.isNotEmpty) ...[
            TextButton.icon(
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit'),
              onPressed: () => _showEditBillSheet(context),
            ),
            TextButton.icon(
              icon: const Icon(Icons.receipt_long_outlined, size: 18),
              label: const Text('Confirm'),
              onPressed: () {
                if (_billItems.isNotEmpty && context.mounted) {
                  for (final billItem in _billItems) {
                    context.read<InventoryBloc>().add(Dispatch(
                        itemId: billItem.item.itemId,
                        quantity: billItem.quantity,
                        createdBy: user!.email));
                  }
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return BlocProvider.value(
                        value: (context).read<MasterDataBloc>(),
                        child: Dialog(
                          insetPadding: EdgeInsets.zero,
                          child: SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: PrintTemplate(billItems: _billItems),
                          ),
                        ));
                  },
                );
              },
            ),
          ],
          _buildBusinessAppBarButton(),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          width: double.infinity,
          child: FloatingActionButton.extended(
            onPressed: _isScanning || _selectedBusiness == null
                ? null
                : () => _startScan(context),
            icon: _isScanning
                ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.qr_code_scanner, color: Colors.white),
            label: Text(_isScanning ? 'Scanning...' : 'Scan Item', style: const TextStyle(color: Colors.white)),
            backgroundColor: _isScanning ? Colors.grey : Colors.deepPurpleAccent,
          ),
        ),
      ),
      body: BlocListener<InventoryBloc, InventoryState>(
        listener: (context, state) {
          if (state.status == InventoryStatus.error &&
              _lastStatus != InventoryStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
            _continueScan(context);
          }

          if (state.status == InventoryStatus.loaded &&
              state.barcodeMatches.isNotEmpty &&
              !_variantPickerShowing &&
              !_itemDetailShowing) {
            if (state.barcodeMatches.length == 1) {
              _pendingItem = state.barcodeMatches.first;
              _itemDetailShowing = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                context.read<InventoryBloc>().add(
                  LoadLotsForItem(itemId: _pendingItem!.itemId),
                );
              });
            } else {
              _pendingMatches = state.barcodeMatches;
              _variantPickerShowing = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _showVariantPicker(context, _pendingMatches).then((_) {
                  _variantPickerShowing = false;
                  if (!_itemDetailShowing) {
                    context
                        .read<InventoryBloc>()
                        .add(const ClearPendingDispatch());
                    _continueScan(context);
                  }
                });
              });
            }
          }

          if (state.status == InventoryStatus.loaded &&
              state.scannedItemLots.isNotEmpty &&
              _itemDetailShowing &&
              _pendingItem != null) {
            _pendingLots = state.scannedItemLots;
            final item = _pendingItem!;
            final lots = _pendingLots;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;

              // AUTO ADD ALWAYS - Bypasses popup detail sheet for continuous scanning
              _autoAddToBill(context, item, lots);
              _itemDetailShowing = false;
              _pendingItem = null;
              context.read<InventoryBloc>().add(const ClearPendingDispatch());
              _continueScan(context);
            });
          }

          _lastStatus = state.status;
        },
        child: SafeArea(
          child: _billItems.isEmpty
              ? _buildEmptyBill(context)
              : _buildBillList(context),
        ),
      ),
    );
  }

  Widget _buildEmptyBill(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 80, color: Colors.grey.withOpacity(0.4))
              .animate()
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 16),
          Text('No items scanned yet',
              style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Tap "Scan Item" to start',
              style: Theme.of(context).textTheme.bodyMedium)
              .animate()
              .fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildBillList(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: _billItems.length,
            itemBuilder: (context, index) {
              final b = _billItems[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                            AppTheme.primaryColor.withOpacity(0.1),
                            child: Text(
                              b.item.name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.item.variant != null
                                      ? '${b.item.name} — ${b.item.variant}'
                                      : b.item.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                Text(
                                  '${b.item.unit} · Stock: ${b.item.currentStock}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red, size: 20),
                            onPressed: () =>
                                setState(() => _billItems.removeAt(index)),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          _buildInfoChip('Qty', '${b.quantity}'),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                              'Price', b.sellingPrice.toStringAsFixed(2)),
                          const SizedBox(width: 8),
                          if (b.discount > 0)
                            _buildInfoChip(
                              b.discountType == DiscountType.percentage
                                  ? 'Disc ${b.discount.toStringAsFixed(0)}%'
                                  : 'Disc',
                              b.discountType == DiscountType.percentage
                                  ? b.discountAmount.toStringAsFixed(2)
                                  : b.discount.toStringAsFixed(2),
                              color: Colors.orange,
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border:
                          Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${b.quantity} × ${b.sellingPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                                Text(b.subtotal.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            if (b.discount > 0) ...[
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    b.discountType == DiscountType.percentage
                                        ? 'Discount (${b.discount.toStringAsFixed(0)}%)'
                                        : 'Discount (flat)',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.orange),
                                  ),
                                  Text(
                                    '- ${b.discountAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Item Total',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                Text(
                                  b.total.toStringAsFixed(2),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (index * 60).ms);
            },
          ),
        ),
        _buildBillSummary(context),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? AppTheme.primaryColor).withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 12,
          color: color ?? AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBillSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              Text(
                _subtotalBeforeDiscount.toStringAsFixed(2),
                style:
                const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              ),
            ],
          ),
          if (_totalDiscount > 0) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Discount',
                    style: TextStyle(color: Colors.orange, fontSize: 14)),
                Text(
                  '- ${_totalDiscount.toStringAsFixed(2)}',
                  style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.w500,
                      fontSize: 14),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Grand Total',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                _grandTotal.toStringAsFixed(2),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showVariantPicker(
      BuildContext context, List<ItemEntity> matches) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Select Variant',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Multiple variants found. Select the correct one.',
                style: TextStyle(fontSize: 13, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: matches
                    .map((item) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                      AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        item.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      item.variant != null
                          ? '${item.name} — ${item.variant}'
                          : item.name,
                      style:
                      const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Stock: ${item.currentStock} ${item.unit}',
                      style: TextStyle(
                        fontSize: 12,
                        color: item.currentStock > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                    trailing: item.currentStock > 0
                        ? const Icon(Icons.arrow_forward_ios, size: 16)
                        : const Icon(Icons.warning_amber_outlined,
                        color: Colors.orange),
                    onTap: item.currentStock <= 0
                        ? null
                        : () {
                      Navigator.pop(ctx);
                      _pendingItem = item;
                      _itemDetailShowing = true;
                      context.read<InventoryBloc>().add(
                        LoadLotsForItem(itemId: item.itemId),
                      );
                    },
                  ),
                ))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemDetailSheet(
      BuildContext context,
      ItemEntity item,
      List<LotEntity> lots,
      ) {
    final defaultLot = lots.isNotEmpty ? lots.first : null;

    final sellingPriceController = TextEditingController(
      text: defaultLot?.sellingPrice.toStringAsFixed(2) ?? '',
    );

    double displayDisc = 0;
    if (defaultLot != null && defaultLot.sellingPrice > 0) {
      displayDisc = ((defaultLot.discount ?? 0) / defaultLot.sellingPrice) * 100;
    }

    final discountController = TextEditingController(
      text: displayDisc > 0 ? displayDisc.toStringAsFixed(2) : '0',
    );

    final qtyController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    double sellingPrice = defaultLot?.sellingPrice ?? 0;
    double discount = displayDisc;
    int qty = 1;
    DiscountType discountType = DiscountType.percentage;
    LotEntity? selectedLot = defaultLot;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          double subtotal = qty * sellingPrice;
          double discountAmount = discountType == DiscountType.percentage
              ? subtotal * (discount / 100)
              : discount;
          double total = subtotal - discountAmount;

          return Padding(
            padding:
            EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.85,
              minChildSize: 0.6,
              maxChildSize: 0.95,
              builder: (_, scrollController) => Form(
                key: formKey,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                          AppTheme.primaryColor.withOpacity(0.1),
                          child: Text(
                            item.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.variant != null
                                    ? '${item.name} — ${item.variant}'
                                    : item.name,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Available: ${item.currentStock} ${item.unit}',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (lots.isNotEmpty) ...[
                      const Text(
                        'Active lots — tap to use pricing',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ...lots.map((lot) {
                        final isSelected = selectedLot?.lotId == lot.lotId;
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedLot = lot;
                              sellingPrice = lot.sellingPrice;
                              double calculatedDisc = 0;
                              if (lot.sellingPrice > 0) {
                                calculatedDisc = ((lot.discount ?? 0) / lot.sellingPrice) * 100;
                              }
                              discount = calculatedDisc;
                              discountType = DiscountType.percentage;
                              sellingPriceController.text =
                                  lot.sellingPrice.toStringAsFixed(2);
                              discountController.text =
                                  calculatedDisc.toStringAsFixed(2);
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : AppTheme.primaryColor.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? AppTheme.primaryColor
                                    : AppTheme.primaryColor.withOpacity(0.15),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  size: 18,
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        lot.poNumber.isNotEmpty
                                            ? 'PO: ${lot.poNumber}'
                                            : 'Lot ${lot.lotId.substring(0, 6)}',
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        '${lot.quantityRemaining} ${item.unit} available',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Cost: ${lot.unitPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 11, color: Colors.grey),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Sell: ${lot.sellingPrice.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    if (lot.discount != null &&
                                        lot.discount! > 0)
                                      Text(
                                        'Disc: -${lot.discount!.toStringAsFixed(2)}  →  ${lot.effectiveSellingPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.orange),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                    const Divider(),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: qtyController,
                      label: 'Quantity *',
                      prefixIcon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final q = int.tryParse(v);
                        if (q == null || q <= 0)
                          return 'Must be greater than 0';
                        if (q > item.currentStock) {
                          return 'Exceeds stock (${item.currentStock})';
                        }
                        return null;
                      },
                      onEditingComplete: () => setSheetState(() {
                        qty = int.tryParse(qtyController.text) ?? 1;
                      }),
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: sellingPriceController,
                      label: 'Selling Price *',
                      prefixIcon: Icons.sell_outlined,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid price';
                        return null;
                      },
                      onEditingComplete: () => setSheetState(() {
                        sellingPrice =
                            double.tryParse(sellingPriceController.text) ?? 0;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: discountController,
                            label: discountType == DiscountType.percentage
                                ? 'Discount %'
                                : 'Discount (flat)',
                            prefixIcon: Icons.discount_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final d = double.tryParse(v);
                              if (d == null) return 'Invalid value';
                              if (discountType == DiscountType.percentage &&
                                  d > 100) return 'Max 100%';
                              return null;
                            },
                            onEditingComplete: () => setSheetState(() {
                              discount =
                                  double.tryParse(discountController.text) ?? 0;
                            }),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text('Type',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                    AppTheme.primaryColor.withOpacity(0.3)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildDiscountTypeBtn(
                                    label: 'Flat',
                                    selected: discountType == DiscountType.flat,
                                    onTap: () => setSheetState(() {
                                      discountType = DiscountType.flat;
                                      discount = double.tryParse(
                                          discountController.text) ??
                                          0;
                                    }),
                                  ),
                                  _buildDiscountTypeBtn(
                                    label: '%',
                                    selected:
                                    discountType == DiscountType.percentage,
                                    onTap: () => setSheetState(() {
                                      discountType = DiscountType.percentage;
                                      discount = double.tryParse(
                                          discountController.text) ??
                                          0;
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.15)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$qty × ${sellingPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 14),
                              ),
                              Text(subtotal.toStringAsFixed(2),
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          if (discount > 0) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  discountType == DiscountType.percentage
                                      ? 'Discount (${discount.toStringAsFixed(2)}% of ${subtotal.toStringAsFixed(2)})'
                                      : 'Discount (flat)',
                                  style: const TextStyle(
                                      color: Colors.orange, fontSize: 13),
                                ),
                                Text(
                                  '- ${discountAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      color: Colors.orange,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Text(
                                total.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Skip'),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add_shopping_cart_outlined),
                            label: const Text('Add to Bill'),
                            onPressed: () {
                              if (!formKey.currentState!.validate()) return;
                              final finalQty =
                                  int.tryParse(qtyController.text) ?? 1;
                              final finalPrice = double.tryParse(
                                  sellingPriceController.text) ??
                                  0;
                              final finalDiscount =
                                  double.tryParse(discountController.text) ?? 0;

                              setState(() {
                                final existingIndex = _billItems.indexWhere(
                                        (b) => b.item.itemId == item.itemId);
                                if (existingIndex >= 0) {
                                  _billItems[existingIndex].quantity +=
                                      finalQty;
                                  _billItems[existingIndex].sellingPrice =
                                      finalPrice;
                                  _billItems[existingIndex].discount =
                                      finalDiscount;
                                  _billItems[existingIndex].discountType =
                                      discountType;
                                } else {
                                  _billItems.add(BillItem(
                                    item: item,
                                    lots: lots,
                                    quantity: finalQty,
                                    sellingPrice: finalPrice,
                                    discount: finalDiscount,
                                    discountType: discountType,
                                  ));
                                }
                              });
                              Navigator.pop(ctx);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDiscountTypeBtn({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessAppBarButton() {
    return TextButton.icon(
      onPressed: () => _showBusinessPickerDialog(context),
      icon: const Icon(Icons.store_outlined, size: 18, color: Colors.deepPurpleAccent),
      label:Text(
        _selectedBusiness?.businessName ?? 'Select Business',
        style: const TextStyle(
          color: Colors.deepPurpleAccent,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  void _showBusinessPickerDialog(BuildContext context) {
    final businesses = context.read<UserBloc>().state.user?.business ?? [];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.store_outlined),
            SizedBox(width: 8),
            Text('Select Business'),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        content: SizedBox(
          width: double.maxFinite,
          child: businesses.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.business_center_outlined,
                    size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No businesses found.\nAdd one in Settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            shrinkWrap: true,
            itemCount: businesses.length,
            itemBuilder: (_, index) {
              final b = businesses[index];
              final isSelected = _selectedBusiness?.uid == b.uid;
              return ListTile(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                tileColor: isSelected
                    ? AppTheme.primaryColor.withOpacity(0.08)
                    : null,
                leading: b.logoUrl != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    b.logoUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const CircleAvatar(
                      child: Icon(Icons.business, size: 20),
                    ),
                  ),
                )
                    : CircleAvatar(
                  backgroundColor:
                  AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    b.businessName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  b.businessName,
                  style: TextStyle(
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryColor : null,
                  ),
                ),
                subtitle: b.address != null
                    ? Text(
                  b.address!,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
                    : null,
                trailing: isSelected
                    ? const Icon(Icons.check_circle,
                    color: AppTheme.primaryColor)
                    : null,
                onTap: () {
                  final currentUser = context.read<UserBloc>().state.user;
                  if (currentUser == null) return;
                  setState(() => _selectedBusiness = b);
                  context.read<UserBloc>().add(
                    UpdateUser(
                      uid: currentUser.uid,
                      user: currentUser.copyWith(
                          activeBusiness: b.businessName),
                    ),
                  );
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditBillSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, scrollController) => Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Edit Bill',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _billItems.length,
                  itemBuilder: (_, index) {
                    final b = _billItems[index];
                    final qtyCtrl =
                    TextEditingController(text: '${b.quantity}');
                    final priceCtrl = TextEditingController(
                        text: b.sellingPrice.toStringAsFixed(2));
                    final discCtrl = TextEditingController(
                        text: b.discount.toStringAsFixed(2));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    b.item.variant != null
                                        ? '${b.item.name} — ${b.item.variant}'
                                        : b.item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 18),
                                  onPressed: () {
                                    setState(() => _billItems.removeAt(index));
                                    setSheetState(() {});
                                    if (_billItems.isEmpty) {
                                      Navigator.pop(ctx);
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: qtyCtrl,
                                    label: 'Qty',
                                    prefixIcon: Icons.numbers_outlined,
                                    keyboardType: TextInputType.number,
                                    onEditingComplete: () {
                                      setState(() {
                                        _billItems[index].quantity =
                                            int.tryParse(qtyCtrl.text) ??
                                                b.quantity;
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: CustomTextField(
                                    controller: priceCtrl,
                                    label: 'Price',
                                    prefixIcon: Icons.attach_money_outlined,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    onEditingComplete: () {
                                      setState(() {
                                        _billItems[index].sellingPrice =
                                            double.tryParse(priceCtrl.text) ??
                                                b.sellingPrice;
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomTextField(
                                    controller: discCtrl,
                                    label: b.discountType ==
                                        DiscountType.percentage
                                        ? 'Disc %'
                                        : 'Disc (flat)',
                                    prefixIcon: Icons.discount_outlined,
                                    keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                    onEditingComplete: () {
                                      setState(() {
                                        _billItems[index].discount =
                                            double.tryParse(discCtrl.text) ??
                                                b.discount;
                                      });
                                      setSheetState(() {});
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    const Text('Type',
                                        style: TextStyle(
                                            fontSize: 11, color: Colors.grey)),
                                    const SizedBox(height: 4),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppTheme.primaryColor
                                                .withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildDiscountTypeBtn(
                                            label: 'Flat',
                                            selected: b.discountType ==
                                                DiscountType.flat,
                                            onTap: () {
                                              setState(() {
                                                _billItems[index].discountType =
                                                    DiscountType.flat;
                                              });
                                              setSheetState(() {});
                                            },
                                          ),
                                          _buildDiscountTypeBtn(
                                            label: '%',
                                            selected: b.discountType ==
                                                DiscountType.percentage,
                                            onTap: () {
                                              setState(() {
                                                _billItems[index].discountType =
                                                    DiscountType.percentage;
                                              });
                                              setSheetState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${b.quantity} × ${b.sellingPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        b.subtotal.toStringAsFixed(2),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  if (b.discount > 0) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          b.discountType ==
                                              DiscountType.percentage
                                              ? 'Discount (${b.discount.toStringAsFixed(2)}%)'
                                              : 'Discount (flat)',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange),
                                        ),
                                        Text(
                                          '- ${b.discountAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.orange),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 4),
                                    child: Divider(height: 1),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Line total',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600)),
                                      Text(
                                        b.total.toStringAsFixed(2),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarcodeCaptureScreen extends StatelessWidget {
  const _BarcodeCaptureScreen();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state.status == ScannerStatus.loaded && state.code != null) {
          Navigator.of(context).pop(state.code);
        }
      },
      child: const ScannerDialog(),
    );
  }
}