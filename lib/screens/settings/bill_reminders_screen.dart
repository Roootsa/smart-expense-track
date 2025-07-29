// lib/screens/settings/bill_reminders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/screens/settings/add_bill_reminder_screen.dart';
import 'package:smart_expense_tracker/utils/helpers.dart';

class BillRemindersScreen extends StatelessWidget {
  const BillRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengingat Tagihan'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingReminders) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.reminders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengingat tagihan.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.reminders.length,
            itemBuilder: (context, index) {
              final reminder = provider.reminders[index];
              return Card(
                elevation: 0,
                color: Theme.of(context).cardColor,
                child: ListTile(
                  leading: Checkbox(
                    value: reminder.isPaid,
                    onChanged: (value) {
                      provider.toggleBillPaidStatus(reminder);
                    },
                    activeColor: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(
                    reminder.title,
                    style: TextStyle(
                      decoration: reminder.isPaid
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: reminder.isPaid ? Colors.grey : null,
                    ),
                  ),
                  subtitle: Text(
                      'Jatuh tempo: ${formatDateForGrouping(reminder.dueDate)}'),
                  trailing: Text(
                    formatCurrency(reminder.amount),
                    style: TextStyle(
                      color: reminder.isPaid ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBillReminderScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}