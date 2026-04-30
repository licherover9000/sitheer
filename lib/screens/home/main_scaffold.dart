import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/main_nav_provider.dart';
import 'package:sitheer/screens/home/home_screen.dart';
import 'package:sitheer/screens/schedule/schedule_screen.dart';
import 'package:sitheer/screens/settings/settings_screen.dart';
import 'package:sitheer/screens/tasks/tasks_screen.dart';
import 'package:sitheer/screens/timer/timer_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  static const List<Widget> _screens = [
    HomeScreen(),
    TasksScreen(),
    TimerScreen(),
    ScheduleScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<MainNavProvider>();

    return Scaffold(
      body: IndexedStack(index: nav.currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.currentIndex,
        onDestinationSelected: (i) =>
            context.read<MainNavProvider>().setIndex(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Timer',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Schedule',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
