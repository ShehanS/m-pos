import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_bloc.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_event.dart';
import 'package:flutter_bloc_app/bloc/scanner/scanner_state.dart';

import '../../widgets/scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final List<String> codes = [];

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ScannerBloc, ScannerState>(
      listener: (context, state) {
        if (state.status == ScannerStatus.loaded && state.code != null) {
          setState(() {
            codes.add(state.code!);
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Scan Code"),
            actions: [
              if (codes.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => setState(() => codes.clear()),
                ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: codes.isEmpty
                    ? const Center(child: Text("No codes scanned yet"))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: codes.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.qr_code),
                      title: Text(codes[index]),
                      trailing: Text(
                        "#${index + 1}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (_) => BlocProvider.value(
                            value: context.read<ScannerBloc>(),
                            child: const ScannerDialog(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text("Scan"),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}