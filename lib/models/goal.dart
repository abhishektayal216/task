enum GoalType { daily, weekly, monthly, yearly }

enum GoalCategory {
  workCareer,
  healthFitness,
  personalDevelopment,
  learningSkills,
  relationships,
  financial,
  custom
}

class Goal {
  final String id;
  final String title;
  final String description;
  final GoalCategory category;
  final GoalType type;
  final DateTime targetDate;
  final double progress;
  final bool isCompleted;
  final List<String> linkedTasks;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.type,
    required this.targetDate,
    this.progress = 0.0,
    this.isCompleted = false,
    required this.linkedTasks,
    required this.createdAt,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    GoalCategory? category,
    GoalType? type,
    DateTime? targetDate,
    double? progress,
    bool? isCompleted,
    List<String>? linkedTasks,
    DateTime? createdAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      linkedTasks: linkedTasks ?? this.linkedTasks,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.index,
      'type': type.index,
      'targetDate': targetDate.millisecondsSinceEpoch,
      'progress': progress,
      'isCompleted': isCompleted ? 1 : 0,
      'linkedTasks': linkedTasks.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: GoalCategory.values[map['category']],
      type: GoalType.values[map['type']],
      targetDate: DateTime.fromMillisecondsSinceEpoch(map['targetDate']),
      progress: map['progress'].toDouble(),
      isCompleted: map['isCompleted'] == 1,
      linkedTasks: map['linkedTasks'].toString().split(',').where((task) => task.isNotEmpty).toList(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  String get categoryText {
    switch (category) {
      case GoalCategory.workCareer:
        return 'Work & Career';
      case GoalCategory.healthFitness:
        return 'Health & Fitness';
      case GoalCategory.personalDevelopment:
        return 'Personal Development';
      case GoalCategory.learningSkills:
        return 'Learning & Skills';
      case GoalCategory.relationships:
        return 'Relationships';
      case GoalCategory.financial:
        return 'Financial';
      case GoalCategory.custom:
        return 'Custom';
    }
  }

  String get typeText {
    switch (type) {
      case GoalType.daily:
        return 'Daily';
      case GoalType.weekly:
        return 'Weekly';
      case GoalType.monthly:
        return 'Monthly';
      case GoalType.yearly:
        return 'Yearly';
    }
  }
}