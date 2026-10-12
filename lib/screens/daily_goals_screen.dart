import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/user_provider.dart';

class DailyGoalsScreen
    extends ConsumerStatefulWidget {
  const DailyGoalsScreen({
    super.key,
  });

  @override
  ConsumerState<DailyGoalsScreen>
      createState() =>
          _DailyGoalsScreenState();
}

class _DailyGoalsScreenState
    extends ConsumerState<
        DailyGoalsScreen> {
  final _stepsController =
      TextEditingController();

  final _waterController =
      TextEditingController();

  final _calorieController =
      TextEditingController();

  final _sleepController =
      TextEditingController();

  bool _filled = false;

  @override
  void dispose() {
    _stepsController.dispose();
    _waterController.dispose();
    _calorieController.dispose();
    _sleepController.dispose();

    super.dispose();
  }

  void _fill(
    Map<String, dynamic> goals,
  ) {
    if (_filled) {
      return;
    }

    _filled = true;

    _stepsController.text =
        '${goals['steps_goal']}';

    _waterController.text =
        '${goals['water_goal_ml']}';

    _calorieController.text =
        '${goals['calorie_goal']}';

    final minutes =
        (goals['sleep_goal_minutes']
                as num)
            .toInt();

    _sleepController.text =
        (minutes / 60)
            .toStringAsFixed(
      minutes % 60 == 0
          ? 0
          : 1,
    );
  }

  Future<void> _save() async {
    final steps =
        int.tryParse(
      _stepsController.text
          .trim(),
    );

    final water =
        int.tryParse(
      _waterController.text
          .trim(),
    );

    final calories =
        int.tryParse(
      _calorieController.text
          .trim(),
    );

    final sleepHours =
        double.tryParse(
      _sleepController.text
          .trim(),
    );

    if (steps == null ||
        water == null ||
        calories == null ||
        sleepHours == null ||
        steps <= 0 ||
        water <= 0 ||
        calories <= 0 ||
        sleepHours <= 0 ||
        sleepHours > 24) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter valid daily goals.',
          ),
        ),
      );

      return;
    }

    final sleepMinutes =
        (sleepHours * 60).round();

    await ref
        .read(
          dailyGoalsNotifierProvider
              .notifier,
        )
        .updateGoals(
          stepsGoal:
              steps,
          waterGoalMl:
              water,
          calorieGoal:
              calories,
          sleepGoalMinutes:
              sleepMinutes,
        );

    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Daily goals updated.',
          ),
        ),
      );

      Navigator.pop(
        context,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final goals =
        ref.watch(
      dailyGoalsNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Daily Goals',
        ),
      ),
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
              (data) {
            _fill(
              data,
            );

            return SafeArea(
              top: false,
              child: ListView(
                padding:
                    const EdgeInsets.all(
                  20,
                ),
                children: [
                  _goalInfo(),

                  const SizedBox(
                    height: 22,
                  ),

                  TextField(
                    controller:
                        _stepsController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Daily Step Goal',
                      suffixText:
                          'steps',
                      prefixIcon:
                          Icon(
                        Icons
                            .directions_walk_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller:
                        _waterController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Daily Water Goal',
                      suffixText:
                          'ml',
                      prefixIcon:
                          Icon(
                        Icons
                            .water_drop_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller:
                        _calorieController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Daily Calorie Goal',
                      suffixText:
                          'kcal',
                      prefixIcon:
                          Icon(
                        Icons
                            .restaurant_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  TextField(
                    controller:
                        _sleepController,
                    keyboardType:
                        const TextInputType
                            .numberWithOptions(
                      decimal: true,
                    ),
                    decoration:
                        const InputDecoration(
                      labelText:
                          'Daily Sleep Goal',
                      suffixText:
                          'hours',
                      prefixIcon:
                          Icon(
                        Icons
                            .bedtime_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 30,
                  ),

                  ElevatedButton.icon(
                    onPressed:
                        _save,
                    icon:
                        const Icon(
                      Icons
                          .save_outlined,
                    ),
                    label:
                        const Text(
                      'Save Goals',
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _goalInfo() {
    return Container(
      padding:
          const EdgeInsets.all(
        17,
      ),
      decoration:
          AppTheme.premiumCard(
        borderColor:
            AppTheme
                .accentColor
                .withOpacity(
          .16,
        ),
      ),
      child:
          const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons
                .track_changes_rounded,
            color:
                AppTheme.accentColor,
          ),
          SizedBox(
            width: 12,
          ),
          Expanded(
            child:
                Text(
              'Set goals that fit your routine. '
              'These values will automatically update your '
              'Dashboard, Habits and Nutrition progress.',
              style:
                  TextStyle(
                color: AppTheme
                    .textSecondary,
                fontSize:
                    12,
                height:
                    1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}