import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/database_helper.dart';

class AnalyticsDay {
  final DateTime date;

  final int steps;
  final int waterMl;
  final int sleepMinutes;

  final int caloriesConsumed;
  final int caloriesBurned;

  final int workoutMinutes;

  const AnalyticsDay({
    required this.date,
    required this.steps,
    required this.waterMl,
    required this.sleepMinutes,
    required this.caloriesConsumed,
    required this.caloriesBurned,
    required this.workoutMinutes,
  });
}

class WeightAnalyticsPoint {
  final DateTime date;
  final double weight;

  const WeightAnalyticsPoint({
    required this.date,
    required this.weight,
  });
}

class ProgressAnalyticsData {
  final int days;

  final List<AnalyticsDay> daily;
  final List<WeightAnalyticsPoint> weights;

  final int stepsGoal;
  final int waterGoalMl;
  final int calorieGoal;
  final int sleepGoalMinutes;

  const ProgressAnalyticsData({
    required this.days,
    required this.daily,
    required this.weights,
    required this.stepsGoal,
    required this.waterGoalMl,
    required this.calorieGoal,
    required this.sleepGoalMinutes,
  });

  // ============================================================
  // TOTALS
  // ============================================================

  int get totalSteps {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.steps,
    );
  }

  int get totalWaterMl {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.waterMl,
    );
  }

  int get totalSleepMinutes {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.sleepMinutes,
    );
  }

  int get totalCaloriesConsumed {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.caloriesConsumed,
    );
  }

  int get totalCaloriesBurned {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.caloriesBurned,
    );
  }

  int get totalWorkoutMinutes {
    return daily.fold(
      0,
      (
        total,
        item,
      ) =>
          total + item.workoutMinutes,
    );
  }

  // ============================================================
  // AVERAGES
  // ============================================================

  double get averageSteps {
    if (daily.isEmpty) {
      return 0;
    }

    return totalSteps / daily.length;
  }

  double get averageWaterMl {
    if (daily.isEmpty) {
      return 0;
    }

    return totalWaterMl / daily.length;
  }

  double get averageSleepMinutes {
    if (daily.isEmpty) {
      return 0;
    }

    return totalSleepMinutes / daily.length;
  }

  double get averageCaloriesConsumed {
    if (daily.isEmpty) {
      return 0;
    }

    return totalCaloriesConsumed / daily.length;
  }

  double get averageCaloriesBurned {
    if (daily.isEmpty) {
      return 0;
    }

    return totalCaloriesBurned / daily.length;
  }

  double get averageWorkoutMinutes {
    if (daily.isEmpty) {
      return 0;
    }

    return totalWorkoutMinutes / daily.length;
  }

  // ============================================================
  // GOAL ACHIEVEMENT
  // ============================================================

  int get stepsGoalDays {
    return daily
        .where(
          (item) =>
              item.steps >=
              stepsGoal,
        )
        .length;
  }

  int get waterGoalDays {
    return daily
        .where(
          (item) =>
              item.waterMl >=
              waterGoalMl,
        )
        .length;
  }

  int get sleepGoalDays {
    return daily
        .where(
          (item) =>
              item.sleepMinutes >=
              sleepGoalMinutes,
        )
        .length;
  }

  int get calorieGoalDays {
    return daily
        .where(
          (item) =>
              item.caloriesConsumed > 0 &&
              item.caloriesConsumed <= calorieGoal,
        )
        .length;
  }
}

// ============================================================
// PROVIDER
// ============================================================

final progressAnalyticsProvider =
    FutureProvider.family<
        ProgressAnalyticsData,
        int>(
  (
    ref,
    days,
  ) async {
    return _loadAnalytics(
      days,
    );
  },
);

// ============================================================
// LOAD ANALYTICS
// ============================================================

Future<ProgressAnalyticsData> _loadAnalytics(
  int requestedDays,
) async {
  final days =
      requestedDays == 30
          ? 30
          : 7;

  final db =
      await DatabaseHelper.instance.database;

  final today = DateTime.now();

  final todayOnly = DateTime(
    today.year,
    today.month,
    today.day,
  );

  final startDate = todayOnly.subtract(
    Duration(
      days: days - 1,
    ),
  );

  final dateFormatter = DateFormat(
    'yyyy-MM-dd',
  );

  // ============================================================
  // DAILY GOALS
  // ============================================================

  final goals =
      await DatabaseHelper.instance.getDailyGoals();

  final stepsGoal =
      (goals['steps_goal'] as num?)?.toInt() ??
      10000;

  final waterGoalMl =
      (goals['water_goal_ml'] as num?)?.toInt() ??
      2500;

  final calorieGoal =
      (goals['calorie_goal'] as num?)?.toInt() ??
      2000;

  final sleepGoalMinutes =
      (goals['sleep_goal_minutes'] as num?)?.toInt() ??
      480;

  // ============================================================
  // QUERY DATA
  // ============================================================

  final habitRows =
      await db.query(
    'habits',
  );

  final workoutRows =
      await db.query(
    'workouts',
  );

  final mealRows =
      await db.query(
    'meals',
  );

  final sleepRows =
      await db.query(
    'sleep_entries',
  );

  final weightRows =
      await db.query(
    'weight_history',
    orderBy: 'date ASC',
  );

  // ============================================================
  // BUILD DAILY DATA
  // ============================================================

  final daily =
      <AnalyticsDay>[];

  for (int i = 0;
      i < days;
      i++) {
    final date =
        startDate.add(
      Duration(
        days: i,
      ),
    );

    final dateKey =
        dateFormatter.format(
      date,
    );

    // ----------------------------------------------------------
    // HABITS
    // ----------------------------------------------------------

    int steps = 0;
    int waterMl = 0;

    for (final row in habitRows) {
      if (row['date'] ==
          dateKey) {
        steps =
            (row['steps'] as num?)?.toInt() ??
            0;

        waterMl =
            (row['water_ml'] as num?)?.toInt() ??
            0;

        break;
      }
    }

    // ----------------------------------------------------------
    // WORKOUT
    // ----------------------------------------------------------

    int caloriesBurned = 0;
    int workoutMinutes = 0;

    for (final row in workoutRows) {
      final rawDate =
          row['date']?.toString();

      final workoutDate =
          rawDate == null
              ? null
              : DateTime.tryParse(
                  rawDate,
                );

      if (workoutDate == null) {
        continue;
      }

      if (_sameDay(
        workoutDate,
        date,
      )) {
        caloriesBurned +=
            (row['calories'] as num?)?.toInt() ??
            0;

        workoutMinutes +=
            (row['duration'] as num?)?.toInt() ??
            0;
      }
    }

    // ----------------------------------------------------------
    // MEALS
    // ----------------------------------------------------------

    int caloriesConsumed = 0;

    for (final row in mealRows) {
      final rawDate =
          row['date']?.toString();

      if (rawDate == null) {
        continue;
      }

      DateTime? mealDate =
          DateTime.tryParse(
        rawDate,
      );

      // Compatibility if an old row only contains yyyy-MM-dd.
      mealDate ??=
          DateTime.tryParse(
        '${rawDate.substring(
          0,
          rawDate.length >= 10
              ? 10
              : rawDate.length,
        )}T00:00:00',
      );

      if (mealDate == null) {
        continue;
      }

      if (_sameDay(
        mealDate,
        date,
      )) {
        caloriesConsumed +=
            (row['calories'] as num?)?.toInt() ??
            0;
      }
    }

    // ----------------------------------------------------------
    // SLEEP
    // ----------------------------------------------------------

    int sleepMinutes = 0;

    for (final row in sleepRows) {
      if (row['date'] ==
          dateKey) {
        sleepMinutes +=
            (row['duration_minutes'] as num?)?.toInt() ??
            0;
      }
    }

    daily.add(
      AnalyticsDay(
        date: date,
        steps: steps,
        waterMl: waterMl,
        sleepMinutes: sleepMinutes,
        caloriesConsumed: caloriesConsumed,
        caloriesBurned: caloriesBurned,
        workoutMinutes: workoutMinutes,
      ),
    );
  }

  // ============================================================
  // WEIGHT HISTORY
  // ============================================================

  final weights =
      <WeightAnalyticsPoint>[];

  for (final row in weightRows) {
    final rawDate =
        row['date']?.toString();

    final weight =
        (row['weight'] as num?)?.toDouble();

    if (rawDate == null ||
        weight == null) {
      continue;
    }

    final date =
        DateTime.tryParse(
      rawDate,
    );

    if (date == null) {
      continue;
    }

    final dateOnly =
        DateTime(
      date.year,
      date.month,
      date.day,
    );

    if (!dateOnly.isBefore(
          startDate,
        ) &&
        !dateOnly.isAfter(
          todayOnly,
        )) {
      weights.add(
        WeightAnalyticsPoint(
          date: date,
          weight: weight,
        ),
      );
    }
  }

  return ProgressAnalyticsData(
    days: days,
    daily: daily,
    weights: weights,
    stepsGoal: stepsGoal,
    waterGoalMl: waterGoalMl,
    calorieGoal: calorieGoal,
    sleepGoalMinutes: sleepGoalMinutes,
  );
}

bool _sameDay(
  DateTime a,
  DateTime b,
) {
  return a.year == b.year &&
      a.month == b.month &&
      a.day == b.day;
}