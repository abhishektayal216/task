import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();
  
  List<Task> _tasks = [];
  List<Task> _todayTasks = [];
  bool _isLoading = false;

  List<Task> get tasks => _tasks;
  List<Task> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _tasks = await _databaseService.getTasks();
      await loadTodayTasks();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTodayTasks() async {
    try {
      final today = DateTime.now();
      _todayTasks = await _databaseService.getTasksForDate(today);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading today tasks: $e');
    }
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = task.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _databaseService.insertTask(newTask);
      _tasks.add(newTask);
      
      if (_isToday(newTask.startTime)) {
        _todayTasks.add(newTask);
        _todayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _databaseService.updateTask(updatedTask);
      
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
      
      final todayIndex = _todayTasks.indexWhere((t) => t.id == task.id);
      if (todayIndex != -1) {
        if (_isToday(updatedTask.startTime)) {
          _todayTasks[todayIndex] = updatedTask;
          _todayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
        } else {
          _todayTasks.removeAt(todayIndex);
        }
      } else if (_isToday(updatedTask.startTime)) {
        _todayTasks.add(updatedTask);
        _todayTasks.sort((a, b) => a.startTime.compareTo(b.startTime));
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _databaseService.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _todayTasks.removeWhere((task) => task.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final task = _tasks[taskIndex];
        final updatedTask = task.copyWith(
          isCompleted: !task.isCompleted,
          updatedAt: DateTime.now(),
        );
        await updateTask(updatedTask);
      }
    } catch (e) {
      debugPrint('Error toggling task completion: $e');
    }
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    try {
      return await _databaseService.getTasksForDate(date);
    } catch (e) {
      debugPrint('Error getting tasks for date: $e');
      return [];
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool hasTimeConflict(DateTime startTime, Duration duration, {String? excludeTaskId}) {
    final endTime = startTime.add(duration);
    
    return _todayTasks.any((task) {
      if (excludeTaskId != null && task.id == excludeTaskId) return false;
      
      final taskEndTime = task.endTime;
      return (startTime.isBefore(taskEndTime) && endTime.isAfter(task.startTime));
    });
  }

  double getTodayUtilization() {
    if (_todayTasks.isEmpty) return 0.0;
    
    final totalMinutes = _todayTasks.fold<int>(
      0, 
      (sum, task) => sum + task.duration.inMinutes,
    );
    
    // Assuming a 16-hour workday (6 AM to 10 PM)
    const availableMinutes = 16 * 60;
    return (totalMinutes / availableMinutes).clamp(0.0, 1.0);
  }

  int getTodayCompletedTasks() {
    return _todayTasks.where((task) => task.isCompleted).length;
  }

  int getTodayTotalTasks() {
    return _todayTasks.length;
  }
}