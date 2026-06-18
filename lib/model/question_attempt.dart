/// Per-question result captured during a mock or PYQ drill, plus the
/// [PracticeSession] container that groups a single attempt's questions.
///
/// These power the wrong-answer review flow and the "flag a problem" feature,
/// and are persisted via [PrepProvider] (locally + Firebase sync).
library;

class QuestionAttempt {
  const QuestionAttempt({
    required this.questionId,
    required this.chapterId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.attemptedAt,
    this.selectedIndex,
    this.explanation,
    this.markedForReview = false,
  });

  final String questionId;
  final String chapterId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final DateTime attemptedAt;

  /// The option the user picked. `null` means the question was skipped.
  final int? selectedIndex;
  final String? explanation;

  /// Whether the user flagged this question to revisit later.
  final bool markedForReview;

  bool get isSkipped => selectedIndex == null;
  bool get isCorrect => !isSkipped && selectedIndex == correctIndex;
  bool get isWrong => !isSkipped && selectedIndex != correctIndex;

  QuestionAttempt copyWith({bool? markedForReview}) => QuestionAttempt(
    questionId: questionId,
    chapterId: chapterId,
    prompt: prompt,
    options: options,
    correctIndex: correctIndex,
    attemptedAt: attemptedAt,
    selectedIndex: selectedIndex,
    explanation: explanation,
    markedForReview: markedForReview ?? this.markedForReview,
  );

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'chapterId': chapterId,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'selectedIndex': selectedIndex,
    'explanation': explanation,
    'markedForReview': markedForReview,
    'attemptedAt': attemptedAt.toIso8601String(),
  };

  factory QuestionAttempt.fromMap(Map<String, dynamic> map) => QuestionAttempt(
    questionId: map['questionId'] as String? ?? '',
    chapterId: map['chapterId'] as String? ?? '',
    prompt: map['prompt'] as String? ?? '',
    options: List<String>.from(map['options'] as List? ?? const []),
    correctIndex: map['correctIndex'] as int? ?? 0,
    selectedIndex: map['selectedIndex'] as int?,
    explanation: map['explanation'] as String?,
    markedForReview: map['markedForReview'] as bool? ?? false,
    attemptedAt:
        DateTime.tryParse(map['attemptedAt'] as String? ?? '') ??
        DateTime.now(),
  );
}

class PracticeSession {
  const PracticeSession({
    required this.id,
    required this.source,
    required this.refId,
    required this.title,
    required this.attempts,
    required this.completedAt,
  });

  final String id;

  /// `'mock'` or `'pyq'`.
  final String source;

  /// The mock paper id (for mocks) or chapter id (for PYQ drills).
  final String refId;
  final String title;
  final List<QuestionAttempt> attempts;
  final DateTime completedAt;

  int get total => attempts.length;
  int get correctCount => attempts.where((a) => a.isCorrect).length;
  int get incorrectCount => attempts.where((a) => a.isWrong).length;
  int get skippedCount => attempts.where((a) => a.isSkipped).length;
  double get accuracy => total == 0 ? 0 : correctCount / total;

  /// GATE-style marks: +1 correct, -1/3 wrong, 0 skipped.
  double get marks => correctCount - (incorrectCount / 3);

  List<QuestionAttempt> get wrongAttempts =>
      attempts.where((a) => a.isWrong).toList();

  Map<String, dynamic> toMap() => {
    'id': id,
    'source': source,
    'refId': refId,
    'title': title,
    'attempts': attempts.map((a) => a.toMap()).toList(),
    'completedAt': completedAt.toIso8601String(),
  };

  factory PracticeSession.fromMap(Map<String, dynamic> map) => PracticeSession(
    id: map['id'] as String? ?? '',
    source: map['source'] as String? ?? 'pyq',
    refId: map['refId'] as String? ?? '',
    title: map['title'] as String? ?? '',
    attempts: (map['attempts'] as List? ?? const [])
        .map(
          (e) => QuestionAttempt.fromMap(Map<String, dynamic>.from(e as Map)),
        )
        .toList(),
    completedAt:
        DateTime.tryParse(map['completedAt'] as String? ?? '') ??
        DateTime.now(),
  );
}
