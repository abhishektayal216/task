import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/database_service.dart';

class SettingsProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  
  UserSettings? _settings;
  bool _isLoading = false;

  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _settings = await _databaseService.getSettings();
      
      // Create default settings if none exist
      if (_settings == null) {
        _settings = UserSettings(
          birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
        );
        await saveSettings(_settings!);
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      // Create default settings on error
      _settings = UserSettings(
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      await _databaseService.insertOrUpdateSettings(settings);
      _settings = settings;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  Future<void> updateLifespan(int lifespan) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(lifespan: lifespan);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateBirthDate(DateTime birthDate) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(birthDate: birthDate);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateTheme(String theme) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(theme: theme);
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateWorkHours(TimeOfDay start, TimeOfDay end) async {
    if (_settings != null) {
      final updatedSettings = _settings!.copyWith(
        workDayStart: start,
        workDayEnd: end,
      );
      await saveSettings(updatedSettings);
    }
  }

  Future<void> updateNotificationSetting(String key, bool value) async {
    if (_settings != null) {
      final updatedNotifications = Map<String, bool>.from(_settings!.notificationSettings);
      updatedNotifications[key] = value;
      
      final updatedSettings = _settings!.copyWith(
        notificationSettings: updatedNotifications,
      );
      await saveSettings(updatedSettings);
    }
  }

  ThemeMode get themeMode {
    switch (_settings?.theme ?? 'system') {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}