import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/widgets/custom_buttons.dart';

class EditExpenseScreen extends StatefulWidget {
  final ExpenseModel expense;
  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _descriptionController;

  CategoryModel? _selectedCategory;
  DateTime? _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi semua controller dan state dengan data dari expense yang diedit
    _titleController = TextEditingController(text: widget.expense.title);
    _amountController = TextEditingController(text: widget.expense.amount.toStringAsFixed(0));
    _dateController = TextEditingController(text: DateFormat('EEEE, d MMMM y', 'id_ID').format(widget.expense.date));
    _descriptionController = TextEditingController(text: widget.expense.description);
    _selectedDate = widget.expense.date;
  }
  
  // Fungsi ini dipanggil setelah build pertama selesai
  void _initializeCategory() {
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    try {
      // Coba cari kategori
      _selectedCategory = provider.categories.firstWhere((cat) => cat.id == widget.expense.categoryId);
    } catch (e) {
      // Jika tidak ketemu, _selectedCategory akan tetap null
      // Tidak perlu melakukan apa-apa di sini
    }
    // Perlu setState agar UI dropdown diperbarui
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCategory();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('EEEE, d MMMM y', 'id_ID').format(picked);
      });
    }
  }

  Future<void> _submitExpense() async {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedDate == null) return;
    
    setState(() => _isLoading = true);

    final updatedExpense = ExpenseModel(
      id: widget.expense.id, // Gunakan ID yang lama
      userId: widget.expense.userId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim().replaceAll(RegExp(r'[^0-9]'), '')),
      date: _selectedDate!,
      categoryId: _selectedCategory!.id,
      description: _descriptionController.text.trim(),
    );

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    try {
      await provider.updateExpense(updatedExpense);
      if (mounted) {
        // Kembali dua kali untuk menutup halaman edit dan halaman detail
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memperbarui: $e")));
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<ExpenseProvider>(context).categories;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Pengeluaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(controller: _titleController, decoration: const InputDecoration(labelText: 'Judul Pengeluaran'), validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _amountController, decoration: const InputDecoration(labelText: 'Jumlah (Rp)'), keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'Jumlah tidak boleh kosong' : null),
              const SizedBox(height: 16),
              if (categories.isNotEmpty)
                DropdownButtonFormField<CategoryModel>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: categories.map((c) => DropdownMenuItem<CategoryModel>(value: c, child: Row(children: [Icon(c.icon, color: c.color), const SizedBox(width: 10), Text(c.name)]))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v),
                  validator: (v) => v == null ? 'Kategori harus dipilih' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(controller: _dateController, decoration: const InputDecoration(labelText: 'Tanggal'), readOnly: true, onTap: () => _selectDate(context)),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Deskripsi (Opsional)'), maxLines: 3),
              const SizedBox(height: 32),
              PrimaryButton(text: 'Simpan Perubahan', onPressed: _submitExpense, isLoading: _isLoading),
            ],
          ),
        ),
      ),
    );
  }
}