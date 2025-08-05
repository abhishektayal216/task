import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

class Task {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final Duration duration;
  final TaskPriority priority;
  final List<String> tags;
  final bool isCompleted;
  final String? goalId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.duration,
    required this.priority,
    required this.tags,
    this.isCompleted = false,
    this.goalId,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime get endTime => startTime.add(duration);

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    Duration? duration,
    TaskPriority? priority,
    List<String>? tags,
    bool? isCompleted,
    String? goalId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      goalId: goalId ?? this.goalId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'duration': duration.inMinutes,
      'priority': priority.index,
      'tags': tags.join(','),
      'isCompleted': isCompleted ? 1 : 0,
      'goalId': goalId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      duration: Duration(minutes: map['duration']),
      priority: TaskPriority.values[map['priority']],
      tags: map['tags'].toString().split(',').where((tag) => tag.isNotEmpty).toList(),
      isCompleted: map['isCompleted'] == 1,
      goalId: map['goalId'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String get priorityText {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }
}