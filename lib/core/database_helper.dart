import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_model.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  static const String _databaseName =
      'fitness_pro_v2.db';

  static const int _databaseVersion = 3;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB(
      _databaseName,
    );

    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {
    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      filePath,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ============================================================
  // CREATE DATABASE
  // ============================================================

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    await db.execute(
      '''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        intensity TEXT NOT NULL DEFAULT 'Moderate',
        distance REAL,
        notes TEXT
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        water_glasses INTEGER NOT NULL DEFAULT 0,
        water_ml INTEGER NOT NULL DEFAULT 0,
        steps INTEGER NOT NULL DEFAULT 0,
        sleep_hours REAL NOT NULL DEFAULT 0
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        calories INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fat REAL NOT NULL DEFAULT 0
      )
      ''',
    );

    await db.execute(
      '''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        goal_weight REAL NOT NULL,
        starting_weight REAL NOT NULL
      )
      ''',
    );

    // ==========================================================
    // DAILY GOALS
    // ==========================================================

    await db.execute(
      '''
      CREATE TABLE daily_goals (
        id INTEGER PRIMARY KEY,
        steps_goal INTEGER NOT NULL DEFAULT 10000,
        water_goal_ml INTEGER NOT NULL DEFAULT 2500,
        calorie_goal INTEGER NOT NULL DEFAULT 2000,
        sleep_goal_minutes INTEGER NOT NULL DEFAULT 480
      )
      ''',
    );

    // ==========================================================
    // WEIGHT HISTORY
    // ==========================================================

    await db.execute(
      '''
      CREATE TABLE weight_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        weight REAL NOT NULL,
        date TEXT NOT NULL
      )
      ''',
    );

    // ==========================================================
    // SLEEP HISTORY
    // ==========================================================

    await db.execute(
      '''
      CREATE TABLE sleep_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sleep_start TEXT NOT NULL,
        sleep_end TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        date TEXT NOT NULL
      )
      ''',
    );

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'height': 1.75,
        'weight': 70.0,
        'goal_weight': 65.0,
        'starting_weight': 70.0,
      },
    );

    await db.insert(
      'daily_goals',
      {
        'id': 1,
        'steps_goal': 10000,
        'water_goal_ml': 2500,
        'calorie_goal': 2000,
        'sleep_goal_minutes': 480,
      },
    );

    await db.insert(
      'weight_history',
      {
        'weight': 70.0,
        'date': DateTime.now().toIso8601String(),
      },
    );

    await _createIndexes(db);
  }

  // ============================================================
  // DATABASE MIGRATION
  // ============================================================

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ==========================================================
    // VERSION 1 -> VERSION 2
    // ==========================================================

    if (oldVersion < 2) {
      final workoutColumns =
          await _columnNames(
        db,
        'workouts',
      );

      if (!workoutColumns.contains(
        'intensity',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN intensity
          TEXT NOT NULL
          DEFAULT 'Moderate'
          ''',
        );
      }

      if (!workoutColumns.contains(
        'distance',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN distance REAL
          ''',
        );
      }

      if (!workoutColumns.contains(
        'notes',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN notes TEXT
          ''',
        );
      }

      final habitColumns =
          await _columnNames(
        db,
        'habits',
      );

      if (!habitColumns.contains(
        'sleep_hours',
      )) {
        await db.execute(
          '''
          ALTER TABLE habits
          ADD COLUMN sleep_hours
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      await db.execute(
        '''
        DELETE FROM habits
        WHERE id NOT IN (
          SELECT MIN(id)
          FROM habits
          GROUP BY date
        )
        ''',
      );

      await db.execute(
        '''
        CREATE UNIQUE INDEX
        IF NOT EXISTS idx_habits_date
        ON habits(date)
        ''',
      );

      final mealColumns =
          await _columnNames(
        db,
        'meals',
      );

      if (!mealColumns.contains(
        'protein',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN protein
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      if (!mealColumns.contains(
        'carbs',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN carbs
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      if (!mealColumns.contains(
        'fat',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN fat
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      final profileColumns =
          await _columnNames(
        db,
        'user_profile',
      );

      if (!profileColumns.contains(
        'starting_weight',
      )) {
        await db.execute(
          '''
          ALTER TABLE user_profile
          ADD COLUMN starting_weight
          REAL NOT NULL DEFAULT 70
          ''',
        );

        await db.execute(
          '''
          UPDATE user_profile
          SET starting_weight = weight
          WHERE id = 1
          ''',
        );
      }
    }

    // ==========================================================
    // VERSION 2 -> VERSION 3
    // ==========================================================

    if (oldVersion < 3) {
      final habitColumns =
          await _columnNames(
        db,
        'habits',
      );

      if (!habitColumns.contains(
        'water_ml',
      )) {
        await db.execute(
          '''
          ALTER TABLE habits
          ADD COLUMN water_ml
          INTEGER NOT NULL DEFAULT 0
          ''',
        );

        // Convert old glasses into approximate ml.
        await db.execute(
          '''
          UPDATE habits
          SET water_ml = water_glasses * 250
          WHERE water_ml = 0
          ''',
        );
      }

      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS daily_goals (
          id INTEGER PRIMARY KEY,
          steps_goal INTEGER NOT NULL DEFAULT 10000,
          water_goal_ml INTEGER NOT NULL DEFAULT 2500,
          calorie_goal INTEGER NOT NULL DEFAULT 2000,
          sleep_goal_minutes INTEGER NOT NULL DEFAULT 480
        )
        ''',
      );

      await db.insert(
        'daily_goals',
        {
          'id': 1,
          'steps_goal': 10000,
          'water_goal_ml': 2500,
          'calorie_goal': 2000,
          'sleep_goal_minutes': 480,
        },
        conflictAlgorithm:
            ConflictAlgorithm.ignore,
      );

      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS weight_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          weight REAL NOT NULL,
          date TEXT NOT NULL
        )
        ''',
      );

      await db.execute(
        '''
        CREATE TABLE IF NOT EXISTS sleep_entries (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sleep_start TEXT NOT NULL,
          sleep_end TEXT NOT NULL,
          duration_minutes INTEGER NOT NULL,
          date TEXT NOT NULL
        )
        ''',
      );

      final countResult =
          await db.rawQuery(
        '''
        SELECT COUNT(*) AS count
        FROM weight_history
        ''',
      );

      final count =
          (countResult.first['count']
                  as num?)
              ?.toInt() ??
          0;

      if (count == 0) {
        final profile =
            await db.query(
          'user_profile',
          where: 'id = ?',
          whereArgs: [1],
          limit: 1,
        );

        if (profile.isNotEmpty) {
          await db.insert(
            'weight_history',
            {
              'weight':
                  (profile.first['weight']
                          as num)
                      .toDouble(),

              'date':
                  DateTime.now()
                      .toIso8601String(),
            },
          );
        }
      }

      await _createIndexes(db);
    }
  }

  Future<void> _createIndexes(
    Database db,
  ) async {
    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS
      idx_workouts_date
      ON workouts(date)
      ''',
    );

    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS
      idx_meals_date
      ON meals(date)
      ''',
    );

    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS
      idx_weight_history_date
      ON weight_history(date)
      ''',
    );

    await db.execute(
      '''
      CREATE INDEX IF NOT EXISTS
      idx_sleep_date
      ON sleep_entries(date)
      ''',
    );
  }

  Future<List<String>> _columnNames(
    Database db,
    String table,
  ) async {
    final info =
        await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    return info
        .map(
          (row) =>
              row['name'] as String,
        )
        .toList();
  }

  // ============================================================
  // PROFILE
  // ============================================================

  Future<Map<String, dynamic>>
      getUserProfile() async {
    final db = await database;

    final result =
        await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    const fallback = {
      'id': 1,
      'height': 1.75,
      'weight': 70.0,
      'goal_weight': 65.0,
      'starting_weight': 70.0,
    };

    await db.insert(
      'user_profile',
      fallback,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );

    return fallback;
  }

  Future<void> updateUserProfile({
    required double height,
    required double weight,
    required double goalWeight,
    required double startingWeight,
  }) async {
    final db = await database;

    final previous =
        await getUserProfile();

    final oldWeight =
        (previous['weight'] as num)
            .toDouble();

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'height': height,
        'weight': weight,
        'goal_weight': goalWeight,
        'starting_weight':
            startingWeight,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );

    if ((oldWeight - weight).abs() >
        0.01) {
      await insertWeightHistory(
        weight,
      );
    }
  }

  // ============================================================
  // WEIGHT HISTORY
  // ============================================================

  Future<int> insertWeightHistory(
    double weight,
  ) async {
    final db = await database;

    return db.insert(
      'weight_history',
      {
        'weight': weight,
        'date':
            DateTime.now()
                .toIso8601String(),
      },
    );
  }

  Future<List<Map<String, dynamic>>>
      getWeightHistory() async {
    final db = await database;

    return db.query(
      'weight_history',
      orderBy: 'date ASC',
    );
  }

  Future<int> deleteWeightHistory(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'weight_history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // DAILY GOALS
  // ============================================================

  Future<Map<String, dynamic>>
      getDailyGoals() async {
    final db = await database;

    final result =
        await db.query(
      'daily_goals',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    final defaults = {
      'id': 1,
      'steps_goal': 10000,
      'water_goal_ml': 2500,
      'calorie_goal': 2000,
      'sleep_goal_minutes': 480,
    };

    await db.insert(
      'daily_goals',
      defaults,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );

    return defaults;
  }

  Future<void> updateDailyGoals({
    required int stepsGoal,
    required int waterGoalMl,
    required int calorieGoal,
    required int sleepGoalMinutes,
  }) async {
    final db = await database;

    await db.insert(
      'daily_goals',
      {
        'id': 1,
        'steps_goal': stepsGoal,
        'water_goal_ml':
            waterGoalMl,
        'calorie_goal':
            calorieGoal,
        'sleep_goal_minutes':
            sleepGoalMinutes,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ============================================================
  // WORKOUT
  // ============================================================

  Future<int> insertWorkout(
    Workout workout,
  ) async {
    final db = await database;

    final map =
        workout.toMap();

    map.remove('id');

    return db.insert(
      'workouts',
      map,
    );
  }

  Future<List<Workout>>
      getAllWorkouts() async {
    final db = await database;

    final result =
        await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    return result
        .map(
          Workout.fromMap,
        )
        .toList();
  }

  Future<int> updateWorkout(
    Workout workout,
  ) async {
    if (workout.id == null) {
      return 0;
    }

    final db = await database;

    final map =
        workout.toMap();

    map.remove('id');

    return db.update(
      'workouts',
      map,
      where: 'id = ?',
      whereArgs: [
        workout.id,
      ],
    );
  }

  Future<int> deleteWorkout(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // MEALS
  // ============================================================

  Future<int> insertMeal(
    Map<String, dynamic> meal,
  ) async {
    final db = await database;

    return db.insert(
      'meals',
      meal,
    );
  }

  Future<List<Map<String, dynamic>>>
      getDailyMeals(
    String date,
  ) async {
    final db = await database;

    return db.query(
      'meals',
      where: 'date LIKE ?',
      whereArgs: [
        '$date%',
      ],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteMeal(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ============================================================
  // HABIT ROW
  // ============================================================

  Future<void> _ensureHabitRow(
    String date,
  ) async {
    final db = await database;

    await db.insert(
      'habits',
      {
        'date': date,
        'water_glasses': 0,
        'water_ml': 0,
        'steps': 0,
        'sleep_hours': 0.0,
      },
      conflictAlgorithm:
          ConflictAlgorithm.ignore,
    );
  }

  // ============================================================
  // WATER ML
  // ============================================================

  Future<int> updateWaterMl(
    String date,
    int amount,
  ) async {
    await _ensureHabitRow(
      date,
    );

    final db = await database;

    return db.update(
      'habits',
      {
        'water_ml': amount,
        'water_glasses':
            (amount / 250).round(),
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getWaterMl(
    String date,
  ) async {
    final db = await database;

    final result =
        await db.query(
      'habits',
      columns: ['water_ml'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['water_ml']
                as num?)
            ?.toInt() ??
        0;
  }

  // Keep old methods for compatibility.

  Future<int> updateWaterCount(
    String date,
    int count,
  ) async {
    return updateWaterMl(
      date,
      count * 250,
    );
  }

  Future<int> getWaterCount(
    String date,
  ) async {
    final ml =
        await getWaterMl(
      date,
    );

    return (ml / 250).round();
  }

  // ============================================================
  // STEPS
  // ============================================================

  Future<int> updateStepCount(
    String date,
    int steps,
  ) async {
    await _ensureHabitRow(
      date,
    );

    final db = await database;

    return db.update(
      'habits',
      {
        'steps': steps,
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getStepCount(
    String date,
  ) async {
    final db = await database;

    final result =
        await db.query(
      'habits',
      columns: ['steps'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['steps']
                as num?)
            ?.toInt() ??
        0;
  }

  // ============================================================
  // LEGACY SLEEP
  // ============================================================

  Future<int> updateSleepHours(
    String date,
    double hours,
  ) async {
    await _ensureHabitRow(
      date,
    );

    final db = await database;

    return db.update(
      'habits',
      {
        'sleep_hours':
            hours,
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<double> getSleepHours(
    String date,
  ) async {
    final db = await database;

    final result =
        await db.query(
      'habits',
      columns: [
        'sleep_hours',
      ],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first[
                'sleep_hours']
            as num?)
        ?.toDouble() ??
        0;
  }

  // ============================================================
  // SLEEP ENTRIES
  // ============================================================

  Future<int> insertSleepEntry({
    required DateTime start,
    required DateTime end,
  }) async {
    final db = await database;

    final duration =
        end.difference(start);

    final date =
        '${end.year.toString().padLeft(4, '0')}-'
        '${end.month.toString().padLeft(2, '0')}-'
        '${end.day.toString().padLeft(2, '0')}';

    return db.insert(
      'sleep_entries',
      {
        'sleep_start':
            start.toIso8601String(),

        'sleep_end':
            end.toIso8601String(),

        'duration_minutes':
            duration.inMinutes,

        'date':
            date,
      },
    );
  }

  Future<List<Map<String, dynamic>>>
      getSleepEntries({
    int limit = 30,
  }) async {
    final db = await database;

    return db.query(
      'sleep_entries',
      orderBy: 'sleep_end DESC',
      limit: limit,
    );
  }

  Future<int> deleteSleepEntry(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'sleep_entries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
/*
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/workout_model.dart';

class DatabaseHelper {
  DatabaseHelper._init();

  static final DatabaseHelper instance =
      DatabaseHelper._init();

  static Database? _database;

  static const String _databaseName =
      'fitness_pro_v2.db';

  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB(
      _databaseName,
    );

    return _database!;
  }

  Future<Database> _initDB(
    String filePath,
  ) async {
    final dbPath =
        await getDatabasesPath();

    final path = join(
      dbPath,
      filePath,
    );

    return openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(
    Database db,
    int version,
  ) async {
    // ---------------- WORKOUT ----------------

    await db.execute(
      '''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        duration INTEGER NOT NULL,
        calories INTEGER NOT NULL,
        date TEXT NOT NULL,
        intensity TEXT NOT NULL DEFAULT 'Moderate',
        distance REAL,
        notes TEXT
      )
      ''',
    );

    // ---------------- HABITS ----------------

    await db.execute(
      '''
      CREATE TABLE habits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        water_glasses INTEGER NOT NULL DEFAULT 0,
        steps INTEGER NOT NULL DEFAULT 0,
        sleep_hours REAL NOT NULL DEFAULT 0
      )
      ''',
    );

    // ---------------- MEALS ----------------

    await db.execute(
      '''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        calories INTEGER NOT NULL,
        meal_type TEXT NOT NULL,
        date TEXT NOT NULL,
        protein REAL NOT NULL DEFAULT 0,
        carbs REAL NOT NULL DEFAULT 0,
        fat REAL NOT NULL DEFAULT 0
      )
      ''',
    );

    // ---------------- PROFILE ----------------

    await db.execute(
      '''
      CREATE TABLE user_profile (
        id INTEGER PRIMARY KEY,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        goal_weight REAL NOT NULL,
        starting_weight REAL NOT NULL
      )
      ''',
    );

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'height': 1.75,
        'weight': 70.0,
        'goal_weight': 65.0,
        'starting_weight': 70.0,
      },
    );
  }

  // ========================================
  // DATABASE MIGRATION
  // ========================================

  Future<void> _upgradeDB(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      // ---------- WORKOUT MIGRATION ----------

      final workoutColumns =
          await _columnNames(
        db,
        'workouts',
      );

      if (!workoutColumns.contains(
        'intensity',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN intensity
          TEXT NOT NULL
          DEFAULT 'Moderate'
          ''',
        );
      }

      if (!workoutColumns.contains(
        'distance',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN distance REAL
          ''',
        );
      }

      if (!workoutColumns.contains(
        'notes',
      )) {
        await db.execute(
          '''
          ALTER TABLE workouts
          ADD COLUMN notes TEXT
          ''',
        );
      }

      // ---------- HABIT MIGRATION ----------

      final habitColumns =
          await _columnNames(
        db,
        'habits',
      );

      if (!habitColumns.contains(
        'sleep_hours',
      )) {
        await db.execute(
          '''
          ALTER TABLE habits
          ADD COLUMN sleep_hours
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      // পুরনো duplicate habit row থাকলে remove
      await db.execute(
        '''
        DELETE FROM habits
        WHERE id NOT IN (
          SELECT MIN(id)
          FROM habits
          GROUP BY date
        )
        ''',
      );

      await db.execute(
        '''
        CREATE UNIQUE INDEX
        IF NOT EXISTS idx_habits_date
        ON habits(date)
        ''',
      );

      // ---------- MEAL MIGRATION ----------

      final mealColumns =
          await _columnNames(
        db,
        'meals',
      );

      if (!mealColumns.contains(
        'protein',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN protein
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      if (!mealColumns.contains(
        'carbs',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN carbs
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      if (!mealColumns.contains(
        'fat',
      )) {
        await db.execute(
          '''
          ALTER TABLE meals
          ADD COLUMN fat
          REAL NOT NULL DEFAULT 0
          ''',
        );
      }

      // ---------- PROFILE MIGRATION ----------

      final profileColumns =
          await _columnNames(
        db,
        'user_profile',
      );

      if (!profileColumns.contains(
        'starting_weight',
      )) {
        await db.execute(
          '''
          ALTER TABLE user_profile
          ADD COLUMN starting_weight
          REAL NOT NULL DEFAULT 70
          ''',
        );

        await db.execute(
          '''
          UPDATE user_profile
          SET starting_weight = weight
          WHERE id = 1
          ''',
        );
      }
    }
  }

  Future<List<String>> _columnNames(
    Database db,
    String table,
  ) async {
    final info = await db.rawQuery(
      'PRAGMA table_info($table)',
    );

    return info
        .map(
          (row) =>
              row['name'] as String,
        )
        .toList();
  }

  // ========================================
  // PROFILE
  // ========================================

  Future<Map<String, dynamic>>
      getUserProfile() async {
    final db = await database;

    final result = await db.query(
      'user_profile',
      where: 'id = ?',
      whereArgs: [1],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    const fallback = {
      'id': 1,
      'height': 1.75,
      'weight': 70.0,
      'goal_weight': 65.0,
      'starting_weight': 70.0,
    };

    await db.insert(
      'user_profile',
      fallback,
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );

    return fallback;
  }

  Future<void> updateUserProfile({
    required double height,
    required double weight,
    required double goalWeight,
    required double startingWeight,
  }) async {
    final db = await database;

    await db.insert(
      'user_profile',
      {
        'id': 1,
        'height': height,
        'weight': weight,
        'goal_weight': goalWeight,
        'starting_weight':
            startingWeight,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ========================================
  // WORKOUT
  // ========================================

  Future<int> insertWorkout(
    Workout workout,
  ) async {
    final db = await database;

    final map = workout.toMap();

    map.remove('id');

    return db.insert(
      'workouts',
      map,
    );
  }

  Future<List<Workout>>
      getAllWorkouts() async {
    final db = await database;

    final result = await db.query(
      'workouts',
      orderBy: 'date DESC',
    );

    return result
        .map(
          Workout.fromMap,
        )
        .toList();
  }

  Future<int> updateWorkout(
    Workout workout,
  ) async {
    if (workout.id == null) {
      return 0;
    }

    final db = await database;

    final map = workout.toMap();

    map.remove('id');

    return db.update(
      'workouts',
      map,
      where: 'id = ?',
      whereArgs: [
        workout.id,
      ],
    );
  }

  Future<int> deleteWorkout(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'workouts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // MEALS
  // ========================================

  Future<int> insertMeal(
    Map<String, dynamic> meal,
  ) async {
    final db = await database;

    return db.insert(
      'meals',
      meal,
    );
  }

  Future<List<Map<String, dynamic>>>
      getDailyMeals(
    String date,
  ) async {
    final db = await database;

    return db.query(
      'meals',
      where: 'date LIKE ?',
      whereArgs: [
        '$date%',
      ],
      orderBy: 'date DESC',
    );
  }

  Future<int> deleteMeal(
    int id,
  ) async {
    final db = await database;

    return db.delete(
      'meals',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // HABITS
  // ========================================

  Future<void> _ensureHabitRow(
    String date,
  ) async {
    final db = await database;

    await db.insert(
      'habits',
      {
        'date': date,
        'water_glasses': 0,
        'steps': 0,
        'sleep_hours': 0.0,
      },
      conflictAlgorithm:
          ConflictAlgorithm.ignore,
    );
  }

  // ---------------- WATER ----------------

  Future<int> updateWaterCount(
    String date,
    int count,
  ) async {
    await _ensureHabitRow(date);

    final db = await database;

    return db.update(
      'habits',
      {
        'water_glasses': count,
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getWaterCount(
    String date,
  ) async {
    final db = await database;

    final result = await db.query(
      'habits',
      columns: [
        'water_glasses',
      ],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first[
                'water_glasses']
            as num?)
        ?.toInt() ??
        0;
  }

  // ---------------- STEPS ----------------

  Future<int> updateStepCount(
    String date,
    int steps,
  ) async {
    await _ensureHabitRow(date);

    final db = await database;

    return db.update(
      'habits',
      {
        'steps': steps,
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<int> getStepCount(
    String date,
  ) async {
    final db = await database;

    final result = await db.query(
      'habits',
      columns: ['steps'],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first['steps']
                as num?)
            ?.toInt() ??
        0;
  }

  // ---------------- SLEEP ----------------

  Future<int> updateSleepHours(
    String date,
    double hours,
  ) async {
    await _ensureHabitRow(date);

    final db = await database;

    return db.update(
      'habits',
      {
        'sleep_hours': hours,
      },
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  Future<double> getSleepHours(
    String date,
  ) async {
    final db = await database;

    final result = await db.query(
      'habits',
      columns: [
        'sleep_hours',
      ],
      where: 'date = ?',
      whereArgs: [date],
      limit: 1,
    );

    if (result.isEmpty) {
      return 0;
    }

    return (result.first[
                'sleep_hours']
            as num?)
        ?.toDouble() ??
        0;
  }
}*/
