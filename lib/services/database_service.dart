import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/goal.dart';
import '../models/user_settings.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'task_manager.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        startTime INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        priority INTEGER NOT NULL,
        tags TEXT,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        goalId TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE goals(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        category INTEGER NOT NULL,
        type INTEGER NOT NULL,
        targetDate INTEGER NOT NULL,
        progress REAL NOT NULL DEFAULT 0.0,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        linkedTasks TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings(
        id INTEGER PRIMARY KEY,
        lifespan INTEGER NOT NULL,
        birthDate INTEGER NOT NULL,
        theme TEXT NOT NULL,
        workDayStartHour INTEGER NOT NULL,
        workDayStartMinute INTEGER NOT NULL,
        workDayEndHour INTEGER NOT NULL,
        workDayEndMinute INTEGER NOT NULL,
        autoMoveIncompleteTasks INTEGER NOT NULL,
        defaultTaskDurationMinutes INTEGER NOT NULL,
        taskReminders INTEGER NOT NULL,
        goalDeadlines INTEGER NOT NULL,
        dailyReflection INTEGER NOT NULL,
        streakAchievements INTEGER NOT NULL
      )
    ''');
  }

  // Task CRUD operations
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final List<Map<String, dynamic>> maps = await db.query(
      'tasks',
      where: 'startTime >= ? AND startTime < ?',
      whereArgs: [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch],
      orderBy: 'startTime ASC',
    );
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Goal CRUD operations
  Future<int> insertGoal(Goal goal) async {
    final db = await database;
    return await db.insert('goals', goal.toMap());
  }

  Future<List<Goal>> getGoals() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('goals');
    return List.generate(maps.length, (i) => Goal.fromMap(maps[i]));
  }

  Future<int> updateGoal(Goal goal) async {
    final db = await database;
    return await db.update(
      'goals',
      goal.toMap(),
      where: 'id = ?',
      whereArgs: [goal.id],
    );
  }

  Future<int> deleteGoal(String id) async {
    final db = await database;
    return await db.delete(
      'goals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // User Settings operations
  Future<int> insertOrUpdateSettings(UserSettings settings) async {
    final db = await database;
    final existing = await db.query('user_settings', limit: 1);
    
    if (existing.isEmpty) {
      return await db.insert('user_settings', settings.toMap());
    } else {
      return await db.update('user_settings', settings.toMap(), where: 'id = 1');
    }
  }

  Future<UserSettings?> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_settings', limit: 1);
    
    if (maps.isEmpty) return null;
    return UserSettings.fromMap(maps.first);
  }

  // Analytics queries
  Future<Map<String, dynamic>> getProductivityStats(DateTime startDate, DateTime endDate) async {
    final db = await database;
    
    final totalTasks = await db.rawQuery('''
      SELECT COUNT(*) as count FROM tasks 
      WHERE startTime >= ? AND startTime < ?
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final completedTasks = await db.rawQuery('''
      SELECT COUNT(*) as count FROM tasks 
      WHERE startTime >= ? AND startTime < ? AND isCompleted = 1
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    final totalTime = await db.rawQuery('''
      SELECT SUM(duration) as total FROM tasks 
      WHERE startTime >= ? AND startTime < ? AND isCompleted = 1
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
    
    return {
      'totalTasks': totalTasks.first['count'] as int,
      'completedTasks': completedTasks.first['count'] as int,
      'totalProductiveMinutes': totalTime.first['total'] as int? ?? 0,
    };
  }

  Future<List<Map<String, dynamic>>> getTasksByCategory(DateTime startDate, DateTime endDate) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT tags, COUNT(*) as count, SUM(duration) as totalDuration
      FROM tasks 
      WHERE startTime >= ? AND startTime < ? AND isCompleted = 1
      GROUP BY tags
    ''', [startDate.millisecondsSinceEpoch, endDate.millisecondsSinceEpoch]);
  }
}