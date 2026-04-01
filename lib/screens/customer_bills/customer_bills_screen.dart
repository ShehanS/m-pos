import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_app/bloc/bill/bill_bloc.dart';
import 'package:flutter_bloc_app/bloc/bill/bill_event.dart';
import 'package:flutter_bloc_app/bloc/bill/bill_state.dart';
import 'package:intl/intl.dart';

import '../../bloc/user/user_bloc.dart';
import '../../entities/bill_entity.dart';
import '../../theme/app_theme.dart';

class CustomerBillsScreen extends StatefulWidget {
  const CustomerBillsScreen({super.key});

  @override
  State<CustomerBillsScreen> createState() => _CustomerBillsScreenState();
}

class _CustomerBillsScreenState extends State<CustomerBillsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _fetchBills();
  }

  void _fetchBills() {
    final user = context.read<UserBloc>().state.user;
    if (user != null) {
      context.read<BillBloc>().add(GetBills(
        userId: user.uid,
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Bills"),
        actions: [
          IconButton(
            icon: Icon(_selectedDateRange == null ? Icons.date_range : Icons.event_available),
            onPressed: _pickDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: "Search Name or Contact...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchController.clear()))
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<BillBloc, BillState>(
              builder: (context, state) {
                if (state.status == CustomerBillStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                final query = _searchController.text.toLowerCase();
                final filteredBills = (state.bills ?? []).where((bill) {
                  final nameMatch = (bill.customerName ?? '').toLowerCase().contains(query);
                  final contactMatch = (bill.customerContact ?? '').contains(query);
                  return nameMatch || contactMatch;
                }).toList();

                if (filteredBills.isEmpty) return const Center(child: Text("No matching bills found"));

                return RefreshIndicator(
                  onRefresh: () async => _fetchBills(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = filteredBills[index];
                      return _buildBillCard(bill);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );
    if (picked != null) {
      setState(() => _selectedDateRange = picked);
      _fetchBills();
    }
  }

  Widget _buildBillCard(BillEntity bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(bill.customerName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("${DateFormat('dd/MM/yy HH:mm').format(bill.createdAt)}\n${bill.customerContact ?? ''}"),
        trailing: Text("LKR ${bill.grandTotal.toStringAsFixed(2)}",
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
        onTap: () => _showBillDetailPopup(bill),
      ),
    );
  }

  void _showBillDetailPopup(BillEntity bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Bill Details"),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Customer: ${bill.customerName ?? 'N/A'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Contact: ${bill.customerContact ?? 'N/A'}"),
                const Divider(),
                ...bill.billItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text("${item.item.name} x${item.quantity} ${item.item.unit}")),
                      Text("LKR ${item.total.toStringAsFixed(2)}"),
                    ],
                  ),
                )),
                const Divider(),
                _summaryRow("Subtotal", bill.subtotal),
                _summaryRow("Discount", -bill.totalDiscount, color: Colors.red),
                _summaryRow("Grand Total", bill.grandTotal, isBold: true),
              ],
            ),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : null)),
        Text(value.toStringAsFixed(2), style: TextStyle(fontWeight: isBold ? FontWeight.bold : null, color: color)),
      ],
    );
  }
}