import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_event.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_state.dart';

class BluetoothPrinterScreen extends StatefulWidget {
  const BluetoothPrinterScreen({super.key});

  @override
  State<BluetoothPrinterScreen> createState() => _BluetoothPrinterScreenState();
}

class _BluetoothPrinterScreenState extends State<BluetoothPrinterScreen> {
  final GlobalKey _receiptKey = GlobalKey();
  bool _isPrinting = false;
  bool _showDeviceList = false;

  Future<void> _print() async {
    final selectedDevice = context.read<ScannerBloc>().state.selectedDevice;

    if (selectedDevice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a printer first')),
      );
      return;
    }

    setState(() => _isPrinting = true);

    try {
      final boundary = _receiptKey.currentContext?.findRenderObject()
      as RenderRepaintBoundary?;

      if (boundary == null) throw Exception('Could not capture receipt image');

      // pixelRatio: 1.0 keeps image at exact widget pixel size
      // so imageWidth matches the 576px container exactly
      final ui.Image image = await boundary.toImage(pixelRatio: 1.0);
      final byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception('Failed to convert image');

      final imageBytes = byteData.buffer.asUint8List();

      await FlutterBluetoothPrinter.printImageSingle(
        address: selectedDevice.address,
        imageBytes: imageBytes,
        imageWidth: image.width,
        imageHeight: image.height,
        paperSize: PaperSize.mm58,
        keepConnected: false,
        addFeeds: 1,
        cutPaper: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Printed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Print failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScannerBloc, ScannerState>(
      builder: (context, scannerState) {
        final selectedDevice = scannerState.selectedDevice;

        return Scaffold(
          appBar: AppBar(title: const Text('Bluetooth Printer')),
          body: Column(
            children: [
              _buildDeviceSection(selectedDevice),
              const Divider(height: 1),
              _buildPrintButton(),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  child: RepaintBoundary(
                    key: _receiptKey,
                    child: _buildReceiptContent(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDeviceSection(selectedDevice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(
            selectedDevice != null ? Icons.print : Icons.print_outlined,
            color: selectedDevice != null ? Colors.green : null,
          ),
          title: Text(
            selectedDevice != null
                ? (selectedDevice.name ?? 'Unknown Device')
                : 'No printer selected',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: selectedDevice != null ? Colors.green : null,
            ),
          ),
          subtitle: Text(
            selectedDevice != null
                ? selectedDevice.address
                : 'Tap to scan and select a printer',
          ),
          trailing: TextButton.icon(
            onPressed: () => setState(() => _showDeviceList = !_showDeviceList),
            icon: Icon(_showDeviceList
                ? Icons.expand_less
                : Icons.bluetooth_searching),
            label: Text(_showDeviceList ? 'Hide' : 'Scan'),
          ),
        ),
        if (_showDeviceList) _buildDeviceList(selectedDevice),
      ],
    );
  }

  Widget _buildDeviceList(selectedDevice) {
    return Container(
      height: 220,
      color: Colors.grey.shade50,
      child: StreamBuilder(
        stream: FlutterBluetoothPrinter.discovery,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Scanning for devices...'),
                ],
              ),
            );
          }

          List<BluetoothDevice> devices = [];
          try {
            final dynamic d = snapshot.data;
            if (d?.devices != null) {
              devices = List<BluetoothDevice>.from(d.devices as List);
            }
          } catch (_) {
            devices = [];
          }

          if (devices.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.bluetooth_disabled, size: 40, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No devices found',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: devices.length,
            itemBuilder: (context, index) {
              final device = devices[index];
              final isSelected = selectedDevice?.address == device.address;

              return ListTile(
                dense: true,
                leading: Icon(
                  Icons.print,
                  color: isSelected ? Colors.green : Colors.grey,
                ),
                title: Text(device.name ?? 'Unknown Device'),
                subtitle: Text(
                  device.address,
                  style: const TextStyle(fontSize: 11),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.radio_button_unchecked,
                        color: Colors.grey),
                onTap: () {
                  context.read<ScannerBloc>().add(SelectDevice(device: device));
                  setState(() => _showDeviceList = false);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPrintButton() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ElevatedButton.icon(
        onPressed: _isPrinting ? null : _print,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
        ),
        icon: _isPrinting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.print),
        label: Text(_isPrinting ? 'Printing...' : 'Print Receipt'),
      ),
    );
  }

  Widget _buildReceiptContent() {
    return Container(
      width: 576,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              "assets/images/logo.png",
              width: 200,
              height: 200,
            ),
          ),
          const Text(
            'MY STORE',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Text(
            'මගේ වෙළඳසැල / என் கடை',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const SizedBox(height: 4),
          const Text(
            '123 Main Street, Colombo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const Text(
            'Tel: +94 11 234 5678',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          const SizedBox(height: 8),
          _dashedDivider(),
          const SizedBox(height: 4),
          _receiptRow('Item A / අයිතමය A', 'LKR 500.00'),
          _receiptRow('Item B / அயிதமய B', 'LKR 300.00'),
          _receiptRow('Item C / අයිතමය C', 'LKR 200.00'),
          const SizedBox(height: 4),
          _dashedDivider(),
          const SizedBox(height: 4),
          _receiptRow('TOTAL / එකතුව', 'LKR 1000.00', bold: true),
          const SizedBox(height: 20),
          const Text(
            'Thank you! / ස්තූතියි! / நன்றி!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
          const Text(
            'Please come again',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _dashedDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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
            fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)
        : const TextStyle(fontSize: 20, color: Colors.black);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
