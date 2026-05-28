import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sitheer/model/task.dart';

class TaskProviders extends ChangeNotifier {
  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  List<Task> _tasks = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();

  /// Listen to Firestore for the signed-in user's task list.
  void startListening(String userId) {
    final db = _db;
    if (db == null) return;
    _subscription?.cancel();
    _subscription = db
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
    final db = _db;
    if (db == null) return;
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .set(task.toMap());
  }

  Future<void> toggleTask(Task task, String userId) async {
    final db = _db;
    if (db == null) return;
    final updated = task.copyWith(isCompleted: !task.isCompleted);
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(task.id)
        .update({'isCompleted': updated.isCompleted});
  }

  Future<void> deleteTask(String userId, String taskId) async {
    final db = _db;
    if (db == null) return;
    await db
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
