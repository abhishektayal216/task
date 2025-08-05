import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../services/database_service.dart';

class GoalProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  List<Goal> get dailyGoals => _goals.where((goal) => goal.type == GoalType.daily).toList();
  List<Goal> get weeklyGoals => _goals.where((goal) => goal.type == GoalType.weekly).toList();
  List<Goal> get monthlyGoals => _goals.where((goal) => goal.type == GoalType.monthly).toList();
  List<Goal> get yearlyGoals => _goals.where((goal) => goal.type == GoalType.yearly).toList();

  Future<void> loadGoals() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _goals = await _databaseService.getGoals();
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    try {
      final newGoal = goal.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
      );
      
      await _databaseService.insertGoal(newGoal);
      _goals.add(newGoal);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding goal: $e');
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _databaseService.updateGoal(goal);
      
      final index = _goals.indexWhere((g) => g.id == goal.id);
      if (index != -1) {
        _goals[index] = goal;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating goal: $e');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _databaseService.deleteGoal(goalId);
      _goals.removeWhere((goal) => goal.id == goalId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting goal: $e');
    }
  }

  Future<void> updateGoalProgress(String goalId, double progress) async {
    try {
      final goalIndex = _goals.indexWhere((goal) => goal.id == goalId);
      if (goalIndex != -1) {
        final goal = _goals[goalIndex];
        final updatedGoal = goal.copyWith(
          progress: progress.clamp(0.0, 100.0),
          isCompleted: progress >= 100.0,
        );
        await updateGoal(updatedGoal);
      }
    } catch (e) {
      debugPrint('Error updating goal progress: $e');
    }
  }

  List<Goal> getGoalsByCategory(GoalCategory category) {
    return _goals.where((goal) => goal.category == category).toList();
  }

  int getCompletedGoalsCount() {
    return _goals.where((goal) => goal.isCompleted).length;
  }

  double getOverallProgress() {
    if (_goals.isEmpty) return 0.0;
    
    final totalProgress = _goals.fold<double>(
      0.0, 
      (sum, goal) => sum + goal.progress,
    );
    
    return totalProgress / _goals.length;
  }
}