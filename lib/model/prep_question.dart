/// A single practice/PYQ question. Supports three GATE answer formats:
/// single-correct MCQ, multiple-select MSQ, and numerical-answer NAT.
library;

enum QuestionType { mcq, msq, nat }

QuestionType questionTypeFromString(String? value) => switch (value) {
  'msq' => QuestionType.msq,
  'nat' => QuestionType.nat,
  _ => QuestionType.mcq,
};

class PrepQuestion {
  const PrepQuestion({
    required this.id,
    required this.chapterId,
    required this.prompt,
    this.options = const [],
    this.correctIndex = 0,
    this.correctIndexes = const [],
    this.numericAnswer,
    this.numericTolerance = 0,
    this.type = QuestionType.mcq,
    this.explanation,
    this.year,
    this.session,
    this.marks = 1,
    this.negativeMarks = 0,
    this.tags = const [],
    this.source,
  });

  final String id;
  final String chapterId;
  final String prompt;

  /// Options for MCQ/MSQ. Empty for NAT.
  final List<String> options;

  /// Correct option for [QuestionType.mcq].
  final int correctIndex;

  /// Correct options for [QuestionType.msq].
  final List<int> correctIndexes;

  /// Correct value for [QuestionType.nat].
  final double? numericAnswer;

  /// Allowed +/- tolerance for NAT answers (e.g. 0.01, or a range half-width).
  final double numericTolerance;

  final QuestionType type;
  final String? explanation;
  final int? year;
  final String? session;
  final int marks;

  /// Negative marks as a positive magnitude (e.g. 0.33). When 0, the GATE
  /// default applies (see [penalty]).
  final double negativeMarks;
  final List<String> tags;
  final String? source;

  /// Negative-mark penalty actually applied for a wrong answer. Uses the GATE
  /// default when [negativeMarks] is unset: −1/3 for 1-mark MCQ, −2/3 for
  /// 2-mark MCQ, and 0 for NAT/MSQ (no negative marking in GATE).
  double get penalty {
    if (negativeMarks != 0) return negativeMarks;
    if (type != QuestionType.mcq) return 0;
    return marks >= 2 ? 2 / 3 : 1 / 3;
  }

  bool isIndexCorrect(int? index) =>
      type == QuestionType.mcq && index != null && index == correctIndex;

  bool areIndexesCorrect(List<int> selected) {
    if (type != QuestionType.msq) return false;
    final a = selected.toSet();
    final b = correctIndexes.toSet();
    return a.length == b.length && a.containsAll(b);
  }

  bool isNumericCorrect(double? value) {
    if (type != QuestionType.nat || value == null || numericAnswer == null) {
      return false;
    }
    return (value - numericAnswer!).abs() <= numericTolerance + 1e-9;
  }

  /// Human-readable correct answer, for review/explanation UIs.
  String get correctAnswerText {
    switch (type) {
      case QuestionType.mcq:
        return correctIndex >= 0 && correctIndex < options.length
            ? options[correctIndex]
            : '-';
      case QuestionType.msq:
        return correctIndexes
            .where((i) => i >= 0 && i < options.length)
            .map((i) => options[i])
            .join(', ');
      case QuestionType.nat:
        return numericAnswer == null
            ? '-'
            : (numericTolerance > 0
                  ? '${_fmt(numericAnswer!)} (±${_fmt(numericTolerance)})'
                  : _fmt(numericAnswer!));
    }
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  factory PrepQuestion.fromJson(Map<String, dynamic> json) => PrepQuestion(
    id: json['id'] as String,
    chapterId: json['chapterId'] as String,
    prompt: json['prompt'] as String,
    options: ((json['options'] as List?) ?? const [])
        .map((e) => e as String)
        .toList(),
    correctIndex: json['correctIndex'] as int? ?? 0,
    correctIndexes: ((json['correctIndexes'] as List?) ?? const [])
        .map((e) => e as int)
        .toList(),
    numericAnswer: (json['numericAnswer'] as num?)?.toDouble(),
    numericTolerance: (json['numericTolerance'] as num?)?.toDouble() ?? 0,
    type: questionTypeFromString(json['type'] as String?),
    explanation: json['explanation'] as String?,
    year: json['year'] as int?,
    session: json['session'] as String?,
    marks: json['marks'] as int? ?? 1,
    negativeMarks: (json['negativeMarks'] as num?)?.toDouble() ?? 0,
    tags: ((json['tags'] as List?) ?? const [])
        .map((e) => e as String)
        .toList(),
    source: json['source'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'chapterId': chapterId,
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'correctIndexes': correctIndexes,
    'numericAnswer': numericAnswer,
    'numericTolerance': numericTolerance,
    'type': type.name,
    'explanation': explanation,
    'year': year,
    'session': session,
    'marks': marks,
    'negativeMarks': negativeMarks,
    'tags': tags,
    'source': source,
  };
}
