import 'package:cloud_firestore/cloud_firestore.dart';

class BillReminderModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final DateTime dueDate;
  bool isPaid;
  final int notificationId;

  BillReminderModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.notificationId,
  });

  factory BillReminderModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return BillReminderModel(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      amount: (data['amount'] as num).toDouble(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      isPaid: data['isPaid'] ?? false,
      notificationId: data['notificationId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaid': isPaid,
      'notificationId': notificationId,
    };
  }
}