import 'package:flutter/material.dart';
// DITAMBAHKAN: Import untuk screen-screen yang digunakan
import 'package:smart_expense_tracker/screens/home/dashboard_tab.dart';
import 'package:smart_expense_tracker/screens/home/expenses_tab.dart';
import 'package:smart_expense_tracker/screens/home/profile_tab.dart';
import 'package:smart_expense_tracker/screens/expense/add_expense_screen.dart'; // <-- IMPORT INI

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // PERBAIKAN: Hapus 'const' dari sini
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardTab(),
    const ExpensesTab(),
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
           // Baris ini sekarang akan berfungsi karena AddExpenseScreen sudah di-import
           Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen()));
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4.0,
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
              IconButton(icon: const Icon(Icons.dashboard_rounded), onPressed: () => _onItemTapped(0), color: _selectedIndex == 0 ? Theme.of(context).colorScheme.primary : Colors.grey),
              IconButton(icon: const Icon(Icons.receipt_long_rounded), onPressed: () => _onItemTapped(1), color: _selectedIndex == 1 ? Theme.of(context).colorScheme.primary : Colors.grey),
              const SizedBox(width: 40), // The space for the FAB
              IconButton(icon: const Icon(Icons.bar_chart_rounded), onPressed: () { /* TODO: Analytics Tab */ }, color: Colors.grey),
              IconButton(icon: const Icon(Icons.person_rounded), onPressed: () => _onItemTapped(2), color: _selectedIndex == 2 ? Theme.of(context).colorScheme.primary : Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}