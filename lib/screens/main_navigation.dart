import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'dashboard_screen.dart';
import 'diet_screen.dart';
import 'habits_screen.dart';
import 'profile_screen.dart';
import 'workout_history_screen.dart';

class MainNavigation
    extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation>
      createState() =>
          _MainNavigationState();
}

class _MainNavigationState
    extends State<
        MainNavigation> {
  int _currentIndex =
      0;

  static const List<Widget>
      _screens = [
    DashboardScreen(),
    WorkoutHistoryScreen(),
    HabitsScreen(),
    DietScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: IndexedStack(
        index:
            _currentIndex,
        children:
            _screens,
      ),
      bottomNavigationBar:
          Container(
        decoration:
            BoxDecoration(
          border:
              Border(
            top:
                BorderSide(
              color:
                  Colors.white
                      .withOpacity(
                .05,
              ),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color:
                  Colors.black
                      .withOpacity(
                .28,
              ),
              blurRadius:
                  24,
              offset:
                  const Offset(
                0,
                -8,
              ),
            ),
          ],
        ),
        child:
            NavigationBar(
          selectedIndex:
              _currentIndex,
          onDestinationSelected:
              (index) {
            setState(
              () {
                _currentIndex =
                    index;
              },
            );
          },
          destinations:
              const [
            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .home_outlined,
              ),
              selectedIcon:
                  Icon(
                Icons
                    .home_rounded,
              ),
              label:
                  'Home',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .fitness_center_outlined,
              ),
              selectedIcon:
                  Icon(
                Icons
                    .fitness_center_rounded,
              ),
              label:
                  'Workout',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .favorite_border_rounded,
              ),
              selectedIcon:
                  Icon(
                Icons
                    .favorite_rounded,
              ),
              label:
                  'Habits',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .restaurant_outlined,
              ),
              selectedIcon:
                  Icon(
                Icons
                    .restaurant_rounded,
              ),
              label:
                  'Diet',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .person_outline_rounded,
              ),
              selectedIcon:
                  Icon(
                Icons
                    .person_rounded,
              ),
              label:
                  'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
/*
import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'dashboard_screen.dart';
import 'diet_screen.dart';
import 'habits_screen.dart';
import 'profile_screen.dart';

class MainNavigation
    extends StatefulWidget {
  const MainNavigation({
    super.key,
  });

  @override
  State<MainNavigation>
      createState() =>
          _MainNavigationState();
}

class _MainNavigationState
    extends State<
        MainNavigation> {
  int _currentIndex = 0;

  static const List<Widget>
      _screens = [
    DashboardScreen(),
    HabitsScreen(),
    DietScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: IndexedStack(
        index:
            _currentIndex,

        children:
            _screens,
      ),

      bottomNavigationBar:
          Container(
        decoration:
            BoxDecoration(
          border:
              Border(
            top:
                BorderSide(
              color: Colors.white
                  .withOpacity(
                .05,
              ),
            ),
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withOpacity(
                .28,
              ),

              blurRadius:
                  24,

              offset:
                  const Offset(
                0,
                -8,
              ),
            ),
          ],
        ),

        child:
            NavigationBar(
          selectedIndex:
              _currentIndex,

          onDestinationSelected:
              (index) {
            setState(
              () {
                _currentIndex =
                    index;
              },
            );
          },

          destinations:
              const [
            NavigationDestination(
              icon:
                  Icon(
                Icons.home_outlined,
              ),

              selectedIcon:
                  Icon(
                Icons.home_rounded,
              ),

              label:
                  'Home',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .favorite_border_rounded,
              ),

              selectedIcon:
                  Icon(
                Icons
                    .favorite_rounded,
              ),

              label:
                  'Habits',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .restaurant_outlined,
              ),

              selectedIcon:
                  Icon(
                Icons
                    .restaurant_rounded,
              ),

              label:
                  'Diet',
            ),

            NavigationDestination(
              icon:
                  Icon(
                Icons
                    .person_outline_rounded,
              ),

              selectedIcon:
                  Icon(
                Icons
                    .person_rounded,
              ),

              label:
                  'Profile',
            ),
          ],
        ),
      ),
    );
  }
}*/