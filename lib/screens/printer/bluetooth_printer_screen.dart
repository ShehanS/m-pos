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
  ReceiptController? _receiptController;
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

    if (_receiptController == null) return;

    setState(() => _isPrinting = true);

    try {
      await _receiptController!.print(
        address: selectedDevice.address,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printed successfully!')),
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
                  child: Receipt(
                    builder: (context) => _buildReceiptContent(),
                    onInitialized: (controller) {
                      _receiptController = controller;
                    },
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
            onPressed: () =>
                setState(() => _showDeviceList = !_showDeviceList),
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
                  context
                      .read<ScannerBloc>()
                      .add(SelectDevice(device: device));
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
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'MY STORE',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text('123 Main Street, Colombo'),
          const Text('Tel: +94 11 234 5678'),
          const Divider(),
          const SizedBox(height: 4),
          _receiptRow('Item A', 'LKR 500.00'),
          _receiptRow('Item B', 'LKR 300.00'),
          _receiptRow('Item C', 'LKR 200.00'),
          const Divider(),
          _receiptRow('TOTAL', 'LKR 1000.00', bold: true),
          const SizedBox(height: 8),
          const Text('Thank you for your purchase!'),
          const Text('Please come again'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool bold = false}) {
    final style =
    bold ? const TextStyle(fontWeight: FontWeight.bold) : const TextStyle();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}