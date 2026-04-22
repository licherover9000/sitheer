import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sitheer/screens/tasks/tasks.dart';

class TaskProviders extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  //listen to firestore in realtie
  void startListening(String userId) {
    _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createAt', descending: true)
        .snapshots()
        .listen((snapshot) {
          _tasks = snapshot.docs
              .map((doc) => Task.fromMap(doc.data()))
              .toList();
          notifyListeners(); //rebuild any listening widgets
        });
  }

  //crud operations
  Future<void> addTask(Task task, String userId) async {
    await _db
        .collection('user')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<void> toggleTask(Task task, String userId) async {
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': updated.isCompleted});
  }

  Future<void> deleteTask(String userId, String taskId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }
}
