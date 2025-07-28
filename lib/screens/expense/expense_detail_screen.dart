import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/screens/expense/edit_expense_screen.dart';
import 'package:smart_expense_tracker/utils/helpers.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final ExpenseModel expense;
  const ExpenseDetailScreen({super.key, required this.expense});

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Transaksi'),
        content: Text('Apakah Anda yakin ingin menghapus "${expense.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Provider.of<ExpenseProvider>(context, listen: false).deleteExpense(expense.id);
              // Tutup dialog dan halaman detail
              Navigator.of(ctx).pop(); 
              Navigator.of(context).pop();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    CategoryModel? category; // Deklarasikan sebagai nullable
    try {
      // Coba cari kategori
      category = provider.categories.firstWhere((cat) => cat.id == expense.categoryId);
    } catch (e) {
      // Jika tidak ketemu (error), biarkan category bernilai null
      category = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pushReplacement( // Ganti halaman, bukan menumpuk
                context,
                MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(expense: expense),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(expense.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(formatCurrency(expense.amount), style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.grey),
              title: const Text('Tanggal'),
              subtitle: Text(formatDateForGrouping(expense.date), style: theme.textTheme.bodyLarge),
            ),
            ListTile(
              leading: Icon(category?.icon ?? Icons.error, color: category?.color ?? Colors.grey),
              title: const Text('Kategori'),
              subtitle: Text(category?.name ?? 'Tanpa Kategori', style: theme.textTheme.bodyLarge),
            ),
            if (expense.description != null && expense.description!.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.description_outlined, color: Colors.grey),
                title: const Text('Deskripsi'),
                subtitle: Text(expense.description!, style: theme.textTheme.bodyLarge),
              ),
          ],
        ),
      ),
    );
  }
}