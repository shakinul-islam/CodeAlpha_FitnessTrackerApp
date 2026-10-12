import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/workout_model.dart';
import '../providers/workout_provider.dart';
import 'add_workout_screen.dart';
import 'edit_workout_screen.dart';

class WorkoutHistoryScreen
    extends ConsumerWidget {
  const WorkoutHistoryScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final workouts =
        ref.watch(
      workoutNotifierProvider,
    );

    return Scaffold(
      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            AppTheme.accentColor,
        foregroundColor:
            AppTheme.bgColor,
        onPressed:
            () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
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
          'Workout',
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
          child: workouts.when(
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
                (items) {
              return ListView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  100,
                ),
                children: [
                  const Text(
                    'Workouts',
                    style:
                        TextStyle(
                      fontSize:
                          25,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        4,
                  ),

                  Text(
                    '${items.length} workouts recorded',
                    style:
                        const TextStyle(
                      color:
                          AppTheme.textSecondary,
                      fontSize:
                          12,
                    ),
                  ),

                  const SizedBox(
                    height:
                        22,
                  ),

                  if (items.isEmpty)
                    _emptyState(
                      context,
                    )
                  else
                    ...items.map(
                      (
                        workout,
                      ) =>
                          _workoutCard(
                        context,
                        ref,
                        workout,
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

  Widget _workoutCard(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) {
    final pace =
        workout.distance != null &&
                workout.distance! > 0
            ? workout.duration /
                workout.distance!
            : null;

    return InkWell(
      borderRadius:
          BorderRadius.circular(
        22,
      ),
      onTap:
          () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) =>
                    EditWorkoutScreen(
              workout:
                  workout,
            ),
          ),
        );
      },
      child:
          Container(
        margin:
            const EdgeInsets.only(
          bottom:
              11,
        ),
        padding:
            const EdgeInsets.all(
          17,
        ),
        decoration:
            AppTheme.premiumCard(),
        child:
            Row(
          children: [
            Container(
              height:
                  52,
              width:
                  52,
              decoration:
                  BoxDecoration(
                color:
                    AppTheme.accentColor
                        .withOpacity(
                  .12,
                ),
                borderRadius:
                    BorderRadius.circular(
                  17,
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
              width:
                  14,
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
                      fontSize:
                          15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height:
                        3,
                  ),

                  Text(
                    '${workout.duration} min • '
                    '${workout.calories} kcal • '
                    '${workout.intensity}',
                    style:
                        const TextStyle(
                      color:
                          AppTheme.textSecondary,
                      fontSize:
                          11,
                    ),
                  ),

                  if (workout.distance != null &&
                      workout.distance! > 0)
                    Text(
                      pace == null
                          ? '${workout.distance!.toStringAsFixed(2)} km'
                          : '${workout.distance!.toStringAsFixed(2)} km • '
                              '${pace.toStringAsFixed(1)} min/km',
                      style:
                          const TextStyle(
                        color:
                            AppTheme.textSecondary,
                        fontSize:
                            10,
                      ),
                    ),

                  Text(
                    DateFormat(
                      'EEE, d MMM yyyy • h:mm a',
                    ).format(
                      workout.date,
                    ),
                    style:
                        TextStyle(
                      color:
                          AppTheme.textSecondary
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

            PopupMenuButton<String>(
              icon:
                  const Icon(
                Icons
                    .more_vert_rounded,
              ),
              color:
                  AppTheme.cardColorSoft,
              onSelected:
                  (
                    value,
                  ) {
                if (value ==
                    'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              EditWorkoutScreen(
                        workout:
                            workout,
                      ),
                    ),
                  );
                }

                if (value ==
                    'delete') {
                  _deleteWorkout(
                    context,
                    ref,
                    workout,
                  );
                }
              },
              itemBuilder:
                  (_) =>
                      const [
                PopupMenuItem(
                  value:
                      'edit',
                  child:
                      Text(
                    'Edit',
                  ),
                ),
                PopupMenuItem(
                  value:
                      'delete',
                  child:
                      Text(
                    'Delete',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteWorkout(
    BuildContext context,
    WidgetRef ref,
    Workout workout,
  ) async {
    if (workout.id == null) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
      context:
          context,
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
          'Remove ${workout.title} from your workout history?',
        ),
        actions: [
          TextButton(
            onPressed:
                () {
              Navigator.pop(
                context,
                false,
              );
            },
            child:
                const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            onPressed:
                () {
              Navigator.pop(
                context,
                true,
              );
            },
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

  Widget _emptyState(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          AppTheme.premiumCard(),
      child:
          Column(
        children: [
          const Icon(
            Icons
                .directions_run_rounded,
            color:
                AppTheme.accentColor,
            size:
                42,
          ),

          const SizedBox(
            height:
                10,
          ),

          const Text(
            'No workout history',
            style:
                TextStyle(
              fontWeight:
                  FontWeight.w800,
            ),
          ),

          const SizedBox(
            height:
                5,
          ),

          const Text(
            'Log your first workout to start tracking your activity.',
            textAlign:
                TextAlign.center,
            style:
                TextStyle(
              color:
                  AppTheme.textSecondary,
              fontSize:
                  12,
            ),
          ),

          const SizedBox(
            height:
                14,
          ),

          OutlinedButton.icon(
            onPressed:
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) =>
                          const AddWorkoutScreen(),
                ),
              );
            },
            icon:
                const Icon(
              Icons
                  .add_rounded,
            ),
            label:
                const Text(
              'Add Workout',
            ),
          ),
        ],
      ),
    );
  }
}