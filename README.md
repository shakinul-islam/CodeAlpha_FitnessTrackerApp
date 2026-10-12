# Fitness Pro

Fitness Pro is a modern Flutter fitness tracking app for monitoring workouts, steps, water intake, sleep, nutrition, weight, and daily fitness goals.

## Features

- Daily dashboard with goal progress
- Custom goals for steps, water, calories, and sleep
- Workout tracking with edit/delete/history
- Step tracking using device pedometer
- Water tracking in ml
- Sleep start/end time tracking
- Meal and nutrition tracking
- Calories, protein, carbs, and fat tracking
- BMI calculation
- Meter or Feet/Inch height input
- Weight history and progress graph
- 7-day and 30-day progress analytics
- Local hydration reminders
- Offline local storage with SQLite

## Progress Analytics

Users can review:

- Average steps
- Average water intake
- Average sleep
- Workout minutes
- Calories consumed
- Calories burned
- Goal consistency
- Weight trend

Available periods:

```text
7 Days
30 Days
```

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
lib/
├── core/
│   ├── database_helper.dart
│   ├── notification_service.dart
│   ├── nutrition_data.dart
│   └── theme.dart
├── models/
├── providers/
│   ├── analytics_provider.dart
│   ├── app_providers.dart
│   ├── user_provider.dart
│   └── workout_provider.dart
├── screens/
│   ├── dashboard_screen.dart
│   ├── workout_history_screen.dart
│   ├── habits_screen.dart
│   ├── diet_screen.dart
│   ├── profile_screen.dart
│   ├── progress_analytics_screen.dart
│   └── ...
└── main.dart
```

## Getting Started

Clone the repository:

```bash
git clone YOUR_REPOSITORY_URL
cd YOUR_PROJECT_FOLDER
```

Install dependencies:

```bash
flutter pub get
```

Run the app:

```bash
flutter run
```

For a clean rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

## Android Permissions

The app may use:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

## Local Storage

Fitness Pro currently stores fitness data locally using SQLite and Shared Preferences, allowing the app to work offline.

## Planned Features

- AI food and nutrition analysis
- AI meal auto-fill
- Fiber tracking
- AI fitness coach
- Smart notifications
- Streaks and achievements
- Health Connect integration
- Cloud backup

## Disclaimer

Fitness and nutrition calculations shown in the app are estimates and are intended for general tracking purposes only.

## Author

Built with Flutter as a modern personal fitness tracking application.
