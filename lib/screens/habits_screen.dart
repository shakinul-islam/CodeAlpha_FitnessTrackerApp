import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/user_provider.dart';

class HabitsScreen
    extends ConsumerStatefulWidget {
  const HabitsScreen({
    super.key,
  });

  @override
  ConsumerState<HabitsScreen>
      createState() =>
          _HabitsScreenState();
}

class _HabitsScreenState
    extends ConsumerState<
        HabitsScreen> {
  StreamSubscription<StepCount>?
      _stepSubscription;

  String _stepStatus =
      'Connecting to step sensor...';

  @override
  void initState() {
    super.initState();

    _initPedometer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();

    super.dispose();
  }

  // ============================================================
  // PEDOMETER
  // ============================================================

  Future<void> _initPedometer() async {
    final status =
        await Permission
            .activityRecognition
            .request();

    if (!status.isGranted) {
      if (mounted) {
        setState(
          () {
            _stepStatus =
                'Activity permission is required.';
          },
        );
      }

      return;
    }

    _stepSubscription =
        Pedometer
            .stepCountStream
            .listen(
      _onStepCount,
      onError:
          (Object error) {
        if (!mounted) {
          return;
        }

        setState(
          () {
            _stepStatus =
                'Step sensor is unavailable.';
          },
        );
      },
    );

    if (mounted) {
      setState(
        () {
          _stepStatus =
              'Live step tracking';
        },
      );
    }
  }

  Future<void> _onStepCount(
    StepCount event,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final today =
        DateFormat(
      'yyyy-MM-dd',
    ).format(
      DateTime.now(),
    );

    final savedDate =
        prefs.getString(
      'step_baseline_date',
    );

    var baseline =
        prefs.getInt(
      'step_baseline_raw',
    );

    if (savedDate != today ||
        baseline == null ||
        event.steps < baseline) {
      baseline =
          event.steps;

      await prefs.setString(
        'step_baseline_date',
        today,
      );

      await prefs.setInt(
        'step_baseline_raw',
        baseline,
      );
    }

    final dailySteps =
        (event.steps - baseline)
            .clamp(
      0,
      1000000,
    );

    await ref
        .read(
          dailyStepsNotifierProvider
              .notifier,
        )
        .setSteps(
          dailySteps,
        );
  }

  // ============================================================
  // SLEEP INPUT
  // ============================================================

  Future<void> _addSleep() async {
    final now =
        DateTime.now();

    final startTime =
        await showTimePicker(
      context: context,
      initialTime:
          const TimeOfDay(
        hour: 23,
        minute: 0,
      ),
      helpText:
          'Select sleep time',
    );

    if (startTime == null ||
        !mounted) {
      return;
    }

    final endTime =
        await showTimePicker(
      context: context,
      initialTime:
          const TimeOfDay(
        hour: 7,
        minute: 0,
      ),
      helpText:
          'Select wake-up time',
    );

    if (endTime == null ||
        !mounted) {
      return;
    }

    var end =
        DateTime(
      now.year,
      now.month,
      now.day,
      endTime.hour,
      endTime.minute,
    );

    var start =
        DateTime(
      now.year,
      now.month,
      now.day,
      startTime.hour,
      startTime.minute,
    );

    // Example:
    // Sleep 11 PM
    // Wake 7 AM
    //
    // Sleep start belongs to previous day.
    if (!start.isBefore(end)) {
      start =
          start.subtract(
        const Duration(
          days: 1,
        ),
      );
    }

    final duration =
        end.difference(
      start,
    );

    if (duration.inMinutes <= 0 ||
        duration.inHours > 24) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content:
                Text(
              'Invalid sleep duration.',
            ),
          ),
        );
      }

      return;
    }

    await ref
        .read(
          sleepHistoryNotifierProvider
              .notifier,
        )
        .addSleep(
          start: start,
          end: end,
        );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            'Sleep recorded: ${_durationText(duration.inMinutes)}',
          ),
        ),
      );
    }
  }

  String _durationText(
    int minutes,
  ) {
    final hours =
        minutes ~/ 60;

    final mins =
        minutes % 60;

    return '${hours}h ${mins}m';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final water =
        ref.watch(
      waterIntakeNotifierProvider,
    );

    final steps =
        ref.watch(
      dailyStepsNotifierProvider,
    );

    final goals =
        ref.watch(
      dailyGoalsNotifierProvider,
    );

    final sleepHistory =
        ref.watch(
      sleepHistoryNotifierProvider,
    );

    final todaySleepMinutes =
        ref.watch(
      todaySleepMinutesProvider,
    );

    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            colors: [
              AppTheme.bgColor,
              Color(0xFF071827),
            ],
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: goals.when(
            loading: () =>
                const Center(
              child:
                  CircularProgressIndicator(
                color:
                    AppTheme.accentColor,
              ),
            ),
            error:
                (error, stack) =>
                    Center(
              child:
                  Text(
                'Error: $error',
              ),
            ),
            data:
                (goalData) {
              final stepsGoal =
                  (goalData['steps_goal']
                          as num)
                      .toInt();

              final waterGoal =
                  (goalData['water_goal_ml']
                          as num)
                      .toInt();

              final sleepGoal =
                  (goalData['sleep_goal_minutes']
                          as num)
                      .toInt();

              return ListView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  28,
                ),
                children: [
                  const Text(
                    'Daily habits',
                    style:
                        TextStyle(
                      fontSize:
                          25,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Small wins build strong routines.',
                    style:
                        TextStyle(
                      color:
                          AppTheme.textSecondary,
                      fontSize:
                          13,
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),

                  // =================================================
                  // WATER
                  // =================================================

                  water.when(
                    loading: () =>
                        _loadingCard(),
                    error:
                        (e, s) =>
                            _errorCard(
                      '$e',
                    ),
                    data:
                        (value) =>
                            _waterCard(
                      value,
                      waterGoal,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // STEPS
                  // =================================================

                  steps.when(
                    loading: () =>
                        _loadingCard(),
                    error:
                        (e, s) =>
                            _errorCard(
                      '$e',
                    ),
                    data:
                        (value) =>
                            _stepsCard(
                      value,
                      stepsGoal,
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // =================================================
                  // SLEEP
                  // =================================================

                  _sleepSummaryCard(
                    todaySleepMinutes:
                        todaySleepMinutes,
                    sleepGoalMinutes:
                        sleepGoal,
                  ),

                  const SizedBox(
                    height: 26,
                  ),

                  Row(
                    children: [
                      const Expanded(
                        child:
                            Text(
                          'Sleep History',
                          style:
                              TextStyle(
                            fontSize:
                                18,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),

                      TextButton.icon(
                        onPressed:
                            _addSleep,
                        icon:
                            const Icon(
                          Icons
                              .add_rounded,
                        ),
                        label:
                            const Text(
                          'Add Sleep',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  sleepHistory.when(
                    loading: () =>
                        _loadingCard(),
                    error:
                        (e, s) =>
                            _errorCard(
                      '$e',
                    ),
                    data:
                        (entries) {
                      if (entries.isEmpty) {
                        return _emptySleep();
                      }

                      return Column(
                        children:
                            entries
                                .take(
                                  7,
                                )
                                .map(
                                  (
                                    entry,
                                  ) =>
                                      _sleepHistoryTile(
                                    entry,
                                  ),
                                )
                                .toList(),
                      );
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Container(
                    padding:
                        const EdgeInsets.all(
                      15,
                    ),
                    decoration:
                        AppTheme
                            .premiumCard(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .info_outline_rounded,
                          color:
                              AppTheme.textSecondary,
                          size:
                              19,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child:
                              Text(
                            _stepStatus,
                            style:
                                const TextStyle(
                              color:
                                  AppTheme.textSecondary,
                              fontSize:
                                  11,
                            ),
                          ),
                        ),
                      ],
                    ),
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
  // WATER
  // ============================================================

  Widget _waterCard(
    int water,
    int goal,
  ) {
    final progress =
        goal == 0
            ? 0.0
            : (water / goal).clamp(
                0.0,
                1.0,
              );

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          AppTheme.premiumCard(),
      child:
          Column(
        children: [
          Row(
            children: [
              Stack(
                alignment:
                    Alignment.center,
                children: [
                  SizedBox(
                    height:
                        62,
                    width:
                        62,
                    child:
                        CircularProgressIndicator(
                      value:
                          progress,
                      strokeWidth:
                          6,
                      backgroundColor:
                          Colors.blueAccent
                              .withOpacity(
                        .10,
                      ),
                      color:
                          Colors.blueAccent,
                    ),
                  ),

                  const Icon(
                    Icons
                        .water_drop_rounded,
                    color:
                        Colors.blueAccent,
                    size:
                        27,
                  ),
                ],
              ),

              const SizedBox(
                width: 16,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Water Intake',
                      style:
                          TextStyle(
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '$water / $goal ml',
                      style:
                          const TextStyle(
                        color:
                            AppTheme.textSecondary,
                        fontSize:
                            12,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '${(progress * 100).round()}%',
                      style:
                          const TextStyle(
                        color:
                            Colors.blueAccent,
                        fontSize:
                            11,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: water > 0
                    ? () => ref
                        .read(
                          waterIntakeNotifierProvider
                              .notifier,
                        )
                        .removeWater(
                          250,
                        )
                    : null,
                icon:
                    const Icon(
                  Icons
                      .remove_circle_outline_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          waterIntakeNotifierProvider
                              .notifier,
                        )
                        .addWater(
                          250,
                        );
                  },
                  icon:
                      const Icon(
                    Icons
                        .water_drop_outlined,
                  ),
                  label:
                      const Text(
                    '+250 ml',
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(
                          waterIntakeNotifierProvider
                              .notifier,
                        )
                        .addWater(
                          500,
                        );
                  },
                  icon:
                      const Icon(
                    Icons
                        .water_drop_rounded,
                  ),
                  label:
                      const Text(
                    '+500 ml',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STEPS
  // ============================================================

  Widget _stepsCard(
    int steps,
    int goal,
  ) {
    final progress =
        goal == 0
            ? 0.0
            : (steps / goal).clamp(
                0.0,
                1.0,
              );

    return _habitCard(
      title:
          'Steps',
      subtitle:
          '$steps / $goal steps',
      icon:
          Icons
              .directions_walk_rounded,
      color:
          AppTheme.accentColor,
      progress:
          progress,
      trailing:
          Text(
        '${(progress * 100).round()}%',
        style:
            const TextStyle(
          color:
              AppTheme.accentColor,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  // ============================================================
  // SLEEP
  // ============================================================

  Widget _sleepSummaryCard({
    required int todaySleepMinutes,
    required int sleepGoalMinutes,
  }) {
    final progress =
        sleepGoalMinutes == 0
            ? 0.0
            : (todaySleepMinutes /
                    sleepGoalMinutes)
                .clamp(
                0.0,
                1.0,
              );

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          AppTheme.premiumCard(),
      child:
          Column(
        children: [
          Row(
            children: [
              Stack(
                alignment:
                    Alignment.center,
                children: [
                  SizedBox(
                    height:
                        62,
                    width:
                        62,
                    child:
                        CircularProgressIndicator(
                      value:
                          progress,
                      strokeWidth:
                          6,
                      backgroundColor:
                          AppTheme
                              .purpleAccent
                              .withOpacity(
                            .10,
                          ),
                      color:
                          AppTheme.purpleAccent,
                    ),
                  ),

                  const Icon(
                    Icons
                        .bedtime_rounded,
                    color:
                        AppTheme.purpleAccent,
                  ),
                ],
              ),

              const SizedBox(
                width:
                    16,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Sleep',
                      style:
                          TextStyle(
                        fontSize:
                            17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(
                      height:
                          3,
                    ),

                    Text(
                      '${_durationText(todaySleepMinutes)} / '
                      '${_durationText(sleepGoalMinutes)}',
                      style:
                          const TextStyle(
                        color:
                            AppTheme.textSecondary,
                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${(progress * 100).round()}%',
                style:
                    const TextStyle(
                  color:
                      AppTheme.purpleAccent,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton.icon(
              onPressed:
                  _addSleep,
              icon:
                  const Icon(
                Icons
                    .bedtime_outlined,
              ),
              label:
                  const Text(
                'Record Sleep Time',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sleepHistoryTile(
    Map<String, dynamic> entry,
  ) {
    final start =
        DateTime.parse(
      entry['sleep_start']
          as String,
    );

    final end =
        DateTime.parse(
      entry['sleep_end']
          as String,
    );

    final minutes =
        (entry['duration_minutes']
                as num)
            .toInt();

    return Dismissible(
      key:
          ValueKey(
        'sleep_${entry['id']}',
      ),
      direction:
          DismissDirection
              .endToStart,
      onDismissed:
          (_) {
        ref
            .read(
              sleepHistoryNotifierProvider
                  .notifier,
            )
            .deleteSleep(
              (entry['id']
                      as num)
                  .toInt(),
            );
      },
      background:
          Container(
        margin:
            const EdgeInsets.only(
          bottom:
              10,
        ),
        padding:
            const EdgeInsets.only(
          right:
              20,
        ),
        alignment:
            Alignment.centerRight,
        decoration:
            BoxDecoration(
          color:
              AppTheme.dangerColor
                  .withOpacity(
            .16,
          ),
          borderRadius:
              BorderRadius.circular(
            22,
          ),
        ),
        child:
            const Icon(
          Icons
              .delete_outline_rounded,
          color:
              AppTheme.dangerColor,
        ),
      ),
      child:
          Container(
        margin:
            const EdgeInsets.only(
          bottom:
              10,
        ),
        padding:
            const EdgeInsets.all(
          16,
        ),
        decoration:
            AppTheme.premiumCard(),
        child:
            Row(
          children: [
            Container(
              height:
                  46,
              width:
                  46,
              decoration:
                  BoxDecoration(
                color: AppTheme
                    .purpleAccent
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
                    .bedtime_rounded,
                color:
                    AppTheme.purpleAccent,
              ),
            ),

            const SizedBox(
              width:
                  13,
            ),

            Expanded(
              child:
                  Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    _durationText(
                      minutes,
                    ),
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        3,
                  ),

                  Text(
                    '${DateFormat('h:mm a').format(start)} → '
                    '${DateFormat('h:mm a').format(end)}',
                    style:
                        const TextStyle(
                      color:
                          AppTheme.textSecondary,
                      fontSize:
                          11,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              DateFormat(
                'd MMM',
              ).format(
                end,
              ),
              style:
                  const TextStyle(
                color:
                    AppTheme.textSecondary,
                fontSize:
                    11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySleep() {
    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),
      decoration:
          AppTheme.premiumCard(),
      child:
          const Column(
        children: [
          Icon(
            Icons
                .bedtime_outlined,
            color:
                AppTheme.purpleAccent,
            size:
                34,
          ),
          SizedBox(
            height:
                8,
          ),
          Text(
            'No sleep history yet',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          SizedBox(
            height:
                4,
          ),
          Text(
            'Record your sleep and wake-up time to start tracking.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppTheme.textSecondary,
              fontSize:
                  11,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SHARED CARD
  // ============================================================

  Widget _habitCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    required Widget trailing,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),
      decoration:
          AppTheme.premiumCard(),
      child:
          Row(
        children: [
          Stack(
            alignment:
                Alignment.center,
            children: [
              SizedBox(
                height:
                    62,
                width:
                    62,
                child:
                    CircularProgressIndicator(
                  value:
                      progress,
                  strokeWidth:
                      6,
                  backgroundColor:
                      color.withOpacity(
                    .10,
                  ),
                  color:
                      color,
                ),
              ),
              Icon(
                icon,
                color:
                    color,
                size:
                    27,
              ),
            ],
          ),

          const SizedBox(
            width:
                16,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    fontSize:
                        17,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height:
                      3,
                ),

                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        AppTheme.textSecondary,
                    fontSize:
                        12,
                  ),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      height:
          110,
      alignment:
          Alignment.center,
      decoration:
          AppTheme.premiumCard(),
      child:
          const CircularProgressIndicator(
        color:
            AppTheme.accentColor,
      ),
    );
  }

  Widget _errorCard(
    String error,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),
      decoration:
          AppTheme.premiumCard(
        borderColor:
            AppTheme.dangerColor
                .withOpacity(
          .25,
        ),
      ),
      child:
          Text(
        'Error: $error',
      ),
    );
  }
}
/*
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme.dart';
import '../providers/user_provider.dart';

class HabitsScreen
    extends ConsumerStatefulWidget {
  const HabitsScreen({
    super.key,
  });

  @override
  ConsumerState<HabitsScreen>
      createState() =>
          _HabitsScreenState();
}

class _HabitsScreenState
    extends ConsumerState<
        HabitsScreen> {
  StreamSubscription<StepCount>?
      _stepSubscription;

  String _stepStatus =
      'Connecting to step sensor...';

  @override
  void initState() {
    super.initState();

    _initPedometer();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();

    super.dispose();
  }

  Future<void>
      _initPedometer() async {
    final status =
        await Permission
            .activityRecognition
            .request();

    if (!status.isGranted) {
      if (mounted) {
        setState(
          () {
            _stepStatus =
                'Activity permission is required.';
          },
        );
      }

      return;
    }

    _stepSubscription =
        Pedometer
            .stepCountStream
            .listen(
      _onStepCount,

      onError:
          (Object error) {
        if (!mounted) {
          return;
        }

        setState(
          () {
            _stepStatus =
                'Step sensor is unavailable.';
          },
        );
      },
    );

    if (mounted) {
      setState(
        () {
          _stepStatus =
              'Live step tracking';
        },
      );
    }
  }

  Future<void> _onStepCount(
    StepCount event,
  ) async {
    final prefs =
        await SharedPreferences
            .getInstance();

    final today =
        DateFormat(
      'yyyy-MM-dd',
    ).format(
      DateTime.now(),
    );

    final savedDate =
        prefs.getString(
      'step_baseline_date',
    );

    var baseline =
        prefs.getInt(
      'step_baseline_raw',
    );

    if (savedDate != today ||
        baseline == null ||
        event.steps < baseline) {
      baseline =
          event.steps;

      await prefs.setString(
        'step_baseline_date',
        today,
      );

      await prefs.setInt(
        'step_baseline_raw',
        baseline,
      );
    }

    final dailySteps =
        (event.steps - baseline)
            .clamp(
      0,
      1000000,
    );

    await ref
        .read(
          dailyStepsNotifierProvider
              .notifier,
        )
        .setSteps(
          dailySteps,
        );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final water =
        ref.watch(
      waterIntakeNotifierProvider,
    );

    final steps =
        ref.watch(
      dailyStepsNotifierProvider,
    );

    final sleep =
        ref.watch(
      sleepNotifierProvider,
    );

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
                Alignment.topCenter,

            end:
                Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: ListView(
            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              20,
              14,
              20,
              28,
            ),

            children: [
              const Text(
                'Daily habits',

                style:
                    TextStyle(
                  fontSize:
                      25,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              const Text(
                'Small wins build strong routines.',

                style:
                    TextStyle(
                  color: AppTheme
                      .textSecondary,

                  fontSize:
                      13,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              water.when(
                loading: () =>
                    _loadingCard(),

                error:
                    (e, s) =>
                        _errorCard(
                  '$e',
                ),

                data:
                    (value) =>
                        _waterCard(
                  value,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              steps.when(
                loading: () =>
                    _loadingCard(),

                error:
                    (e, s) =>
                        _errorCard(
                  '$e',
                ),

                data:
                    (value) =>
                        _stepsCard(
                  value,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              sleep.when(
                loading: () =>
                    _loadingCard(),

                error:
                    (e, s) =>
                        _errorCard(
                  '$e',
                ),

                data:
                    (value) =>
                        _sleepCard(
                  value,
                ),
              ),

              const SizedBox(
                height: 16,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  15,
                ),

                decoration:
                    AppTheme.premiumCard(),

                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .info_outline_rounded,

                      color:
                          AppTheme.textSecondary,

                      size:
                          19,
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    Expanded(
                      child:
                          Text(
                        _stepStatus,

                        style:
                            const TextStyle(
                          color: AppTheme
                              .textSecondary,

                          fontSize:
                              11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _waterCard(
    int water,
  ) {
    final progress =
        (water /
                WaterIntakeNotifier
                    .dailyGoal)
            .clamp(
      0.0,
      1.0,
    );

    return _habitCard(
      title:
          'Water intake',

      subtitle:
          '$water / ${WaterIntakeNotifier.dailyGoal} glasses',

      icon:
          Icons.water_drop_rounded,

      color:
          Colors.blueAccent,

      progress:
          progress,

      trailing:
          Row(
        mainAxisSize:
            MainAxisSize.min,

        children: [
          IconButton(
            onPressed: water > 0
                ? () => ref
                    .read(
                      waterIntakeNotifierProvider
                          .notifier,
                    )
                    .removeGlass()
                : null,

            icon:
                const Icon(
              Icons
                  .remove_circle_outline_rounded,
            ),
          ),

          IconButton.filled(
            style:
                IconButton.styleFrom(
              backgroundColor:
                  Colors.blueAccent
                      .withOpacity(
                .16,
              ),

              foregroundColor:
                  Colors.blueAccent,
            ),

            onPressed: water <
                    WaterIntakeNotifier
                        .dailyGoal
                ? () => ref
                    .read(
                      waterIntakeNotifierProvider
                          .notifier,
                    )
                    .addGlass()
                : null,

            icon:
                const Icon(
              Icons.add_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepsCard(
    int steps,
  ) {
    return _habitCard(
      title:
          'Steps',

      subtitle:
          '$steps / 10,000 steps',

      icon:
          Icons
              .directions_walk_rounded,

      color:
          AppTheme.accentColor,

      progress:
          (steps / 10000)
              .clamp(
        0.0,
        1.0,
      ),

      trailing:
          const Icon(
        Icons.sensors_rounded,

        color:
            AppTheme.accentColor,
      ),
    );
  }

  Widget _sleepCard(
    double hours,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          AppTheme.premiumCard(),

      child:
          Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                height: 52,
                width: 52,

                decoration:
                    BoxDecoration(
                  color: AppTheme
                      .purpleAccent
                      .withOpacity(
                    .14,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                ),

                child:
                    const Icon(
                  Icons
                      .bedtime_rounded,

                  color: AppTheme
                      .purpleAccent,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    const Text(
                      'Sleep',

                      style:
                          TextStyle(
                        fontSize:
                            17,

                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    Text(
                      '${hours.toStringAsFixed(1)} / 8 hours',

                      style:
                          const TextStyle(
                        color: AppTheme
                            .textSecondary,

                        fontSize:
                            12,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '${((hours / 8).clamp(
                  0.0,
                  1.0,
                ) * 100).round()}%',

                style:
                    const TextStyle(
                  color: AppTheme
                      .purpleAccent,

                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          Slider(
            min: 0,
            max: 12,
            divisions: 24,

            value:
                hours.clamp(
              0.0,
              12.0,
            ),

            activeColor:
                AppTheme
                    .purpleAccent,

            onChanged:
                (value) {
              ref
                  .read(
                    sleepNotifierProvider
                        .notifier,
                  )
                  .updateHours(
                    value,
                  );
            },
          ),

          const Text(
            'Drag to record last night\'s sleep.',

            style:
                TextStyle(
              color: AppTheme
                  .textSecondary,

              fontSize:
                  11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _habitCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double progress,
    required Widget trailing,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          AppTheme.premiumCard(),

      child: Row(
        children: [
          Stack(
            alignment:
                Alignment.center,

            children: [
              SizedBox(
                height: 62,
                width: 62,

                child:
                    CircularProgressIndicator(
                  value:
                      progress,

                  strokeWidth:
                      6,

                  backgroundColor:
                      color.withOpacity(
                    .10,
                  ),

                  color:
                      color,
                ),
              ),

              Icon(
                icon,
                color: color,
                size: 27,
              ),
            ],
          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(
            child:
                Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    fontSize:
                        17,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  subtitle,

                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondary,

                    fontSize:
                        12,
                  ),
                ),
              ],
            ),
          ),

          trailing,
        ],
      ),
    );
  }

  Widget _loadingCard() {
    return Container(
      height: 110,

      alignment:
          Alignment.center,

      decoration:
          AppTheme.premiumCard(),

      child:
          const CircularProgressIndicator(
        color:
            AppTheme.accentColor,
      ),
    );
  }

  Widget _errorCard(
    String error,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration:
          AppTheme.premiumCard(
        borderColor:
            AppTheme
                .dangerColor
                .withOpacity(
          .25,
        ),
      ),

      child:
          Text(
        'Error: $error',
      ),
    );
  }
}*/