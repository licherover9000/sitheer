import 'package:sitheer/model/prep_question.dart';

/// Per-question result captured during a mock or PYQ drill, plus the
/// [PracticeSession] container that groups a single attempt's questions.
///
/// Supports MCQ (single select), MSQ (multi-select), and NAT (numeric) answer
/// formats. Powers the wrong-answer review flow and the "flag a problem"
/// feature, and is persisted via [PrepProvider] (locally + Firebase sync).

class QuestionAttempt {
  const QuestionAttempt({
    required this.questionId,
    required this.chapterId,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.attemptedAt,
    this.type = QuestionType.mcq,
    this.correctIndexes = const [],
    this.numericAnswer,
    this.numericTolerance = 0,
    this.marks = 1,
    this.penalty = 0,
    this.selectedIndex,
    this.selectedIndexes = const [],
    this.numericResponse,
    this.explanation,
    this.markedForReview = false,
  });

  /// Builds an attempt snapshot from a [PrepQuestion] plus the user's response.
  factory QuestionAttempt.fromQuestion(
    PrepQuestion q, {
    required DateTime attemptedAt,
    int? selectedIndex,
    List<int> selectedIndexes = const [],
    double? numericResponse,
    bool markedForReview = false,
  }) => QuestionAttempt(
    questionId: q.id,
    chapterId: q.chapterId,
    prompt: q.prompt,
    options: q.options,
    correctIndex: q.correctIndex,
    correctIndexes: q.correctIndexes,
    numericAnswer: q.numericAnswer,
    numericTolerance: q.numericTolerance,
    type: q.type,
    marks: q.marks,
    penalty: q.penalty,
    explanation: q.explanation,
    attemptedAt: attemptedAt,
    selectedIndex: selectedIndex,
    selectedIndexes: selectedIndexes,
    numericResponse: numericResponse,
    markedForReview: markedForReview,
  );

  final String questionId;
  final String chapterId;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final List<int> correctIndexes;
  final double? numericAnswer;
  final double numericTolerance;
  final QuestionType type;
  final int marks;
  final double penalty;
  final DateTime attemptedAt;

  // Responses (only the one matching [type] is meaningful).
  final int? selectedIndex;
  final List<int> selectedIndexes;
  final double? numericResponse;

  final String? explanation;

  /// Whether the user flagged this question to revisit later.
  final bool markedForReview;

  bool get isSkipped {
    switch (type) {
      case QuestionType.mcq:
        return selectedIndex == null;
      case QuestionType.msq:
        return selectedIndexes.isEmpty;
      case QuestionType.nat:
        return numericResponse == null;
    }
  }

  bool get isCorrect {
    if (isSkipped) return false;
    switch (type) {
      case QuestionType.mcq:
        return selectedIndex == correctIndex;
      case QuestionType.msq:
        final a = selectedIndexes.toSet();
        final b = correctIndexes.toSet();
        return a.length == b.length && a.containsAll(b);
      case QuestionType.nat:
        return numericAnswer != null &&
            (numericResponse! - numericAnswer!).abs() <=
                numericTolerance + 1e-9;
    }
  }

  bool get isWrong => !isSkipped && !isCorrect;

  /// GATE marks earned: +marks if correct, −penalty if wrong, 0 if skipped.
  double get earnedMarks => isCorrect
      ? marks.toDouble()
      : isWrong
      ? -penalty
      : 0;

  /// The user's answer rendered for review UIs.
  String get responseText {
    if (isSkipped) return 'Skipped';
    switch (type) {
      case QuestionType.mcq:
        return _optionText(selectedIndex!);
      case QuestionType.msq:
        return selectedIndexes.map(_optionText).join(', ');
      case QuestionType.nat:
        return _fmt(numericResponse!);
    }
  }

  /// The correct answer rendered for review UIs.
  String get correctText {
    switch (type) {
      case QuestionType.mcq:
        return _optionText(correctIndex);
      case QuestionType.msq:
        return correctIndexes.map(_optionText).join(', ');
      case QuestionType.nat:
        return numericAnswer == null
            ? '-'
            : (numericTolerance > 0
                  ? '${_fmt(numericAnswer!)} (±${_fmt(numericTolerance)})'
                  : _fmt(numericAnswer!));
    }
  }

  String _optionText(int i) =>
      i >= 0 && i < options.length ? options[i] : 'option ${i + 1}';

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  QuestionAttempt copyWith({bool? markedForReview}) => QuestionAttempt(
    questionId: questionId,
    chapterId: chapterId,
    prompt: prompt,
    options: options,
    correctIndex: correctIndex,
    correctIndexes: correctIndexes,
    numericAnswer: numericAnswer,
    numericTolerance: numericTolerance,
    type: type,
    marks: marks,
    penalty: penalty,
    attemptedAt: attemptedAt,
    selectedIndex: selectedIndex,
    selectedIndexes: selectedIndexes,
    numericResponse: numericResponse,
    explanation: explanation,
    markedForReview: markedForReview ?? this.markedForReview,
  );

  Map<String, dynamic> toMap() => {
    'questionId': questionId,
    'chapterId': chapterId,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'correctIndexes': correctIndexes,
    'numericAnswer': numericAnswer,
    'numericTolerance': numericTolerance,
    'type': type.name,
    'marks': marks,
    'penalty': penalty,
    'selectedIndex': selectedIndex,
    'selectedIndexes': selectedIndexes,
    'numericResponse': numericResponse,
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
    correctIndexes: List<int>.from(map['correctIndexes'] as List? ?? const []),
    numericAnswer: (map['numericAnswer'] as num?)?.toDouble(),
    numericTolerance: (map['numericTolerance'] as num?)?.toDouble() ?? 0,
    type: questionTypeFromString(map['type'] as String?),
    marks: map['marks'] as int? ?? 1,
    penalty: (map['penalty'] as num?)?.toDouble() ?? 0,
    selectedIndex: map['selectedIndex'] as int?,
    selectedIndexes: List<int>.from(
      map['selectedIndexes'] as List? ?? const [],
    ),
    numericResponse: (map['numericResponse'] as num?)?.toDouble(),
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

  /// The mock paper id (for mocks) or chapter/year id (for PYQ drills).
  final String refId;
  final String title;
  final List<QuestionAttempt> attempts;
  final DateTime completedAt;

  int get total => attempts.length;
  int get correctCount => attempts.where((a) => a.isCorrect).length;
  int get incorrectCount => attempts.where((a) => a.isWrong).length;
  int get skippedCount => attempts.where((a) => a.isSkipped).length;
  double get accuracy => total == 0 ? 0 : correctCount / total;

  /// Total GATE marks earned across the session (per-question marks/penalty).
  double get marks => attempts.fold(0.0, (sum, a) => sum + a.earnedMarks);

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
