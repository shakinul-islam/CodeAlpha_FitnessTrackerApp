import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/nutrition_data.dart';
import '../core/theme.dart';
import '../providers/app_providers.dart';

class AddMealScreen extends ConsumerStatefulWidget {
  const AddMealScreen({
    super.key,
  });

  @override
  ConsumerState<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends ConsumerState<AddMealScreen> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  final _calController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbController = TextEditingController();
  final _fatController = TextEditingController();

  final _gramsController = TextEditingController(
    text: '100',
  );

  String _selectedType = 'Breakfast';

  NutritionFood _selectedFood = commonNutritionFoods.first;

  final List<_MealIngredient> _ingredients = [];

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();

    _calController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();

    _gramsController.dispose();

    super.dispose();
  }

  // ============================================================
  // INGREDIENT CALCULATOR
  // ============================================================

  void _addIngredient() {
    final grams = double.tryParse(
      _gramsController.text.trim(),
    );

    if (grams == null || grams <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter a valid amount in grams.',
          ),
        ),
      );

      return;
    }

    setState(() {
      _ingredients.add(
        _MealIngredient(
          food: _selectedFood,
          grams: grams,
        ),
      );

      _updateNutritionFromIngredients();
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);

      _updateNutritionFromIngredients();
    });
  }

  void _clearIngredients() {
    setState(() {
      _ingredients.clear();

      _updateNutritionFromIngredients();
    });
  }

  void _updateNutritionFromIngredients() {
    double calories = 0;
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final ingredient in _ingredients) {
      calories += ingredient.food.caloriesFor(
        ingredient.grams,
      );

      protein += ingredient.food.proteinFor(
        ingredient.grams,
      );

      carbs += ingredient.food.carbsFor(
        ingredient.grams,
      );

      fat += ingredient.food.fatFor(
        ingredient.grams,
      );
    }

    _calController.text = calories.round().toString();

    _proteinController.text = protein.toStringAsFixed(1);

    _carbController.text = carbs.toStringAsFixed(1);

    _fatController.text = fat.toStringAsFixed(1);
  }

  // ============================================================
  // SAVE MEAL
  // ============================================================

  Future<void> _save() async {
    final calories = int.tryParse(
      _calController.text.trim(),
    );

    final protein = double.tryParse(
          _proteinController.text.trim(),
        ) ??
        0;

    final carbs = double.tryParse(
          _carbController.text.trim(),
        ) ??
        0;

    final fat = double.tryParse(
          _fatController.text.trim(),
        ) ??
        0;

    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter the meal name.',
          ),
        ),
      );

      return;
    }

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter or calculate valid calories.',
          ),
        ),
      );

      return;
    }

    if (protein < 0 || carbs < 0 || fat < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Protein, carbs and fat cannot be negative.',
          ),
        ),
      );

      return;
    }

    String description = _descController.text.trim();

    // If user used ingredient calculator and didn't write description,
    // automatically create a useful description.
    if (description.isEmpty && _ingredients.isNotEmpty) {
      description = _ingredients
          .map(
            (item) =>
                '${item.food.name} ${item.grams.toStringAsFixed(item.grams % 1 == 0 ? 0 : 1)}g',
          )
          .join(', ');
    }

    await ref.read(dietNotifierProvider.notifier).addMeal(
          name: _nameController.text.trim(),
          description: description,
          calories: calories,
          type: _selectedType,
          protein: protein,
          carbs: carbs,
          fat: fat,
        );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add meal',
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
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32,
            ),
            children: [
              // ==================================================
              // BASIC MEAL INFO
              // ==================================================

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Meal type',
                  prefixIcon: Icon(
                    Icons.restaurant_menu_rounded,
                  ),
                ),
                dropdownColor: AppTheme.cardColorSoft,
                items: const [
                  'Breakfast',
                  'Lunch',
                  'Dinner',
                  'Snack',
                ]
                    .map(
                      (item) => DropdownMenuItem(
                        value: item,
                        child: Text(item),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _selectedType = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Meal name',
                  hintText: 'e.g. Chicken Rice',
                  prefixIcon: Icon(
                    Icons.fastfood_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional',
                  prefixIcon: Icon(
                    Icons.notes_rounded,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // NUTRITION CALCULATOR
              // ==================================================

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nutrition Calculator',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (_ingredients.isNotEmpty)
                    TextButton(
                      onPressed: _clearIngredients,
                      child: const Text(
                        'Clear',
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 4),

              const Text(
                'Select each ingredient and enter its weight. '
                'Calories and macros will be calculated automatically.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<NutritionFood>(
                value: _selectedFood,
                isExpanded: true,
                dropdownColor: AppTheme.cardColorSoft,
                decoration: const InputDecoration(
                  labelText: 'Ingredient / Food',
                  prefixIcon: Icon(
                    Icons.search_rounded,
                  ),
                ),
                items: commonNutritionFoods
                    .map(
                      (food) => DropdownMenuItem<NutritionFood>(
                        value: food,
                        child: Text(
                          food.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (food) {
                  if (food == null) {
                    return;
                  }

                  setState(() {
                    _selectedFood = food;
                  });
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gramsController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        suffixText: 'g',
                        prefixIcon: Icon(
                          Icons.scale_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 58,
                    child: FilledButton.icon(
                      onPressed: _addIngredient,
                      icon: const Icon(
                        Icons.add_rounded,
                      ),
                      label: const Text(
                        'Add',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (_ingredients.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.premiumCard(),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calculate_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Example: Add 150g cooked rice + '
                          '100g cooked chicken to calculate the meal.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(
                  _ingredients.length,
                  (index) => _ingredientCard(
                    index,
                    _ingredients[index],
                  ),
                ),

              const SizedBox(height: 28),

              // ==================================================
              // RESULT / MANUAL NUTRITION
              // ==================================================

              const Text(
                'Meal Nutrition',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              const Text(
                'You can also manually adjust these values using a '
                'food label or another verified nutrition source.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _calController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories',
                  suffixText: 'kcal',
                  prefixIcon: Icon(
                    Icons.local_fire_department_outlined,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _macroField(
                      controller: _proteinController,
                      label: 'Protein',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _macroField(
                      controller: _carbController,
                      label: 'Carbs',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _macroField(
                      controller: _fatController,
                      label: 'Fat',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(
                  Icons.check_circle_outline_rounded,
                ),
                label: const Text(
                  'Save meal',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _ingredientCard(
    int index,
    _MealIngredient ingredient,
  ) {
    final calories = ingredient.food.caloriesFor(
      ingredient.grams,
    );

    final protein = ingredient.food.proteinFor(
      ingredient.grams,
    );

    final carbs = ingredient.food.carbsFor(
      ingredient.grams,
    );

    final fat = ingredient.food.fatFor(
      ingredient.grams,
    );

    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(15),
      decoration: AppTheme.premiumCard(),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: AppTheme.accentColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.food.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${ingredient.grams.toStringAsFixed(ingredient.grams % 1 == 0 ? 0 : 1)}g'
                  '  •  ${calories.round()} kcal',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'P ${protein.toStringAsFixed(1)}g  •  '
                  'C ${carbs.toStringAsFixed(1)}g  •  '
                  'F ${fat.toStringAsFixed(1)}g',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              _removeIngredient(index);
            },
            icon: const Icon(
              Icons.close_rounded,
              color: AppTheme.dangerColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _macroField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'g',
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),
      ),
    );
  }
}

class _MealIngredient {
  final NutritionFood food;
  final double grams;

  const _MealIngredient({
    required this.food,
    required this.grams,
  });
}