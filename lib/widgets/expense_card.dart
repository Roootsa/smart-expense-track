import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/utils/helpers.dart';
import 'package:smart_expense_tracker/screens/expense/expense_detail_screen.dart';

class ExpenseCard extends StatelessWidget {
  final ExpenseModel expense;

  const ExpenseCard({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    
    // ## PERBAIKAN 2: Tambahkan tanda tanya (?) untuk membuat variabel ini nullable ##
    final CategoryModel? category = provider.categories
        .where((cat) => cat.id == expense.categoryId)
        .isNotEmpty
        ? provider.categories.firstWhere((cat) => cat.id == expense.categoryId)
        : null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExpenseDetailScreen(expense: expense),
            ),
          );
        },
        leading: CircleAvatar(
          backgroundColor: category?.color.withOpacity(0.2) ?? Colors.grey.shade200,
          child: Icon(category?.icon ?? Icons.error, color: category?.color ?? Colors.grey),
        ),
        title: Text(expense.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(category?.name ?? 'Tanpa Kategori'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatCurrency(expense.amount),
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade400, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(formatDateForGrouping(expense.date), style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}