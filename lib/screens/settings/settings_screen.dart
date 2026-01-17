import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/professional_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _attendanceReminders = true;
  bool _gradeNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _attendanceReminders = prefs.getBool('attendance_reminders') ?? true;
      _gradeNotifications = prefs.getBool('grade_notifications') ?? true;
    });
  }

  Future<void> _saveSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppPadding.lg),
        children: [
          // Theme Section
          _buildSectionHeader('Appearance'),
          ProfessionalCard(
            child: Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  subtitle: const Text('Toggle between light and dark theme'),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppPadding.lg),

          // Notifications Section
          _buildSectionHeader('Notifications'),
          ProfessionalCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Enable Notifications'),
                  subtitle: const Text('Receive notifications from the app'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                    _saveSetting('notifications_enabled', value);
                  },
                  secondary: const Icon(Icons.notifications, color: AppColors.primary),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Attendance Reminders'),
                  subtitle: const Text('Get reminded to mark attendance'),
                  value: _attendanceReminders && _notificationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _attendanceReminders = value;
                          });
                          _saveSetting('attendance_reminders', value);
                        }
                      : null,
                  secondary: const Icon(Icons.calendar_today, color: AppColors.accent),
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text('Grade Notifications'),
                  subtitle: const Text('Get notified when grades are submitted'),
                  value: _gradeNotifications && _notificationsEnabled,
                  onChanged: _notificationsEnabled
                      ? (value) {
                          setState(() {
                            _gradeNotifications = value;
                          });
                          _saveSetting('grade_notifications', value);
                        }
                      : null,
                  secondary: const Icon(Icons.grade, color: AppColors.secondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppPadding.lg),

          // Data Management Section
          _buildSectionHeader('Data Management'),
          ProfessionalCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: AppColors.info),
                  title: const Text('Export Data'),
                  subtitle: const Text('Export your data to CSV/JSON'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showExportDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.upload, color: AppColors.warning),
                  title: const Text('Import Data'),
                  subtitle: const Text('Import data from CSV file'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showImportDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.backup, color: AppColors.success),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Create a backup of all your data'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showBackupDialog();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.restore, color: AppColors.accent),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Restore from a previous backup'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    _showRestoreDialog();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppPadding.lg),

          // Account Section
          _buildSectionHeader('Account'),
          ProfessionalCard(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person, color: AppColors.primary),
                      title: const Text('Profile'),
                      subtitle: Text('Logged in as: ${authProvider.currentUser?.username ?? 'Guest'}'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text('Logout'),
                      subtitle: const Text('Sign out of your account'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showLogoutDialog(context, authProvider);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppPadding.lg),

          // About Section
          _buildSectionHeader('About'),
          ProfessionalCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info, color: AppColors.primary),
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.description, color: AppColors.secondary),
                  title: const Text('Terms of Service'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show terms
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: AppColors.accent),
                  title: const Text('Privacy Policy'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // Show privacy policy
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppPadding.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Text('This feature will export all your data to a CSV/JSON file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export feature coming soon!')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Data'),
        content: const Text('This feature will import data from a CSV file.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Import feature coming soon!')),
              );
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('This will create a backup of all your data.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup feature coming soon!')),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Data'),
        content: const Text('This will restore data from a previous backup. All current data will be replaced.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore feature coming soon!')),
              );
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              authProvider.logout();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

