import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/model/task.dart';
import '../../providers/task_providers.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  Priority _selectedPriority = Priority.medium;

  void _submit() {
    if (_titleController.text.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Create the new task object
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      priority: _selectedPriority,
      createAt: DateTime.now(),
    );

    // Send it to the provider
    context.read<TaskProviders>().addTask(newTask, uid);

    // Close the bottom sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'What needs to be done?',
            ),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          DropdownButton<Priority>(
            value: _selectedPriority,
            isExpanded: true,
            items: Priority.values.map((p) {
              return DropdownMenuItem(
                value: p,
                child: Text(p.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (val) => setState(() => _selectedPriority = val!),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Add Task'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
