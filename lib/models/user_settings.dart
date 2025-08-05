import 'package:flutter/material.dart';

class UserSettings {
  final int lifespan;
  final DateTime birthDate;
  final String theme;
  final TimeOfDay workDayStart;
  final TimeOfDay workDayEnd;
  final bool autoMoveIncompleteTasks;
  final Duration defaultTaskDuration;
  final Map<String, bool> notificationSettings;

  UserSettings({
    this.lifespan = 80,
    required this.birthDate,
    this.theme = 'system',
    this.workDayStart = const TimeOfDay(hour: 9, minute: 0),
    this.workDayEnd = const TimeOfDay(hour: 17, minute: 0),
    this.autoMoveIncompleteTasks = true,
    this.defaultTaskDuration = const Duration(hours: 1),
    this.notificationSettings = const {
      'taskReminders': true,
      'goalDeadlines': true,
      'dailyReflection': true,
      'streakAchievements': true,
    },
  });

  UserSettings copyWith({
    int? lifespan,
    DateTime? birthDate,
    String? theme,
    TimeOfDay? workDayStart,
    TimeOfDay? workDayEnd,
    bool? autoMoveIncompleteTasks,
    Duration? defaultTaskDuration,
    Map<String, bool>? notificationSettings,
  }) {
    return UserSettings(
      lifespan: lifespan ?? this.lifespan,
      birthDate: birthDate ?? this.birthDate,
      theme: theme ?? this.theme,
      workDayStart: workDayStart ?? this.workDayStart,
      workDayEnd: workDayEnd ?? this.workDayEnd,
      autoMoveIncompleteTasks: autoMoveIncompleteTasks ?? this.autoMoveIncompleteTasks,
      defaultTaskDuration: defaultTaskDuration ?? this.defaultTaskDuration,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lifespan': lifespan,
      'birthDate': birthDate.millisecondsSinceEpoch,
      'theme': theme,
      'workDayStartHour': workDayStart.hour,
      'workDayStartMinute': workDayStart.minute,
      'workDayEndHour': workDayEnd.hour,
      'workDayEndMinute': workDayEnd.minute,
      'autoMoveIncompleteTasks': autoMoveIncompleteTasks ? 1 : 0,
      'defaultTaskDurationMinutes': defaultTaskDuration.inMinutes,
      'taskReminders': notificationSettings['taskReminders'] == true ? 1 : 0,
      'goalDeadlines': notificationSettings['goalDeadlines'] == true ? 1 : 0,
      'dailyReflection': notificationSettings['dailyReflection'] == true ? 1 : 0,
      'streakAchievements': notificationSettings['streakAchievements'] == true ? 1 : 0,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      lifespan: map['lifespan'],
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate']),
      theme: map['theme'],
      workDayStart: TimeOfDay(hour: map['workDayStartHour'], minute: map['workDayStartMinute']),
      workDayEnd: TimeOfDay(hour: map['workDayEndHour'], minute: map['workDayEndMinute']),
      autoMoveIncompleteTasks: map['autoMoveIncompleteTasks'] == 1,
      defaultTaskDuration: Duration(minutes: map['defaultTaskDurationMinutes']),
      notificationSettings: {
        'taskReminders': map['taskReminders'] == 1,
        'goalDeadlines': map['goalDeadlines'] == 1,
        'dailyReflection': map['dailyReflection'] == 1,
        'streakAchievements': map['streakAchievements'] == 1,
      },
    );
  }

  int get currentAge {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  int get yearsRemaining => lifespan - currentAge;
  int get monthsRemaining => yearsRemaining * 12;
  int get weeksRemaining => (yearsRemaining * 365.25 / 7).round();
  int get daysRemaining => (yearsRemaining * 365.25).round();
}