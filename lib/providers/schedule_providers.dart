import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sitheer/model/event.dart';
import 'package:sitheer/services/notification_service.dart';

class ScheduleProviders extends ChangeNotifier {
  FirebaseFirestore? get _db {
    if (Firebase.apps.isEmpty) return null;
    return FirebaseFirestore.instance;
  }

  List<AppEvent> _events = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;

  List<AppEvent> get events => _events;

  List<AppEvent> eventsForDay(DateTime day) {
    return _events
        .where(
          (e) =>
              e.date.year == day.year &&
              e.date.month == day.month &&
              e.date.day == day.day,
        )
        .toList();
  }

  DateTime _startDateTime(AppEvent e) {
    final d = e.date;
    return DateTime(
      d.year,
      d.month,
      d.day,
      e.startTime.hour,
      e.startTime.minute,
    );
  }

  /// Nearest event whose start time is not before [DateTime.now()].
  AppEvent? get nextUpcomingEvent {
    final now = DateTime.now();
    AppEvent? best;
    DateTime? bestStart;
    for (final e in _events) {
      final start = _startDateTime(e);
      if (start.isBefore(now)) continue;
      if (bestStart == null || start.isBefore(bestStart)) {
        best = e;
        bestStart = start;
      }
    }
    return best;
  }

  void startListening(String userId) {
    final db = _db;
    if (db == null) return;
    _subscription?.cancel();
    _subscription = db
        .collection('users')
        .doc(userId)
        .collection('events')
        .orderBy('date')
        .snapshots()
        .listen((snapshot) {
          _events = snapshot.docs
              .map((doc) => AppEvent.fromMap(doc.data()))
              .toList();
          notifyListeners();
        });
  }

  Future<void> addEvent(AppEvent event, String userId) async {
    final db = _db;
    if (db == null) return;
    await db
        .collection('users')
        .doc(userId)
        .collection('events')
        .doc(event.id)
        .set(event.toMap());

    unawaited(
      NotificationService.scheduleEventReminder(
        eventId: event.id,
        title: event.title,
        startLocal: _startDateTime(event),
      ),
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
