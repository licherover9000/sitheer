import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/providers/task_providers.dart';
import 'package:sitheer/core/constants.dart';
import 'package:sitheer/model/task.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});
  Color _getPriorityColor() {
    switch (task.priority) {
      case Priority.high:
        return AppColors.high;
      case Priority.medium:
        return AppColors.medium;
      case Priority.low:
        return AppColors.low;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(task.id),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              context.read<TaskProviders>().deleteTask(uid, task.id);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.paddingS),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: _getPriorityColor(), width: 4),
            ),
          ),
          child: CheckboxListTile(
            value: task.isCompleted,
            onChanged: (_) {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              context.read<TaskProviders>().toggleTask(task, uid);
            },
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted
                    ? TextDecoration.lineThrough
                    : null,
                color: task.isCompleted ? Colors.grey : AppColors.bgDark,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
