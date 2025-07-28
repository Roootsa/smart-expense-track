import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

// Helper untuk format mata uang
String formatCurrency(double amount) {
  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return currencyFormatter.format(amount);
}

// Helper untuk memformat tanggal untuk pengelompokan di daftar transaksi
String formatDateForGrouping(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateToCompare = DateTime(date.year, date.month, date.day);

  if (dateToCompare == today) {
    return 'Hari Ini';
  } else if (dateToCompare == yesterday) {
    return 'Kemarin';
  } else {
    // Menggunakan format 'Jumat, 26 Juli 2025'
    return DateFormat('EEEE, d MMMM y', 'id_ID').format(date);
  }
}