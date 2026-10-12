import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/workout_model.dart';
import '../providers/app_providers.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    // ============================================================
    // WORKOUT DATA
    // ============================================================

    final workoutState = ref.watch(
      workoutNotifierProvider,
    );

    final weeklyData = ref.watch(
      weeklyCaloriesChartProvider,
    );

    final todayWorkout = ref.watch(
      todayWorkoutSummaryProvider,
    );

    // ============================================================
    // DAILY HABIT DATA
    // ============================================================

    final water =
        ref
            .watch(
              waterIntakeNotifierProvider,
            )
            .asData
            ?.value ??
        0;

    final steps =
        ref
            .watch(
              dailyStepsNotifierProvider,
            )
            .asData
            ?.value ??
        0;

    final sleepMinutes = ref.watch(
      todaySleepMinutesProvider,
    );

    // ============================================================
    // DAILY GOALS
    // ============================================================

    final goalsState = ref.watch(
      dailyGoalsNotifierProvider,
    );

    // ============================================================
    // DIET / NUTRITION
    // ============================================================

    final mealsState = ref.watch(
      dietNotifierProvider,
    );

    // ============================================================
    // PROFILE / WEIGHT
    // ============================================================

    final profileState = ref.watch(
      profileNotifierProvider,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(0xFF071827),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: workoutState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),

            error: (error, stack) => _ErrorState(
              message: '$error',
            ),

            data: (workouts) {
              // ==================================================
              // GOAL VALUES
              // ==================================================

              final goalData = goalsState.asData?.value;

              final stepsGoal =
                  (goalData?['steps_goal'] as num?)?.toInt() ??
                  10000;

              final waterGoal =
                  (goalData?['water_goal_ml'] as num?)?.toInt() ??
                  2500;

              final calorieGoal =
                  (goalData?['calorie_goal'] as num?)?.toInt() ??
                  2000;

              final sleepGoalMinutes =
                  (goalData?['sleep_goal_minutes'] as num?)
                      ?.toInt() ??
                  480;

              // ==================================================
              // TODAY'S CALORIES CONSUMED
              // ==================================================

              final meals =
                  mealsState.asData?.value ??
                  <Map<String, dynamic>>[];

              final consumedCalories = meals.fold<int>(
                0,
                (
                  total,
                  meal,
                ) {
                  return total +
                      ((meal['calories'] as num?)?.toInt() ?? 0);
                },
              );

              // ==================================================
              // DAILY PROGRESS
              // ==================================================

              final stepsProgress = _progress(
                steps,
                stepsGoal,
              );

              final waterProgress = _progress(
                water,
                waterGoal,
              );

              final nutritionProgress = _progress(
                consumedCalories,
                calorieGoal,
              );

              final sleepProgress = _progress(
                sleepMinutes,
                sleepGoalMinutes,
              );

              final overallDailyProgress =
                  (
                        stepsProgress +
                        waterProgress +
                        nutritionProgress +
                        sleepProgress
                      ) /
                      4;

              // ==================================================
              // WEIGHT GOAL
              // ==================================================

              final profile = profileState.asData?.value;

              final currentWeight =
                  (profile?['weight'] as num?)?.toDouble() ?? 0;

              final startingWeight =
                  (profile?['starting_weight'] as num?)
                      ?.toDouble() ??
                  currentWeight;

              final goalWeight =
                  (profile?['goal_weight'] as num?)?.toDouble() ??
                  currentWeight;

              final weightProgress = _weightGoalProgress(
                start: startingWeight,
                current: currentWeight,
                goal: goalWeight,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    workoutNotifierProvider,
                  );

                  ref.invalidate(
                    waterIntakeNotifierProvider,
                  );

                  ref.invalidate(
                    dailyStepsNotifierProvider,
                  );

                  ref.invalidate(
                    sleepHistoryNotifierProvider,
                  );

                  ref.invalidate(
                    dailyGoalsNotifierProvider,
                  );

                  ref.invalidate(
                    dietNotifierProvider,
                  );

                  ref.invalidate(
                    profileNotifierProvider,
                  );
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    28,
                  ),
                  children: [
                    // ==================================================
                    // HEADER
                    // ==================================================

                    _header(
                      context,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ==================================================
                    // TODAY WORKOUT HERO
                    // ==================================================

                    _heroCard(
                      todayWorkout,
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==================================================
                    // DAILY GOAL OVERVIEW
                    // ==================================================

                    _sectionTitle(
                      'Today\'s Goal Progress',
                      '${(overallDailyProgress * 100).round()}%',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _overallProgressCard(
                      progress: overallDailyProgress,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ==================================================
                    // STEPS
                    // ==================================================

                    _goalProgressCard(
                      icon: Icons.directions_walk_rounded,
                      title: 'Steps',
                      currentText:
                          '${NumberFormat.decimalPattern().format(steps)} / '
                          '${NumberFormat.decimalPattern().format(stepsGoal)}',
                      progress: stepsProgress,
                      color: AppTheme.accentColor,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // WATER
                    // ==================================================

                    _goalProgressCard(
                      icon: Icons.water_drop_rounded,
                      title: 'Water',
                      currentText: '$water / $waterGoal ml',
                      progress: waterProgress,
                      color: Colors.blueAccent,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // NUTRITION
                    // ==================================================

                    _goalProgressCard(
                      icon: Icons.restaurant_rounded,
                      title: 'Nutrition',
                      currentText:
                          '$consumedCalories / $calorieGoal kcal',
                      progress: nutritionProgress,
                      color: AppTheme.orangeAccent,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // SLEEP
                    // ==================================================

                    _goalProgressCard(
                      icon: Icons.bedtime_rounded,
                      title: 'Sleep',
                      currentText:
                          '${_durationText(sleepMinutes)} / '
                          '${_durationText(sleepGoalMinutes)}',
                      progress: sleepProgress,
                      color: AppTheme.purpleAccent,
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    // ==================================================
                    // WEIGHT GOAL
                    // ==================================================

                    if (profile != null)
                      _weightProgressCard(
                        start: startingWeight,
                        current: currentWeight,
                        goal: goalWeight,
                        progress: weightProgress,
                      ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // WEEKLY WORKOUT
                    // ==================================================

                    _sectionTitle(
                      'Weekly burn',
                      '${weeklyData.fold<double>(
                        0,
                        (
                          total,
                          value,
                        ) =>
                            total + value,
                      ).round()} kcal',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _chartCard(
                      weeklyData,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // RECENT WORKOUTS
                    // ==================================================

                    _sectionTitle(
                      'Recent workouts',
                      '${workouts.length} total',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (workouts.isEmpty)
                      _emptyWorkout(
                        context,
                      )
                    else
                      ...workouts
                          .take(
                            5,
                          )
                          .map(
                            (
                              workout,
                            ) =>
                                _workoutTile(
                              context,
                              ref,
                              workout,
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NORMAL PROGRESS CALCULATION
  // ============================================================

  double _progress(
    num current,
    num goal,
  ) {
    if (goal <= 0) {
      return 0;
    }

    return (current / goal).clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // WEIGHT GOAL CALCULATION
  // ============================================================

  double _weightGoalProgress({
    required double start,
    required double current,
    required double goal,
  }) {
    final totalDistance = (start - goal).abs();

    if (totalDistance == 0) {
      return current == goal ? 1.0 : 0.0;
    }

    // Weight loss goal
    if (goal < start) {
      if (current >= start) {
        return 0.0;
      }

      if (current <= goal) {
        return 1.0;
      }

      return ((start - current) / totalDistance).clamp(
        0.0,
        1.0,
      );
    }

    // Weight gain goal
    if (goal > start) {
      if (current <= start) {
        return 0.0;
      }

      if (current >= goal) {
        return 1.0;
      }

      return ((current - start) / totalDistance).clamp(
        0.0,
        1.0,
      );
    }

    return 0.0;
  }

  // ============================================================
  // DURATION FORMAT
  // ============================================================

  String _durationText(
    int minutes,
  ) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours == 0) {
      return '${mins}m';
    }

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}m';
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _header(
    BuildContext context,
  ) {
    final hour = DateTime.now().hour;

    final greeting =
        hour < 12
            ? 'Good morning'
            : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              const Text(
                'Ready to move?',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        IconButton.filled(
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: AppTheme.bgColor,
            minimumSize: const Size(
              48,
              48,
            ),
          ),

          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AddWorkoutScreen(),
              ),
            );
          },

          icon: const Icon(
            Icons.add_rounded,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TODAY WORKOUT CARD
  // ============================================================

  Widget _heroCard(
    Map<String, int> today,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        22,
      ),

      decoration: AppTheme.premiumCard(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF17C8B8),
            Color(0xFF5F54E8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderColor: Colors.transparent,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TODAY\'S ACTIVITY',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 1.4,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  '${today['calories']} kcal',
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${today['minutes']} min • '
                  '${today['sessions']} sessions',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 68,
            width: 68,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(
                .14,
              ),
              borderRadius: BorderRadius.circular(
                22,
              ),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 38,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERALL DAILY PROGRESS
  // ============================================================

  Widget _overallProgressCard({
    required double progress,
  }) {
    final percentage = (progress * 100).round();

    String message;

    if (percentage >= 100) {
      message = 'Excellent! Today\'s goals are complete.';
    } else if (percentage >= 75) {
      message = 'Great progress. You\'re almost there.';
    } else if (percentage >= 50) {
      message = 'Good progress. Keep moving.';
    } else if (percentage >= 25) {
      message = 'A good start. Keep building your day.';
    } else {
      message = 'Your goals are ready. Start with one small step.';
    }

    return Container(
      padding: const EdgeInsets.all(
        20,
      ),

      decoration: AppTheme.premiumCard(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(
              .13,
            ),
            AppTheme.purpleAccent.withOpacity(
              .09,
            ),
          ],
        ),

        borderColor: AppTheme.accentColor.withOpacity(
          .17,
        ),
      ),

      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 82,
                width: 82,

                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.white.withOpacity(
                    .06,
                  ),
                  color: AppTheme.accentColor,
                ),
              ),

              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily Progress',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    99,
                  ),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withOpacity(
                      .05,
                    ),
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INDIVIDUAL GOAL CARD
  // ============================================================

  Widget _goalProgressCard({
    required IconData icon,
    required String title,
    required String currentText,
    required double progress,
    required Color color,
  }) {
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(
        16,
      ),

      decoration: AppTheme.premiumCard(),

      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,

            decoration: BoxDecoration(
              color: color.withOpacity(
                .12,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),

            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Text(
                      '$percentage%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  currentText,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 9,
                ),

                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    99,
                  ),

                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.white.withOpacity(
                      .05,
                    ),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEIGHT PROGRESS
  // ============================================================

  Widget _weightProgressCard({
    required double start,
    required double current,
    required double goal,
    required double progress,
  }) {
    final percentage = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(
        17,
      ),

      decoration: AppTheme.premiumCard(
        borderColor: AppTheme.purpleAccent.withOpacity(
          .12,
        ),
      ),

      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 48,

                decoration: BoxDecoration(
                  color: AppTheme.purpleAccent.withOpacity(
                    .12,
                  ),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),

                child: const Icon(
                  Icons.monitor_weight_outlined,
                  color: AppTheme.purpleAccent,
                ),
              ),

              const SizedBox(
                width: 13,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Weight Goal',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '${start.toStringAsFixed(1)} kg → '
                      '${current.toStringAsFixed(1)} kg → '
                      '${goal.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '$percentage%',
                style: const TextStyle(
                  color: AppTheme.purpleAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              99,
            ),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withOpacity(
                .05,
              ),
              color: AppTheme.purpleAccent,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
    String trailing,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Text(
          trailing,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // WEEKLY CHART
  // ============================================================

  Widget _chartCard(
    List<double> data,
  ) {
    final maxY = data.fold<double>(
      0,
      (
        max,
        value,
      ) =>
          value > max ? value : max,
    );

    final chartMax =
        maxY <= 0
            ? 100.0
            : maxY * 1.25;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(
        16,
        24,
        16,
        12,
      ),

      decoration: AppTheme.premiumCard(),

      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: chartMax,

          alignment: BarChartAlignment.spaceAround,

          gridData: const FlGridData(
            show: false,
          ),

          borderData: FlBorderData(
            show: false,
          ),

          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            rightTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            topTitles: const AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,

                getTitlesWidget: (
                  value,
                  meta,
                ) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];

                  final index = value.toInt();

                  if (index < 0 || index > 6) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),

                    child: Text(
                      days[index],
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups:
              data.asMap().entries.map(
                (
                  entry,
                ) {
                  return BarChartGroupData(
                    x: entry.key,

                    barRods: [
                      BarChartRodData(
                        toY: entry.value,
                        width: 16,

                        borderRadius: BorderRadius.circular(
                          8,
                        ),

                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.accentColor,
                            AppTheme.purpleAccent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),

                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: chartMax,
                          color: Colors.white.withOpacity(
                            .035,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // WORKOUT TILE
  // ============================================================

  Widget _workoutTile(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),

      padding: const EdgeInsets.all(
        16,
      ),

      decoration: AppTheme.premiumCard(),

      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,

            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(
                .12,
              ),
              borderRadius: BorderRadius.circular(
                15,
              ),
            ),

            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppTheme.accentColor,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '${workout.duration} min • '
                  '${workout.calories} kcal • '
                  '${workout.intensity}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),

                Text(
                  DateFormat(
                    'EEE, d MMM • h:mm a',
                  ).format(
                    workout.date,
                  ),

                  style: TextStyle(
                    color: AppTheme.textSecondary.withOpacity(
                      .75,
                    ),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip: 'Delete workout',

            onPressed: () => _confirmDelete(
              context,
              ref,
              workout,
            ),

            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DELETE WORKOUT
  // ============================================================

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    if (workout.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,

      builder: (
        context,
      ) =>
          AlertDialog(
        backgroundColor: AppTheme.cardColorSoft,

        title: const Text(
          'Delete workout?',
        ),

        content: Text(
          'Remove ${workout.title} from your history?',
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(
              context,
              false,
            ),
            child: const Text(
              'Cancel',
            ),
          ),

          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              true,
            ),
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(
            workoutNotifierProvider.notifier,
          )
          .deleteWorkout(
            workout.id!,
          );
    }
  }

  // ============================================================
  // EMPTY WORKOUT
  // ============================================================

  Widget _emptyWorkout(
    BuildContext context,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        24,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        children: [
          const Icon(
            Icons.directions_run_rounded,
            size: 40,
            color: AppTheme.accentColor,
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'No workouts yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Log your first activity and your progress will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddWorkoutScreen(),
                ),
              );
            },

            icon: const Icon(
              Icons.add_rounded,
            ),

            label: const Text(
              'Add workout',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),

        child: Text(
          'Something went wrong:\n$message',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
/*
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/workout_model.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';

class DashboardScreen
    extends ConsumerWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workoutState =
        ref.watch(
      workoutNotifierProvider,
    );

    final weeklyData =
        ref.watch(
      weeklyCaloriesChartProvider,
    );

    final today =
        ref.watch(
      todayWorkoutSummaryProvider,
    );

    final water =
        ref
                .watch(
                  waterIntakeNotifierProvider,
                )
                .asData
                ?.value ??
            0;

    final steps =
        ref
                .watch(
                  dailyStepsNotifierProvider,
                )
                .asData
                ?.value ??
            0;

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(
                0xFF071827,
              ),
            ],

            begin:
                Alignment.topLeft,

            end:
                Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child:
              workoutState.when(
            loading: () =>
                const Center(
              child:
                  CircularProgressIndicator(
                color: AppTheme
                    .accentColor,
              ),
            ),

            error:
                (error, stack) =>
                    _ErrorState(
              message: '$error',
            ),

            data:
                (workouts) {
              return RefreshIndicator(
                onRefresh: () =>
                    ref.refresh(
                  workoutNotifierProvider
                      .future,
                ),

                child: ListView(
                  physics:
                      const AlwaysScrollableScrollPhysics(
                    parent:
                        BouncingScrollPhysics(),
                  ),

                  padding:
                      const EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    28,
                  ),

                  children: [
                    _header(
                      context,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    _heroCard(
                      today,
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _metricCard(
                            icon:
                                Icons.directions_walk_rounded,

                            label:
                                'Steps',

                            value:
                                NumberFormat.compact()
                                    .format(
                              steps,
                            ),

                            color:
                                AppTheme.accentColor,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              _metricCard(
                            icon:
                                Icons.water_drop_rounded,

                            label:
                                'Water',

                            value:
                                '$water / 8',

                            color:
                                Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 26,
                    ),

                    _sectionTitle(
                      'Weekly burn',

                      '${weeklyData.fold<double>(
                        0,
                        (a, b) =>
                            a + b,
                      ).round()} kcal',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _chartCard(
                      weeklyData,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    _sectionTitle(
                      'Recent workouts',

                      '${workouts.length} total',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    if (workouts.isEmpty)
                      _emptyWorkout(
                        context,
                      )
                    else
                      ...workouts
                          .take(5)
                          .map(
                            (
                              workout,
                            ) =>
                                _workoutTile(
                              context,
                              ref,
                              workout,
                            ),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _header(
    BuildContext context,
  ) {
    final hour =
        DateTime.now().hour;

    final greeting =
        hour < 12
            ? 'Good morning'
            : hour < 17
                ? 'Good afternoon'
                : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                greeting,

                style:
                    const TextStyle(
                  color: AppTheme
                      .textSecondary,

                  fontSize: 13,
                ),
              ),

              const SizedBox(
                height: 2,
              ),

              const Text(
                'Ready to move?',

                style:
                    TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        IconButton.filled(
          style:
              IconButton.styleFrom(
            backgroundColor:
                AppTheme.accentColor,

            foregroundColor:
                AppTheme.bgColor,

            minimumSize:
                const Size(
              48,
              48,
            ),
          ),

          onPressed: () {
            Navigator.push(
              context,

              MaterialPageRoute(
                builder: (_) =>
                    const AddWorkoutScreen(),
              ),
            );
          },

          icon:
              const Icon(
            Icons.add_rounded,
          ),
        ),
      ],
    );
  }

  Widget _heroCard(
    Map<String, int> today,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),

      decoration:
          AppTheme.premiumCard(
        gradient:
            const LinearGradient(
          colors: [
            Color(
              0xFF17C8B8,
            ),
            Color(
              0xFF5F54E8,
            ),
          ],

          begin:
              Alignment.topLeft,

          end:
              Alignment.bottomRight,
        ),

        borderColor:
            Colors.transparent,
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                const Text(
                  'TODAY',

                  style:
                      TextStyle(
                    color:
                        Colors.white70,

                    letterSpacing:
                        1.4,

                    fontSize:
                        11,

                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  '${today['calories']} kcal',

                  style:
                      const TextStyle(
                    fontSize:
                        31,

                    fontWeight:
                        FontWeight.w900,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${today['minutes']} min  •  ${today['sessions']} sessions',

                  style:
                      const TextStyle(
                    color:
                        Colors.white70,

                    fontSize:
                        13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            height: 68,
            width: 68,

            decoration:
                BoxDecoration(
              color: Colors.white
                  .withOpacity(
                .14,
              ),

              borderRadius:
                  BorderRadius.circular(
                22,
              ),
            ),

            child:
                const Icon(
              Icons
                  .local_fire_department_rounded,

              size: 38,

              color:
                  Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          AppTheme.premiumCard(),

      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,

            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                .13,
              ),

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child:
                Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  value,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w800,

                    fontSize:
                        17,
                  ),
                ),

                Text(
                  label,

                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondary,

                    fontSize:
                        11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    String trailing,
  ) {
    return Row(
      children: [
        Expanded(
          child:
              Text(
            title,

            style:
                const TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ),

        Text(
          trailing,

          style:
              const TextStyle(
            color: AppTheme
                .textSecondary,

            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _chartCard(
    List<double> data,
  ) {
    final maxY =
        data.fold<double>(
      0,
      (
        max,
        value,
      ) =>
          value > max
              ? value
              : max,
    );

    final chartMax =
        maxY <= 0
            ? 100.0
            : maxY * 1.25;

    return Container(
      height: 250,

      padding:
          const EdgeInsets.fromLTRB(
        16,
        24,
        16,
        12,
      ),

      decoration:
          AppTheme.premiumCard(),

      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: chartMax,

          alignment:
              BarChartAlignment
                  .spaceAround,

          gridData:
              const FlGridData(
            show: false,
          ),

          borderData:
              FlBorderData(
            show: false,
          ),

          titlesData:
              FlTitlesData(
            leftTitles:
                const AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles:
                    false,
              ),
            ),

            rightTitles:
                const AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles:
                    false,
              ),
            ),

            topTitles:
                const AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles:
                    false,
              ),
            ),

            bottomTitles:
                AxisTitles(
              sideTitles:
                  SideTitles(
                showTitles:
                    true,

                reservedSize:
                    30,

                getTitlesWidget:
                    (
                  value,
                  meta,
                ) {
                  const days = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ];

                  final index =
                      value.toInt();

                  if (index < 0 ||
                      index > 6) {
                    return const SizedBox
                        .shrink();
                  }

                  return Padding(
                    padding:
                        const EdgeInsets
                            .only(
                      top: 8,
                    ),

                    child:
                        Text(
                      days[index],

                      style:
                          const TextStyle(
                        color: AppTheme
                            .textSecondary,

                        fontSize:
                            11,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barGroups:
              data
                  .asMap()
                  .entries
                  .map(
            (entry) {
              return BarChartGroupData(
                x: entry.key,

                barRods: [
                  BarChartRodData(
                    toY:
                        entry.value,

                    width:
                        16,

                    borderRadius:
                        BorderRadius
                            .circular(
                      8,
                    ),

                    gradient:
                        const LinearGradient(
                      colors: [
                        AppTheme
                            .accentColor,

                        AppTheme
                            .purpleAccent,
                      ],

                      begin:
                          Alignment.bottomCenter,

                      end:
                          Alignment.topCenter,
                    ),

                    backDrawRodData:
                        BackgroundBarChartRodData(
                      show:
                          true,

                      toY:
                          chartMax,

                      color:
                          Colors.white
                              .withOpacity(
                        .035,
                      ),
                    ),
                  ),
                ],
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _workoutTile(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),

      padding:
          const EdgeInsets.all(
        16,
      ),

      decoration:
          AppTheme.premiumCard(),

      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,

            decoration:
                BoxDecoration(
              color: AppTheme
                  .accentColor
                  .withOpacity(
                .12,
              ),

              borderRadius:
                  BorderRadius.circular(
                15,
              ),
            ),

            child:
                const Icon(
              Icons
                  .fitness_center_rounded,

              color:
                  AppTheme.accentColor,
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  workout.title,

                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.w700,

                    fontSize:
                        15,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '${workout.duration} min • ${workout.calories} kcal • ${workout.intensity}',

                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondary,

                    fontSize:
                        11,
                  ),
                ),

                Text(
                  DateFormat(
                    'EEE, d MMM • h:mm a',
                  ).format(
                    workout.date,
                  ),

                  style:
                      TextStyle(
                    color: AppTheme
                        .textSecondary
                        .withOpacity(
                      .75,
                    ),

                    fontSize:
                        10,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            tooltip:
                'Delete workout',

            onPressed: () =>
                _confirmDelete(
              context,
              ref,
              workout,
            ),

            icon:
                const Icon(
              Icons
                  .delete_outline_rounded,

              color: AppTheme
                  .textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void>
      _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    if (workout.id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context: context,

      builder:
          (context) =>
              AlertDialog(
        backgroundColor:
            AppTheme.cardColorSoft,

        title:
            const Text(
          'Delete workout?',
        ),

        content:
            Text(
          'Remove ${workout.title} from your history?',
        ),

        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
              context,
              false,
            ),

            child:
                const Text(
              'Cancel',
            ),
          ),

          FilledButton(
            onPressed: () =>
                Navigator.pop(
              context,
              true,
            ),

            child:
                const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref
          .read(
            workoutNotifierProvider
                .notifier,
          )
          .deleteWorkout(
            workout.id!,
          );
    }
  }

  Widget _emptyWorkout(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        24,
      ),

      decoration:
          AppTheme.premiumCard(),

      child:
          Column(
        children: [
          const Icon(
            Icons
                .directions_run_rounded,

            size: 40,

            color:
                AppTheme.accentColor,
          ),

          const SizedBox(
            height: 10,
          ),

          const Text(
            'No workouts yet',

            style:
                TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Log your first activity and your progress will appear here.',

            textAlign:
                TextAlign.center,

            style:
                TextStyle(
              color: AppTheme
                  .textSecondary,

              fontSize:
                  12,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) =>
                      const AddWorkoutScreen(),
                ),
              );
            },

            icon:
                const Icon(
              Icons.add_rounded,
            ),

            label:
                const Text(
              'Add workout',
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState
    extends StatelessWidget {
  const _ErrorState({
    required this.message,
  });

  final String message;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
          24,
        ),

        child:
            Text(
          'Something went wrong:\n$message',

          textAlign:
              TextAlign.center,
        ),
      ),
    );
  }
}*/