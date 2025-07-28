import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime date;
  final String categoryId;
  final String? description;

  ExpenseModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.date,
    required this.categoryId,
    this.description,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ExpenseModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      categoryId: data['categoryId'],
      description: data['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'categoryId': categoryId,
      'description': description,
    };
  }
}