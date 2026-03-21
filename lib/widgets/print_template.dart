import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/blocs.dart';
import 'package:flutter_bloc_app/bloc/printer/printer_bloc.dart';
import 'package:flutter_bloc_app/bloc/user/user_bloc.dart';
import 'package:flutter_bloc_app/dtos/bill_item.dart';
import 'package:flutter_bloc_app/entities/user_entity.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/scanner/scanner_bloc.dart';

class PrintTemplate extends StatefulWidget {
  final List<BillItem> billItems;
  final String? dispatchedTo;
  final String? notes;

  const PrintTemplate({
    super.key,
    required this.billItems,
    this.dispatchedTo,
    this.notes,
  });

  @override
  State<PrintTemplate> createState() => _PrintTemplateState();
}

class _PrintTemplateState extends State<PrintTemplate> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isPrinting = false;
  bool _logoLoaded = false;
  String? _logoUrl;

  double get _subtotal =>
      widget.billItems.fold(0.0, (sum, i) => sum + i.subtotal);

  double get _totalDiscount =>
      widget.billItems.fold(0.0, (sum, i) => sum + i.discountAmount);

  double get _grandTotal =>
      widget.billItems.fold(0.0, (sum, i) => sum + i.total);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndPrint();
    });
  }

  Future<void> _initAndPrint() async {
    final user = context.read<UserBloc>().state.user;
    final selectedBusiness = user?.business?.firstWhere(
          (b) => b.businessName == user.activeBusiness,
      orElse: () => user.business!.first,
    );

    _logoUrl = selectedBusiness?.logoUrl;

    if (_logoUrl != null && _logoUrl!.isNotEmpty) {
      // preload image and wait for it to complete before printing
      await _preloadImage(_logoUrl!);
    } else {
      setState(() => _logoLoaded = true);
    }

    // extra frame after setState to ensure UI redraws with loaded image
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) _print();
  }

  Future<void> _preloadImage(String url) async {
    try {
      final imageProvider = NetworkImage(url);
      final completer = Completer<void>();
      final stream = imageProvider.resolve(ImageConfiguration.empty);
      late ImageStreamListener listener;
      listener = ImageStreamListener(
            (info, _) {
          if (!completer.isCompleted) completer.complete();
          stream.removeListener(listener);
          if (mounted) setState(() => _logoLoaded = true);
        },
        onError: (error, stack) {
          if (!completer.isCompleted) completer.complete();
          stream.removeListener(listener);
          if (mounted) setState(() => _logoLoaded = true);
        },
      );
      stream.addListener(listener);
      await completer.future;
    } catch (_) {
      if (mounted) setState(() => _logoLoaded = true);
    }
  }

  Future<void> _print() async {
    final selectedDevice =
        context.read<PrinterBloc>().state.selectedDevice;

    if (selectedDevice == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No printer selected. Please pair a printer first.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isPrinting = true);

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      final boundary = _receiptKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find receipt render boundary');
      }

      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to convert receipt to image');
      }

      final imageBytes = byteData.buffer.asUint8List();

      await FlutterBluetoothPrinter.printImageSingle(
        address: selectedDevice.address,
        imageBytes: imageBytes,
        imageWidth: image.width,
        imageHeight: image.height,
        paperSize: PaperSize.mm58,
        keepConnected: false,
        addFeeds: 2,
        cutPaper: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Print failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
        actions: [
          if (_isPrinting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.print_outlined, size: 18),
              label: const Text('Print'),
              onPressed: _isPrinting ? null : _print,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: _buildReceiptContent(context),
      ),
    );
  }

  Widget _buildReceiptContent(BuildContext context) {
    return BlocBuilder<MasterDataBloc, MasterDataState>(
      builder: (context, state) {
        final UserEntity? user = context.watch<UserBloc>().state.user;
        final selectedBusiness = user?.business?.firstWhere(
              (business) => business.businessName == user.activeBusiness,
          orElse: () => user!.business!.first,
        );

        return RepaintBoundary(
          key: _receiptKey,
          child: Container(
            width: 576,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_logoUrl != null && _logoUrl!.isNotEmpty && _logoLoaded)
                  Center(
                    child: Image.network(
                      _logoUrl!,
                      width: 80,
                      height: 80,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                Text(
                  selectedBusiness?.businessName ?? 'MY STORE',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (selectedBusiness?.address != null)
                  Text(
                    selectedBusiness!.address!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                if (selectedBusiness?.contact != null)
                  Text(
                    selectedBusiness!.contact!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                _dashedDivider(),
                _receiptRow(
                  'Date',
                  DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
                ),
                if (widget.dispatchedTo != null &&
                    widget.dispatchedTo!.isNotEmpty)
                  _receiptRow('Customer', widget.dispatchedTo!),
                _dashedDivider(),
                const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        'Item',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Text(
                        'Qty',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 85,
                      child: Text(
                        'Price',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: 85,
                      child: Text(
                        'Total',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
                _dashedDivider(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.billItems.length,
                  itemBuilder: (context, index) {
                    final b = widget.billItems[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4,
                                child: Text(
                                  b.item.variant != null
                                      ? '${b.item.name} (${b.item.variant})'
                                      : b.item.name,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: Text(
                                  '${b.quantity}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                width: 85,
                                child: Text(
                                  b.sellingPrice.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                width: 85,
                                child: Text(
                                  b.subtotal.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          if (b.discount > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  b.discountType == DiscountType.percentage
                                      ? 'Disc ${b.discount.toStringAsFixed(0)}%'
                                      : 'Disc',
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.black),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    '- ${b.discountAmount.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.grey),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  'Item Total',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                ),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 85,
                                  child: Text(
                                    b.total.toStringAsFixed(2),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                _dashedDivider(),
                _receiptRow('Subtotal', _subtotal.toStringAsFixed(2)),
                if (_totalDiscount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Discount',
                            style: TextStyle(fontSize: 20, color: Colors.black)),
                        Text(
                          '- ${_totalDiscount.toStringAsFixed(2)}',
                          style:
                          const TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                _dashedDivider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL / එකතුව',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black),
                    ),
                    Text(
                      'LKR ${_grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.black),
                    ),
                  ],
                ),
                if (widget.notes != null && widget.notes!.isNotEmpty) ...[
                  _dashedDivider(),
                  Text(
                    'Note: ${widget.notes}',
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
                _dashedDivider(),
                const Text(
                  'Thank you! / ස්තූතියි! / நன்றி!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
                const Text(
                  'Please come again',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dashedDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 3),
      child: Text(
        '- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, color: Colors.grey),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) {
    final style = bold
        ? const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black)
        : const TextStyle(fontSize: 20, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }
}