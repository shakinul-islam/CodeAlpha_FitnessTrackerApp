import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';
import '../providers/user_provider.dart';
import 'daily_goals_screen.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';
import 'progress_analytics_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final profileState = ref.watch(
      profileNotifierProvider,
    );

    final weightHistory = ref.watch(
      weightHistoryNotifierProvider,
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(0xFF071827),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: profileState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),

            error: (
              error,
              stack,
            ) =>
                Center(
              child: Text(
                'Error: $error',
              ),
            ),

            data: (
              profile,
            ) {
              final height =
                  (profile['height'] as num).toDouble();

              final weight =
                  (profile['weight'] as num).toDouble();

              final goal =
                  (profile['goal_weight'] as num).toDouble();

              final start =
                  (profile['starting_weight'] as num).toDouble();

              final bmi =
                  weight /
                  (height * height);

              final progress =
                  _goalProgress(
                start: start,
                current: weight,
                goal: goal,
              );

              return ListView(
                physics: const BouncingScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  28,
                ),

                children: [
                  // =================================================
                  // HEADER
                  // =================================================

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      IconButton.filledTonal(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfileScreen(),
                            ),
                          );

                          ref.invalidate(
                            profileNotifierProvider,
                          );

                          ref.invalidate(
                            weightHistoryNotifierProvider,
                          );
                        },

                        icon: const Icon(
                          Icons.edit_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // =================================================
                  // BMI
                  // =================================================

                  _profileHero(
                    bmi,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // HEIGHT + WEIGHT
                  // =================================================

                  Row(
                    children: [
                      Expanded(
                        child: _heightMetric(
                          height,
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: _metric(
                          'Weight',
                          '${weight.toStringAsFixed(1)} kg',
                          Icons.monitor_weight_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // WEIGHT GOAL
                  // =================================================

                  _goalCard(
                    start: start,
                    current: weight,
                    goal: goal,
                    progress: progress,
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // =================================================
                  // WEIGHT PROGRESS
                  // =================================================

                  const Text(
                    'Weight Progress',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  weightHistory.when(
                    loading: () => const SizedBox(
                      height: 220,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),

                    error: (
                      error,
                      stack,
                    ) =>
                        Container(
                      padding: const EdgeInsets.all(
                        20,
                      ),
                      decoration: AppTheme.premiumCard(),
                      child: const Text(
                        'Unable to load weight history.',
                      ),
                    ),

                    data: (
                      history,
                    ) =>
                        _weightChart(
                      history,
                    ),
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  // =================================================
                  // PROGRESS & SETTINGS
                  // =================================================

                  const Text(
                    'Progress & Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // =================================================
                  // PROGRESS ANALYTICS
                  // =================================================

                  _settingsTile(
                    icon: Icons.insights_rounded,
                    title: 'Progress Analytics',
                    subtitle:
                        'Review your progress over 7 or 30 days',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProgressAnalyticsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================================
                  // DAILY GOALS
                  // =================================================

                  _settingsTile(
                    icon: Icons.track_changes_rounded,
                    title: 'Daily Goals',
                    subtitle:
                        'Steps, water, calories and sleep goals',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const DailyGoalsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================================
                  // NOTIFICATIONS
                  // =================================================

                  _settingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle:
                        'Water reminder settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================================
                  // HEALTH INFO
                  // =================================================

                  _settingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Health metrics',
                    subtitle:
                        'BMI and calories are estimates, not medical advice',
                    onTap: null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WEIGHT GRAPH
  // ============================================================

  Widget _weightChart(
    List<Map<String, dynamic>> history,
  ) {
    if (history.isEmpty) {
      return Container(
        height: 180,
        padding: const EdgeInsets.all(
          22,
        ),

        decoration: AppTheme.premiumCard(),

        child: const Center(
          child: Text(
            'Update your weight to start building your history.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    final visible =
        history.length > 10
            ? history.sublist(
                history.length - 10,
              )
            : history;

    final weights =
        visible
            .map(
              (
                item,
              ) =>
                  (item['weight'] as num).toDouble(),
            )
            .toList();

    var minWeight =
        weights.reduce(
      (
        a,
        b,
      ) =>
          a < b ? a : b,
    );

    var maxWeight =
        weights.reduce(
      (
        a,
        b,
      ) =>
          a > b ? a : b,
    );

    minWeight -= 1;
    maxWeight += 1;

    final spots =
        List.generate(
      visible.length,
      (
        index,
      ) {
        return FlSpot(
          index.toDouble(),
          (visible[index]['weight'] as num).toDouble(),
        );
      },
    );

    return Container(
      height: 245,

      padding: const EdgeInsets.fromLTRB(
        16,
        22,
        16,
        14,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,

                maxX:
                    visible.length == 1
                        ? 1
                        : (visible.length - 1).toDouble(),

                minY: minWeight,

                maxY: maxWeight,

                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,

                  horizontalInterval: 2,

                  getDrawingHorizontalLine: (
                    value,
                  ) {
                    return FlLine(
                      color:
                          Colors.white.withOpacity(
                        .04,
                      ),
                      strokeWidth: 1,
                    );
                  },
                ),

                borderData: FlBorderData(
                  show: false,
                ),

                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),

                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),

                lineBarsData: [
                  LineChartBarData(
                    spots: spots,

                    isCurved: true,

                    barWidth: 4,

                    color: AppTheme.accentColor,

                    dotData: const FlDotData(
                      show: true,
                    ),

                    belowBarData: BarAreaData(
                      show: true,

                      color:
                          AppTheme.accentColor.withOpacity(
                        .10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          Row(
            children: [
              Text(
                '${weights.first.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),

              const Spacer(),

              Text(
                '${weights.last.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEIGHT
  // ============================================================

  Widget _heightMetric(
    double meters,
  ) {
    return FutureBuilder<String>(
      future: _heightDisplayText(
        meters,
      ),

      builder: (
        context,
        snapshot,
      ) {
        final value =
            snapshot.data ??
            '${meters.toStringAsFixed(2)} m';

        return _metric(
          'Height',
          value,
          Icons.height_rounded,
        );
      },
    );
  }

  Future<String> _heightDisplayText(
    double meters,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    final unit =
        prefs.getString(
          'height_input_unit',
        ) ??
        'meter';

    if (unit == 'meter') {
      return '${meters.toStringAsFixed(2)} m';
    }

    final totalInches =
        meters *
        39.3700787;

    final feet =
        totalInches ~/ 12;

    final inches =
        totalInches -
        (feet * 12);

    return '$feet ft ${inches.toStringAsFixed(1)} in';
  }

  // ============================================================
  // WEIGHT GOAL PROGRESS
  // ============================================================

  double _goalProgress({
    required double start,
    required double current,
    required double goal,
  }) {
    final total =
        (start - goal).abs();

    if (total == 0) {
      return current == goal
          ? 1
          : 0;
    }

    if (goal < start) {
      if (current >= start) {
        return 0;
      }

      if (current <= goal) {
        return 1;
      }

      return ((start - current) / total).clamp(
        0.0,
        1.0,
      );
    }

    if (goal > start) {
      if (current <= start) {
        return 0;
      }

      if (current >= goal) {
        return 1;
      }

      return ((current - start) / total).clamp(
        0.0,
        1.0,
      );
    }

    return 0;
  }

  // ============================================================
  // BMI
  // ============================================================

  Widget _profileHero(
    double bmi,
  ) {
    final category =
        _bmiCategory(
      bmi,
    );

    return Container(
      padding: const EdgeInsets.all(
        22,
      ),

      decoration: AppTheme.premiumCard(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(
              .16,
            ),
            AppTheme.purpleAccent.withOpacity(
              .12,
            ),
          ],
        ),

        borderColor:
            AppTheme.accentColor.withOpacity(
          .18,
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 74,
            width: 74,

            decoration: const BoxDecoration(
              shape: BoxShape.circle,

              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor,
                  AppTheme.purpleAccent,
                ],
              ),
            ),

            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 39,
            ),
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Your BMI',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),

                Text(
                  bmi.toStringAsFixed(
                    1,
                  ),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bmiCategory(
    double bmi,
  ) {
    if (bmi < 18.5) {
      return 'Underweight';
    }

    if (bmi < 25) {
      return 'Normal range';
    }

    if (bmi < 30) {
      return 'Overweight';
    }

    return 'Obesity range';
  }

  // ============================================================
  // METRIC
  // ============================================================

  Widget _metric(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        17,
      ),

      decoration: AppTheme.premiumCard(),

      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
          ),

          const SizedBox(
            width: 10,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
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
  // WEIGHT GOAL
  // ============================================================

  Widget _goalCard({
    required double start,
    required double current,
    required double goal,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        20,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'Weight goal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            '${start.toStringAsFixed(1)} kg  →  '
            '${goal.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          ClipRRect(
            borderRadius: BorderRadius.circular(
              99,
            ),

            child: LinearProgressIndicator(
              value: progress,

              minHeight: 12,

              backgroundColor:
                  Colors.white.withOpacity(
                .06,
              ),

              color: AppTheme.accentColor,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Row(
            children: [
              Text(
                'Current: ${current.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),

              const Spacer(),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS TILE
  // ============================================================

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,

      child: InkWell(
        borderRadius: BorderRadius.circular(
          22,
        ),

        onTap: onTap,

        child: Container(
          padding: const EdgeInsets.all(
            17,
          ),

          decoration: AppTheme.premiumCard(),

          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,

                decoration: BoxDecoration(
                  color:
                      AppTheme.purpleAccent.withOpacity(
                    .12,
                  ),

                  borderRadius: BorderRadius.circular(
                    14,
                  ),
                ),

                child: Icon(
                  icon,
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
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';
import 'edit_profile_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: profileState.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),
            error: (error, stack) => Center(
              child: Text(
                'Error: $error',
              ),
            ),
            data: (profile) {
              final height = (profile['height'] as num).toDouble();

              final weight = (profile['weight'] as num).toDouble();

              final goal = (profile['goal_weight'] as num).toDouble();

              final start =
                  (profile['starting_weight'] as num).toDouble();

              final bmi = weight / (height * height);

              final progress = _goalProgress(
                start: start,
                current: weight,
                goal: goal,
              );

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  28,
                ),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const EditProfileScreen(),
                            ),
                          );

                          // Refresh profile display after returning.
                          ref.invalidate(
                            profileNotifierProvider,
                          );
                        },
                        icon: const Icon(
                          Icons.edit_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  _profileHero(
                    bmi,
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _heightMetric(
                          height,
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _metric(
                          'Weight',
                          '${weight.toStringAsFixed(1)} kg',
                          Icons.monitor_weight_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _goalCard(
                    start: start,
                    current: weight,
                    goal: goal,
                    progress: progress,
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Preferences',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _settingsTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Water reminder settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const NotificationSettingsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  _settingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Health metrics',
                    subtitle:
                        'BMI and calories are estimates, not medical advice',
                    onTap: null,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEIGHT DISPLAY
  // ============================================================

  Widget _heightMetric(
    double meters,
  ) {
    return FutureBuilder<String>(
      future: _heightDisplayText(
        meters,
      ),
      builder: (context, snapshot) {
        final value =
            snapshot.data ?? '${meters.toStringAsFixed(2)} m';

        return _metric(
          'Height',
          value,
          Icons.height_rounded,
        );
      },
    );
  }

  Future<String> _heightDisplayText(
    double meters,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final unit = prefs.getString(
          'height_input_unit',
        ) ??
        'meter';

    if (unit == 'meter') {
      return '${meters.toStringAsFixed(2)} m';
    }

    final totalInches = meters * 39.3700787;

    final feet = totalInches ~/ 12;

    final inches = totalInches - (feet * 12);

    return '$feet ft ${inches.toStringAsFixed(1)} in';
  }

  // ============================================================
  // GOAL PROGRESS
  // ============================================================

  double _goalProgress({
    required double start,
    required double current,
    required double goal,
  }) {
    final denominator = (start - goal).abs();

    if (denominator == 0) {
      return current == goal ? 1 : 0;
    }

    final moved = (start - current).abs();

    final movingTowardGoal =
        (goal < start && current <= start) ||
            (goal > start && current >= start);

    if (!movingTowardGoal) {
      return 0;
    }

    return (moved / denominator).clamp(
      0.0,
      1.0,
    );
  }

  // ============================================================
  // BMI CARD
  // ============================================================

  Widget _profileHero(
    double bmi,
  ) {
    final category = _bmiCategory(
      bmi,
    );

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: AppTheme.premiumCard(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(.16),
            AppTheme.purpleAccent.withOpacity(.12),
          ],
        ),
        borderColor: AppTheme.accentColor.withOpacity(.18),
      ),
      child: Row(
        children: [
          Container(
            height: 74,
            width: 74,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor,
                  AppTheme.purpleAccent,
                ],
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 39,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your BMI',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),

                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                Text(
                  category,
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bmiCategory(
    double bmi,
  ) {
    if (bmi < 18.5) {
      return 'Underweight';
    }

    if (bmi < 25) {
      return 'Normal range';
    }

    if (bmi < 30) {
      return 'Overweight';
    }

    return 'Obesity range';
  }

  // ============================================================
  // METRIC CARD
  // ============================================================

  Widget _metric(
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: AppTheme.premiumCard(),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentColor,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),

                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
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
  // GOAL CARD
  // ============================================================

  Widget _goalCard({
    required double start,
    required double current,
    required double goal,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.premiumCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weight goal',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '${start.toStringAsFixed(1)} kg  →  '
            '${goal.toStringAsFixed(1)} kg',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(.06),
              color: AppTheme.accentColor,
            ),
          ),

          const SizedBox(height: 9),

          Row(
            children: [
              Text(
                'Current: ${current.toStringAsFixed(1)} kg',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),

              const Spacer(),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: AppTheme.accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS
  // ============================================================

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: AppTheme.premiumCard(),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: AppTheme.purpleAccent.withOpacity(.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.purpleAccent,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}*/