import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/bill_reminder_model.dart';
import 'package:smart_expense_tracker/providers/auth_provider.dart';
// ## PERBAIKAN DI BARIS IMPORT INI ##
import 'package:smart_expense_tracker/providers/expense_provider.dart'; 
import 'package:smart_expense_tracker/widgets/custom_buttons.dart';

class AddBillReminderScreen extends StatefulWidget {
  const AddBillReminderScreen({super.key});

  @override
  State<AddBillReminderScreen> createState() => _AddBillReminderScreenState();
}

class _AddBillReminderScreenState extends State<AddBillReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEEE, d MMMM y', 'id_ID').format(picked);
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final newReminder = BillReminderModel(
        id: '',
        userId: authProvider.user!.uid,
        title: _titleController.text,
        amount: double.parse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')),
        dueDate: _selectedDate!,
        isPaid: false,
        notificationId: Random().nextInt(100000), // ID unik untuk notifikasi
      );
      // Baris ini sekarang akan berfungsi karena import sudah benar
      Provider.of<ExpenseProvider>(context, listen: false).addBillReminder(newReminder);
      Navigator.pop(context);
    } else {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan lengkapi semua data.'), backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pengingat Tagihan')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama Tagihan (e.g. Internet, Listrik)'),
                validator: (v) => v!.isEmpty ? 'Nama tagihan wajib diisi' : null
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Jumlah (Rp)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Jumlah wajib diisi' : null
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Tanggal Jatuh Tempo'),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (v) => v!.isEmpty ? 'Tanggal wajib diisi' : null
              ),
              const SizedBox(height: 32),
              PrimaryButton(text: 'Simpan Pengingat', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}