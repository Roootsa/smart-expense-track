// lib/providers/expense_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/models/category_model.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/services/expense_service.dart';

class ExpenseProvider with ChangeNotifier {
  final String? uid;
  late final ExpenseService _service;
  
  List<ExpenseModel> _expenses = [];
  bool _isLoadingExpenses = false;
  StreamSubscription? _expensesSubscription;

  List<CategoryModel> _categories = [];
  bool _isLoadingCategories = false;
  StreamSubscription? _categoriesSubscription;

  ExpenseProvider(this.uid) {
    _service = ExpenseService(uid);
    if (uid != null) {
      _listenToExpenses();
      _listenToCategories();
    }
  }

  // Getters
  List<ExpenseModel> get expenses => _expenses;
  bool get isLoadingExpenses => _isLoadingExpenses;
  List<CategoryModel> get categories => _categories;
  bool get isLoadingCategories => _isLoadingCategories;

  // === GETTER BARU UNTUK DASHBOARD ===
  double get monthlyTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.month == now.month && e.date.year == now.year)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  double get todayTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.day == now.day && e.date.month == now.month && e.date.year == now.year)
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
  // ===================================

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
  
  Future<void> addCategory(String name, IconData icon, Color color) async {
    await _service.addCategory(name, icon.codePoint, color.value);
  }
  
  Future<void> updateCategory(String id, String name, IconData icon, Color color) async {
    await _service.updateCategory(id, name, icon.codePoint, color.value);
  }

  Future<void> deleteCategory(String id) async {
    await _service.deleteCategory(id);
  }

  

    Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _service.addExpense(expense);
    } catch (e) {
      // Anda bisa menambahkan penanganan error di sini jika perlu
      rethrow;
    }
  }

  @override
  void dispose() {
    _expensesSubscription?.cancel();
    _categoriesSubscription?.cancel();
    super.dispose();
  }
}