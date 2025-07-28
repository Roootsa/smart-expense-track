import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/providers/auth_provider.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/utils/helpers.dart';
import 'package:smart_expense_tracker/widgets/expense_card.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Halo,', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey)),
            Text(
              authProvider.userModel?.displayName ?? 'User',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: theme.iconTheme.color),
            onPressed: () { /* TODO: Navigasi ke halaman notifikasi tagihan */ },
          ),
        ],
      ),
      // Gunakan Consumer untuk mendapatkan data terbaru dari ExpenseProvider
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          // Tampilkan loading jika data belum siap
          if (expenseProvider.isLoadingExpenses || expenseProvider.isLoadingCategories) {
            return const Center(child: CircularProgressIndicator());
          }

          // Tampilkan pesan jika tidak ada transaksi sama sekali
          if (expenseProvider.expenses.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada transaksi.\nMulai catat pengeluaranmu!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // Tampilan utama jika data sudah ada
          return RefreshIndicator(
            onRefresh: () async {
              // TODO: Implement refresh logic if needed
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSummaryCard(context, expenseProvider),
                const SizedBox(height: 24),
                _buildChartCard(context, expenseProvider),
                const SizedBox(height: 24),
                _buildRecentTransactions(context, expenseProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET UNTUK KARTU RINGKASAN ---
  Widget _buildSummaryCard(BuildContext context, ExpenseProvider expenseProvider) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, Colors.teal],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Pengeluaran Bulan Ini', style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            // Menggunakan data asli dari provider
            formatCurrency(expenseProvider.monthlyTotal),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // --- WIDGET UNTUK KARTU GRAFIK ---
  Widget _buildChartCard(BuildContext context, ExpenseProvider expenseProvider) {
    final theme = Theme.of(context);
    final categoryExpenses = expenseProvider.expensesByCategory;
    final totalExpense = expenseProvider.monthlyTotal;

    // Jangan tampilkan kartu jika tidak ada pengeluaran bulan ini
    if (totalExpense == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan Kategori', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Row(
              children: [
                // Pie Chart
                SizedBox(
                  height: 150,
                  width: 150,
                  child: PieChart(
                    PieChartData(
                      sections: categoryExpenses.entries.map((entry) {
                        final category = expenseProvider.categories.firstWhere((c) => c.id == entry.key);
                        final percentage = (entry.value / totalExpense) * 100;
                        return PieChartSectionData(
                          color: category.color,
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      }).toList(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 2,
                      centerSpaceRadius: 35,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                // Legenda
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categoryExpenses.entries.map((entry) {
                      final category = expenseProvider.categories.firstWhere((c) => c.id == entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Container(width: 12, height: 12, color: category.color),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // --- WIDGET UNTUK TRANSAKSI TERAKHIR ---
  Widget _buildRecentTransactions(BuildContext context, ExpenseProvider expenseProvider) {
    final theme = Theme.of(context);
    // Ambil 3 transaksi terakhir
    final recentExpenses = expenseProvider.expenses.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaksi Terakhir', style: theme.textTheme.titleLarge),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentExpenses.length,
          itemBuilder: (context, index) {
            return ExpenseCard(expense: recentExpenses[index]);
          },
        ),
      ],
    );
  }
}