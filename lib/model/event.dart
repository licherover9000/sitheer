import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppEvent {
  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String? note;
  final Color color;

  const AppEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.note,
    required this.color,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'date': Timestamp.fromDate(date),
    'startHour': startTime.hour,
    'startMinute': startTime.minute,
    'endHour': endTime.hour,
    'endMinute': endTime.minute,
    'note': note,
    'colorValue': color.toARGB32(),
  };

  factory AppEvent.fromMap(Map<String, dynamic> map) {
    final colorRaw = map['colorValue'];
    final colorValue = colorRaw is int
        ? colorRaw
        : (colorRaw as num).toInt();
    int asInt(Object? v) => v is int ? v : (v as num).toInt();

    return AppEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      date: (map['date'] as Timestamp).toDate(),
      startTime: TimeOfDay(
        hour: asInt(map['startHour']),
        minute: asInt(map['startMinute']),
      ),
      endTime: TimeOfDay(
        hour: asInt(map['endHour']),
        minute: asInt(map['endMinute']),
      ),
      note: map['note'] as String?,
      color: Color(colorValue),
    );
  }
}
