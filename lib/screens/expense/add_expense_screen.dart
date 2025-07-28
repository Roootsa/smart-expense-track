import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/providers/auth_provider.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/widgets/custom_buttons.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _dateController = TextEditingController();
  final _descriptionController = TextEditingController();

  CategoryModel? _selectedCategory;
  DateTime? _selectedDate;
  
  // DITAMBAHKAN: State untuk loading
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEEE, d MMMM y', 'id_ID').format(picked);
      });
    }
  }

  // ## FUNGSI INI DITULIS ULANG DENGAN ASYNC/AWAIT ##
  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategory == null || _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kategori dan Tanggal harus diisi'), backgroundColor: Colors.orange),
      );
      return;
    }

    // Mulai loading
    setState(() {
      _isLoading = true;
    });

    try {
      final expenseProvider = Provider.of<ExpenseProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final newExpense = ExpenseModel(
        id: '',
        userId: authProvider.user!.uid,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')),
        date: _selectedDate!,
        categoryId: _selectedCategory!.id,
        description: _descriptionController.text.trim(),
      );

      // Tunggu sampai proses simpan selesai
      await expenseProvider.addExpense(newExpense);
      
      // Jika berhasil, tampilkan notifikasi dan KEMBALI
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengeluaran berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }

    } catch (e) {
      // Jika terjadi error, tampilkan pesan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      // Apapun yang terjadi (sukses atau gagal), hentikan loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pengeluaran'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ... TextFormField lainnya tidak berubah ...
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Pengeluaran'), validator: (v) => v!.isEmpty?'Judul tidak boleh kosong':null),
              const SizedBox(height: 16),
              TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Jumlah (Rp)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty?'Jumlah tidak boleh kosong':null),
              const SizedBox(height: 16),
              Consumer<ExpenseProvider>(builder: (context, provider, child) {
                  if(provider.isLoadingCategories){return const Center(child: CircularProgressIndicator());}
                  if(provider.categories.isEmpty){return const ListTile(leading: Icon(Icons.warning), title: Text('Tidak ada kategori'), subtitle: Text('Buat kategori dulu di Profil'));}
                  return DropdownButtonFormField<CategoryModel>(value: _selectedCategory, decoration: const InputDecoration(labelText: 'Kategori'), hint: const Text('Pilih Kategori'), items: provider.categories.map((c) => DropdownMenuItem<CategoryModel>(value: c, child: Row(children: [Icon(c.icon, color: c.color), const SizedBox(width: 10), Text(c.name)]))).toList(), onChanged: (v){setState(()=>_selectedCategory = v);}, validator: (v)=>v==null?'Kategori harus dipilih':null);
              }),
              const SizedBox(height: 16),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Tanggal'), readOnly: true, onTap: () => _selectDate(context)),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'), maxLines: 3),
              const SizedBox(height: 32),
              
              // PERBARUI TOMBOL INI UNTUK MENUNJUKKAN LOADING
              PrimaryButton(
                text: 'Simpan',
                onPressed: _submitExpense,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}