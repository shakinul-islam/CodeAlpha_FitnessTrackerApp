import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../providers/analytics_provider.dart';

class ProgressAnalyticsScreen
    extends ConsumerStatefulWidget {
  const ProgressAnalyticsScreen({
    super.key,
  });

  @override
  ConsumerState<ProgressAnalyticsScreen>
      createState() =>
          _ProgressAnalyticsScreenState();
}

class _ProgressAnalyticsScreenState
    extends ConsumerState<
        ProgressAnalyticsScreen> {
  int _selectedDays = 7;

  @override
  Widget build(
    BuildContext context,
  ) {
    final analytics =
        ref.watch(
      progressAnalyticsProvider(
        _selectedDays,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Progress Analytics',
        ),
      ),

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
          top: false,
          child: analytics.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentColor,
              ),
            ),

            error: (
              error,
              stack,
            ) =>
                _errorState(
              error,
            ),

            data: (
              data,
            ) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(
                    progressAnalyticsProvider(
                      _selectedDays,
                    ),
                  );
                },

                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),

                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    30,
                  ),

                  children: [
                    // =================================================
                    // PERIOD
                    // =================================================

                    _periodSelector(),

                    const SizedBox(
                      height: 20,
                    ),

                    _periodSummary(
                      data,
                    ),

                    const SizedBox(
                      height: 22,
                    ),

                    // =================================================
                    // SUMMARY
                    // =================================================

                    const Text(
                      'Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.directions_walk_rounded,
                            title:
                                'Avg Steps',
                            value:
                                NumberFormat.decimalPattern().format(
                              data.averageSteps.round(),
                            ),
                            color:
                                AppTheme.accentColor,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.water_drop_rounded,
                            title:
                                'Avg Water',
                            value:
                                '${data.averageWaterMl.round()} ml',
                            color:
                                Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.bedtime_rounded,
                            title:
                                'Avg Sleep',
                            value:
                                _durationText(
                              data.averageSleepMinutes.round(),
                            ),
                            color:
                                AppTheme.purpleAccent,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.timer_outlined,
                            title:
                                'Workout',
                            value:
                                '${data.totalWorkoutMinutes} min',
                            color:
                                AppTheme.orangeAccent,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.restaurant_rounded,
                            title:
                                'Consumed',
                            value:
                                '${data.totalCaloriesConsumed} kcal',
                            color:
                                AppTheme.orangeAccent,
                          ),
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: _summaryCard(
                            icon:
                                Icons.local_fire_department_rounded,
                            title:
                                'Burned',
                            value:
                                '${data.totalCaloriesBurned} kcal',
                            color:
                                AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // =================================================
                    // GOAL CONSISTENCY
                    // =================================================

                    const Text(
                      'Goal Consistency',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _goalConsistencyCard(
                      data,
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // =================================================
                    // STEPS CHART
                    // =================================================

                    _sectionTitle(
                      'Steps',
                      'Daily',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _barChartCard(
                      data: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.steps.toDouble(),
                          )
                          .toList(),
                      dates: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.date,
                          )
                          .toList(),
                      goal:
                          data.stepsGoal.toDouble(),
                      color:
                          AppTheme.accentColor,
                      valueFormatter: (
                        value,
                      ) =>
                          NumberFormat.compact().format(
                        value,
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // WATER
                    // =================================================

                    _sectionTitle(
                      'Water',
                      'ml',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _barChartCard(
                      data: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.waterMl.toDouble(),
                          )
                          .toList(),
                      dates: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.date,
                          )
                          .toList(),
                      goal:
                          data.waterGoalMl.toDouble(),
                      color:
                          Colors.blueAccent,
                      valueFormatter: (
                        value,
                      ) =>
                          '${value.round()}',
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // SLEEP
                    // =================================================

                    _sectionTitle(
                      'Sleep',
                      'Hours',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _barChartCard(
                      data: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.sleepMinutes / 60,
                          )
                          .toList(),
                      dates: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.date,
                          )
                          .toList(),
                      goal:
                          data.sleepGoalMinutes / 60,
                      color:
                          AppTheme.purpleAccent,
                      valueFormatter: (
                        value,
                      ) =>
                          '${value.toStringAsFixed(1)}h',
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // WORKOUT
                    // =================================================

                    _sectionTitle(
                      'Workout Minutes',
                      '${data.totalWorkoutMinutes} min',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _barChartCard(
                      data: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.workoutMinutes.toDouble(),
                          )
                          .toList(),
                      dates: data.daily
                          .map(
                            (
                              item,
                            ) =>
                                item.date,
                          )
                          .toList(),
                      color:
                          AppTheme.orangeAccent,
                      valueFormatter: (
                        value,
                      ) =>
                          '${value.round()}m',
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // CALORIES
                    // =================================================

                    _sectionTitle(
                      'Calories',
                      'Consumed vs Burned',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _calorieChart(
                      data,
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // =================================================
                    // WEIGHT
                    // =================================================

                    _sectionTitle(
                      'Weight Trend',
                      data.weights.isEmpty
                          ? 'No entries'
                          : '${data.weights.last.weight.toStringAsFixed(1)} kg',
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    _weightChart(
                      data.weights,
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
  // PERIOD SELECTOR
  // ============================================================

  Widget _periodSelector() {
    return SizedBox(
      width: double.infinity,

      child: SegmentedButton<int>(
        segments: const [
          ButtonSegment<int>(
            value: 7,
            label: Text(
              '7 Days',
            ),
            icon: Icon(
              Icons.calendar_view_week_rounded,
            ),
          ),

          ButtonSegment<int>(
            value: 30,
            label: Text(
              '30 Days',
            ),
            icon: Icon(
              Icons.calendar_month_rounded,
            ),
          ),
        ],

        selected: {
          _selectedDays,
        },

        onSelectionChanged: (
          selection,
        ) {
          setState(
            () {
              _selectedDays =
                  selection.first;
            },
          );
        },
      ),
    );
  }

  // ============================================================
  // PERIOD SUMMARY
  // ============================================================

  Widget _periodSummary(
    ProgressAnalyticsData data,
  ) {
    final first =
        data.daily.first.date;

    final last =
        data.daily.last.date;

    return Container(
      padding: const EdgeInsets.all(
        18,
      ),

      decoration: AppTheme.premiumCard(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentColor.withOpacity(
              .12,
            ),
            AppTheme.purpleAccent.withOpacity(
              .08,
            ),
          ],
        ),
        borderColor:
            AppTheme.accentColor.withOpacity(
          .15,
        ),
      ),

      child: Row(
        children: [
          Container(
            height: 54,
            width: 54,

            decoration: BoxDecoration(
              color:
                  AppTheme.accentColor.withOpacity(
                .13,
              ),
              borderRadius: BorderRadius.circular(
                17,
              ),
            ),

            child: const Icon(
              Icons.insights_rounded,
              color: AppTheme.accentColor,
              size: 28,
            ),
          ),

          const SizedBox(
            width: 14,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.days}-Day Progress',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  '${DateFormat('d MMM').format(first)}'
                  ' – '
                  '${DateFormat('d MMM yyyy').format(last)}',
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
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(
        15,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 39,
            width: 39,

            decoration: BoxDecoration(
              color: color.withOpacity(
                .12,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),

            child: Icon(
              icon,
              color: color,
              size: 21,
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GOAL CONSISTENCY
  // ============================================================

  Widget _goalConsistencyCard(
    ProgressAnalyticsData data,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        18,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        children: [
          _consistencyRow(
            icon:
                Icons.directions_walk_rounded,
            title:
                'Step goal',
            value:
                data.stepsGoalDays,
            days:
                data.days,
            color:
                AppTheme.accentColor,
          ),

          const SizedBox(
            height: 16,
          ),

          _consistencyRow(
            icon:
                Icons.water_drop_rounded,
            title:
                'Water goal',
            value:
                data.waterGoalDays,
            days:
                data.days,
            color:
                Colors.blueAccent,
          ),

          const SizedBox(
            height: 16,
          ),

          _consistencyRow(
            icon:
                Icons.bedtime_rounded,
            title:
                'Sleep goal',
            value:
                data.sleepGoalDays,
            days:
                data.days,
            color:
                AppTheme.purpleAccent,
          ),

          const SizedBox(
            height: 16,
          ),

          _consistencyRow(
            icon:
                Icons.restaurant_rounded,
            title:
                'Calorie target',
            value:
                data.calorieGoalDays,
            days:
                data.days,
            color:
                AppTheme.orangeAccent,
          ),
        ],
      ),
    );
  }

  Widget _consistencyRow({
    required IconData icon,
    required String title,
    required int value,
    required int days,
    required Color color,
  }) {
    final progress =
        days <= 0
            ? 0.0
            : (value / days).clamp(
                0.0,
                1.0,
              );

    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 21,
        ),

        const SizedBox(
          width: 11,
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
                        fontSize: 12,
                      ),
                    ),
                  ),

                  Text(
                    '$value / $days days',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(
                height: 7,
              ),

              ClipRRect(
                borderRadius: BorderRadius.circular(
                  99,
                ),

                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                      Colors.white.withOpacity(
                    .05,
                  ),
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BAR CHART
  // ============================================================

  Widget _barChartCard({
    required List<double> data,
    required List<DateTime> dates,
    required Color color,
    double? goal,
    required String Function(
      double value,
    ) valueFormatter,
  }) {
    double maxValue = 0;

    for (final value in data) {
      if (value >
          maxValue) {
        maxValue =
            value;
      }
    }

    if (goal != null &&
        goal >
            maxValue) {
      maxValue =
          goal;
    }

    final maxY =
        maxValue <= 0
            ? 10.0
            : maxValue * 1.25;

    final interval =
        _selectedDays == 7
            ? 1
            : 5;

    return Container(
      height: 245,
      padding: const EdgeInsets.fromLTRB(
        10,
        20,
        14,
        10,
      ),

      decoration: AppTheme.premiumCard(),

      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,

          alignment:
              BarChartAlignment.spaceAround,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (
              value,
            ) {
              return FlLine(
                color: Colors.white.withOpacity(
                  .04,
                ),
                strokeWidth: 1,
              );
            },
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
                reservedSize: 31,
                interval:
                    interval.toDouble(),

                getTitlesWidget: (
                  value,
                  meta,
                ) {
                  final index =
                      value.toInt();

                  if (index < 0 ||
                      index >= dates.length) {
                    return const SizedBox.shrink();
                  }

                  if (_selectedDays == 30 &&
                      index != 0 &&
                      index != dates.length - 1 &&
                      index % 5 != 0) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      top: 8,
                    ),

                    child: Text(
                      _selectedDays == 7
                          ? DateFormat('E').format(
                              dates[index],
                            )
                          : DateFormat('d MMM').format(
                              dates[index],
                            ),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          barTouchData: BarTouchData(
            enabled: true,

            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor:
                  AppTheme.cardColorSoft,

              getTooltipItem: (
                group,
                groupIndex,
                rod,
                rodIndex,
              ) {
                return BarTooltipItem(
                  '${DateFormat('d MMM').format(
                    dates[group.x],
                  )}\n'
                  '${valueFormatter(
                    rod.toY,
                  )}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
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
                        width:
                            _selectedDays == 7
                                ? 17
                                : 6,
                        color: color,
                        borderRadius:
                            BorderRadius.circular(
                          6,
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
  // CALORIE CHART
  // ============================================================

  Widget _calorieChart(
    ProgressAnalyticsData data,
  ) {
    double maxY = 0;

    for (final item in data.daily) {
      if (item.caloriesConsumed >
          maxY) {
        maxY =
            item.caloriesConsumed.toDouble();
      }

      if (item.caloriesBurned >
          maxY) {
        maxY =
            item.caloriesBurned.toDouble();
      }
    }

    if (maxY <= 0) {
      maxY = 100;
    } else {
      maxY *= 1.25;
    }

    return Container(
      height: 270,
      padding: const EdgeInsets.fromLTRB(
        10,
        18,
        14,
        12,
      ),

      decoration: AppTheme.premiumCard(),

      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _legendDot(
                AppTheme.orangeAccent,
                'Consumed',
              ),

              const SizedBox(
                width: 14,
              ),

              _legendDot(
                AppTheme.accentColor,
                'Burned',
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Expanded(
            child: BarChart(
              BarChartData(
                minY: 0,
                maxY: maxY,

                alignment:
                    BarChartAlignment.spaceAround,

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
                        final index =
                            value.toInt();

                        if (index < 0 ||
                            index >= data.daily.length) {
                          return const SizedBox.shrink();
                        }

                        if (_selectedDays == 30 &&
                            index != 0 &&
                            index != data.daily.length - 1 &&
                            index % 5 != 0) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8,
                          ),
                          child: Text(
                            _selectedDays == 7
                                ? DateFormat('E').format(
                                    data.daily[index].date,
                                  )
                                : DateFormat('d').format(
                                    data.daily[index].date,
                                  ),
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                barGroups:
                    data.daily.asMap().entries.map(
                      (
                        entry,
                      ) {
                        final item =
                            entry.value;

                        return BarChartGroupData(
                          x: entry.key,

                          barsSpace: 2,

                          barRods: [
                            BarChartRodData(
                              toY:
                                  item.caloriesConsumed.toDouble(),
                              width:
                                  _selectedDays == 7
                                      ? 7
                                      : 3,
                              color:
                                  AppTheme.orangeAccent,
                              borderRadius:
                                  BorderRadius.circular(
                                4,
                              ),
                            ),

                            BarChartRodData(
                              toY:
                                  item.caloriesBurned.toDouble(),
                              width:
                                  _selectedDays == 7
                                      ? 7
                                      : 3,
                              color:
                                  AppTheme.accentColor,
                              borderRadius:
                                  BorderRadius.circular(
                                4,
                              ),
                            ),
                          ],
                        );
                      },
                    ).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WEIGHT CHART
  // ============================================================

  Widget _weightChart(
    List<WeightAnalyticsPoint> weights,
  ) {
    if (weights.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(
          20,
        ),
        decoration: AppTheme.premiumCard(),

        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor_weight_outlined,
              color: AppTheme.textSecondary,
              size: 31,
            ),

            SizedBox(
              height: 8,
            ),

            Text(
              'No weight changes recorded in this period.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    final values =
        weights
            .map(
              (
                item,
              ) =>
                  item.weight,
            )
            .toList();

    var minY =
        values.reduce(
      (
        a,
        b,
      ) =>
          a < b ? a : b,
    );

    var maxY =
        values.reduce(
      (
        a,
        b,
      ) =>
          a > b ? a : b,
    );

    minY -= 1;
    maxY += 1;

    final spots =
        weights.asMap().entries.map(
      (
        entry,
      ) {
        return FlSpot(
          entry.key.toDouble(),
          entry.value.weight,
        );
      },
    ).toList();

    return Container(
      height: 235,
      padding: const EdgeInsets.fromLTRB(
        15,
        20,
        15,
        14,
      ),

      decoration: AppTheme.premiumCard(),

      child: LineChart(
        LineChartData(
          minX: 0,
          maxX:
              weights.length <= 1
                  ? 1
                  : (weights.length - 1).toDouble(),
          minY: minY,
          maxY: maxY,

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
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
              color: AppTheme.purpleAccent,

              dotData: const FlDotData(
                show: true,
              ),

              belowBarData: BarAreaData(
                show: true,
                color:
                    AppTheme.purpleAccent.withOpacity(
                  .10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(
    Color color,
    String text,
  ) {
    return Row(
      children: [
        Container(
          height: 9,
          width: 9,

          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(
          width: 5,
        ),

        Text(
          text,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

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
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _durationText(
    int minutes,
  ) {
    final hours =
        minutes ~/ 60;

    final mins =
        minutes % 60;

    if (hours == 0) {
      return '${mins}m';
    }

    if (mins == 0) {
      return '${hours}h';
    }

    return '${hours}h ${mins}m';
  }

  Widget _errorState(
    Object error,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(
          24,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppTheme.dangerColor,
              size: 40,
            ),

            const SizedBox(
              height: 10,
            ),

            const Text(
              'Could not load analytics.',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 12,
            ),

            OutlinedButton(
              onPressed: () {
                ref.invalidate(
                  progressAnalyticsProvider(
                    _selectedDays,
                  ),
                );
              },

              child: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}