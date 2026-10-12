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
// PROFILE
// ========================================

class ProfileNotifier
    extends AsyncNotifier<
        Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>>
      build() {
    return DatabaseHelper.instance
        .getUserProfile();
  }

  Future<void> updateProfile({
    required double height,
    required double weight,
    required double goalWeight,
    required double startingWeight,
  }) async {
    await DatabaseHelper.instance
        .updateUserProfile(
      height: height,
      weight: weight,
      goalWeight: goalWeight,
      startingWeight:
          startingWeight,
    );

    state = AsyncData(
      await DatabaseHelper.instance
          .getUserProfile(),
    );
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<
        ProfileNotifier,
        Map<String, dynamic>>(
  ProfileNotifier.new,
);

// ========================================
// DIET
// ========================================

class DietNotifier
    extends AsyncNotifier<
        List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>>
      build() {
    return DatabaseHelper.instance
        .getDailyMeals(
      _today(),
    );
  }

  Future<void> addMeal({
    required String name,
    required String description,
    required int calories,
    required String type,
    required double protein,
    required double carbs,
    required double fat,
  }) async {
    await DatabaseHelper.instance
        .insertMeal(
      {
        'name': name.trim(),
        'description':
            description.trim(),
        'calories': calories,
        'meal_type': type,
        'date': DateTime.now()
            .toIso8601String(),
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      },
    );

    state = AsyncData(
      await DatabaseHelper.instance
          .getDailyMeals(
        _today(),
      ),
    );
  }

  Future<void> deleteMeal(
    int id,
  ) async {
    await DatabaseHelper.instance
        .deleteMeal(id);

    state = AsyncData(
      await DatabaseHelper.instance
          .getDailyMeals(
        _today(),
      ),
    );
  }
}

final dietNotifierProvider =
    AsyncNotifierProvider<
        DietNotifier,
        List<Map<String, dynamic>>>(
  DietNotifier.new,
);