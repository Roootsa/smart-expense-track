import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_expense_tracker/providers/auth_provider.dart';
import 'package:smart_expense_tracker/providers/theme_provider.dart';

// DITAMBAHKAN: Import untuk semua halaman pengaturan
import 'package:smart_expense_tracker/screens/settings/edit_profile_screen.dart';
import 'package:smart_expense_tracker/screens/category/manage_categories_screen.dart';
import 'package:smart_expense_tracker/screens/settings/bill_reminders_screen.dart';
import 'package:smart_expense_tracker/screens/settings/export_data_screen.dart';


class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // --- Bagian Info Pengguna ---
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                  style: TextStyle(fontSize: 36, color: theme.colorScheme.primary),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? 'Nama Pengguna',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@pengguna.com',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 30),

          // --- Grup Menu Pengaturan Akun & Data ---
          _buildSettingsGroup(context, theme, [
            _buildSettingsTile(
              context,
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.category_rounded,
              title: 'Kelola Kategori',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageCategoriesScreen())),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'Pengingat Tagihan',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillRemindersScreen())),
            ),
             _buildSettingsTile(
              context,
              icon: Icons.download_for_offline_rounded,
              title: 'Ekspor Data',
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExportDataScreen())),
            ),
          ]),

          const SizedBox(height: 20),

          // --- Grup Menu Pengaturan Aplikasi ---
          _buildSettingsGroup(context, theme, [
             ListTile(
              leading: Icon(Icons.dark_mode_rounded, color: theme.iconTheme.color),
              title: const Text('Mode Gelap'),
              trailing: Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                    activeColor: theme.colorScheme.primary,
                  );
                }
              ),
            ),
            _buildSettingsTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'Bantuan',
              onTap: () {}, // Kosongkan untuk saat ini
            ),
          ]),
          
          const SizedBox(height: 30),

          // --- Tombol Keluar ---
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: const Text('Keluar', style: TextStyle(color: Colors.red)),
            onTap: () => _showLogoutDialog(context, authProvider),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: Colors.red.withOpacity(0.1),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, ThemeData theme, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                authProvider.signOut();
              },
              child: const Text('Ya', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}