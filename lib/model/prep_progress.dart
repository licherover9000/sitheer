class ChapterProgress {
  const ChapterProgress({
    this.accuracy = 0,
    this.completedResourceIds = const [],
    this.attemptedPyqs = 0,
    this.incorrectCount = 0,
  });

  final double accuracy;
  final List<String> completedResourceIds;
  final int attemptedPyqs;
  final int incorrectCount;

  ChapterProgress copyWith({
    double? accuracy,
    List<String>? completedResourceIds,
    int? attemptedPyqs,
    int? incorrectCount,
  }) {
    return ChapterProgress(
      accuracy: accuracy ?? this.accuracy,
      completedResourceIds: completedResourceIds ?? this.completedResourceIds,
      attemptedPyqs: attemptedPyqs ?? this.attemptedPyqs,
      incorrectCount: incorrectCount ?? this.incorrectCount,
    );
  }

  Map<String, dynamic> toMap() => {
    'accuracy': accuracy,
    'completedResourceIds': completedResourceIds,
    'attemptedPyqs': attemptedPyqs,
    'incorrectCount': incorrectCount,
  };

  factory ChapterProgress.fromMap(Map<String, dynamic> map) {
    return ChapterProgress(
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      completedResourceIds: List<String>.from(
        map['completedResourceIds'] as List? ?? [],
      ),
      attemptedPyqs: map['attemptedPyqs'] as int? ?? 0,
      incorrectCount: map['incorrectCount'] as int? ?? 0,
    );
  }
}

class MockAttemptRecord {
  const MockAttemptRecord({
    required this.paperId,
    required this.score,
    required this.accuracy,
    required this.completedAt,
    this.correctCount = 0,
    this.incorrectCount = 0,
    this.skippedCount = 0,
    this.marksObtained = 0.0,
  });

  final String paperId;
  final int score;
  final double accuracy;
  final DateTime completedAt;
  final int correctCount;
  final int incorrectCount;
  final int skippedCount;
  final double marksObtained;

  Map<String, dynamic> toMap() => {
    'paperId': paperId,
    'score': score,
    'accuracy': accuracy,
    'completedAt': completedAt.toIso8601String(),
    'correctCount': correctCount,
    'incorrectCount': incorrectCount,
    'skippedCount': skippedCount,
    'marksObtained': marksObtained,
  };

  factory MockAttemptRecord.fromMap(Map<String, dynamic> map) {
    return MockAttemptRecord(
      paperId: map['paperId'] as String,
      score: map['score'] as int? ?? 0,
      accuracy: (map['accuracy'] as num?)?.toDouble() ?? 0,
      completedAt:
          DateTime.tryParse(map['completedAt'] as String? ?? '') ??
          DateTime.now(),
      correctCount: map['correctCount'] as int? ?? 0,
      incorrectCount: map['incorrectCount'] as int? ?? 0,
      skippedCount: map['skippedCount'] as int? ?? 0,
      marksObtained: (map['marksObtained'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
