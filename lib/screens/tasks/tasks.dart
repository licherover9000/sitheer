import 'package:cloud_firestore/cloud_firestore.dart';

enum Priority { high, medium, low }

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final Priority priority;
  final DateTime createAt;
  final String? tag; // study , personal

  const Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    this.priority = Priority.medium,
    required this.createAt,
    this.tag,
  });
  //convert task -> map(to save to firestore)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'isCompleted': isCompleted,
    'priority': priority.name,
    'createAt': Timestamp.fromDate(createAt),
    'tag': tag,
  };
  //map ko task mai change karna firestore se data read karne ke liye
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    isCompleted: map['isCompleted'] as bool,
    priority: Priority.values.byName(map['priority']),
    createAt: (map['createAt'] as Timestamp).toDate(),
    tag: map['tag'] as String?,
  );
  //modified copy of task
  Task copyWith({
    String? title,
    bool? isCompleted,
    Priority? priority,
    String? tag,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createAt: createAt,
      tag: tag ?? this.tag,
    );
  }
}
