import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/settings_provider.dart';
import '../models/user_settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<SettingsProvider>(
          builder: (context, settingsProvider, child) {
            if (settingsProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final settings = settingsProvider.settings;
            if (settings == null) {
              return _buildInitialSetup(settingsProvider);
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildPersonalSection(settings, settingsProvider),
                  _buildAppPreferencesSection(settings, settingsProvider),
                  _buildTaskManagementSection(settings, settingsProvider),
                  _buildNotificationsSection(settings, settingsProvider),
                  _buildDataManagementSection(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialSetup(SettingsProvider settingsProvider) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to Task Manager',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s set up your personal information to get started.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _showInitialSetupDialog(settingsProvider),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalSection(UserSettings settings, SettingsProvider provider) {
    return _buildSection(
      'Personal Information',
      [
        _buildListTile(
          'Birth Date',
          DateFormat('MMMM d, yyyy').format(settings.birthDate),
          Icons.cake,
          () => _showBirthDatePicker(settings, provider),
        ),
        _buildListTile(
          'Expected Lifespan',
          '${settings.lifespan} years',
          Icons.timeline,
          () => _showLifespanDialog(settings, provider),
        ),
        _buildListTile(
          'Current Age',
          '${settings.currentAge} years old',
          Icons.person,
          null,
        ),
      ],
    );
  }

  Widget _buildAppPreferencesSection(UserSettings settings, SettingsProvider provider) {
    return _buildSection(
      'App Preferences',
      [
        _buildListTile(
          'Theme',
          _getThemeDisplayName(settings.theme),
          Icons.palette,
          () => _showThemeDialog(settings, provider),
        ),
      ],
    );
  }

  Widget _buildTaskManagementSection(UserSettings settings, SettingsProvider provider) {
    return _buildSection(
      'Task Management',
      [
        _buildSwitchTile(
          'Auto-move incomplete tasks',
          'Move unfinished tasks to the next day',
          Icons.auto_fix_high,
          settings.autoMoveIncompleteTasks,
          (value) => _updateAutoMove(settings, provider, value),
        ),
        _buildListTile(
          'Default task duration',
          '${settings.defaultTaskDuration.inMinutes} minutes',
          Icons.timer,
          () => _showDurationDialog(settings, provider),
        ),
        _buildListTile(
          'Work day hours',
          '${settings.workDayStart.format(context)} - ${settings.workDayEnd.format(context)}',
          Icons.work,
          () => _showWorkHoursDialog(settings, provider),
        ),
      ],
    );
  }

  Widget _buildNotificationsSection(UserSettings settings, SettingsProvider provider) {
    return _buildSection(
      'Notifications',
      [
        _buildSwitchTile(
          'Task reminders',
          'Get notified about upcoming tasks',
          Icons.notifications,
          settings.notificationSettings['taskReminders'] ?? true,
          (value) => provider.updateNotificationSetting('taskReminders', value),
        ),
        _buildSwitchTile(
          'Goal deadlines',
          'Alerts for approaching goal deadlines',
          Icons.flag,
          settings.notificationSettings['goalDeadlines'] ?? true,
          (value) => provider.updateNotificationSetting('goalDeadlines', value),
        ),
        _buildSwitchTile(
          'Daily reflection',
          'Evening prompts for daily reflection',
          Icons.self_improvement,
          settings.notificationSettings['dailyReflection'] ?? true,
          (value) => provider.updateNotificationSetting('dailyReflection', value),
        ),
        _buildSwitchTile(
          'Streak achievements',
          'Celebrate your productivity streaks',
          Icons.celebration,
          settings.notificationSettings['streakAchievements'] ?? true,
          (value) => provider.updateNotificationSetting('streakAchievements', value),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return _buildSection(
      'Data Management',
      [
        _buildListTile(
          'Export data',
          'Download your tasks and goals',
          Icons.download,
          _exportData,
        ),
        _buildListTile(
          'Clear all data',
          'Reset the app to initial state',
          Icons.delete_forever,
          _showClearDataDialog,
          textColor: Colors.red,
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback? onTap, {
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showInitialSetupDialog(SettingsProvider provider) {
    DateTime selectedBirthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
    int selectedLifespan = 80;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Personal Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Birth Date'),
                subtitle: Text(DateFormat('MMMM d, yyyy').format(selectedBirthDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedBirthDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() {
                      selectedBirthDate = date;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              Text('Expected Lifespan: $selectedLifespan years'),
              Slider(
                value: selectedLifespan.toDouble(),
                min: 60,
                max: 120,
                divisions: 60,
                onChanged: (value) {
                  setState(() {
                    selectedLifespan = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final settings = UserSettings(
                  birthDate: selectedBirthDate,
                  lifespan: selectedLifespan,
                );
                provider.saveSettings(settings);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBirthDatePicker(UserSettings settings, SettingsProvider provider) async {
    final date = await showDatePicker(
      context: context,
      initialDate: settings.birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (date != null) {
      provider.updateBirthDate(date);
    }
  }

  void _showLifespanDialog(UserSettings settings, SettingsProvider provider) {
    int selectedLifespan = settings.lifespan;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Expected Lifespan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selectedLifespan years'),
              Slider(
                value: selectedLifespan.toDouble(),
                min: 60,
                max: 120,
                divisions: 60,
                onChanged: (value) {
                  setState(() {
                    selectedLifespan = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                provider.updateLifespan(selectedLifespan);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(UserSettings settings, SettingsProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'light',
              groupValue: settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'dark',
              groupValue: settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'system',
              groupValue: settings.theme,
              onChanged: (value) {
                if (value != null) {
                  provider.updateTheme(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDurationDialog(UserSettings settings, SettingsProvider provider) {
    int selectedMinutes = settings.defaultTaskDuration.inMinutes;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Default Task Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$selectedMinutes minutes'),
              Slider(
                value: selectedMinutes.toDouble(),
                min: 15,
                max: 480,
                divisions: 31,
                onChanged: (value) {
                  setState(() {
                    selectedMinutes = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final updatedSettings = settings.copyWith(
                  defaultTaskDuration: Duration(minutes: selectedMinutes),
                );
                provider.saveSettings(updatedSettings);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorkHoursDialog(UserSettings settings, SettingsProvider provider) async {
    TimeOfDay? startTime = await showTimePicker(
      context: context,
      initialTime: settings.workDayStart,
    );
    
    if (startTime != null) {
      if (!mounted) return;
      
      TimeOfDay? endTime = await showTimePicker(
        context: context,
        initialTime: settings.workDayEnd,
      );
      
      if (endTime != null) {
        provider.updateWorkHours(startTime, endTime);
      }
    }
  }

  void _updateAutoMove(UserSettings settings, SettingsProvider provider, bool value) {
    final updatedSettings = settings.copyWith(autoMoveIncompleteTasks: value);
    provider.saveSettings(updatedSettings);
  }

  void _exportData() {
    // Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your tasks, goals, and settings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement clear data functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear data functionality coming soon!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      default:
        return 'System';
    }
  }
}