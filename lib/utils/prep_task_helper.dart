import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sitheer/model/task.dart';
import 'package:sitheer/providers/task_providers.dart';

Future<void> addRoadmapTask(BuildContext context, String title) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in required to save tasks')),
      );
    }
    return;
  }
  final task = Task(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    title: title,
    createAt: DateTime.now(),
    tag: 'roadmap',
  );
  await context.read<TaskProviders>().addTask(task, uid);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added to planner: $title')));
  }
}
