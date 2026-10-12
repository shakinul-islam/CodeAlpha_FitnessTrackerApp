import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/notification_service.dart';
import 'core/theme.dart';
import 'screens/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized();

  await NotificationService
      .instance
      .init();

  runApp(
    const ProviderScope(
      child:
          FitnessApp(),
    ),
  );
}

class FitnessApp
    extends StatelessWidget {
  const FitnessApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner:
          false,

      title:
          'Fitness Pro',

      theme:
          AppTheme.darkTheme,

      home:
          const MainNavigation(),
    );
  }
}