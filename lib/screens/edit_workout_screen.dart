import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/workout_model.dart';
import '../providers/app_providers.dart';
import '../providers/workout_provider.dart';

class EditWorkoutScreen
    extends ConsumerStatefulWidget {
  final Workout workout;

  const EditWorkoutScreen({
    super.key,
    required this.workout,
  });

  @override
  ConsumerState<EditWorkoutScreen>
      createState() =>
          _EditWorkoutScreenState();
}

class _EditWorkoutScreenState
    extends ConsumerState<
        EditWorkoutScreen> {
  final _durationController =
      TextEditingController();

  final _distanceController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  final Map<String, double>
      _exerciseMet = const {
    'Running': 9.8,
    'Walking': 3.8,
    'Cycling': 7.5,
    'Yoga': 3.0,
    'Swimming': 8.0,
    'Strength': 6.0,
    'Gym': 6.0,
    'HIIT': 10.0,
    'Jump Rope': 11.8,
    'Boxing': 8.5,
    'Football': 8.0,
    'Badminton': 5.5,
    'Dancing': 6.0,
  };

  late String _title;
  late String _intensity;

  int _calories = 0;

  @override
  void initState() {
    super.initState();

    _title =
        widget.workout.title;

    _intensity =
        widget.workout.intensity;

    _durationController.text =
        widget.workout.duration
            .toString();

    _distanceController.text =
        widget.workout.distance
                ?.toString() ??
            '';

    _notesController.text =
        widget.workout.notes ??
            '';

    _calories =
        widget.workout.calories;

    _durationController.addListener(
      _calculateCalories,
    );
  }

  @override
  void dispose() {
    _durationController.removeListener(
      _calculateCalories,
    );

    _durationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  double get _intensityMultiplier {
    switch (_intensity) {
      case 'Light':
        return .85;

      case 'High':
        return 1.15;

      default:
        return 1.0;
    }
  }

  void _calculateCalories() {
    final duration =
        int.tryParse(
              _durationController.text,
            ) ??
            0;

    final profile =
        ref
            .read(
              profileNotifierProvider,
            )
            .asData
            ?.value;

    final weight =
        (profile?['weight']
                    as num?)
                ?.toDouble() ??
            70;

    final met =
        _exerciseMet[_title] ??
            6.0;

    final calories =
        ((met *
                    3.5 *
                    weight /
                    200) *
                duration *
                _intensityMultiplier)
            .round();

    if (mounted) {
      setState(
        () {
          _calories =
              calories;
        },
      );
    }
  }

  Future<void> _save() async {
    final duration =
        int.tryParse(
      _durationController.text
          .trim(),
    );

    final distance =
        _distanceController.text
                .trim()
                .isEmpty
            ? null
            : double.tryParse(
                _distanceController.text
                    .trim(),
              );

    if (duration == null ||
        duration <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Enter a valid duration.',
          ),
        ),
      );

      return;
    }

    final updated =
        widget.workout.copyWith(
      title:
          _title,
      duration:
          duration,
      calories:
          _calories,
      intensity:
          _intensity,
      distance:
          distance,
      notes:
          _notesController.text
                  .trim()
                  .isEmpty
              ? null
              : _notesController.text
                  .trim(),
    );

    await ref
        .read(
          workoutNotifierProvider
              .notifier,
        )
        .updateWorkout(
          updated,
        );

    if (mounted) {
      Navigator.pop(
        context,
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    ref.watch(
      profileNotifierProvider,
    );

    final activities =
        _exerciseMet.keys
            .toList();

    if (!activities.contains(
      _title,
    )) {
      activities.add(
        _title,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Edit Workout',
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
        child: SafeArea(
          top: false,
          child: ListView(
            padding:
                const EdgeInsets.fromLTRB(
              20,
              10,
              20,
              32,
            ),
            children: [
              DropdownButtonFormField<
                  String>(
                value:
                    _title,
                dropdownColor:
                    AppTheme.cardColorSoft,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Activity',
                  prefixIcon:
                      Icon(
                    Icons
                        .fitness_center_rounded,
                  ),
                ),
                items:
                    activities
                        .map(
                          (
                            item,
                          ) =>
                              DropdownMenuItem(
                            value:
                                item,
                            child:
                                Text(
                              item,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) {
                  if (value == null) {
                    return;
                  }

                  setState(
                    () {
                      _title =
                          value;
                    },
                  );

                  _calculateCalories();
                },
              ),

              const SizedBox(
                height:
                    14,
              ),

              TextField(
                controller:
                    _durationController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Duration',
                  suffixText:
                      'min',
                  prefixIcon:
                      Icon(
                    Icons
                        .timer_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    14,
              ),

              DropdownButtonFormField<
                  String>(
                value:
                    _intensity,
                dropdownColor:
                    AppTheme.cardColorSoft,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Intensity',
                  prefixIcon:
                      Icon(
                    Icons
                        .speed_rounded,
                  ),
                ),
                items:
                    const [
                  'Light',
                  'Moderate',
                  'High',
                ]
                        .map(
                          (
                            item,
                          ) =>
                              DropdownMenuItem(
                            value:
                                item,
                            child:
                                Text(
                              item,
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (value) {
                  if (value == null) {
                    return;
                  }

                  setState(
                    () {
                      _intensity =
                          value;
                    },
                  );

                  _calculateCalories();
                },
              ),

              const SizedBox(
                height:
                    14,
              ),

              TextField(
                controller:
                    _distanceController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal:
                      true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Distance',
                  suffixText:
                      'km',
                  prefixIcon:
                      Icon(
                    Icons
                        .route_rounded,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    14,
              ),

              TextField(
                controller:
                    _notesController,
                maxLines:
                    3,
                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes',
                  prefixIcon:
                      Icon(
                    Icons
                        .notes_rounded,
                  ),
                ),
              ),

              const SizedBox(
                height:
                    20,
              ),

              Container(
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                decoration:
                    AppTheme.premiumCard(),
                child:
                    Row(
                  children: [
                    const Icon(
                      Icons
                          .local_fire_department_rounded,
                      color:
                          AppTheme.orangeAccent,
                    ),

                    const SizedBox(
                      width:
                          12,
                    ),

                    const Expanded(
                      child:
                          Text(
                        'Estimated Calories',
                        style:
                            TextStyle(
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                    ),

                    Text(
                      '$_calories kcal',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize:
                            18,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(
                height:
                    28,
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
                  'Update Workout',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}