import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_providers.dart';
import '../../core/constants.dart';
import 'task_tile.dart';
import 'add_task_sheet.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const AddTaskSheet(),
    );
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
                style: TextStyle(color: Colors.deepPurple),
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
