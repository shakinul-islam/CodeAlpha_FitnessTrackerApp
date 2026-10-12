class NutritionFood {
  final String name;

  /// Nutrition values per 100 grams.
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  const NutritionFood({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  double caloriesFor(double grams) {
    return calories * grams / 100;
  }

  double proteinFor(double grams) {
    return protein * grams / 100;
  }

  double carbsFor(double grams) {
    return carbs * grams / 100;
  }

  double fatFor(double grams) {
    return fat * grams / 100;
  }
}

/// Approximate nutrition values per 100g.
///
/// These values are intended for general fitness tracking.
/// Brand, recipe, cooking method and added oil/sauce can change nutrition.
const List<NutritionFood> commonNutritionFoods = [
  NutritionFood(
    name: 'Cooked White Rice',
    calories: 130,
    protein: 2.7,
    carbs: 28.2,
    fat: 0.3,
  ),

  NutritionFood(
    name: 'Cooked Brown Rice',
    calories: 123,
    protein: 2.7,
    carbs: 25.6,
    fat: 1.0,
  ),

  NutritionFood(
    name: 'Chicken Breast - Cooked',
    calories: 165,
    protein: 31.0,
    carbs: 0,
    fat: 3.6,
  ),

  NutritionFood(
    name: 'Chicken Leg - Cooked',
    calories: 184,
    protein: 24.0,
    carbs: 0,
    fat: 9.0,
  ),

  NutritionFood(
    name: 'Beef - Lean Cooked',
    calories: 250,
    protein: 26.0,
    carbs: 0,
    fat: 15.0,
  ),

  NutritionFood(
    name: 'Fish - Cooked',
    calories: 140,
    protein: 22.0,
    carbs: 0,
    fat: 5.0,
  ),

  NutritionFood(
    name: 'Boiled Egg',
    calories: 155,
    protein: 13.0,
    carbs: 1.1,
    fat: 11.0,
  ),

  NutritionFood(
    name: 'Oats - Dry',
    calories: 389,
    protein: 16.9,
    carbs: 66.3,
    fat: 6.9,
  ),

  NutritionFood(
    name: 'Whole Milk',
    calories: 61,
    protein: 3.2,
    carbs: 4.8,
    fat: 3.3,
  ),

  NutritionFood(
    name: 'Low Fat Milk',
    calories: 42,
    protein: 3.4,
    carbs: 5.0,
    fat: 1.0,
  ),

  NutritionFood(
    name: 'Banana',
    calories: 89,
    protein: 1.1,
    carbs: 22.8,
    fat: 0.3,
  ),

  NutritionFood(
    name: 'Apple',
    calories: 52,
    protein: 0.3,
    carbs: 13.8,
    fat: 0.2,
  ),

  NutritionFood(
    name: 'Orange',
    calories: 47,
    protein: 0.9,
    carbs: 11.8,
    fat: 0.1,
  ),

  NutritionFood(
    name: 'Bread',
    calories: 265,
    protein: 9.0,
    carbs: 49.0,
    fat: 3.2,
  ),

  NutritionFood(
    name: 'Potato - Boiled',
    calories: 87,
    protein: 1.9,
    carbs: 20.1,
    fat: 0.1,
  ),

  NutritionFood(
    name: 'Sweet Potato - Cooked',
    calories: 90,
    protein: 2.0,
    carbs: 20.7,
    fat: 0.2,
  ),

  NutritionFood(
    name: 'Lentils / Dal - Cooked',
    calories: 116,
    protein: 9.0,
    carbs: 20.1,
    fat: 0.4,
  ),

  NutritionFood(
    name: 'Chickpeas - Cooked',
    calories: 164,
    protein: 8.9,
    carbs: 27.4,
    fat: 2.6,
  ),

  NutritionFood(
    name: 'Plain Yogurt',
    calories: 61,
    protein: 3.5,
    carbs: 4.7,
    fat: 3.3,
  ),

  NutritionFood(
    name: 'Greek Yogurt',
    calories: 59,
    protein: 10.3,
    carbs: 3.6,
    fat: 0.4,
  ),

  NutritionFood(
    name: 'Peanut Butter',
    calories: 588,
    protein: 25.0,
    carbs: 20.0,
    fat: 50.0,
  ),

  NutritionFood(
    name: 'Almonds',
    calories: 579,
    protein: 21.2,
    carbs: 21.6,
    fat: 49.9,
  ),

  NutritionFood(
    name: 'Cucumber',
    calories: 15,
    protein: 0.7,
    carbs: 3.6,
    fat: 0.1,
  ),

  NutritionFood(
    name: 'Tomato',
    calories: 18,
    protein: 0.9,
    carbs: 3.9,
    fat: 0.2,
  ),

  NutritionFood(
    name: 'Mixed Vegetables - Cooked',
    calories: 65,
    protein: 3.0,
    carbs: 12.0,
    fat: 1.0,
  ),

  NutritionFood(
    name: 'Chapati / Roti',
    calories: 297,
    protein: 9.0,
    carbs: 55.0,
    fat: 7.0,
  ),
];