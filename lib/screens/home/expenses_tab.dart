import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/widgets/expense_card.dart';
// ## PERBAIKAN 1: Path import yang benar ##
import 'package:smart_expense_tracker/utils/helpers.dart';

class ExpensesTab extends StatelessWidget {
  const ExpensesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Pengeluaran'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoadingExpenses) {
            return const Center(child: CircularProgressIndicator());
          }

          if (expenseProvider.expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Belum ada transaksi', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const Text('Tekan tombol + untuk menambah', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final groupedExpenses = _groupExpensesByDate(expenseProvider.expenses);
          final dateKeys = groupedExpenses.keys.toList();

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: dateKeys.length,
            itemBuilder: (context, index) {
              final date = dateKeys[index];
              final expensesOnDate = groupedExpenses[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 20, bottom: 8),
                    child: Text(
                      date,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...expensesOnDate.map((expense) {
                    return ExpenseCard(expense: expense);
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Fungsi ini sekarang akan dikenali karena import sudah benar
  Map<String, List<ExpenseModel>> _groupExpensesByDate(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};
    for (var expense in expenses) {
      String formattedDate = formatDateForGrouping(expense.date);
      if (grouped[formattedDate] == null) {
        grouped[formattedDate] = [];
      }
      grouped[formattedDate]!.add(expense);
    }
    return grouped;
  }
}