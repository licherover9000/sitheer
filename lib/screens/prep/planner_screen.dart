import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/schedule_providers.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/screens/home/home_screen.dart';
import 'package:sitheer/screens/schedule/schedule_screen.dart';
import 'package:sitheer/screens/tasks/tasks_screen.dart';
import 'package:sitheer/screens/timer/timer_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startListeners());
  }

  void _startListeners() {
    if (Firebase.apps.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !mounted) return;
    context.read<TaskProviders>().startListening(uid);
    context.read<ScheduleProviders>().startListening(uid);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Planner'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Tasks'),
              Tab(text: 'Focus'),
              Tab(text: 'Schedule'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _PlannerOverview(),
            TasksScreen(),
            TimerScreen(),
            ScheduleScreen(),
          ],
        ),
      ),
    );
  }
}

class _PlannerOverview extends StatelessWidget {
  const _PlannerOverview();

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}
