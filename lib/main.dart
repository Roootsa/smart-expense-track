import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart'; // DITAMBAHKAN: Import ini
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/firebase_options.dart';

import 'package:smart_expense_tracker/providers/auth_provider.dart';
import 'package:smart_expense_tracker/providers/expense_provider.dart';
import 'package:smart_expense_tracker/providers/theme_provider.dart';

import 'package:smart_expense_tracker/services/notification_service.dart';

import 'package:smart_expense_tracker/screens/splash_screen.dart';
import 'package:smart_expense_tracker/screens/auth/login_screen.dart';
import 'package:smart_expense_tracker/screens/home/home_screen.dart';

import 'package:smart_expense_tracker/utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ## PERBAIKAN DI SINI ##
  // Inisialisasi format tanggal untuk Bahasa Indonesia ('id_ID')
  await initializeDateFormatting('id_ID', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadTheme()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(null),
          update: (context, auth, previous) => ExpenseProvider(auth.user?.uid),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Smart Expense Tracker',
            theme: AppColors.lightTheme,
            darkTheme: AppColors.darkTheme,
            themeMode: themeProvider.themeMode,
            debugShowCheckedModeBanner: false,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.status == AuthStatus.uninitialized) {
      return const SplashScreen();
    } else if (authProvider.status == AuthStatus.authenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}