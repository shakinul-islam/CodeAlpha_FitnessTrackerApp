import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../models/workout_model.dart';
import '../providers/app_providers.dart';
import '../providers/workout_provider.dart';

class AddWorkoutScreen
    extends ConsumerStatefulWidget {
  const AddWorkoutScreen({
    super.key,
  });

  @override
  ConsumerState<AddWorkoutScreen>
      createState() =>
          _AddWorkoutScreenState();
}

class _AddWorkoutScreenState
    extends ConsumerState<
        AddWorkoutScreen> {
  final _durationController =
      TextEditingController();

  final _distanceController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  final List<Map<String, dynamic>>
      _exercises = const [
    {
      'name': 'Running',
      'icon':
          Icons.directions_run_rounded,
      'met': 9.8,
    },
    {
      'name': 'Walking',
      'icon':
          Icons.directions_walk_rounded,
      'met': 3.8,
    },
    {
      'name': 'Cycling',
      'icon':
          Icons.pedal_bike_rounded,
      'met': 7.5,
    },
    {
      'name': 'Yoga',
      'icon':
          Icons.self_improvement_rounded,
      'met': 3.0,
    },
    {
      'name': 'Swimming',
      'icon': Icons.pool_rounded,
      'met': 8.0,
    },
    {
      'name': 'Strength',
      'icon':
          Icons.fitness_center_rounded,
      'met': 6.0,
    },
    {
      'name': 'HIIT',
      'icon': Icons.bolt_rounded,
      'met': 10.0,
    },
    {
      'name': 'Jump Rope',
      'icon':
          Icons.sports_gymnastics_rounded,
      'met': 11.8,
    },
    {
      'name': 'Boxing',
      'icon':
          Icons.sports_mma_rounded,
      'met': 8.5,
    },
    {
      'name': 'Football',
      'icon':
          Icons.sports_soccer_rounded,
      'met': 8.0,
    },
    {
      'name': 'Badminton',
      'icon':
          Icons.sports_tennis_rounded,
      'met': 5.5,
    },
    {
      'name': 'Dancing',
      'icon':
          Icons.music_note_rounded,
      'met': 6.0,
    },
  ];

  int _selectedIndex = 0;

  String _intensity =
      'Moderate';

  int _calculatedCalories = 0;

  @override
  void initState() {
    super.initState();

    _durationController
        .addListener(
      _calculateCalories,
    );
  }

  @override
  void dispose() {
    _durationController
        .removeListener(
      _calculateCalories,
    );

    _durationController.dispose();
    _distanceController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  double get
      _intensityMultiplier {
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

    final profile = ref
        .read(
          profileNotifierProvider,
        )
        .asData
        ?.value;

    final weight =
        (profile?['weight']
                    as num?)
                ?.toDouble() ??
            70.0;

    final met =
        (_exercises[
                    _selectedIndex]
                ['met'] as num)
            .toDouble();

    // MET formula
    //
    // Calories per minute =
    // MET × 3.5 × Weight KG / 200

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
          _calculatedCalories =
              calories;
        },
      );
    }
  }

  Future<void>
      _saveWorkout() async {
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
      _showError(
        'Please enter a valid workout duration.',
      );

      return;
    }

    if (_distanceController.text
            .trim()
            .isNotEmpty &&
        distance == null) {
      _showError(
        'Please enter a valid distance.',
      );

      return;
    }

    final workout = Workout(
      title: _exercises[
              _selectedIndex]
          ['name'] as String,

      duration: duration,

      calories:
          _calculatedCalories,

      date: DateTime.now(),

      intensity: _intensity,

      distance: distance,

      notes: _notesController
              .text
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
        .addWorkout(
          workout,
        );

    if (mounted) {
      Navigator.pop(
        context,
      );
    }
  }

  void _showError(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    ref.watch(
      profileNotifierProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title:
            const Text(
          'Log workout',
        ),
      ),

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
          top: false,

          child: ListView(
            physics:
                const BouncingScrollPhysics(),

            padding:
                const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),

            children: [
              const Text(
                'Choose activity',

                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              GridView.builder(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount:
                    _exercises.length,

                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio:
                      1.05,
                ),

                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final exercise =
                      _exercises[index];

                  final selected =
                      index ==
                          _selectedIndex;

                  return InkWell(
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),

                    onTap: () {
                      setState(
                        () {
                          _selectedIndex =
                              index;
                        },
                      );

                      _calculateCalories();
                    },

                    child:
                        AnimatedContainer(
                      duration:
                          const Duration(
                        milliseconds:
                            220,
                      ),

                      decoration:
                          BoxDecoration(
                        color: selected
                            ? AppTheme
                                .accentColor
                                .withOpacity(
                                .14,
                              )
                            : AppTheme
                                .cardColor,

                        borderRadius:
                            BorderRadius
                                .circular(
                          20,
                        ),

                        border:
                            Border.all(
                          color: selected
                              ? AppTheme
                                  .accentColor
                              : Colors
                                  .white
                                  .withOpacity(
                                  .05,
                                ),
                        ),
                      ),

                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .center,

                        children: [
                          Icon(
                            exercise[
                                    'icon']
                                as IconData,

                            color: selected
                                ? AppTheme
                                    .accentColor
                                : AppTheme
                                    .textSecondary,

                            size: 28,
                          ),

                          const SizedBox(
                            height: 8,
                          ),

                          Text(
                            exercise[
                                    'name']
                                as String,

                            textAlign:
                                TextAlign
                                    .center,

                            style:
                                TextStyle(
                              fontSize:
                                  12,

                              fontWeight:
                                  FontWeight
                                      .w600,

                              color: selected
                                  ? AppTheme
                                      .textPrimary
                                  : AppTheme
                                      .textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(
                height: 26,
              ),

              TextField(
                controller:
                    _durationController,

                keyboardType:
                    TextInputType.number,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Duration (minutes)',

                  prefixIcon:
                      Icon(
                    Icons
                        .timer_outlined,
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              DropdownButtonFormField<
                  String>(
                value: _intensity,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Intensity',

                  prefixIcon:
                      Icon(
                    Icons.speed_rounded,
                  ),
                ),

                dropdownColor:
                    AppTheme
                        .cardColorSoft,

                items: const [
                  'Light',
                  'Moderate',
                  'High',
                ]
                    .map(
                      (item) =>
                          DropdownMenuItem(
                        value: item,
                        child:
                            Text(item),
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
                height: 14,
              ),

              TextField(
                controller:
                    _distanceController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    const InputDecoration(
                  labelText:
                      'Distance in km (optional)',

                  prefixIcon:
                      Icon(
                    Icons.route_rounded,
                  ),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              TextField(
                controller:
                    _notesController,

                maxLines: 3,

                decoration:
                    const InputDecoration(
                  labelText:
                      'Notes (optional)',

                  prefixIcon:
                      Icon(
                    Icons.notes_rounded,
                  ),

                  alignLabelWithHint:
                      true,
                ),
              ),

              const SizedBox(
                height: 24,
              ),

              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                child:
                    BackdropFilter(
                  filter:
                      ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),

                  child: Container(
                    padding:
                        const EdgeInsets
                            .all(
                      22,
                    ),

                    decoration:
                        AppTheme
                            .premiumCard(
                      gradient:
                          LinearGradient(
                        colors: [
                          AppTheme
                              .accentColor
                              .withOpacity(
                              .16,
                            ),

                          AppTheme
                              .purpleAccent
                              .withOpacity(
                              .10,
                            ),
                        ],
                      ),

                      borderColor:
                          AppTheme
                              .accentColor
                              .withOpacity(
                              .25,
                            ),
                    ),

                    child: Row(
                      children: [
                        Container(
                          height:
                              58,
                          width:
                              58,

                          decoration:
                              BoxDecoration(
                            color: AppTheme
                                .orangeAccent
                                .withOpacity(
                                .14,
                              ),

                            borderRadius:
                                BorderRadius
                                    .circular(
                              18,
                            ),
                          ),

                          child:
                              const Icon(
                            Icons
                                .local_fire_department_rounded,

                            color: AppTheme
                                .orangeAccent,

                            size:
                                31,
                          ),
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
                                'Estimated burn',

                                style:
                                    TextStyle(
                                  color: AppTheme
                                      .textSecondary,

                                  fontSize:
                                      13,
                                ),
                              ),

                              const SizedBox(
                                height:
                                    3,
                              ),

                              Text(
                                '$_calculatedCalories kcal',

                                style:
                                    const TextStyle(
                                  fontSize:
                                      27,

                                  fontWeight:
                                      FontWeight
                                          .w800,
                                ),
                              ),

                              const Text(
                                'Based on activity, weight & intensity',

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
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 28,
              ),

              ElevatedButton.icon(
                onPressed:
                    _saveWorkout,

                icon: const Icon(
                  Icons
                      .check_circle_outline_rounded,
                ),

                label:
                    const Text(
                  'Save workout',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}