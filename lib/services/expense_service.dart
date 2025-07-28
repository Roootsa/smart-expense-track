import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_expense_tracker/models/expense_model.dart';
import 'package:smart_expense_tracker/models/category_model.dart';

class ExpenseService {
  final String? uid;
  ExpenseService(this.uid);

  final CollectionReference _expenseCollection = FirebaseFirestore.instance.collection('expenses');
  final CollectionReference _categoryCollection = FirebaseFirestore.instance.collection('categories');

  // --- Expense CRUD ---
   Stream<List<ExpenseModel>> getExpenses() {
    return _expenseCollection
        .where('userId', isEqualTo: uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map(_expenseListFromSnapshot);
  }
  List<ExpenseModel> _expenseListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ExpenseModel.fromFirestore(doc);
    }).toList();
  }
  
    Future<void> addExpense(ExpenseModel expense) async {
    // Pastikan UID dari user yang login ikut tersimpan
    final data = expense.toJson();
    data['userId'] = uid; 
    await _expenseCollection.add(data);
  }
  Future<void> updateExpense(ExpenseModel expense) async {
    await _expenseCollection.doc(expense.id).update(expense.toJson());
  }

  Future<void> deleteExpense(String id) async {
    await _expenseCollection.doc(id).delete();
  }

  
  
  Stream<List<CategoryModel>> getCategories() {
    // Kategori dibuat per-user agar tidak tercampur
    return _categoryCollection
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map(_categoryListFromSnapshot);
  }

  List<CategoryModel> _categoryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return CategoryModel.fromFirestore(doc);
    }).toList();
  }
  
  Future<void> addCategory(String name, int iconCodePoint, int colorValue) async {
    await _categoryCollection.add({
      'userId': uid, // Penting untuk memisahkan kategori antar user
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    });
  }

  Future<void> updateCategory(String id, String name, int iconCodePoint, int colorValue) async {
    await _categoryCollection.doc(id).update({
      'name': name,
      'iconCodePoint': iconCodePoint,
      'colorValue': colorValue,
    });
  }

  Future<void> deleteCategory(String id) async {
    await _categoryCollection.doc(id).delete();
  }
}