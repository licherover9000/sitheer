class ChapterProgress {
  const ChapterProgress({
    this.accuracy = 0,
    this.completedResourceIds = const [],
    this.attemptedPyqs = 0,
  });

  final double accuracy;
  final List<String> completedResourceIds;
  final int attemptedPyqs;

  ChapterProgress copyWith({
    double? accuracy,
    List<String>? completedResourceIds,
    int? attemptedPyqs,
  }) {
    return ChapterProgress(
      accuracy: accuracy ?? this.accuracy,
      completedResourceIds: completedResourceIds ?? this.completedResourceIds,
      attemptedPyqs: attemptedPyqs ?? this.attemptedPyqs,
    );
  }

  Map<String, dynamic> toMap() => {
    'accuracy': accuracy,
    'completedResourceIds': completedResourceIds,
    'attemptedPyqs': attemptedPyqs,
  };

  factory ChapterProgress.fromMap(Map<String, dynamic> map) {
    return ChapterProgress(
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      completedResourceIds: List<String>.from(
        map['completedResourceIds'] as List? ?? [],
      ),
      attemptedPyqs: map['attemptedPyqs'] as int? ?? 0,
    );
  }
}

class MockAttemptRecord {
  const MockAttemptRecord({
    required this.paperId,
    required this.score,
    required this.accuracy,
    required this.completedAt,
  });

  final String paperId;
  final int score;
  final double accuracy;
  final DateTime completedAt;

  Map<String, dynamic> toMap() => {
    'paperId': paperId,
    'score': score,
    'accuracy': accuracy,
    'completedAt': completedAt.toIso8601String(),
  };

  factory MockAttemptRecord.fromMap(Map<String, dynamic> map) {
    return MockAttemptRecord(
      paperId: map['paperId'] as String,
      score: map['score'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}
