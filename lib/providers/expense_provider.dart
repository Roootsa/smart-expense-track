import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/models/bill_reminder_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/services/expense_service.dart';
import 'package:smart_expense_tracker/services/notification_service.dart';
import 'package:smart_expense_tracker/utils/helpers.dart'; // DITAMBAHKAN: Untuk formatCurrency

class ExpenseProvider with ChangeNotifier {
  final String? uid;
  late final ExpenseService _service;

  // State untuk Expenses
  List<ExpenseModel> _expenses = [];
  bool _isLoadingExpenses = false;
  StreamSubscription? _expensesSubscription;

  // State untuk Categories
  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  StreamSubscription? _categoriesSubscription;
  
  // State untuk Bill Reminders
  final NotificationService _notificationService = NotificationService();
  List<BillReminderModel> _reminders = [];
  bool _isLoadingReminders = false;
  StreamSubscription? _remindersSubscription;

  ExpenseProvider(this.uid) {
    _service = ExpenseService(uid);
    if (uid != null) {
      _listenToExpenses();
      _listenToCategories();
      _listenToReminders();
    }
  }

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoadingExpenses => _isLoadingExpenses;
  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;
  List<BillReminderModel> get reminders => _reminders;
  bool get isLoadingReminders => _isLoadingReminders;

  double get monthlyTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  Map<String, double> get expensesByCategory {
    final Map<String, double> data = {};
    for (var expense in _expenses) {
      data.update(
        expense.categoryId,
        (value) => value + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }
    return data;
  }

  // Listeners
  void _listenToExpenses() {
    _isLoadingExpenses = true;
    notifyListeners();
    _expensesSubscription = _service.getExpenses().listen((expenses) {
      _expenses = expenses;
      _isLoadingExpenses = false;
      notifyListeners();
    });
  }

  void _listenToCategories() {
    _isLoadingCategories = true;
    notifyListeners();
    _categoriesSubscription = _service.getCategories().listen((categories) {
      _categories = categories;
      _isLoadingCategories = false;
      notifyListeners();
    });
  }

  void _listenToReminders() {
    _isLoadingReminders = true;
    notifyListeners();
    _remindersSubscription = _service.getBillReminders().listen((reminders) {
      _reminders = reminders;
      _isLoadingReminders = false;
      notifyListeners();
    });
  }

  // Expense Methods
  Future<void> addExpense(ExpenseModel expense) async => await _service.addExpense(expense);
  Future<void> updateExpense(ExpenseModel expense) async => await _service.updateExpense(expense);
  Future<void> deleteExpense(String expenseId) async => await _service.deleteExpense(expenseId);

  // Category Methods
  Future<void> addCategory(String name, IconData icon, Color color) async => await _service.addCategory(name, icon.codePoint, color.value);
  Future<void> updateCategory(String id, String name, IconData icon, Color color) async => await _service.updateCategory(id, name, icon.codePoint, color.value);
  Future<void> deleteCategory(String id) async => await _service.deleteCategory(id);
  
  // Bill Reminder Methods
  Future<void> addBillReminder(BillReminderModel reminder) async {
    await _service.addBillReminder(reminder);
    final notificationDate = reminder.dueDate.subtract(const Duration(days: 1));
    if (notificationDate.isAfter(DateTime.now())) {
      await _notificationService.scheduleBillNotification(
        id: reminder.notificationId,
        title: 'Pengingat Tagihan: ${reminder.title}',
        body: 'Tagihan Anda sebesar ${formatCurrency(reminder.amount)} akan jatuh tempo besok.',
        scheduledDate: notificationDate,
      );
    }
  }

  Future<void> toggleBillPaidStatus(BillReminderModel reminder) async {
    reminder.isPaid = !reminder.isPaid;
    await _service.updateBillReminder(reminder);
    if (reminder.isPaid) {
      await _notificationService.cancelNotification(reminder.notificationId);
    }
  }

  Future<void> deleteBillReminder(BillReminderModel reminder) async {
    await _service.deleteBillReminder(reminder.id);
    await _notificationService.cancelNotification(reminder.notificationId);
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _remindersSubscription?.cancel();
    super.dispose();
  }
}