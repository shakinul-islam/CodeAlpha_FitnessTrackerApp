import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database_helper.dart';
import '../models/workout_model.dart';

// ========================================
// WORKOUT PROVIDER
// ========================================

class WorkoutNotifier
    extends AsyncNotifier<
        List<Workout>> {
  @override
  Future<List<Workout>> build() {
    return DatabaseHelper.instance
        .getAllWorkouts();
  }

  Future<void> addWorkout(
    Workout workout,
  ) async {
    await DatabaseHelper.instance
        .insertWorkout(
      workout,
    );

    state = AsyncData(
      await DatabaseHelper.instance
          .getAllWorkouts(),
    );
  }

  Future<void> updateWorkout(
    Workout workout,
  ) async {
    await DatabaseHelper.instance
        .updateWorkout(
      workout,
    );

    state = AsyncData(
      await DatabaseHelper.instance
          .getAllWorkouts(),
    );
  }

  Future<void> deleteWorkout(
    int id,
  ) async {
    await DatabaseHelper.instance
        .deleteWorkout(id);

    state = AsyncData(
      await DatabaseHelper.instance
          .getAllWorkouts(),
    );
  }
}

final workoutNotifierProvider =
    AsyncNotifierProvider<
        WorkoutNotifier,
        List<Workout>>(
  WorkoutNotifier.new,
);

// ========================================
// WEEKLY CALORIES
// Monday → Sunday
// ========================================

final weeklyCaloriesChartProvider =
    Provider<List<double>>(
  (ref) {
    final workouts =
        ref
                .watch(
                  workoutNotifierProvider,
                )
                .asData
                ?.value ??
            <Workout>[];

    final data =
        List<double>.filled(
      7,
      0,
    );

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final monday =
        today.subtract(
      Duration(
        days: today.weekday - 1,
      ),
    );

    for (final workout
        in workouts) {
      final day = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      final index =
          day.difference(
            monday,
          ).inDays;

      if (index >= 0 &&
          index < 7) {
        data[index] +=
            workout.calories
                .toDouble();
      }
    }

    return data;
  },
);

// ========================================
// TODAY SUMMARY
// ========================================

final todayWorkoutSummaryProvider =
    Provider<Map<String, int>>(
  (ref) {
    final workouts =
        ref
                .watch(
                  workoutNotifierProvider,
                )
                .asData
                ?.value ??
            <Workout>[];

    final now = DateTime.now();

    final todayWorkouts =
        workouts.where(
      (workout) {
        return workout.date.year ==
                now.year &&
            workout.date.month ==
                now.month &&
            workout.date.day ==
                now.day;
      },
    ).toList();

    return {
      'calories':
          todayWorkouts.fold<int>(
        0,
        (sum, item) =>
            sum + item.calories,
      ),

      'minutes':
          todayWorkouts.fold<int>(
        0,
        (sum, item) =>
            sum + item.duration,
      ),

      'sessions':
          todayWorkouts.length,
    };
  },
);