import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/database_helper.dart';

String _today() {
  return DateFormat(
    'yyyy-MM-dd',
  ).format(
    DateTime.now(),
  );
}

// ============================================================
// DAILY GOALS
// ============================================================

class DailyGoalsNotifier
    extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() {
    return DatabaseHelper.instance.getDailyGoals();
  }

  Future<void> updateGoals({
    required int stepsGoal,
    required int waterGoalMl,
    required int calorieGoal,
    required int sleepGoalMinutes,
  }) async {
    await DatabaseHelper.instance.updateDailyGoals(
      stepsGoal: stepsGoal,
      waterGoalMl: waterGoalMl,
      calorieGoal: calorieGoal,
      sleepGoalMinutes: sleepGoalMinutes,
    );

    state = AsyncData(
      await DatabaseHelper.instance.getDailyGoals(),
    );
  }
}

final dailyGoalsNotifierProvider =
    AsyncNotifierProvider<
        DailyGoalsNotifier,
        Map<String, dynamic>>(
  DailyGoalsNotifier.new,
);

// ============================================================
// WATER ML
// ============================================================

class WaterIntakeNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    return DatabaseHelper.instance.getWaterMl(
      _today(),
    );
  }

  Future<void> addWater(
    int ml,
  ) async {
    final current =
        state.asData?.value ?? 0;

    final next =
        current + ml;

    await DatabaseHelper.instance.updateWaterMl(
      _today(),
      next,
    );

    state = AsyncData(
      next,
    );
  }

  Future<void> removeWater(
    int ml,
  ) async {
    final current =
        state.asData?.value ?? 0;

    var next =
        current - ml;

    if (next < 0) {
      next = 0;
    }

    await DatabaseHelper.instance.updateWaterMl(
      _today(),
      next,
    );

    state = AsyncData(
      next,
    );
  }

  // ==========================================================
  // COMPATIBILITY WITH OLD GLASS-BASED CODE
  // ==========================================================

  Future<void> addGlass() async {
    await addWater(
      250,
    );
  }

  Future<void> removeGlass() async {
    await removeWater(
      250,
    );
  }
}

final waterIntakeNotifierProvider =
    AsyncNotifierProvider<
        WaterIntakeNotifier,
        int>(
  WaterIntakeNotifier.new,
);

// ============================================================
// STEPS
// ============================================================

class DailyStepsNotifier extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    return DatabaseHelper.instance.getStepCount(
      _today(),
    );
  }

  Future<void> setSteps(
    int steps,
  ) async {
    final safeSteps =
        steps < 0 ? 0 : steps;

    await DatabaseHelper.instance.updateStepCount(
      _today(),
      safeSteps,
    );

    state = AsyncData(
      safeSteps,
    );
  }
}

final dailyStepsNotifierProvider =
    AsyncNotifierProvider<
        DailyStepsNotifier,
        int>(
  DailyStepsNotifier.new,
);

// ============================================================
// LEGACY SLEEP PROVIDER
// ============================================================
//
// Kept so older parts of the app that still reference
// sleepNotifierProvider do not break.
//
// New sleep tracking uses SleepHistoryNotifier below.
// ============================================================

class SleepNotifier extends AsyncNotifier<double> {
  @override
  Future<double> build() {
    return DatabaseHelper.instance.getSleepHours(
      _today(),
    );
  }

  Future<void> updateHours(
    double hours,
  ) async {
    final safeHours =
        hours.clamp(
      0.0,
      12.0,
    ).toDouble();

    await DatabaseHelper.instance.updateSleepHours(
      _today(),
      safeHours,
    );

    state = AsyncData(
      safeHours,
    );
  }
}

final sleepNotifierProvider =
    AsyncNotifierProvider<
        SleepNotifier,
        double>(
  SleepNotifier.new,
);

// ============================================================
// SLEEP HISTORY
// ============================================================

class SleepHistoryNotifier
    extends AsyncNotifier<
        List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() {
    return DatabaseHelper.instance.getSleepEntries();
  }

  Future<void> addSleep({
    required DateTime start,
    required DateTime end,
  }) async {
    await DatabaseHelper.instance.insertSleepEntry(
      start: start,
      end: end,
    );

    state = AsyncData(
      await DatabaseHelper.instance.getSleepEntries(),
    );
  }

  Future<void> deleteSleep(
    int id,
  ) async {
    await DatabaseHelper.instance.deleteSleepEntry(
      id,
    );

    state = AsyncData(
      await DatabaseHelper.instance.getSleepEntries(),
    );
  }

  Future<void> refreshHistory() async {
    state = AsyncData(
      await DatabaseHelper.instance.getSleepEntries(),
    );
  }
}

final sleepHistoryNotifierProvider =
    AsyncNotifierProvider<
        SleepHistoryNotifier,
        List<Map<String, dynamic>>>(
  SleepHistoryNotifier.new,
);

// ============================================================
// TODAY SLEEP
// ============================================================

final todaySleepMinutesProvider =
    Provider<int>(
  (ref) {
    final entries =
        ref
                .watch(
                  sleepHistoryNotifierProvider,
                )
                .asData
                ?.value ??
            <Map<String, dynamic>>[];

    final today =
        _today();

    return entries
        .where(
          (entry) =>
              entry['date'] ==
              today,
        )
        .fold<int>(
          0,
          (
            sum,
            entry,
          ) =>
              sum +
              ((entry['duration_minutes']
                          as num?)
                      ?.toInt() ??
                  0),
        );
  },
);

// ============================================================
// WEIGHT HISTORY
// ============================================================

class WeightHistoryNotifier
    extends AsyncNotifier<
        List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() {
    return DatabaseHelper.instance.getWeightHistory();
  }

  Future<void> refreshHistory() async {
    state = AsyncData(
      await DatabaseHelper.instance.getWeightHistory(),
    );
  }

  Future<void> deleteEntry(
    int id,
  ) async {
    await DatabaseHelper.instance.deleteWeightHistory(
      id,
    );

    await refreshHistory();
  }
}

final weightHistoryNotifierProvider =
    AsyncNotifierProvider<
        WeightHistoryNotifier,
        List<Map<String, dynamic>>>(
  WeightHistoryNotifier.new,
);
/*
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/database_helper.dart';

String _today() {
  return DateFormat(
    'yyyy-MM-dd',
  ).format(
    DateTime.now(),
  );
}

// ========================================
// WATER
// ========================================

class WaterIntakeNotifier
    extends AsyncNotifier<int> {
  static const int dailyGoal = 8;

  @override
  Future<int> build() {
    return DatabaseHelper.instance
        .getWaterCount(
      _today(),
    );
  }

  Future<void> addGlass() async {
    final current =
        state.asData?.value ?? 0;

    if (current >= dailyGoal) {
      return;
    }

    final next = current + 1;

    await DatabaseHelper.instance
        .updateWaterCount(
      _today(),
      next,
    );

    state = AsyncData(next);
  }

  Future<void> removeGlass() async {
    final current =
        state.asData?.value ?? 0;

    if (current <= 0) {
      return;
    }

    final next = current - 1;

    await DatabaseHelper.instance
        .updateWaterCount(
      _today(),
      next,
    );

    state = AsyncData(next);
  }
}

final waterIntakeNotifierProvider =
    AsyncNotifierProvider<
        WaterIntakeNotifier,
        int>(
  WaterIntakeNotifier.new,
);

// ========================================
// DAILY STEPS
// ========================================

class DailyStepsNotifier
    extends AsyncNotifier<int> {
  @override
  Future<int> build() {
    return DatabaseHelper.instance
        .getStepCount(
      _today(),
    );
  }

  Future<void> setSteps(
    int steps,
  ) async {
    final safeSteps =
        steps < 0 ? 0 : steps;

    await DatabaseHelper.instance
        .updateStepCount(
      _today(),
      safeSteps,
    );

    state = AsyncData(
      safeSteps,
    );
  }
}

final dailyStepsNotifierProvider =
    AsyncNotifierProvider<
        DailyStepsNotifier,
        int>(
  DailyStepsNotifier.new,
);

// ========================================
// SLEEP
// ========================================

class SleepNotifier
    extends AsyncNotifier<double> {
  @override
  Future<double> build() {
    return DatabaseHelper.instance
        .getSleepHours(
      _today(),
    );
  }

  Future<void> updateHours(
    double hours,
  ) async {
    final safeHours =
        hours.clamp(
      0.0,
      12.0,
    );

    await DatabaseHelper.instance
        .updateSleepHours(
      _today(),
      safeHours,
    );

    state = AsyncData(
      safeHours,
    );
  }
}

final sleepNotifierProvider =
    AsyncNotifierProvider<
        SleepNotifier,
        double>(
  SleepNotifier.new,
);*/