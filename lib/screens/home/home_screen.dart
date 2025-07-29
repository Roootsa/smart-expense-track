import 'package:flutter/material.dart';
import 'package:smart_expense_tracker/screens/expense/add_expense_screen.dart';
import 'package:smart_expense_tracker/screens/home/analytics_tab.dart'; // DITAMBAHKAN
import 'package:smart_expense_tracker/screens/home/dashboard_tab.dart';
import 'package:smart_expense_tracker/screens/home/expenses_tab.dart';
import 'package:smart_expense_tracker/screens/home/profile_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // PERBARUI DAFTAR WIDGET INI
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardTab(),
    const ExpensesTab(),
    const AnalyticsTab(), // Tambahkan AnalyticsTab di urutan ke-3
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildNavItem(icon: Icons.dashboard_rounded, index: 0),
              _buildNavItem(icon: Icons.receipt_long_rounded, index: 1),
              const SizedBox(width: 40), // Spasi untuk FAB
              _buildNavItem(icon: Icons.bar_chart_rounded, index: 2), // Perbarui index
              _buildNavItem(icon: Icons.person_rounded, index: 3), // Perbarui index
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat item navigasi
  Widget _buildNavItem({required IconData icon, required int index}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => _onItemTapped(index),
      color: _selectedIndex == index ? Theme.of(context).colorScheme.primary : Colors.grey,
    );
  }
}