import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'cuteapp.db');
    return openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY, title TEXT, category TEXT, emoji TEXT,
        time INTEGER, repeatDays TEXT, isActive INTEGER, note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY, title TEXT, emoji TEXT, color TEXT,
        streak INTEGER, longestStreak INTEGER, completedDates TEXT, createdAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE grocery_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, emoji TEXT,
        isChecked INTEGER, quantity INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE fitness_logs (
        id TEXT PRIMARY KEY, type TEXT, value REAL, unit TEXT,
        emoji TEXT, date INTEGER, note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE nutrition_days (
        id TEXT PRIMARY KEY, date TEXT, type TEXT, emoji TEXT, note TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE flights (
        id TEXT PRIMARY KEY, flightNumber TEXT, "from" TEXT, "to" TEXT,
        departureTime INTEGER, gate TEXT, seat TEXT, airline TEXT, reminderSet INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE shopping_items (
        id TEXT PRIMARY KEY, name TEXT, category TEXT, emoji TEXT,
        isChecked INTEGER, quantity INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_plans (
        id TEXT PRIMARY KEY, name TEXT, emoji TEXT, createdAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE workout_exercises (
        id TEXT PRIMARY KEY, planId TEXT, name TEXT, sets INTEGER, reps INTEGER,
        weight REAL, weightUnit TEXT, note TEXT, isCompleted INTEGER, sortOrder INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE learning_goals (
        id TEXT PRIMARY KEY, title TEXT, subject TEXT, emoji TEXT,
        createdAt INTEGER, targetDate INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE learning_tasks (
        id TEXT PRIMARY KEY, goalId TEXT, title TEXT, isCompleted INTEGER, sortOrder INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shopping_items (
          id TEXT PRIMARY KEY, name TEXT, category TEXT, emoji TEXT,
          isChecked INTEGER, quantity INTEGER
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_plans (
          id TEXT PRIMARY KEY, name TEXT, emoji TEXT, createdAt INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS workout_exercises (
          id TEXT PRIMARY KEY, planId TEXT, name TEXT, sets INTEGER, reps INTEGER,
          weight REAL, weightUnit TEXT, note TEXT, isCompleted INTEGER, sortOrder INTEGER
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS learning_goals (
          id TEXT PRIMARY KEY, title TEXT, subject TEXT, emoji TEXT,
          createdAt INTEGER, targetDate INTEGER
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS learning_tasks (
          id TEXT PRIMARY KEY, goalId TEXT, title TEXT, isCompleted INTEGER, sortOrder INTEGER
        )
      ''');
    }
  }

  // Generic CRUD
  Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await database;
    return db.query(table);
  }

  Future<void> update(
      String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String table, String id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll(String table) async {
    final db = await database;
    await db.delete(table);
  }

  Future<void> clearTable(String table) async {
    final db = await database;
    await db.delete(table);
  }

  // Workout helpers
  Future<void> ensureWorkoutTables() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_plans (
        id TEXT PRIMARY KEY, name TEXT, emoji TEXT, createdAt INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS workout_exercises (
        id TEXT PRIMARY KEY, planId TEXT, name TEXT, sets INTEGER,
        reps INTEGER, weightKg REAL, note TEXT, sortOrder INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getExercisesForPlan(String planId) async {
    final db = await database;
    return db.query('workout_exercises',
        where: 'planId = ?', whereArgs: [planId], orderBy: 'sortOrder ASC');
  }

  Future<void> deleteExercisesForPlan(String planId) async {
    final db = await database;
    await db
        .delete('workout_exercises', where: 'planId = ?', whereArgs: [planId]);
  }

  // Learning helpers
  Future<void> ensureLearningTables() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS learning_goals (
        id TEXT PRIMARY KEY, title TEXT, subject TEXT, emoji TEXT,
        createdAt INTEGER, targetDate INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS learning_tasks (
        id TEXT PRIMARY KEY, goalId TEXT, title TEXT,
        isCompleted INTEGER, sortOrder INTEGER
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getTasksForGoal(String goalId) async {
    final db = await database;
    return db.query('learning_tasks',
        where: 'goalId = ?', whereArgs: [goalId], orderBy: 'sortOrder ASC');
  }

  Future<void> deleteTasksForGoal(String goalId) async {
    final db = await database;
    await db.delete('learning_tasks', where: 'goalId = ?', whereArgs: [goalId]);
  }

  // Subscription helpers
  Future<void> ensureSubscriptionTable() async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT PRIMARY KEY, name TEXT, emoji TEXT, category TEXT,
        amount REAL, currency TEXT, billingCycle TEXT,
        nextBillingDate INTEGER, reminderEnabled INTEGER,
        reminderDaysBefore INTEGER, note TEXT
      )
    ''');
  }
}
