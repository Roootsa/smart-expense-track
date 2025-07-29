import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/widgets/custom_buttons.dart';

class ExportDataScreen extends StatefulWidget {
  const ExportDataScreen({super.key});

  @override
  State<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends State<ExportDataScreen> {
  bool _isLoading = false;

    Future<void> _exportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<ExpenseProvider>(context, listen: false);
      final expenses = provider.expenses;
      final categories = provider.categories;

      if (expenses.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak ada data untuk diekspor.')),
        );
        setState(() => _isLoading = false); // Hentikan loading
        return;
      }

      // Siapkan data untuk CSV
      List<List<dynamic>> rows = [];
      rows.add(["Tanggal", "Judul", "Jumlah", "Kategori", "Deskripsi"]);

      // Tambahkan data transaksi
      for (var expense in expenses) {
        // ## PERBAIKAN DI SINI ##
        String categoryName;
        try {
          // Coba cari nama kategori
          categoryName = categories.firstWhere((cat) => cat.id == expense.categoryId).name;
        } catch (e) {
          // Jika tidak ketemu (misal: kategori sudah dihapus), beri nilai default
          categoryName = 'Tanpa Kategori';
        }

        rows.add([
          expense.date.toIso8601String().substring(0, 10),
          expense.title,
          expense.amount,
          categoryName,
          expense.description ?? ''
        ]);
      }

      // Ubah data menjadi format string CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Simpan file ke direktori sementara
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/laporan_pengeluaran.csv';
      final file = File(path);
      await file.writeAsString(csv);

      // Bagikan file menggunakan share_plus
      final result = await Share.shareXFiles([XFile(path)], text: 'Berikut adalah laporan pengeluaran Anda.');
      
      if (mounted && result.status == ShareResultStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File berhasil diekspor!'), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ekspor Data'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.file_download_done_rounded, size: 80, color: Colors.teal),
              const SizedBox(height: 16),
              const Text(
                'Unduh Riwayat Transaksi',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Semua data pengeluaran Anda akan diubah menjadi file CSV yang bisa dibuka di Excel atau Google Sheets.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: 'Ekspor Sekarang',
                onPressed: _exportData,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}