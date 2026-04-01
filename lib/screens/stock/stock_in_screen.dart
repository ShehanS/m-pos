import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/inventory/inventory_bloc.dart';
import '../../bloc/inventory/inventory_event.dart';
import '../../bloc/inventory/inventory_state.dart';
import '../../bloc/scanner/scanner_bloc.dart';
import '../../bloc/scanner/scanner_event.dart';
import '../../bloc/scanner/scanner_state.dart';
import '../../dtos/bill_item.dart';
import '../../entities/item_entity.dart';
import '../../entities/lot_entity.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/scanner.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  InventoryStatus? _lastStatus;
  bool _variantDialogShowing = false;

  @override
  void initState() {
    super.initState();
    context.read<InventoryBloc>().add(const LoadItems());
  }

  Future<T?> _showFullScreen<T>({
    required BuildContext context,
    required Widget child,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => child,
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<InventoryBloc>().state;
    final items = state.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock In'),
        actions: [
          TextButton(
            onPressed: () => _showAddItemDialog(context),
            child: const Text('Add Item'),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'add_stock',
            onPressed: items.isEmpty ? null : () => _showStockInDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Stock'),
          ),
        ],
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
          }
          if (state.status == InventoryStatus.loaded &&
              _lastStatus == InventoryStatus.loading &&
              state.lastOperation != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.lastOperation!),
                backgroundColor: Colors.green,
              ),
            );
          }
          if (state.status == InventoryStatus.loaded &&
              state.barcodeMatches.isNotEmpty &&
              state.pendingDispatch != null &&
              !_variantDialogShowing) {
            _variantDialogShowing = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _showVariantPickerDialog(
                context,
                matches: state.barcodeMatches,
                pending: state.pendingDispatch!,
              ).then((_) {
                _variantDialogShowing = false;
              });
            });
          }
          _lastStatus = state.status;
        },
        child: SafeArea(
          child: state.status == InventoryStatus.loading && items.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? _buildEmptyState(context)
                  : _buildItemList(context, state),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined,
                  size: 80, color: Colors.grey.withOpacity(0.5))
              .animate()
              .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
              .fadeIn(),
          const SizedBox(height: 16),
          Text('No items yet',
                  style: Theme.of(context).textTheme.headlineMedium)
              .animate()
              .fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Add an item to get started',
                  style: Theme.of(context).textTheme.bodyMedium)
              .animate()
              .fadeIn(delay: 300.ms),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context, InventoryState state) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<InventoryBloc>().add(const LoadItems());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Text(
                  item.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Unit: ${item.unit}'
                      '${item.variant != null ? ' • ${item.variant}' : ''}'
                      '${item.category != null ? ' • ${item.category}' : ''}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (item.barcode != null) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.qr_code, size: 12, color: Colors.grey),
                  ],
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${item.currentStock}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: item.currentStock > 0
                              ? AppTheme.primaryColor
                              : Colors.red,
                        ),
                      ),
                      Text(item.unit,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditItemDialog(context, item);
                      } else if (value == 'manage_stock') {
                        _showManageStockDialog(context, item);
                      } else if (value == 'delete') {
                        _confirmDelete(context, item);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Edit Item'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'manage_stock',
                        child: Row(
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 18),
                            SizedBox(width: 10),
                            Text('Manage Stock'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              onTap: () =>
                  _showStockInDialog(context, preSelectedItemId: item.itemId),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 80).ms)
              .slideX(begin: 0.1, end: 0, delay: (index * 80).ms);
        },
      ),
    );
  }

  void _showManageStockDialog(BuildContext context, ItemEntity item) {
    context.read<InventoryBloc>().add(LoadActiveLots(itemId: item.itemId));

    _showFullScreen(
      context: context,
      child: BlocBuilder<InventoryBloc, InventoryState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Stock Details: ${item.name}'),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: state.status == InventoryStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.activeLots.isEmpty
                    ? const Center(child: Text("No stock found."))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.activeLots.length,
                        itemBuilder: (ctx, index) {
                          final lot = state.activeLots[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text('Batch: ${lot.poNumber ?? "N/A"}'),
                              subtitle: Text(
                                'Cost: ${lot.unitPrice.toStringAsFixed(2)} | Sell: ${lot.sellingPrice.toStringAsFixed(2)}\nDiscount: ${lot.discount?.toStringAsFixed(2) ?? "0.00"} | Stock: ${lot.quantityRemaining}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_note_outlined,
                                    color: AppTheme.primaryColor),
                                onPressed: () =>
                                    _showEditStockForm(context, item, lot),
                              ),
                            ),
                          );
                        },
                      ),
          );
        },
      ),
    );
  }

  void _showEditStockForm(
      BuildContext context, ItemEntity item, LotEntity lot) {
    final unitPriceController =
        TextEditingController(text: lot.unitPrice.toString());
    final sellingPriceController =
        TextEditingController(text: lot.sellingPrice.toString());

    DiscountType discountType = DiscountType.percentage;

    double savedFlatDiscount = lot.discount ?? 0.0;
    double displayDiscount = 0.0;
    if (lot.sellingPrice > 0) {
      displayDiscount = (savedFlatDiscount / lot.sellingPrice) * 100;
    }

    final discountController = TextEditingController(
        text: displayDiscount == 0 ? '0' : displayDiscount.toStringAsFixed(2));

    final qtyController =
        TextEditingController(text: lot.quantityRemaining.toString());
    final notesController = TextEditingController(text: lot.notes ?? '');
    final formKey = GlobalKey<FormState>();

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final currentSellingPrice =
              double.tryParse(sellingPriceController.text) ?? 0;
          final inputDiscountValue =
              double.tryParse(discountController.text) ?? 0;

          final calculatedFlatDiscount = discountType == DiscountType.percentage
              ? currentSellingPrice * (inputDiscountValue / 100)
              : inputDiscountValue;

          final effectivePrice = currentSellingPrice - calculatedFlatDiscount;

          return _buildFormScaffold(
            title: 'Edit Stock Batch',
            dialogContext: ctx,
            actions: [
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final finalSellingPrice =
                      double.parse(sellingPriceController.text.trim());
                  final finalDiscountInput =
                      double.tryParse(discountController.text.trim()) ?? 0;

                  final flatDiscountToSave =
                      discountType == DiscountType.percentage
                          ? finalSellingPrice * (finalDiscountInput / 100)
                          : finalDiscountInput;

                  context.read<InventoryBloc>().add(
                        EditStock(
                          itemId: item.itemId,
                          lotId: lot.lotId,
                          unitPrice:
                              double.parse(unitPriceController.text.trim()),
                          sellingPrice: finalSellingPrice,
                          quantity: int.parse(qtyController.text.trim()),
                          discount: flatDiscountToSave <= 0
                              ? 0.00
                              : flatDiscountToSave,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        ),
                      );
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Update'),
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      controller: unitPriceController,
                      label: 'Unit Price (Cost) *',
                      prefixIcon: Icons.attach_money_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: sellingPriceController,
                      label: 'Selling Price *',
                      prefixIcon: Icons.sell_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onEditingComplete: () => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: discountController,
                            label: discountType == DiscountType.percentage
                                ? 'Discount %'
                                : 'Discount flat',
                            prefixIcon: Icons.discount_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onEditingComplete: () => setDialogState(() {}),
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
                                    onTap: () => setDialogState(
                                        () => discountType = DiscountType.flat),
                                  ),
                                  _buildDiscountTypeBtn(
                                    label: '%',
                                    selected:
                                        discountType == DiscountType.percentage,
                                    onTap: () => setDialogState(() =>
                                        discountType = DiscountType.percentage),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (currentSellingPrice > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Original Selling Price',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)),
                                Text(currentSellingPrice.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Discount Amount',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.orange)),
                                Text(
                                    '- ${calculatedFlatDiscount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.orange)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Effective Selling Price',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                Text(effectivePrice.toStringAsFixed(2),
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: qtyController,
                      label: 'Remaining Quantity *',
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: notesController,
                      label: 'Notes',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
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

  Widget _buildFormScaffold({
    required String title,
    required Widget body,
    required List<Widget> actions,
    BuildContext? dialogContext,
  }) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(dialogContext!),
        ),
        actions: actions
            .map((a) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: a,
                ))
            .toList(),
      ),
      body: SafeArea(child: body),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final unitController = TextEditingController();
    final variantController = TextEditingController();
    final categoryController = TextEditingController();
    final descController = TextEditingController();
    final barcodeController = TextEditingController();
    bool isScanningEnabled = true;
    final formKey = GlobalKey<FormState>();

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => _buildFormScaffold(
          title: 'Add New Item',
          dialogContext: ctx,
          actions: [
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<InventoryBloc>().add(
                      InventoryEvent.addItem(
                        item: ItemEntity(
                          itemId: '',
                          name: nameController.text.trim(),
                          unit: unitController.text.trim(),
                          isScanning: isScanningEnabled,
                          variant: variantController.text.trim().isEmpty
                              ? null
                              : variantController.text.trim(),
                          category: categoryController.text.trim().isEmpty
                              ? null
                              : categoryController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          barcode: barcodeController.text.trim().isEmpty
                              ? null
                              : barcodeController.text.trim(),
                        ),
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Item Name *',
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Enable Scanning"),
                    subtitle: const Text("Allow this item to be scanned"),
                    value: isScanningEnabled,
                    onChanged: (val) =>
                        setDialogState(() => isScanningEnabled = val),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: variantController,
                    label: 'Variant (e.g. 400g, 800g, Large)',
                    prefixIcon: Icons.tune_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: unitController,
                    label: 'Unit * (e.g. kg, pcs, L)',
                    prefixIcon: Icons.straighten_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: categoryController,
                    label: 'Category (optional)',
                    prefixIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descController,
                    label: 'Description (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: barcodeController,
                    label: 'Barcode / QR (optional) / ID',
                    prefixIcon: Icons.qr_code_outlined,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan barcode',
                      onPressed: () async {
                        Navigator.pop(ctx);
                        context.read<ScannerBloc>().add(const ScannerReset());
                        final scanned = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _BarcodeCaptureScreen(),
                          ),
                        );
                        if (context.mounted) {
                          _showAddItemDialogPrefilled(
                            context,
                            name: nameController.text,
                            variant: variantController.text,
                            unit: unitController.text,
                            category: categoryController.text,
                            desc: descController.text,
                            barcode: scanned ?? barcodeController.text,
                            isScanning: isScanningEnabled,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  void _showEditItemDialog(BuildContext context, ItemEntity item) {
    final nameController = TextEditingController(text: item.name);
    final unitController = TextEditingController(text: item.unit);
    final variantController = TextEditingController(text: item.variant ?? '');
    final categoryController = TextEditingController(text: item.category ?? '');
    final descController = TextEditingController(text: item.description ?? '');
    final barcodeController = TextEditingController(text: item.barcode ?? '');
    bool isScanningEnabled = item.isScanning ?? true;
    final formKey = GlobalKey<FormState>();

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => _buildFormScaffold(
          title: 'Edit Item',
          dialogContext: ctx,
          actions: [
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<InventoryBloc>().add(
                      InventoryEvent.editItem(
                        item: item.copyWith(
                          name: nameController.text.trim(),
                          unit: unitController.text.trim(),
                          isScanning: isScanningEnabled,
                          variant: variantController.text.trim().isEmpty
                              ? null
                              : variantController.text.trim(),
                          category: categoryController.text.trim().isEmpty
                              ? null
                              : categoryController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          barcode: barcodeController.text.trim().isEmpty
                              ? null
                              : barcodeController.text.trim(),
                        ),
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Update'),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Item Name *',
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Enable Scanning"),
                    subtitle: const Text("Allow this item to be scanned"),
                    value: isScanningEnabled,
                    onChanged: (val) =>
                        setDialogState(() => isScanningEnabled = val),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: variantController,
                    label: 'Variant (e.g. 400g, 800g, Large)',
                    prefixIcon: Icons.tune_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: unitController,
                    label: 'Unit * (e.g. kg, pcs, L)',
                    prefixIcon: Icons.straighten_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: categoryController,
                    label: 'Category (optional)',
                    prefixIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descController,
                    label: 'Description (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: barcodeController,
                    label: 'Barcode / QR (optional)',
                    prefixIcon: Icons.qr_code_outlined,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      tooltip: 'Scan barcode',
                      onPressed: () async {
                        Navigator.pop(ctx);
                        context.read<ScannerBloc>().add(const ScannerReset());
                        final scanned = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const _BarcodeCaptureScreen(),
                          ),
                        );
                        if (scanned != null &&
                            scanned.isNotEmpty &&
                            context.mounted) {
                          barcodeController.text = scanned;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddItemDialogPrefilled(BuildContext context,
      {String name = '',
      String variant = '',
      String unit = '',
      String category = '',
      String desc = '',
      String barcode = '',
      required bool isScanning}) {
    final nameController = TextEditingController(text: name);
    final variantController = TextEditingController(text: variant);
    final unitController = TextEditingController(text: unit);
    final categoryController = TextEditingController(text: category);
    final descController = TextEditingController(text: desc);
    final barcodeController = TextEditingController(text: barcode);
    bool isScanningEnabled = isScanning;
    final formKey = GlobalKey<FormState>();

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) => _buildFormScaffold(
          title: 'Add New Item',
          dialogContext: ctx,
          actions: [
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context.read<InventoryBloc>().add(
                      InventoryEvent.addItem(
                        item: ItemEntity(
                          itemId: '',
                          name: nameController.text.trim(),
                          unit: unitController.text.trim(),
                          isScanning: isScanningEnabled,
                          variant: variantController.text.trim().isEmpty
                              ? null
                              : variantController.text.trim(),
                          category: categoryController.text.trim().isEmpty
                              ? null
                              : categoryController.text.trim(),
                          description: descController.text.trim().isEmpty
                              ? null
                              : descController.text.trim(),
                          barcode: barcodeController.text.trim().isEmpty
                              ? null
                              : barcodeController.text.trim(),
                        ),
                      ),
                    );
                Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  CustomTextField(
                    controller: nameController,
                    label: 'Item Name *',
                    prefixIcon: Icons.inventory_2_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text("Enable Scanning"),
                    subtitle: const Text("Allow this item to be scanned"),
                    value: isScanningEnabled,
                    onChanged: (val) =>
                        setDialogState(() => isScanningEnabled = val),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: variantController,
                    label: 'Variant (e.g. 400g, 800g, Large)',
                    prefixIcon: Icons.tune_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: unitController,
                    label: 'Unit * (e.g. kg, pcs, L)',
                    prefixIcon: Icons.straighten_outlined,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: categoryController,
                    label: 'Category (optional)',
                    prefixIcon: Icons.category_outlined,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: descController,
                    label: 'Description (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: barcodeController,
                    label: 'Barcode / QR',
                    prefixIcon: Icons.qr_code_outlined,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showStockInDialog(BuildContext context, {String? preSelectedItemId}) {
    final poController = TextEditingController();
    final unitPriceController = TextEditingController();
    final sellingPriceController = TextEditingController();

    DiscountType discountType = DiscountType.percentage;
    final discountController = TextEditingController(text: '0');

    final qtyController = TextEditingController();
    final notesController = TextEditingController();
    final dateController =
        TextEditingController(text: DateFormat.yMMMd().format(DateTime.now()));
    final formKey = GlobalKey<FormState>();
    final items = context.read<InventoryBloc>().state.items;
    final user = context.read<AuthBloc>().state.user;

    String? selectedItemId =
        preSelectedItemId ?? (items.isNotEmpty ? items.first.itemId : null);
    DateTime selectedDate = DateTime.now();

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, setDialogState) {
          final sellingPrice =
              double.tryParse(sellingPriceController.text) ?? 0;
          final discountInput = double.tryParse(discountController.text) ?? 0;
          final calculatedFlatDiscount = discountType == DiscountType.percentage
              ? sellingPrice * (discountInput / 100)
              : discountInput;
          final effectivePrice = sellingPrice - calculatedFlatDiscount;

          return _buildFormScaffold(
            title: 'Add New Stock Batch',
            dialogContext: ctx,
            actions: [
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;
                  final finalSellingPrice =
                      double.parse(sellingPriceController.text.trim());
                  final finalDiscountValue =
                      double.tryParse(discountController.text.trim()) ?? 0;
                  final flatDiscountToSave =
                      discountType == DiscountType.percentage
                          ? finalSellingPrice * (finalDiscountValue / 100)
                          : finalDiscountValue;

                  context.read<InventoryBloc>().add(
                        AddStock(
                          itemId: selectedItemId!,
                          poNumber: poController.text.trim(),
                          unitPrice:
                              double.parse(unitPriceController.text.trim()),
                          sellingPrice: finalSellingPrice,
                          quantity: int.parse(qtyController.text.trim()),
                          receivedDate: selectedDate,
                          createdBy: user?.uid ?? '',
                          discount: flatDiscountToSave <= 0
                              ? 0.00
                              : flatDiscountToSave,
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        ),
                      );
                  Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomDropdown<String>(
                      value: selectedItemId,
                      label: 'Item *',
                      prefixIcon: Icons.inventory_2_outlined,
                      items: items
                          .map((item) => DropdownMenuItem(
                                value: item.itemId,
                                child: Text(
                                  item.variant != null
                                      ? '${item.name} — ${item.variant}'
                                      : item.name,
                                ),
                              ))
                          .toList(),
                      onChanged: (val) =>
                          setDialogState(() => selectedItemId = val),
                      validator: (v) =>
                          v == null ? 'Please select an item' : null,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: poController,
                      label: 'Batch / PO Number',
                      prefixIcon: Icons.receipt_long_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: unitPriceController,
                      label: 'Unit Price (Cost) *',
                      prefixIcon: Icons.attach_money_outlined,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid price';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                      onEditingComplete: () => setDialogState(() {}),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CustomTextField(
                            controller: discountController,
                            label: discountType == DiscountType.percentage
                                ? 'Discount %'
                                : 'Discount flat',
                            prefixIcon: Icons.discount_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            onEditingComplete: () => setDialogState(() {}),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          children: [
                            const Text(
                              'Type',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.grey),
                            ),
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
                                    onTap: () => setDialogState(
                                        () => discountType = DiscountType.flat),
                                  ),
                                  _buildDiscountTypeBtn(
                                    label: '%',
                                    selected:
                                        discountType == DiscountType.percentage,
                                    onTap: () => setDialogState(() =>
                                        discountType = DiscountType.percentage),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (sellingPrice > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: AppTheme.primaryColor.withOpacity(0.15)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Base Selling Price',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.grey)),
                                Text(sellingPrice.toStringAsFixed(2),
                                    style: const TextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Discount Amount',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.orange)),
                                Text(
                                    '- ${calculatedFlatDiscount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontSize: 13, color: Colors.orange)),
                              ],
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Net Price',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  effectivePrice.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 16,
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
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: qtyController,
                      label: 'Quantity *',
                      prefixIcon: Icons.numbers_outlined,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final qty = int.tryParse(v);
                        if (qty == null || qty <= 0) {
                          return 'Must be greater than 0';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                            dateController.text =
                                DateFormat.yMMMd().format(picked);
                          });
                        }
                      },
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: dateController,
                          label: 'Received Date',
                          prefixIcon: Icons.calendar_today_outlined,
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: notesController,
                      label: 'Notes (optional)',
                      prefixIcon: Icons.notes_outlined,
                      maxLines: 3,
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

  void _showScanDispatchDialog(BuildContext context) {
    final qtyController = TextEditingController(text: '1');
    final notesController = TextEditingController();
    final dispatchedToController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final user = context.read<AuthBloc>().state.user;

    _showFullScreen(
      context: context,
      child: StatefulBuilder(
        builder: (ctx, _) => _buildFormScaffold(
          title: 'Dispatch by Scan',
          dialogContext: ctx,
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.qr_code_scanner, size: 18),
              label: const Text('Scan & Dispatch'),
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                context.read<ScannerBloc>().add(const ScannerReset());
                final scanned = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _BarcodeCaptureScreen(),
                  ),
                );
                if (scanned != null && scanned.isNotEmpty && context.mounted) {
                  context.read<InventoryBloc>().add(
                        DispatchByBarcode(
                          barcode: scanned,
                          quantity: int.parse(qtyController.text.trim()),
                          createdBy: user?.uid ?? '',
                          dispatchedTo:
                              dispatchedToController.text.trim().isEmpty
                                  ? null
                                  : dispatchedToController.text.trim(),
                          notes: notesController.text.trim().isEmpty
                              ? null
                              : notesController.text.trim(),
                        ),
                      );
                }
              },
            ),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.orange, size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Scan barcode then confirm the quantity to dispatch.',
                            style:
                                TextStyle(fontSize: 13, color: Colors.orange),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    controller: qtyController,
                    label: 'Quantity *',
                    prefixIcon: Icons.numbers_outlined,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      final qty = int.tryParse(v);
                      if (qty == null || qty <= 0) {
                        return 'Must be greater than 0';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: dispatchedToController,
                    label: 'Dispatched To (optional)',
                    prefixIcon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: notesController,
                    label: 'Notes (optional)',
                    prefixIcon: Icons.notes_outlined,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showVariantPickerDialog(
    BuildContext context, {
    required List<ItemEntity> matches,
    required PendingDispatch pending,
  }) {
    return _showFullScreen<void>(
      context: context,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Select Variant'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              Navigator.pop(context);
              context.read<InventoryBloc>().add(const ClearPendingDispatch());
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: AppTheme.primaryColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Multiple variants found. Select one to dispatch ${pending.quantity} unit(s) from:',
                        style: const TextStyle(
                            fontSize: 13, color: AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: matches
                      .map(
                        (item) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppTheme.primaryColor.withOpacity(0.1),
                              child: Text(
                                item.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                color: item.currentStock >= pending.quantity
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            trailing: item.currentStock >= pending.quantity
                                ? const Icon(Icons.check_circle_outline,
                                    color: Colors.green)
                                : const Icon(Icons.warning_amber_outlined,
                                    color: Colors.orange),
                            onTap: item.currentStock < pending.quantity
                                ? null
                                : () {
                                    Navigator.pop(context);
                                    context.read<InventoryBloc>().add(
                                          DispatchByItem(
                                            itemId: item.itemId,
                                            quantity: pending.quantity,
                                            createdBy: pending.createdBy,
                                            dispatchedTo: pending.dispatchedTo,
                                            notes: pending.notes,
                                          ),
                                        );
                                  },
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ItemEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              context
                  .read<InventoryBloc>()
                  .add(DeleteItem(itemId: item.itemId));
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
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
