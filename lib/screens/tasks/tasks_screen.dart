import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_providers.dart';
import '../../core/constants.dart';
import 'task_tile.dart';
import 'add_task_sheet.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskSheet(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      if (!mounted) return;
      context.read<TaskProviders>().startListening(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProviders>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      body: provider.tasks.isEmpty
          ? const Center(
              child: Text(
                "No tasks yet! Time to focus.",
                style: TextStyle(color: Color.fromARGB(255, 93, 0, 255)),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: provider.tasks.length,
              itemBuilder: (ctx, i) => TaskTile(task: provider.tasks[i]),
            ),
    );
  }
}
