import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';
import '../providers/user_provider.dart';
import 'add_meal_screen.dart';

class DietScreen extends ConsumerWidget {
  const DietScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final mealsState = ref.watch(
      dietNotifierProvider,
    );

    // ============================================================
    // DAILY GOAL
    // ============================================================

    final goalsState = ref.watch(
      dailyGoalsNotifierProvider,
    );

    final dailyCalorieGoal =
        (goalsState.asData?.value['calorie_goal'] as num?)?.toInt() ??
        2000;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.bgColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddMealScreen(),
            ),
          );
        },
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Meal',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
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
          child: mealsState.when(
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

            data: (meals) {
              // ==================================================
              // TOTAL CALORIES
              // ==================================================

              final calories = meals.fold<int>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum + (meal['calories'] as num).toInt(),
              );

              // ==================================================
              // TOTAL PROTEIN
              // ==================================================

              final protein = meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['protein'] as num?)?.toDouble() ?? 0),
              );

              // ==================================================
              // TOTAL CARBS
              // ==================================================

              final carbs = meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['carbs'] as num?)?.toDouble() ?? 0),
              );

              // ==================================================
              // TOTAL FAT
              // ==================================================

              final fat = meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['fat'] as num?)?.toDouble() ?? 0),
              );

              return ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  14,
                  20,
                  100,
                ),
                children: [
                  const Text(
                    'Nutrition',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Fuel your goals with better choices.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  // ==================================================
                  // CALORIE CARD
                  // ==================================================

                  _calorieCard(
                    calories,
                    dailyCalorieGoal,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==================================================
                  // MACRO CARD
                  // ==================================================

                  _macroCard(
                    protein: protein,
                    carbs: carbs,
                    fat: fat,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // ==================================================
                  // TODAY'S MEALS
                  // ==================================================

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Today\'s meals',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),

                      Text(
                        '${meals.length} items',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  if (meals.isEmpty)
                    _emptyState()
                  else
                    ...meals.map(
                      (
                        meal,
                      ) =>
                          _mealCard(
                        context,
                        ref,
                        meal,
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
  // CALORIE CARD
  // ============================================================

  Widget _calorieCard(
    int calories,
    int dailyCalorieGoal,
  ) {
    final progress =
        dailyCalorieGoal <= 0
            ? 0.0
            : (calories / dailyCalorieGoal).clamp(
                0.0,
                1.0,
              );

    final remaining = (dailyCalorieGoal - calories).clamp(
      0,
      dailyCalorieGoal,
    );

    return Container(
      padding: const EdgeInsets.all(
        22,
      ),

      decoration: AppTheme.premiumCard(
        gradient: LinearGradient(
          colors: [
            AppTheme.purpleAccent.withOpacity(
              .19,
            ),
            AppTheme.accentColor.withOpacity(
              .10,
            ),
          ],
        ),

        borderColor: AppTheme.purpleAccent.withOpacity(
          .22,
        ),
      ),

      child: Row(
        children: [
          SizedBox(
            height: 104,
            width: 104,

            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(
                    .06,
                  ),
                  color: AppTheme.accentColor,
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$calories',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const Text(
                      'kcal',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily calories',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  '$remaining kcal remaining',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  'Goal: $dailyCalorieGoal kcal',
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
  // MACRO CARD
  // ============================================================

  Widget _macroCard({
    required double protein,
    required double carbs,
    required double fat,
  }) {
    final total = protein + carbs + fat;

    final hasData = total > 0;

    return Container(
      padding: const EdgeInsets.all(
        20,
      ),

      decoration: AppTheme.premiumCard(),

      child: Row(
        children: [
          SizedBox(
            height: 124,
            width: 124,

            child:
                hasData
                    ? PieChart(
                        PieChartData(
                          centerSpaceRadius: 34,
                          sectionsSpace: 3,
                          sections: [
                            PieChartSectionData(
                              value: protein,
                              color: AppTheme.accentColor,
                              showTitle: false,
                              radius: 18,
                            ),

                            PieChartSectionData(
                              value: carbs,
                              color: AppTheme.orangeAccent,
                              showTitle: false,
                              radius: 18,
                            ),

                            PieChartSectionData(
                              value: fat,
                              color: AppTheme.purpleAccent,
                              showTitle: false,
                              radius: 18,
                            ),
                          ],
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(
                              .08,
                            ),
                            width: 16,
                          ),
                        ),

                        child: const Center(
                          child: Text(
                            'No\nmacros',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child: Column(
              children: [
                _legend(
                  'Protein',
                  protein,
                  AppTheme.accentColor,
                ),

                const SizedBox(
                  height: 10,
                ),

                _legend(
                  'Carbs',
                  carbs,
                  AppTheme.orangeAccent,
                ),

                const SizedBox(
                  height: 10,
                ),

                _legend(
                  'Fat',
                  fat,
                  AppTheme.purpleAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MACRO LEGEND
  // ============================================================

  Widget _legend(
    String label,
    double value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              99,
            ),
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),

        Text(
          '${value.toStringAsFixed(
            value % 1 == 0 ? 0 : 1,
          )} g',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MEAL CARD
  // ============================================================

  Widget _mealCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> meal,
  ) {
    final type = meal['meal_type'] as String? ?? 'Meal';

    return Dismissible(
      key: ValueKey(
        meal['id'],
      ),

      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return showDialog<bool>(
          context: context,

          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.cardColorSoft,

            title: const Text(
              'Delete meal?',
            ),

            content: Text(
              'Remove ${meal['name']} from today?',
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
      },

      onDismissed: (_) {
        ref
            .read(
              dietNotifierProvider.notifier,
            )
            .deleteMeal(
              (meal['id'] as num).toInt(),
            );
      },

      background: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.only(
          right: 22,
        ),
        alignment: Alignment.centerRight,

        decoration: BoxDecoration(
          color: AppTheme.dangerColor.withOpacity(
            .18,
          ),
          borderRadius: BorderRadius.circular(
            22,
          ),
        ),

        child: const Icon(
          Icons.delete_outline_rounded,
          color: AppTheme.dangerColor,
        ),
      ),

      child: Container(
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
              height: 48,
              width: 48,

              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(
                  .12,
                ),
                borderRadius: BorderRadius.circular(
                  16,
                ),
              ),

              child: Icon(
                _mealIcon(
                  type,
                ),
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
                    meal['name'] as String? ?? 'Meal',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    '${meal['description'] ?? ''}'.trim().isEmpty
                        ? type
                        : '$type • ${meal['description']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '${meal['calories']} kcal',
              style: const TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MEAL ICON
  // ============================================================

  IconData _mealIcon(
    String type,
  ) {
    switch (type) {
      case 'Breakfast':
        return Icons.breakfast_dining_rounded;

      case 'Lunch':
        return Icons.lunch_dining_rounded;

      case 'Dinner':
        return Icons.dinner_dining_rounded;

      default:
        return Icons.apple_rounded;
    }
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(
        28,
      ),

      decoration: AppTheme.premiumCard(),

      child: const Column(
        children: [
          Icon(
            Icons.restaurant_rounded,
            size: 38,
            color: AppTheme.accentColor,
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'Nothing logged yet',
            style: TextStyle(
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'Add your first meal to start tracking calories and macros.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}/*
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme.dart';
import '../providers/app_providers.dart';
import 'add_meal_screen.dart';

class DietScreen
    extends ConsumerWidget {
  const DietScreen({
    super.key,
  });

  static const int
      dailyCalorieGoal = 2000;

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final mealsState =
        ref.watch(
      dietNotifierProvider,
    );

    return Scaffold(
      floatingActionButton:
          FloatingActionButton
              .extended(
        backgroundColor:
            AppTheme.accentColor,

        foregroundColor:
            AppTheme.bgColor,

        onPressed: () {
          Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddMealScreen(),
            ),
          );
        },

        icon:
            const Icon(
          Icons.add_rounded,
        ),

        label:
            const Text(
          'Meal',

          style:
              TextStyle(
            fontWeight:
                FontWeight.w700,
          ),
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
                Alignment.topCenter,

            end:
                Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child:
              mealsState.when(
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
                    Center(
              child:
                  Text(
                'Error: $error',
              ),
            ),

            data:
                (meals) {
              final calories =
                  meals.fold<int>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    (meal['calories']
                            as num)
                        .toInt(),
              );

              final protein =
                  meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['protein']
                                as num?)
                            ?.toDouble() ??
                        0),
              );

              final carbs =
                  meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['carbs']
                                as num?)
                            ?.toDouble() ??
                        0),
              );

              final fat =
                  meals.fold<double>(
                0,
                (
                  sum,
                  meal,
                ) =>
                    sum +
                    ((meal['fat']
                                as num?)
                            ?.toDouble() ??
                        0),
              );

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
                    'Nutrition',

                    style:
                        TextStyle(
                      fontSize:
                          25,

                      fontWeight:
                          FontWeight
                              .w800,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  const Text(
                    'Fuel your goals with better choices.',

                    style:
                        TextStyle(
                      color: AppTheme
                          .textSecondary,

                      fontSize:
                          13,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  _calorieCard(
                    calories,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  _macroCard(
                    protein:
                        protein,

                    carbs:
                        carbs,

                    fat:
                        fat,
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  Row(
                    children: [
                      const Expanded(
                        child:
                            Text(
                          'Today\'s meals',

                          style:
                              TextStyle(
                            fontSize:
                                18,

                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ),

                      Text(
                        '${meals.length} items',

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

                  const SizedBox(
                    height: 12,
                  ),

                  if (meals.isEmpty)
                    _emptyState()
                  else
                    ...meals.map(
                      (
                        meal,
                      ) =>
                          _mealCard(
                        context,
                        ref,
                        meal,
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

  Widget _calorieCard(
    int calories,
  ) {
    final progress =
        (calories /
                dailyCalorieGoal)
            .clamp(
      0.0,
      1.0,
    );

    final remaining =
        (dailyCalorieGoal -
                calories)
            .clamp(
      0,
      dailyCalorieGoal,
    );

    return Container(
      padding:
          const EdgeInsets.all(
        22,
      ),

      decoration:
          AppTheme.premiumCard(
        gradient:
            LinearGradient(
          colors: [
            AppTheme
                .purpleAccent
                .withOpacity(
              .19,
            ),

            AppTheme
                .accentColor
                .withOpacity(
              .10,
            ),
          ],
        ),

        borderColor:
            AppTheme
                .purpleAccent
                .withOpacity(
          .22,
        ),
      ),

      child: Row(
        children: [
          SizedBox(
            height: 104,
            width: 104,

            child: Stack(
              alignment:
                  Alignment.center,

              children: [
                CircularProgressIndicator(
                  value:
                      progress,

                  strokeWidth:
                      10,

                  backgroundColor:
                      Colors.white
                          .withOpacity(
                    .06,
                  ),

                  color:
                      AppTheme
                          .accentColor,
                ),

                Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    Text(
                      '$calories',

                      style:
                          const TextStyle(
                        fontSize:
                            21,

                        fontWeight:
                            FontWeight
                                .w900,
                      ),
                    ),

                    const Text(
                      'kcal',

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
              ],
            ),
          ),

          const SizedBox(
            width: 20,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                const Text(
                  'Daily calories',

                  style:
                      TextStyle(
                    fontSize:
                        17,

                    fontWeight:
                        FontWeight.w800,
                  ),
                ),

                const SizedBox(
                  height: 6,
                ),

                Text(
                  '$remaining kcal remaining',

                  style:
                      const TextStyle(
                    color: AppTheme
                        .textSecondary,

                    fontSize:
                        12,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                const Text(
                  'Goal: 2000 kcal',

                  style:
                      TextStyle(
                    color: AppTheme
                        .accentColor,

                    fontSize:
                        12,

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroCard({
    required double protein,
    required double carbs,
    required double fat,
  }) {
    final total =
        protein +
        carbs +
        fat;

    final hasData =
        total > 0;

    return Container(
      padding:
          const EdgeInsets.all(
        20,
      ),

      decoration:
          AppTheme.premiumCard(),

      child: Row(
        children: [
          SizedBox(
            height: 124,
            width: 124,

            child: hasData
                ? PieChart(
                    PieChartData(
                      centerSpaceRadius:
                          34,

                      sectionsSpace:
                          3,

                      sections: [
                        PieChartSectionData(
                          value:
                              protein,

                          color:
                              AppTheme.accentColor,

                          showTitle:
                              false,

                          radius:
                              18,
                        ),

                        PieChartSectionData(
                          value:
                              carbs,

                          color:
                              AppTheme.orangeAccent,

                          showTitle:
                              false,

                          radius:
                              18,
                        ),

                        PieChartSectionData(
                          value:
                              fat,

                          color:
                              AppTheme.purpleAccent,

                          showTitle:
                              false,

                          radius:
                              18,
                        ),
                      ],
                    ),
                  )
                : Container(
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,

                      border:
                          Border.all(
                        color:
                            Colors.white.withOpacity(
                          .08,
                        ),

                        width:
                            16,
                      ),
                    ),

                    child:
                        const Center(
                      child:
                          Text(
                        'No\nmacros',

                        textAlign:
                            TextAlign.center,

                        style:
                            TextStyle(
                          color: AppTheme
                              .textSecondary,

                          fontSize:
                              11,
                        ),
                      ),
                    ),
                  ),
          ),

          const SizedBox(
            width: 18,
          ),

          Expanded(
            child:
                Column(
              children: [
                _legend(
                  'Protein',
                  protein,
                  AppTheme
                      .accentColor,
                ),

                const SizedBox(
                  height: 10,
                ),

                _legend(
                  'Carbs',
                  carbs,
                  AppTheme
                      .orangeAccent,
                ),

                const SizedBox(
                  height: 10,
                ),

                _legend(
                  'Fat',
                  fat,
                  AppTheme
                      .purpleAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(
    String label,
    double value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          height: 10,
          width: 10,

          decoration:
              BoxDecoration(
            color: color,

            borderRadius:
                BorderRadius.circular(
              99,
            ),
          ),
        ),

        const SizedBox(
          width: 9,
        ),

        Expanded(
          child:
              Text(
            label,

            style:
                const TextStyle(
              color: AppTheme
                  .textSecondary,

              fontSize: 12,
            ),
          ),
        ),

        Text(
          '${value.toStringAsFixed(
            value % 1 == 0
                ? 0
                : 1,
          )} g',

          style:
              const TextStyle(
            fontWeight:
                FontWeight.w700,

            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _mealCard(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> meal,
  ) {
    final type =
        meal['meal_type']
                as String? ??
            'Meal';

    return Dismissible(
      key:
          ValueKey(
        meal['id'],
      ),

      direction:
          DismissDirection
              .endToStart,

      confirmDismiss:
          (_) async {
        return showDialog<bool>(
          context: context,

          builder:
              (context) =>
                  AlertDialog(
            backgroundColor:
                AppTheme
                    .cardColorSoft,

            title:
                const Text(
              'Delete meal?',
            ),

            content:
                Text(
              'Remove ${meal['name']} from today?',
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
      },

      onDismissed: (_) {
        ref
            .read(
              dietNotifierProvider
                  .notifier,
            )
            .deleteMeal(
              (meal['id']
                      as num)
                  .toInt(),
            );
      },

      background:
          Container(
        margin:
            const EdgeInsets.only(
          bottom: 10,
        ),

        padding:
            const EdgeInsets.only(
          right: 22,
        ),

        alignment:
            Alignment.centerRight,

        decoration:
            BoxDecoration(
          color: AppTheme
              .dangerColor
              .withOpacity(
            .18,
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
              height: 48,
              width: 48,

              decoration:
                  BoxDecoration(
                color: AppTheme
                    .accentColor
                    .withOpacity(
                  .12,
                ),

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child:
                  Icon(
                _mealIcon(
                  type,
                ),

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
                    meal['name']
                            as String? ??
                        'Meal',

                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    '${meal['description'] ?? ''}'
                            .trim()
                            .isEmpty
                        ? type
                        : '$type • ${meal['description']}',

                    maxLines:
                        1,

                    overflow:
                        TextOverflow
                            .ellipsis,

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

            Text(
              '${meal['calories']} kcal',

              style:
                  const TextStyle(
                color: AppTheme
                    .accentColor,

                fontWeight:
                    FontWeight.w800,

                fontSize:
                    13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _mealIcon(
    String type,
  ) {
    switch (type) {
      case 'Breakfast':
        return Icons
            .breakfast_dining_rounded;

      case 'Lunch':
        return Icons
            .lunch_dining_rounded;

      case 'Dinner':
        return Icons
            .dinner_dining_rounded;

      default:
        return Icons
            .apple_rounded;
    }
  }

  Widget _emptyState() {
    return Container(
      padding:
          const EdgeInsets.all(
        28,
      ),

      decoration:
          AppTheme.premiumCard(),

      child:
          const Column(
        children: [
          Icon(
            Icons
                .restaurant_rounded,

            size: 38,

            color:
                AppTheme.accentColor,
          ),

          SizedBox(
            height: 10,
          ),

          Text(
            'Nothing logged yet',

            style:
                TextStyle(
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          SizedBox(
            height: 4,
          ),

          Text(
            'Add your first meal to start tracking calories and macros.',

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
        ],
      ),
    );
  }
}*/