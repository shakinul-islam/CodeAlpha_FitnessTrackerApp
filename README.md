# Fitness Pro

Fitness Pro is a modern Flutter-based fitness tracking application that helps users monitor workouts, steps, hydration, sleep, nutrition, weight, and daily fitness goals from one place.

## Features

- Daily fitness dashboard
- Custom daily goals
- Step tracking with device pedometer
- Water intake tracking in ml
- Sleep tracking with sleep/wake time
- Workout logging and history
- Edit and delete workouts
- Meal and nutrition tracking
- Calories, protein, carbs, and fat tracking
- BMI calculation
- Meter or Feet/Inch height input
- Weight history and progress chart
- Daily goal progress
- 7-day and 30-day progress analytics
- Local hydration reminder notifications
- Offline local storage with SQLite

## Progress Analytics

Users can review progress for:

- 7 Days
- 30 Days

Analytics include:

- Average steps
- Average water intake
- Average sleep duration
- Workout minutes
- Calories consumed
- Calories burned
- Goal consistency
- Weight trend

## Tech Stack

- Flutter
- Dart
- Riverpod
- SQLite / Sqflite
- Shared Preferences
- FL Chart
- Pedometer
- Permission Handler
- Flutter Local Notifications
- Intl
- Google Fonts

## Project Structure

```text
fitness_tracker/
│
├── android/
├── assets/
├── ios/
├── lib/
│   │
│   ├── core/
│   │   ├── database_helper.dart
│   │   ├── notification_service.dart
│   │   ├── nutrition_data.dart
│   │   └── theme.dart
│   │
│   ├── models/
│   │   ├── food_item.dart
│   │   └── workout_model.dart
│   │
│   ├── providers/
│   │   ├── analytics_provider.dart
│   │   ├── app_providers.dart
│   │   ├── user_provider.dart
│   │   └── workout_provider.dart
│   │
│   ├── screens/
│   │   ├── add_meal_screen.dart
│   │   ├── add_workout_screen.dart
│   │   ├── daily_goals_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── diet_screen.dart
│   │   ├── edit_profile_screen.dart
│   │   ├── edit_workout_screen.dart
│   │   ├── habits_screen.dart
│   │   ├── main_navigation.dart
│   │   ├── notification_settings_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── progress_analytics_screen.dart
│   │   └── workout_history_screen.dart
│   │
│   └── main.dart
│
├── linux/
├── macos/
├── test/
├── web/
├── windows/
├── analysis_options.yaml
├── pubspec.yaml
└── README.md
