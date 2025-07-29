import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/utils/helpers.dart';

class AnalyticsTab extends StatelessWidget {
  const AnalyticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Pengeluaran'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingExpenses) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.expenses.isEmpty) {
            return const Center(child: Text('Belum ada data untuk dianalisis.'));
          }
          
          final weeklySummary = provider.weeklySpendingSummary;
          final maxY = weeklySummary.map((d) => d['amount'] as double).reduce((a, b) => a > b ? a : b) * 1.2;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Pengeluaran 7 Hari Terakhir', style: theme.textTheme.titleLarge),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: BarChart(
                  BarChartData(
                    maxY: maxY == 0 ? 100000 : maxY, // Atur nilai Y maks
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY/5),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 50, getTitlesWidget: (value, meta) => Text(formatCurrency(value).replaceAll('Rp ', '').replaceAll(',00', ''), style: const TextStyle(fontSize: 10)))),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final dayData = weeklySummary.firstWhere((d) => d['x_axis'] == value.toInt());
                            return Text(dayData['day'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold));
                          },
                          reservedSize: 30,
                        ),
                      ),
                    ),
                    barGroups: weeklySummary.map((data) {
                      return BarChartGroupData(
                        x: data['x_axis'] as int,
                        barRods: [
                          BarChartRodData(
                            toY: data['amount'] as double,
                            color: theme.colorScheme.primary,
                            width: 16,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          )
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}