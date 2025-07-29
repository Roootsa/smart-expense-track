import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/models/bill_reminder_model.dart'; // DITAMBAHKAN
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';

class ExpenseService {
  final String? uid;
  ExpenseService(this.uid);

  final CollectionReference _expenseCollection = FirebaseFirestore.instance.collection('expenses');
  final CollectionReference _categoryCollection = FirebaseFirestore.instance.collection('categories');
  final CollectionReference _billReminderCollection = FirebaseFirestore.instance.collection('bill_reminders');

  // --- Expense CRUD ---
  Stream<List<ExpenseModel>> getExpenses() => _expenseCollection.where('userId', isEqualTo: uid).orderBy('date', descending: true).snapshots().map((s) => s.docs.map((d) => ExpenseModel.fromFirestore(d)).toList());
  Future<void> addExpense(ExpenseModel e) async => await _expenseCollection.add(e.toJson()..['userId'] = uid);
  Future<void> updateExpense(ExpenseModel e) async => await _expenseCollection.doc(e.id).update(e.toJson()..['userId'] = uid);
  Future<void> deleteExpense(String id) async => await _expenseCollection.doc(id).delete();
  
  // --- Category CRUD ---
  Stream<List<CategoryModel>> getCategories() => _categoryCollection.where('userId', isEqualTo: uid).snapshots().map((s) => s.docs.map((d) => CategoryModel.fromFirestore(d)).toList());
  Future<void> addCategory(String n, int i, int c) async => await _categoryCollection.add({'userId': uid, 'name': n, 'iconCodePoint': i, 'colorValue': c});
  Future<void> updateCategory(String id, String n, int i, int c) async => await _categoryCollection.doc(id).update({'name': n, 'iconCodePoint': i, 'colorValue': c});
  Future<void> deleteCategory(String id) async => await _categoryCollection.doc(id).delete();
  
  // --- Bill Reminders CRUD ---
  Stream<List<BillReminderModel>> getBillReminders() {
    return _billReminderCollection.where('userId', isEqualTo: uid).orderBy('dueDate').snapshots().map((s) => s.docs.map((d) => BillReminderModel.fromFirestore(d)).toList());
  }
  Future<void> addBillReminder(BillReminderModel r) async => await _billReminderCollection.add(r.toJson()..['userId'] = uid);
  Future<void> updateBillReminder(BillReminderModel r) async => await _billReminderCollection.doc(r.id).update(r.toJson());
  Future<void> deleteBillReminder(String id) async => await _billReminderCollection.doc(id).delete();
}